/**
 *  @file O3BufferedReader.mm
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#include "O3BufferedReader.h"
#include "O3Value.h"
#include "O3ValueArray.h"
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
	O3Assign(handle, mHandle);
	mHandle_readDataOfLength_ = (mHandle_readDataOfLength_t)[handle methodForSelector:@selector(readDataOfLength:)];
	mOffset	= 0;
}

O3BufferedReader::~O3BufferedReader() {
	O3Destroy(mHandle);
	O3Destroy(mBlockData);
}

/************************************/ #pragma mark Private Inline Stuff /************************************/
void O3BufferedReader::FetchNextBlockOrThrow() {
	AssertOpen();
	if (!mHandle) [NSException raise:NSRangeException format:@"!NSData (%@) based O3BufferedReader tried to read past end", mBlockData];
	O3Destroy(mBlockData);
	O3Assign(mHandle_readDataOfLength_(mHandle, @selector(readDataOfLength:), mBlockSize), mBlockData);
	if (!mBlockData) [NSException raise:NSRangeException format:@"O3BufferedReader %p tried to read past end of file", this];
	if (!mBlockData_bytes) {
		mBlockData_bytes = (mBlockData_bytes_t)[mBlockData methodForSelector:@selector(bytes)];
		mBlockData_length = (mBlockData_length_t)[mBlockData methodForSelector:@selector(length)];
	}
	mBlockBytesRemaining = mBlockData_length(mBlockData, @selector(length));
	if (!mBlockBytesRemaining) [NSException raise:NSRangeException format:@"O3BufferedReader %p tried to read past end of file", this];
	mBlockBytes = (UInt8*)mBlockData_bytes(mBlockData, @selector(bytes));
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
///@param classname the class nome of the object (an autoreleased NSString) iff type==O3PkgTypeObj. Otherwise it is untouched (not set to nil!)
enum O3PkgType O3BufferedReader::ReadObjectHeader(UIntP* size, NSString** classname) {
	UInt8 infobyte = ReadByte();
	enum O3PkgType type = (enum O3PkgType)((infobyte&0xF0)>>4);
	if (type==O3PkgTypeObject && classname) *classname = ReadCCString(O3CCSClassTable);
	UIntP readsize = infobyte&0xF;
	UIntP realsize = readsize;
	if (readsize==0xF) realsize = ReadUCIntAsUInt64();
	if (size) {
		if (readsize==0xE) realsize = 64;
		else if (readsize==0xD) realsize = 32;
		else if (readsize==0xC) realsize = 16;
		else if (readsize==0xB) realsize = 12;
		*size = realsize;
	}
	return type;
}

///Skips over an object header and that header's object
void O3BufferedReader::SkipObject() {
	UIntP size;
	ReadObjectHeader(&size);
	if (mBlockBytesRemaining>size) {
		Advance(size);
		return;
	}
	SeekToOffset(Offset()+size);
}

///@warning This will fail to read archived objects (if coder is nil, because of the callback). Use O3KeyedUnarchiver.
///@return an autoreleased object
///@param coder The NSCoder handling the deserialization (for callback purposes, namely readO3ADictionary:) or nil. If [coder readO3ADictionary:] returns YES the buffered reader will continue deserializing under the assumption that deserialazation of the dictionary is complete and it has been seeked past. Otherwise it will simply make a NSDictionary and populate it.
///@param z The zone objects will be allocated in (%coder must be aware of this zone as well, or callback objects will be allocated by the coder)
id O3BufferedReader::ReadObject(NSCoder<O3UnarchiverCallbackable>* coder, NSZone* z) {
	UIntP size;
	NSString* className;
	enum O3PkgType type = ReadObjectHeader(&size, &className);
	UIntP oldOffset = Offset();
	id to_return = nil;
	switch (type) {
		case O3PkgTypeFalse:		to_return = [[NSNumber allocWithZone:z] initWithBool:NO];								                 break;
		case O3PkgTypeTrue:			to_return = [[NSNumber allocWithZone:z] initWithBool:YES];                                               break;
		case O3PkgTypePositiveInt:	to_return = [[NSNumber allocWithZone:z] initWithUnsignedLongLong:ReadBytesAsUInt64(size)];               break;
		case O3PkgTypeNegativeInt:	to_return = [[NSNumber allocWithZone:z] initWithLongLong:-(Int64)ReadBytesAsUInt64(size)];               break;
		case O3PkgTypeValue:		to_return = [[O3Value allocWithZone:z] initByReadingFrom:this];                                      break;
		case O3PkgTypeValueArray:   to_return = [[[O3ValueArray allocWithZone:z] initWithPortableBufferReader:this] autorelease];        break;
		//case O3PkgType01Fixed:		to_return = [[NSNumber allocWithZone:z] initWithDouble:ReadBytesAsUInt64(size)/(double)(1<<(8*size)-1)]; break;
		case O3PkgTypeRawData:      to_return = ReadData(size);                                                              break;
		case O3PkgTypeFloat:{	 	
			if (size==sizeof(float))  {to_return = [[NSNumber allocWithZone:z] initWithFloat:ReadFloat()];   break;}
			if (size==sizeof(double)) {to_return = [[NSNumber allocWithZone:z] initWithDouble:ReadDouble()]; break;}
			O3Assert(NO, @"Cannot read a %l byte float!", (long)size);
			to_return = nil; break;
		}
		case O3PkgTypeString: {
			if (!size) {to_return = @""; break;}
			to_return = [[[NSString allocWithZone:z] initWithBytesNoCopy:ReadBytes(size) length:size encoding:NSUTF8StringEncoding freeWhenDone:YES] autorelease];
			break;
			O3Assert(NO, @"Cannot read an indexed CCString yet!");
			to_return = nil; break;
		}
		case O3PkgTypeDictionary: {
			id dict = [coder readO3ADictionaryFrom:this size:size];
			if (!dict) {
				unsigned long long dict_end = Offset()+size;
				dict = [[[NSMutableDictionary allocWithZone:z] init] autorelease];
				while (Offset()<dict_end) {
					NSString* key = ReadCCString(O3CCSKeyTable);
					[dict setValue:ReadObject(coder, z) forKey:key];
				}
			}
			to_return = dict; break;
		}
		case O3PkgTypeArray: {
			NSArray* arr = [coder readO3AArrayFrom:this size:size];
			if (!arr) {
				unsigned long long arr_end = Offset()+size;
				arr = [[[NSMutableArray allocWithZone:z] init] autorelease];
				while (Offset()<arr_end) {
					id obj = ReadObject(coder, z);
					[(NSMutableArray*)arr addObject:obj];
				}
			}
			to_return = arr; break;
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
		case O3PkgTypeObject: {
			if (!coder) {
				to_return = nil;
				O3CLogWarn(@"All O3PkgTypeObjects are replaced with nil in an archive which is unarchived with O3BufferedReader::ReadObject and a nil coder.");
				break;
			}
			to_return = [coder readO3AObjectOfClass:className from:this size:size];
			break;
		}
		default:
			O3AssertFalse(@"PkgType not recognized!");
	} //switch
	UIntP offset = Offset();
	UIntP correctOffset = oldOffset+size;
	if (offset!=correctOffset) {
		O3CLogWarn(@"The contract in the O3UnarchiverCallbackable protocol was broken: during the reading of (type:%i size:0x%X) %@, the offset was 0x%X after reading when it should have been 0x%X according to the object header ending at 0x%X. Attempting recovery (returning nil).", type, size, to_return, offset, correctOffset, oldOffset);
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
	AssertOpen();
	if (!BytesLeft(1)) FetchNextBlockOrThrow();
	UInt8 to_return = *mBlockBytes;
	Advance(1);
	return to_return;
}

Int32 O3BufferedReader::ReadBytesAsInt32(int bytes) {
	AssertOpen();
	O3AssertArg(bytes>0 && bytes<100, @"Absurd value for parameter bytes: %i", bytes);
	if (bytes==4 && BytesLeft(bytes)) {
		UInt32 uval = O3ByteswapBigToHost(*(UInt32*)mBlockBytes);
		BOOL negative = (*mBlockBytes)&0x80;
		Advance(4);
		Int32 to_return = uval&0x7FFFFFFF;
		if (negative) to_return = (-to_return)-1;
		return to_return;
	}
	Int32 to_return = 0;
	UInt8 firstbyte = ReadByte();
	BOOL negative = firstbyte&0x80;
	to_return += firstbyte&0x7F;
	while (--bytes) {
		to_return<<=8;
		if (bytes>=4 && to_return>>24) O3CLogWarn(@"Definite loss of precision (more than 4 bytes being put into a 32 bit integer) in O3BufferedReader::ReadBytesAsUInt32");
		to_return |= ReadByte();
	}
	to_return&=0x7FFFFFFF;
	if (negative) to_return = (-to_return)-1;
	return to_return;
}

Int64 O3BufferedReader::ReadBytesAsInt64(int bytes) {
	AssertOpen();
	O3AssertArg(bytes>0 && bytes<100, @"Absurd value for parameter bytes: %i", bytes);
	if (bytes==8 && BytesLeft(bytes)) {
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
		to_return |= ReadByte();
	}
	to_return&=0x7FFFFFFFFFFFFFFFull;
	if (negative) to_return = (-to_return)-1;
	return to_return;		
}

UInt32 O3BufferedReader::ReadBytesAsUInt32(int bytes) {
	AssertOpen();
	O3AssertArg(bytes>0, @"Absurd value for parameter bytes: %i", bytes);
	if (bytes==4 && BytesLeft(bytes)) {
		UInt32 to_return = O3ByteswapBigToHost(*(UInt32*)mBlockBytes);
		Advance(4);
		return to_return;
	}
	UInt32 to_return = 0;
	while (bytes--) {
		to_return<<=8;
		if (bytes>=4 && to_return>>24) O3CLogWarn(@"Definite loss of precision (more than 4 bytes being put into a 32 bit integer) in O3BufferedReader::ReadBytesAsUInt32");
		to_return |= ReadByte();
	}
	return  to_return;		
}

UInt64 O3BufferedReader::ReadBytesAsUInt64(int bytes) {
	AssertOpen();
	O3AssertArg(bytes>0, @"Absurd value for parameter bytes: %i", bytes);
	if (bytes==8 && BytesLeft(bytes)) {
		UInt64 to_return = O3ByteswapBigToHost(*(UInt64*)mBlockBytes);
		Advance(8);
		return to_return;
	}
	UInt64 to_return = 0;
	while (bytes--) {
		to_return<<=8;
		if (bytes>=8 && to_return>>56) O3CLogWarn(@"Definite loss of precision (more than 8 bytes being put into a 64 bit integer) in O3BufferedReader::ReadBytesAsUInt32");
		to_return |= ReadByte();
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
	AssertOpen();
	UInt64 to_read = len+extra_bytes;
	void* to_return = malloc(to_read);
	if (BytesLeft(len)) {
		memcpy(to_return, mBlockBytes, len);
		Advance(len);
	} else {
		if (!mHandle) [NSException raise:NSInconsistentArchiveException format:@"Attempt to read past end of archived data (archive is corrupt)"];
		memcpy(to_return, mBlockBytes, mBlockBytesRemaining);
		O3Destroy(mBlockData);
		void* new_pos = (UInt8*)to_return+mBlockBytesRemaining;
		UInt64 new_toread = to_read-mBlockBytesRemaining;
		mBlockBytesRemaining=0;
		NSData* newBytes = mHandle_readDataOfLength_(mHandle, @selector(readDataOfLength:), new_toread);
		if (!mBlockData_bytes) {
			mBlockData_bytes = (mBlockData_bytes_t)[mBlockData methodForSelector:@selector(bytes)];
			mBlockData_length = (mBlockData_length_t)[mBlockData methodForSelector:@selector(length)];
		}
		O3Assert(mBlockData_length(newBytes, @selector(length))==new_toread , @"Attempt to read outside of file in O3BufferedReader::ReadBytes");
		memcpy(new_pos, mBlockData_bytes(newBytes, @selector(bytes)), new_toread);
	}
	return to_return;
}

void O3BufferedReader::ReadBytesInto(void* b, UInt64 len) {
	AssertOpen();
	if (BytesLeft(len)) {
		memcpy(b, mBlockBytes, len);
		Advance(len);
	} else {
		if (!mHandle) [NSException raise:NSInconsistentArchiveException format:@"Attempt to read past end of archived data (archive is corrupt)"];
		memcpy(b, mBlockBytes, mBlockBytesRemaining);
		O3Destroy(mBlockData);
		void* new_pos = (UInt8*)b+mBlockBytesRemaining;
		UInt64 new_toread = len-mBlockBytesRemaining;
		mBlockBytesRemaining=0;
		NSData* newBytes = mHandle_readDataOfLength_(mHandle, @selector(readDataOfLength:), new_toread);
		if (!mBlockData_bytes) {
			mBlockData_bytes = (mBlockData_bytes_t)[mBlockData methodForSelector:@selector(bytes)];
			mBlockData_length = (mBlockData_length_t)[mBlockData methodForSelector:@selector(length)];
		}
		O3Assert(mBlockData_length(newBytes, @selector(length))==new_toread , @"Attempt to read outside of file in O3BufferedReader::ReadBytes");
		memcpy(new_pos, mBlockData_bytes(newBytes, @selector(bytes)), new_toread);
	}
}

NSData* O3BufferedReader::ReadData(UInt64 len) {
	AssertOpen();
	return [NSData dataWithBytesNoCopy:ReadBytes(len,0) length:len freeWhenDone:YES];
}

void O3BufferedReader::Close() {
	AssertOpen();
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
