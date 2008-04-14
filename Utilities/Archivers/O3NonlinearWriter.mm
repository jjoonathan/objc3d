#import "O3NonlinearWriter.h"
#import "O3GPUData.h"
#import <sys/uio.h>
#ifndef UIO_MAXIOV
#define UIO_MAXIOV 1024
#endif

/************************************/ #pragma mark Memory Management /************************************/
///Use an allocation scheme optimized for small and oddly sized blocks
///@warning Do not tell the O3NonlinearWriter to free bytes allocated with AllocBytes.
UInt8* O3NonlinearWriter::AllocBytes(UIntP bytes) {
	O3CLogDebug(@"AllocBytes(%p);", bytes);
	if (bytes<=mBytesLeft) { //Carve a chunk off our arena if we can
		mBytesLeft -= bytes;
		UInt8* to_return = mCurrentPos;
		mCurrentPos += bytes;
		mLastAllocationSize = bytes;
		mLastAllocation = to_return;
		return to_return;
	}
	if (bytes<=mBlockSize) { //Otherwise make a new arena and return a chunk off it
		UInt8* buf = (UInt8*)malloc(mBlockSize);
		mBuffers.push_back(buf);
		mCurrentPos = buf + bytes;
		mBytesLeft = mBlockSize - bytes;
		mLastAllocationSize = bytes;
		mLastAllocation = buf;
		mLastAllocationBlock = buf;
		return buf;
	}
	UInt8* buf = (UInt8*)malloc(bytes); //If all else fails, just use malloc
	mBuffers.push_back(buf);
	mCurrentPos = buf + bytes;
	mBytesLeft = 0;
	mLastAllocationSize = bytes;
	mLastAllocation = buf;
	mLastAllocationBlock = buf;
	return buf;
}

///Give back a few bytes off the last allocation.
void O3NonlinearWriter::RelinquishBytes(UIntP bytes) {
#ifdef O3DEBUG
	if (bytes>mLastAllocationSize) {
		O3CLogWarn(@"More bytes were relinquished than were in the last allocation. Ignoring the relinquish call.", nil);
		return;
	}
#endif
	mCurrentPos -= bytes;
	mBytesLeft += bytes;
}

///@return Returns an integer that serves as a placeholder for other data.
UIntP O3NonlinearWriter::ReservePlaceholder() {
	struct iovec v = {NULL, 0};
	mChunksToWrite.push_back(v);
	return mChunksToWrite.size()-1;
}

/************************************/ #pragma mark Placeholder Writing /************************************/
UIntP O3NonlinearWriter::WriteByteAtPlaceholder(UInt8 byte, UIntP p) {
	UInt8* bytes = AllocBytes(1);
	bytes[0]=byte;
	WriteBytesAtPlaceholder((void*)bytes, 1, p);
	return 1;
}

UIntP O3NonlinearWriter::WriteFloatAtPlaceholder(float value, UIntP p) {
	UInt32 raw = *(UInt32*)&value;
	WriteUIntAsBytesAtPlaceholder(raw,sizeof(float),p);
	return sizeof(float);
}

UIntP O3NonlinearWriter::WriteDoubleAtPlaceholder(double value, UIntP p) {
	UInt64 raw = *(UInt64*)&value;
	WriteUIntAsBytesAtPlaceholder(raw,sizeof(double),p);
	return sizeof(double);
}

UIntP O3NonlinearWriter::WriteCCStringAtPlaceholder(const char* str, UIntP p) {
	UIntP slen=strlen(str);
	UInt8 ilen = O3BytesNeededForCInt(slen);
	UIntP len = slen+ilen;
	UInt8* bytes=AllocBytes(len);
	O3WriteCInt(bytes, slen);
	memcpy(bytes+ilen, str, slen); //Intentionally drop the null terminator
	WriteBytesAtPlaceholder(bytes, len, p);
	return len;
}

UIntP O3NonlinearWriter::WriteCCStringAtPlaceholder(NSString* str, UIntP p, O3CCSTableType tabletype) {
	NSDictionary* table = nil;
	switch (tabletype) {
		case O3CCSKeyTable: table = mKT; break;
		case O3CCSClassTable: table = mCT; break;
		case O3CCSStringTable: table = mST; break;
		default: 
			O3AssertFalse(@"Unrecognized table!");
			return 0;
	}
	O3CCStringHint hint;
	UIntP len = O3BytesNeededForCCStringWithTable(str, table, &hint);
	UInt8* bytes=AllocBytes(len);
	UIntP rsize = O3WriteCCStringWithTableOrIndex(bytes, str, table, &hint); rsize;
	O3Assert(rsize==len, @"Estimate mismatch");
	WriteBytesAtPlaceholder(bytes, len, p);
	return len;
}

///@note dat is retained, but it must not be a mutable data that then changes
UIntP O3NonlinearWriter::WriteDataAtPlaceholder(NSData* dat, UIntP p) {
	mToRelease.push_back([dat copy]);
	UIntP len = [dat length];
	WriteBytesAtPlaceholder([dat bytes], len, p);
	return len;
}

///@warning It is unknown what happens with \e bytes. Likely nothing (the const should be obeyed), but if things happen, make copies. I do not mean the warning about not freeWhenDone-ing AllocBytes().
UIntP O3NonlinearWriter::WriteBytesAtPlaceholder(const void* bytes, UIntP len, UIntP p, BOOL freeWhenDone) {
	#ifdef O3DEBUG
	char* lastbuf = (char*)mLastAllocationBlock;
	if (freeWhenDone && bytes>lastbuf && bytes<(lastbuf+mBlockSize) && lastbuf) {
		O3CLogError(@"Do not tell O3NonlinearWriter::WriteBytesAtPlaceholder to freeWhenDone buffers allocated with AllocBytes(), namely %p. They are automatically freed, and malloc errors will ensue with O3DEBUG turned off.", bytes);
		freeWhenDone=NO;
	}
	#endif
	#undef O3NonlinearWriterCombinationOptimization /*Causes issues with BytesWrittenInPlaceholderRange*/
	#ifdef O3NonlinearWriterCombinationOptimization
	UIntP lastChunkIndex = mChunksToWrite.size()-1;
	if ((lastChunkIndex==p) && ((UInt8*)(mChunksToWrite[lastChunkIndex-1].iov_base)+mChunksToWrite[lastChunkIndex-1].iov_len)==bytes) {
		mChunksToWrite[lastChunkIndex-1].iov_len += len;
		mChunksToWrite.pop_back();
		O3Assert(!freeWhenDone, @"?");
		return len;
	} else
	#endif
	if (freeWhenDone) mBuffers.push_back((void*)bytes);
	mChunksToWrite[p].iov_base = (void*)bytes;
	mChunksToWrite[p].iov_len  = len;
	return len;
}

UIntP O3NonlinearWriter::WriteTypedObjectHeaderAtPlaceholder(NSString* className, UIntP size, enum O3PkgType type, UIntP placeholder) {
	if ((className?YES:NO)^type==O3PkgTypeObject)
		[NSException raise:NSInvalidArgumentException format:@"In WriteTypedObjectHeaderAtPlaceholder, a className (%@) must be and must only be provided for type==O3PkgTypeObject==14 (%i)", className, type];
	O3CCStringHint classNameHint;
	UIntP allocSize = O3BytesNeededForTypedObjectHeader(size, className, mCT, &classNameHint);
	UInt8* buf = (UInt8*)AllocBytes(allocSize);
	UIntP usedBytes = O3WriteTypedObjectHeader(buf, type, size, className, mCT, &classNameHint);
	
	//RelinquishBytes(allocedBytes-usedBytes);
	O3Assert(usedBytes==allocSize, @"Allocation estimation equation in WriteTypedObjectHeaderAtPlaceholder was wrong, archive is possibly corrupt.");
	WriteBytesAtPlaceholder(buf, usedBytes, placeholder);
	return usedBytes;
}

UIntP O3NonlinearWriter::WriteStringArrayAtPlaceholder(const std::vector<std::string>& strings, UIntP placeholder) {
	UIntP usedBytes=0;
	UIntP strCount=strings.size();
	UIntP allocedBytes = 0;
	UIntP i; for (i=0; i<strCount; i++)	{
		UIntP s = strings[i].size();
		allocedBytes += s + (i==strCount-1)? 0 : 1;
	}
	UInt8* bytes=AllocBytes(allocedBytes);
	for (i=0; i<strCount; i++) {
		UIntP size = strings[i].size();
		memcpy(usedBytes+bytes, strings[i].c_str(), size);
		usedBytes+=size;
		if (i!=strCount-1) {
			bytes[usedBytes]=0;
			usedBytes+=1;
		}
	}
	//RelinquishBytes(allocedBytes-usedBytes);
	O3Assert(usedBytes==allocedBytes, @"Allocation estimation equation in WriteStringArrayAtPlaceholder was wrong, archive is possibly corrupt.");
	WriteBytesAtPlaceholder(bytes, allocedBytes, placeholder);
	return usedBytes;
}

UIntP O3NonlinearWriter::WriteChildrenHeaderAtPlaceholder(std::vector<O3ChildEnt>* children, UIntP p, NSDictionary* kt, NSDictionary* ct) {
	UIntP size = 0;
	O3Asrt(children);
	std::vector<O3ChildEnt>::iterator it=children->begin(),  e=children->end();
	for (; it!=e; it++) {
		O3ChildEnt& e = *it;
		if (e.key) size += O3BytesNeededForCCStringWithTable(e.key, kt);
		size += O3BytesNeededForTypedObjectHeader(e.len, e.className, ct, nil);
	}
	UInt8* b = (UInt8*)malloc(size);
	UIntP pos=0;
	it=children->begin();
	for (; it!=e; it++) {
		O3ChildEnt& e = *it;
		if (e.key) pos += O3WriteCCStringWithTableOrIndex(b+pos, e.key, kt, nil);
		pos += O3WriteTypedObjectHeader(b+pos, e.type, e.len, e.className, ct, nil);
	}
	O3Assert(size==pos, @"Header size prediction was incorrect, an overflow or underflow occured while writing!");
	WriteBytesAtPlaceholder(b, size, p, YES);
	return pos;
}

UIntP O3NonlinearWriter::BytesWrittenInPlaceholderRange(IntP start, IntP length) {
	if (length<0 || start<0) return 0;
	O3Assert(start+length-1<=LastPlaceholder(), @"Range for BytesWrittenInPlaceholderRange out of bounds");
	UIntP end = start+length;
	UIntP accum_len = 0;
	for (; start<end; start++) accum_len += mChunksToWrite[start].iov_len;
	return accum_len;
}

IntP O3NonlinearWriter::LastPlaceholder() {
	return mChunksToWrite.size()-1;
}

/************************************/ #pragma mark Memory Management /************************************/
void O3NonlinearWriter::Init() {
	mCurrentPos = NULL;
	mBytesLeft = 0;
	mCT = mKT = mST = nil;
	mLastAllocationBlock = NULL;
}

O3NonlinearWriter::O3NonlinearWriter() {
	Init();
}

O3NonlinearWriter::~O3NonlinearWriter() {
	UIntP i;
	for (i=0; i<mBuffers.size(); i++) free(mBuffers[i]);
	for (i=0; i<mToRelease.size(); i++) {
		IMP rb = [mToRelease[i] methodForSelector:@selector(relinquishBytes)];
		if (rb) rb(mToRelease[i], @selector(relinquishBytes));
		[mToRelease[i] release];
	}
}

/************************************/ #pragma mark  Collection /************************************/
///@return a NSData that you are free to modify, save, or do whatever with
NSData* O3NonlinearWriter::Data() {
	UIntP totalsize = 0;
	UIntP numChunks = mChunksToWrite.size();
	UIntP i; for (i=0; i<numChunks; i++) totalsize += mChunksToWrite[i].iov_len;
	UInt8* bytes = (UInt8*)malloc(totalsize);
	UInt8* bytes_loop = bytes;
	for (i=0; i<numChunks; i++) {
		UIntP len = mChunksToWrite[i].iov_len;
		memcpy(bytes_loop, mChunksToWrite[i].iov_base, len);
		bytes_loop += len;
	}
	return [NSData dataWithBytesNoCopy:bytes length:totalsize freeWhenDone:YES];
}

void O3NonlinearWriter::WriteToFileDescriptor(int descriptor) {
	int s = flock(descriptor, LOCK_EX);
	if (s) O3CLogError(@"Error getting lock: errno=%i",errno);
	struct iovec* towrite = NULL;
#ifdef O3AllowVectorConversionHack
	towrite = &(mChunksToWrite[0]);
#else
	towrite = (iovec*)malloc(sizeof(struct iovec)*mBuffers.size());
	UIntP i; for (i=0; i<mChunksToWrite.size(); i++) towrite[i] = mChunksToWrite[i];
#endif
	UIntP iovtw = mChunksToWrite.size();
	while (iovtw) {
		UIntP iov_on_this_pass = O3Min(iovtw, UIO_MAXIOV);
		int stat = writev(descriptor, towrite, iov_on_this_pass); stat;
		O3Assert(stat!=-1, @"O3NonlinearWriter writing failed, errno=%i",errno);
		iovtw -= iov_on_this_pass;
	}
	flock(descriptor, LOCK_UN);
}