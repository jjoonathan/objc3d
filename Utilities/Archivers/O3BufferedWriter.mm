#include "O3BufferedWriter.h"

/************************************/ #pragma mark Init and Destruction /************************************/
void O3BufferedWriter::Init() {
	mHandle = nil;
	mBlockSize = 10000;
	mBlockData = nil;
	mBlockData_setLength_ = nil;
	mBlockData_appendBytes_length_ = nil;
	mBlockData_length = nil;
	mHandle_writeData_ = nil;
	mKT = mST = mCT = nil;
#ifdef O3DEBUG
	mDebug = NO;
#endif
}

O3BufferedWriter::O3BufferedWriter(NSFileHandle* handle) {
	O3AssertArg(handle, @"O3BufferedWriter cannot be passed a nil handle in its constructor.");
	Init();
	O3Assign(handle, mHandle);
	mBlockData = [[NSMutableData alloc] initWithCapacity:mBlockSize];
	mBlockData_setLength_ = (mBlockData_setLength_t)[mBlockData methodForSelector:@selector(setLength:)];
	mBlockData_appendBytes_length_ = (mBlockData_appendBytes_length_t)[mBlockData methodForSelector:@selector(appendBytes:length:)];
	mBlockData_length = (mBlockData_length_t)[mBlockData methodForSelector:@selector(length)];
	mHandle_writeData_ = (mHandle_writeData_t)[mHandle methodForSelector:@selector(writeData:)];
}

O3BufferedWriter::O3BufferedWriter(NSMutableData* data) {
	O3AssertArg(data, @"O3BufferedWriter cannot be passed a nil (NSMutableData*)data in its constructor.");
	Init();
	O3Assign(data, mBlockData);
	mBlockData_setLength_ = (mBlockData_setLength_t)[mBlockData methodForSelector:@selector(setLength:)];
	mBlockData_appendBytes_length_ = (mBlockData_appendBytes_length_t)[mBlockData methodForSelector:@selector(appendBytes:length:)];
	mBlockData_length = (mBlockData_length_t)[mBlockData methodForSelector:@selector(length)];
	mBlockSize = 0;
}

O3BufferedWriter::~O3BufferedWriter() {
	if (mHandle&&mBlockData) Close();
}

/************************************/ #pragma mark Private inline stuff /************************************/
inline void O3BufferedWriter::Flush() {
	AssertOpen();
	O3Assert(mHandle, @"O3BufferedWriter::Flush() got called on a data-only HandleWriter");
	O3Assert(mBlockData_setLength_ && mHandle_writeData_, @"Runtime cache data missing! mBlockData_setLength_=0x%X mHandle_writeData_=0x%X",mBlockData_setLength_,mHandle_writeData_);
	mHandle_writeData_(mHandle, @selector(writeData:), mBlockData);
	mBlockData_setLength_(mBlockData, @selector(setLength:), 0);
}

inline void O3BufferedWriter::FlushIfNecessary() {
	AssertOpen();
	if (!mHandle) return;
	O3Assert(mBlockData_length, @"Runtime cache missing!");
	if (mBlockData_length(mBlockData,@selector(length)) > mBlockSize) Flush();
}

void O3BufferedWriter::WriteBytes(const void* bytes, UIntP len) {
	AssertOpen();
	O3Assert(mBlockData_appendBytes_length_, @"Cannot append bytes. Missing runtime cache info!");
	mBlockData_appendBytes_length_(mBlockData, @selector(appendBytes:length:), bytes, len);
	FlushIfNecessary();
}

/************************************/ #pragma mark Public Writer Methods /************************************/
void O3BufferedWriter::WriteByte(UInt8 byte) {
	O3BufferedWriterDebugLog(@"WriteByte(%i)", (int)byte);
	AssertOpen();
	WriteBytes(&byte, 1);
}

void O3BufferedWriter::WriteFloat(float value) {
	O3BufferedWriterDebugLog(@"WriteFloat(%f)", value);
	AssertOpen();
	UInt32 raw = *(UInt32*)&value;
	WriteUIntAsBytes(raw);
}

void O3BufferedWriter::WriteDouble(double value) {
	O3BufferedWriterDebugLog(@"WriteDouble(%f)", value);
	AssertOpen();
	UInt64 raw = *(UInt64*)&value;
	WriteUIntAsBytes(raw);
}

void O3BufferedWriter::WriteCCString(const char* str) {
	O3BufferedWriterDebugLog(@"WriteCCString(%s)", str);
	AssertOpen();
	if (!str) {
		WriteByte(0);
		return;
	}
	Int64 len = strlen(str);
	WriteUCInt(len);
	WriteBytes(str, len);
}

void O3BufferedWriter::WriteCCString(NSString* str, O3CCSTableType tabletype) {
	NSDictionary* table = nil;
	switch (tabletype) {
		case O3CCSKeyTable: table = mKT; break;
		case O3CCSClassTable: table = mCT; break;
		case O3CCSStringTable: table = mST; break;
		default: O3AssertFalse(@"Unrecognized table!");
	}
	O3CCStringHint hint;
	UIntP len = O3BytesNeededForCCStringWithTable(str, table, &hint);
	UInt8* bytes=(UInt8*)malloc(len);
	O3WriteCCStringWithTableOrIndex(bytes, str, table, &hint);
	WriteBytes(bytes, len);
	free(bytes);
	//return len;
}

void O3BufferedWriter::WriteTypedObjectHeader(NSString* className, UIntP size, enum O3PkgType type) {
	O3CCStringHint hint;
	UIntP len = O3BytesNeededForTypedObjectHeader(size, className, mCT, &hint);
	UInt8* buf = (UInt8*)malloc(len);
	UIntP rlen = O3WriteTypedObjectHeader(buf, type, size, className, mCT, &hint); rlen;
	O3Assert(len==rlen, @"Typed Object Header size estimation failed. %p != %p", len, rlen);
	WriteBytes(buf, len);
	free(buf);
}

void O3BufferedWriter::WriteData(NSData* dat) {
	AssertOpen();
	WriteBytes([dat bytes], [dat length]);
}

void O3BufferedWriter::Close() {
	AssertOpen();
	if (mHandle) Flush();
	O3Destroy(mHandle);
	O3Destroy(mBlockData);
}