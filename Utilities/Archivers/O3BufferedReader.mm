/**
 *  @file O3BufferedReader.mm
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#include "O3BufferedReader.h"
#import "NSData+zlib.h"
#include <string>

/************************************/ #pragma mark Init and Destruction /************************************/
O3BufferedReader::O3BufferedReader(NSData* data) {
	Init();
	O3Assign(data, mBlockData);
	mBlockBytes = (UInt8*)[mBlockData bytes];
	mBlockBytesRemaining = [mBlockData length];
	mOffset	= 0;
}

O3BufferedReader::O3BufferedReader(NSFileHandle* handle) {
	Init();
	int fd = [handle fileDescriptor];
	flock(fd, LOCK_SH);
	O3Assign(handle, mHandle);
	mHandle_readDataOfLength_ = (mHandle_readDataOfLength_t)[handle methodForSelector:@selector(readDataOfLength:)];
	mOffset	= 0;
}

O3BufferedReader::~O3BufferedReader() {
	if (mHandle||mBlockData) Close();
}

/************************************/ #pragma mark Private Stuff /************************************/
inline void O3BufferedReader::AssureBytesLeft(UIntP bl) {
	Int64 remaining = (Int64)mBlockBytesRemaining - (Int64)bl;
	if (remaining>=0) return;
	FetchNextBlockOrThrow(-remaining); //If a negative number remain, try to fetch them
}

void O3BufferedReader::FetchNextBlockOrThrow(UIntP min_size) {
	AssertOpen();
	UIntP try_size = O3Max(min_size, mBlockSize);
	if (!mHandle) [NSException raise:NSRangeException format:@"!NSData (%@) based O3BufferedReader tried to read past end", mBlockData];
	//O3Destroy(mBlockData);
	NSData* new_data = mHandle_readDataOfLength_(mHandle, @selector(readDataOfLength:), try_size);
	if (!new_data) [NSException raise:NSRangeException format:@"O3BufferedReader %p tried to read past end of file", this];
	FillFetchIMPCache(new_data);
	UIntP fetched_len = mBlockData_length(new_data, @selector(length));
	UInt8* fetched_bytes = (UInt8*)mBlockData_bytes(new_data, @selector(bytes));
	if (mBlockBytesRemaining) {
		UIntP newBufLen = fetched_len+mBlockBytesRemaining;
		UInt8* newBuf = (UInt8*)malloc(newBufLen);
		memcpy(newBuf, mBlockBytes, mBlockBytesRemaining);
		memcpy(newBuf+mBlockBytesRemaining, fetched_bytes, fetched_len);
		NSData* d = [[NSData alloc] initWithBytesNoCopy:newBuf length:newBufLen freeWhenDone:YES];
		O3Assign(d, mBlockData);
		[d release];
		mBlockBytes = newBuf;
		mBlockBytesRemaining = newBufLen;
	} else {
		O3Assign(new_data, mBlockData);
		mBlockBytes = fetched_bytes;
		mBlockBytesRemaining = fetched_len;
	}
	if (mBlockBytesRemaining<min_size) [NSException raise:NSRangeException format:@"O3BufferedReader %p tried to read past end of file", this];
	O3Assert(mBlockBytes, @"Cannot get data from NSData %@ returned by %@", mBlockData, mHandle);
}

inline BOOL O3BufferedReader::BytesLeft(UInt64 bytes) {
	AssertOpen();
	return mBlockBytesRemaining>=bytes;
}

inline void O3BufferedReader::Advance(UInt64 bytes) {
	AssertOpen();
	O3Assert(mBlockBytesRemaining>=bytes, @"Somehow an attempt to read past the end of the current block wasn't caught and the cache wasn't flushed");
	mOffset+=bytes;
	mBlockBytesRemaining-=bytes;
	mBlockBytes+=bytes;
}

/************************************/ #pragma mark Public Reader Methods /************************************/
std::vector<O3ChildEnt> O3BufferedReader::ReadChildEntsOfTotalLength(UIntP len, BOOL have_keys) {
	std::vector<O3ChildEnt> ret;
	UInt64 accum_len=0; //The ammount of accumulated object data (not header data)
	UInt64 old_offset=Offset(); //Used to calculate accumulated header data
	UInt64 pos=0;
	while (pos<len) {
		NSString* k = nil;
		if (have_keys) k = [ReadCCString(O3CCSKeyTable) retain];
		O3ChildEnt e(ReadChildEnt());
		e.key = k;
		e.offset=accum_len; //This is the offset past the ents list
		ret.push_back(e);
		accum_len+=e.len;
		pos = accum_len+(Offset()-old_offset);
	}
	UInt64 post_ents_offset=Offset();
	std::vector<O3ChildEnt>::iterator it=ret.begin(), e=ret.end();
	for (; it!=e; it++)
		(*it).offset += post_ents_offset;
	return ret;
}

O3ChildEnt O3BufferedReader::ReadChildEnt() {
	O3ChildEnt ret;
	UInt8 infobyte = ReadByte();
	ret.type = (enum O3PkgType)((infobyte&0xF0)>>4);
	if (ret.type==O3PkgTypeObject) ret.className = [ReadCCString(O3CCSClassTable) retain];
	UIntP size = infobyte&0xF;
	if (size==0xF) size = ReadUCIntAsUInt64();
	else if (size==0xE) size = 64;
	else if (size==0xD) size = 32;
	else if (size==0xC) size = 16;
	else if (size==0xB) size = 12;
	ret.len = size;
	return ret;
}


///@warning This will fail to read archived objects (if coder is nil, because of the callback). Use O3KeyedUnarchiver.
///@return an autoreleased object
///@param coder The NSCoder handling the deserialization (for callback purposes, namely readO3ADictionary:) or nil. If [coder readO3ADictionary:] returns YES the buffered reader will continue deserializing under the assumption that deserialazation of the dictionary is complete and it has been seeked past. Otherwise it will simply make a NSDictionary and populate it.
///@param z The zone objects will be allocated in (%coder must be aware of this zone as well, or callback objects will be allocated by the coder)
id O3BufferedReader::ReadObject(NSCoder<O3UnarchiverCallbackable>* coder, NSZone* z, O3ChildEnt& ent) {
	switch (ent.type) {
		case O3PkgTypeFalse:		return [[[NSNumber allocWithZone:z] initWithBool:NO] autorelease];
		case O3PkgTypeTrue:			return [[[NSNumber allocWithZone:z] initWithBool:YES] autorelease];
	}
	SeekToOffset(ent.offset);
	id to_return = nil;
	UInt64 size = ent.len;
	switch (ent.type) {
		case O3PkgTypePositiveInt:	to_return = [[[NSNumber allocWithZone:z] initWithUnsignedLongLong:ReadBytesAsUInt64(size)] autorelease];               break;
		case O3PkgTypeNegativeInt:	to_return = [[[NSNumber allocWithZone:z] initWithLongLong:-(Int64)ReadBytesAsUInt64(size)] autorelease];               break;
		case O3PkgTypeFloat:{
			if (size==sizeof(float))  {to_return = [[[NSNumber allocWithZone:z] initWithFloat:ReadFloat()] autorelease];   break;}
			if (size==sizeof(double)) {to_return = [[[NSNumber allocWithZone:z] initWithDouble:ReadDouble()] autorelease]; break;}
			O3Assert(NO, @"Cannot read a %l byte float!", (long)size);
			to_return = nil; break;
		}
		case O3PkgTypeIndexedString: {
			UIntP idx = ReadBytesAsUInt64(size);
			to_return = [mST objectAtIndex:idx]; break;
		}
		case O3PkgTypeString: {
			if (!size) {to_return = @""; break;}
			void* b = ReadBytes(size);
			NSString* s = [[NSString allocWithZone:z] initWithBytesNoCopy:b length:size encoding:NSUTF8StringEncoding freeWhenDone:YES];
			to_return = [s autorelease];
			break;
		}
		case O3PkgTypeDictionary: {
			id cdict = [coder readO3ADictionaryFrom:this size:size];
			if (cdict) return cdict;
			std::vector<O3ChildEnt> ents = ReadChildEntsOfTotalLength(size, YES);
			std::vector<O3ChildEnt>::iterator it=ents.begin(), e=ents.end();
			NSMutableDictionary* dict = [[[NSMutableDictionary allocWithZone:z] init] autorelease];
			for (; it!=e; it++) {
				O3ChildEnt& chEnt = *it;
				NSString* k = chEnt.key;
				if (chEnt.domain) k = [chEnt.domain stringByAppendingString:k];
				[dict setValue:ReadObject(coder, z, chEnt) forKey:k];
			}
			to_return = dict; break;
		}
		case O3PkgTypeArray: {
			id carr = [coder readO3AArrayFrom:this size:size];
			if (carr) return carr;
			std::vector<O3ChildEnt> ents = ReadChildEntsOfTotalLength(size, NO);
			std::vector<O3ChildEnt>::iterator it=ents.begin(), e=ents.end();
			NSMutableArray* marr = [[[NSMutableArray allocWithZone:z] initWithCapacity:ents.size()] autorelease];
			for (; it!=e; it++) {
				O3ChildEnt& chEnt = *it;
				id obj = ReadObject(coder, z, chEnt);
				[marr addObject:obj];
			}
			to_return = marr; break;
		}
		O3PkgTypeStructArray: {
			to_return = [O3StructArrayRead(this, size) autorelease];
			break;
		}
		case O3PkgTypeStringArray: {
			NSMutableArray* arr = [[[NSMutableArray allocWithZone:z] initWithCapacity:size/6] autorelease];
			char* bytes = (char*)ReadBytes(size,1); bytes[size]=0;
			char* bend = bytes+size;
			UIntP len = 0;
			for (char* str=bytes; str<bend; str+=len) {
				len = strlen(str);
				O3CFArrayAppendValue(arr,   NSStringWithUTF8String(str, len)   );
			}
			free(bytes);
 			to_return = arr; break;
		}
		case O3PkgTypeRawData: {
			to_return = ReadData(size);
			break;
		}
		case O3PkgTypeCompressed: {
			UInt64 o0 = Offset();
			O3ChildEnt ee(ReadChildEnt());
			UInt64 o1 = Offset();
			UInt64 clen = size - (o1-o0);
			O3InflationOptions iopts;
			NSMutableData* md = iopts.inflateInto = [[NSMutableData allocWithZone:z] initWithCapacity:ee.len];
			iopts.rawInflate = YES;
			[ReadDataNoCopy(clen) o3InflateWithOptions:iopts];
			O3BufferedReader br2(md);
			br2.mKT = mKT; br2.mST = mST; br2.mCT = mCT;
			ee.offset = 0;
			to_return = ReadObject(coder, z, ee);
			[md release];
			break;
		}
		case O3PkgTypeObject: {
			if (!coder) {
				to_return = nil;
				O3CLogWarn(@"All O3PkgTypeObjects are replaced with nil in an archive which is unarchived with O3BufferedReader::ReadObject and a nil coder.");
				break;
			}
			to_return = [coder readO3AObjectOfClass:ent.className from:this size:size];
			break;
		}
		default:
			O3AssertFalse(@"PkgType not recognized!");
	} //switch
	UIntP offset = Offset();
	UIntP correctOffset = ent.offset+size;
	if (offset!=correctOffset) {
		O3CLogWarn(@"The contract in the O3UnarchiverCallbackable protocol was broken: during the reading of (type:%i size:0x%X) %@, the offset was 0x%X after reading when it should have been 0x%X according to the object header ending at 0x%X. Attempting recovery (returning nil).", ent.type, size, to_return, offset, correctOffset, ent.offset);
		@try {
			SeekToOffset(correctOffset);
			to_return = nil;
		} @catch (NSException* e) {
			O3CLogError(@"Recovery failed (cannot seek on this handle). Throwing an exception.");
			[NSException raise:NSInconsistentArchiveException format:@"Archive %@ could not be parsed because a reader violated its contract (read all bytes it ought to).", coder];
		}
	}
	return to_return;
}

UInt8 O3BufferedReader::ReadByte() {
	AssureBytesLeft(1);
	return ReadAssuredByte();
}

Int32 O3BufferedReader::ReadBytesAsInt32(int bytes) {
	O3AssertArg(bytes>0 && bytes<100, @"Absurd value for parameter bytes: %i", bytes);
	AssureBytesLeft(bytes);
	if (bytes==4) {
		UInt32 uval = O3ByteswapBigToHost(*(UInt32*)mBlockBytes);
		BOOL negative = (*mBlockBytes)&0x80;
		Advance(4);
		Int32 to_return = uval&0x7FFFFFFF;
		if (negative) to_return = (-to_return)-1;
		return to_return;
	}
	Int32 to_return = 0;
	UInt8 firstbyte = ReadAssuredByte();
	BOOL negative = firstbyte&0x80;
	to_return += firstbyte&0x7F;
	while (--bytes) {
		to_return<<=8;
		if (bytes>=4 && to_return>>24) O3CLogWarn(@"Definite loss of precision (more than 4 bytes being put into a 32 bit integer) in O3BufferedReader::ReadBytesAsUInt32");
		to_return |= ReadAssuredByte();
	}
	to_return&=0x7FFFFFFF;
	if (negative) to_return = (-to_return)-1;
	return to_return;
}

Int64 O3BufferedReader::ReadBytesAsInt64(int bytes) {
	O3AssertArg(bytes>0 && bytes<100, @"Absurd value for parameter bytes: %i", bytes);
	AssureBytesLeft(bytes);
	if (bytes==8) {
		UInt64 uval = O3ByteswapBigToHost(*(UInt64*)mBlockBytes);
		BOOL negative = (*mBlockBytes)&0x80;
		Advance(8);
		Int64 to_return = uval&0x7FFFFFFFFFFFFFFFull;
		if (negative) to_return = (-to_return)-1;
		return to_return;
	}
	Int64 to_return = 0;
	UInt8 firstbyte = ReadByte();
	BOOL negative = firstbyte&0x80;
	to_return += firstbyte&0x7F;
	while (--bytes) {
		to_return<<=8;
		if (bytes>=8 && to_return>>56) O3CLogWarn(@"Definite loss of precision (more than 8 bytes being put into a 64 bit integer) in O3BufferedReader::ReadBytesAsUInt32");
		to_return |= ReadAssuredByte();
	}
	to_return&=0x7FFFFFFFFFFFFFFFull;
	if (negative) to_return = (-to_return)-1;
	return to_return;		
}

UInt32 O3BufferedReader::ReadBytesAsUInt32(int bytes) {
	O3AssertArg(bytes>0, @"Absurd value for parameter bytes: %i", bytes);
	AssureBytesLeft(bytes);
	if (bytes==4) {
		UInt32 to_return = O3ByteswapBigToHost(*(UInt32*)mBlockBytes);
		Advance(4);
		return to_return;
	}
	UInt32 to_return = 0;
	while (bytes--) {
		to_return<<=8;
		if (bytes>=4 && to_return>>24) O3CLogWarn(@"Definite loss of precision (more than 4 bytes being put into a 32 bit integer) in O3BufferedReader::ReadBytesAsUInt32");
		to_return |= ReadAssuredByte();
	}
	return  to_return;		
}

UInt64 O3BufferedReader::ReadBytesAsUInt64(int bytes) {
	O3AssertArg(bytes>0, @"Absurd value for parameter bytes: %i", bytes);
	AssureBytesLeft(bytes);
	if (bytes==8) {
		UInt64 to_return = O3ByteswapBigToHost(*(UInt64*)mBlockBytes);
		Advance(8);
		return to_return;
	}
	UInt64 to_return = 0;
	while (bytes--) {
		to_return<<=8;
		if (bytes>=8 && to_return>>56) O3CLogWarn(@"Definite loss of precision (more than 8 bytes being put into a 64 bit integer) in O3BufferedReader::ReadBytesAsUInt32");
		to_return |= ReadAssuredByte();
	}
	return  to_return;		
}

Int32 O3BufferedReader::ReadCIntAsInt32() {
	AssertOpen();
	Int64 to_ret = ReadCIntAsInt64();
	if (to_ret>0x7FFFFFFF)  O3CLogWarn(@"Definite loss of precision (more than 4 bytes being put into a 32 bit integer) in O3BufferedReader::ReadCIntAsInt32");
	Int32 to_ret2 = O3Abs(to_ret)&0x7FFFFFFF;
	return (to_ret<0)? -to_ret2 : to_ret2;
}

Int64 O3BufferedReader::ReadCIntAsInt64() {
	AssertOpen();
	UInt8 b = ReadByte();
	BOOL negative = b&0x40; //Get sign
	Int64 to_return = b&0x3F;
	int bshift = 6;
	while (b&0x80) {
		b = ReadByte();
		if (bshift>=64 && b&0x7F) O3CLogWarn(@"Possible loss of precision (more than 8 bytes being put into a 64 bit integer) in O3BufferedReader::ReadCIntAsInt64");
		UInt64 shifted_b = (0x7Full&b)<<bshift;
		bshift += 7;
		to_return |= shifted_b;
	}
	to_return&=0x7FFFFFFFFFFFFFFFull;
	if (negative) to_return = (-to_return)-1;
	return to_return;		
}

UInt32 O3BufferedReader::ReadUCIntAsUInt32() {
	AssertOpen();
	UInt64 to_ret = ReadUCIntAsUInt64();
	if (to_ret>0xFFFFFFFF) O3CLogWarn(@"Definite loss of precision (more than 4 bytes being put into a 32 bit integer) in O3BufferedReader::ReadUCIntAsUInt32");
	return (UInt32)to_ret;
}

UInt64 O3BufferedReader::ReadUCIntAsUInt64() {
	AssertOpen();
	UInt8 b = 0x80;
	UInt64 to_return = 0;
	int bshift = 0;
	while (b&0x80) {
		b = ReadByte();
		if (bshift>=64 && b&0x7F) O3CLogWarn(@"Possible loss of precision (more than 8 bytes being put into a 64 bit integer) in O3BufferedReader::ReadUCIntAsUInt64");
		UInt64 shifted_b = (0x7Full&b)<<bshift;
		to_return |= shifted_b;
		bshift+=7;
	}
	return to_return;
}

void O3BufferedReader::SeekToOffset(unsigned long long offset) {
	if (mHandle) {
		[mHandle seekToFileOffset:offset]; //If this throws, let it throw
		mBlockBytesRemaining = 0; //Flush the cache
		mOffset = offset;
	}
	else {
		O3Asrt(offset<1ull<<63);
		Int64 diff = ((Int64)offset-(Int64)mOffset);
		mBlockBytes += diff; //Mapped data space is guarenteed to be contiguous
		mBlockBytesRemaining -= diff;
		mOffset = offset;
	}
}

float O3BufferedReader::ReadFloat() {
	AssertOpen();
	UInt32 theint = ReadBytesAsUInt32(4);
	return *(float*)&theint;
}

double O3BufferedReader::ReadDouble() {
	AssertOpen();
	UInt64 theint = ReadBytesAsUInt64(8);
	return *(double*)&theint;
}

///@returns an autoreleased NSString
///@raises an NSInconsistentArchiveException if O3CCSTableType references a nil table when needed
NSString* O3BufferedReader::ReadCCString(enum O3CCSTableType ttype) {
	AssertOpen();
	Int64 len = ReadCIntAsInt64();
	if (!len) return @"";
	if (len>0) {
		char* str = (char*)ReadBytes(len,1);
		str[len]=0;
		return NSStringWithUTF8StringNoCopy(str, len, YES);
	} else {
		NSArray* table = nil;
		switch (ttype) {
			case O3CCSKeyTable:    table = mKT; break;
			case O3CCSClassTable:  table = mCT; break;
			case O3CCSStringTable: table = mST; break;
			default:
				O3AssertFalse(@"Invalid string table?!");
				return nil;
		}
		if (!table) [NSException raise:NSInconsistentArchiveException format:@"Undefined table referenced."];
		return O3CFArrayGetValueAtIndex(table, -len-1);
	}
	O3AssertFalse();
	return nil;
}

///@todo Make secure: assure that len is resonable.
void* O3BufferedReader::ReadBytes(UInt64 len, UInt64 extra_bytes) {
	AssureBytesLeft(len);
	UInt64 len_to_return = len+extra_bytes;
	void* to_return = malloc(len_to_return);
	memcpy(to_return, mBlockBytes, len);
	Advance(len);
	return to_return;
}

void O3BufferedReader::ReadBytesInto(void* b, UInt64 len) {
	AssureBytesLeft(len);
	memcpy(b, mBlockBytes, len);
	Advance(len);
}

NSData* O3BufferedReader::ReadData(UInt64 len) {
	return [NSData dataWithBytesNoCopy:ReadBytes(len,0) length:len freeWhenDone:YES];
}

NSData* O3BufferedReader::ReadDataNoCopy(UInt64 len) {
	AssureBytesLeft(len);
	return [NSData dataWithBytesNoCopy:mBlockBytes length:len freeWhenDone:NO];
	Advance(len);
	return nil;
}

void O3BufferedReader::Close() {
	AssertOpen();
	if (mHandle) {
		int fd = [mHandle fileDescriptor];
		flock(fd, LOCK_UN);
	}
	O3Destroy(mHandle);
	O3Destroy(mBlockData);
}

unsigned long long O3BufferedReader::Offset() {
	return mOffset;
}

BOOL O3BufferedReader::IsAtEnd() {
	if (mBlockBytesRemaining) return NO;
	if (mHandle) {
		@try {
			UInt64 off = [mHandle offsetInFile];
			[mHandle seekToEndOfFile];
			UInt64 noff = [mHandle offsetInFile];
			if (off==noff) return YES;
			[mHandle seekToFileOffset:off];
			return NO;
		} @catch (NSException* e) {
			O3CLogError(@"IsAtEnd() not implemented for unseekable reading.");
			return NO;
		}
	}
	return YES;
}

UInt64 O3BufferedReader::TotalLength() {
	if (!mHandle) return [mBlockData length];
	UInt64 off = [mHandle offsetInFile];
	[mHandle seekToEndOfFile];
	UInt64 noff = [mHandle offsetInFile];
	[mHandle seekToFileOffset:off];
	return noff;
}
