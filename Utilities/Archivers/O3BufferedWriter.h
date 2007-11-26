#ifdef __cplusplus
/**
 *  @file O3BufferedWriter.h
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#pragma once
#include "O3ArchiveFormat.h"
using namespace std;

#ifdef O3DEBUG
#define O3BufferedWriterDebugLog(pattern, args...) ({ id self = nil; if (mDebug) O3LogDebug(pattern, args); })
#else
#define O3BufferedWriterDebugLog(pattern, args...) 
#endif

///@warning This entire class is depricated. Use O3NonlinearWriter instead.
class O3BufferedWriter {
private:
	NSFileHandle* mHandle; //If NULL, the O3BufferedWriter is data based
	BOOL mShouldCloseHandle;
	
	unsigned mBlockSize;
	NSMutableData* mBlockData;
	
	typedef unsigned (*mBlockData_setLength_t)(NSMutableData* self, SEL cmd, unsigned len);
	typedef unsigned (*mBlockData_appendBytes_length_t)(NSData* self, SEL cmd, const void* bytes, unsigned len);
	typedef unsigned (*mBlockData_length_t)(NSMutableData* self, SEL cmd);
	typedef void     (*mHandle_writeData_t)(NSFileHandle*self, SEL cmd, NSData* dat);
	mBlockData_setLength_t				mBlockData_setLength_;
	mBlockData_appendBytes_length_t		mBlockData_appendBytes_length_;
	mBlockData_length_t					mBlockData_length;
	mHandle_writeData_t					mHandle_writeData_;
	
public:
	BOOL mDebug;
	NSDictionary* mKT; ///<@note Not retained
	NSDictionary* mST; ///<@note Not retained
	NSDictionary* mCT; ///<@note Not retained
	
public:
	O3BufferedWriter(NSFileHandle* handle);
	O3BufferedWriter(NSMutableData* data);
	~O3BufferedWriter();
	
	template <typename IntegerType>
		void WriteIntAsBytes(IntegerType value, int bytes=sizeof(IntegerType));
	template <typename UIntegerType>
		void WriteUIntAsBytes(UIntegerType value, int bytes=sizeof(UIntegerType));
	template <typename IntegerType>
		void	WriteCInt(IntegerType value);
	template <typename UIntegerType>
		void	WriteUCInt(UIntegerType value);
	void WriteByte(UInt8 byte);
	void WriteFloat(float value);
	void WriteDouble(double value);
	void WriteCCString(const char* str);
	void WriteCCString(NSString* str, O3CCSTableType tabletype = O3CCSStringTable);
	void WriteBytes(const void* bytes, UIntP len);
	void WriteData(NSData* dat);
	void WriteTypedObjectHeader(NSString* className, UIntP size, enum O3PkgType type);
	
	void Close();
	inline void Flush();
	
private:
	void Init();
	inline void FlushIfNecessary();
	inline void AssertOpen() {
		O3Assert(mHandle||mBlockData, @"Either mHandle or mBlockData is missing from the O3BufferedWriter 0x%X. Probably it was prematurely closed.", this);	   
	}
};

template <typename IntegerType>
	void O3BufferedWriter::WriteIntAsBytes(IntegerType value, int bytes) {
		O3BufferedWriterDebugLog(@"WriteIntAsBytes(%s0x%qX==%qi, %i)", (value<0)?"-":"", (Int64)value, (Int64)value, bytes);
		AssertOpen();
		IntegerType uval = value;
		if (uval<0) uval = -(uval+1);
		BOOL negative = value<0;
		if (uval>>1 >= 1ull<<(bytes*8-2) && bytes<=sizeof(IntegerType))
			[NSException raise:NSInconsistentArchiveException format:@"Definite loss of precision in O3BufferedWriter::WriteInt32AsBytes (%s%X does not fit in %i bytes)", negative?"-":"", uval, bytes];
		UInt8* wb = new UInt8[bytes];
		int i; for (i=bytes-1; i>=0; i--) {
			wb[i] = uval&0xFF;
			uval >>= 8;
		}
		if (negative)	wb[0] |= 0x80;
		else 			wb[0] &= 0x7F;
		WriteBytes(wb, bytes);
		delete[] wb;
	}

template <typename UIntegerType>
	void O3BufferedWriter::WriteUIntAsBytes(UIntegerType value, int bytes) {
		O3BufferedWriterDebugLog(@"WriteUIntAsBytes(0x%qX==%i, %i)", (UInt64)value, (UInt64)value, bytes);
		AssertOpen();
		if (value>>1 >= 1ull<<(bytes*8-1) && bytes<=sizeof(UIntegerType))
			[NSException raise:NSInconsistentArchiveException format:@"Definite loss of precision in O3BufferedWriter::WriteInt32AsBytes (%X does not fit in %i bytes)", value, bytes];
		UInt8* writebytes = new UInt8[bytes];
		int i; for (i=bytes-1; i>=0; i--) {
			writebytes[i] = value&0xFF;
			value >>= 8;
		}
		WriteBytes(writebytes, bytes);
		delete[] writebytes;
	}

template <typename IntegerType>
	void O3BufferedWriter::WriteCInt(IntegerType value) {
		O3BufferedWriterDebugLog(@"WriteUCInt(%s0x%qX==%qi)", (value<0)?"-":"", (UInt64)value, (Int64)value);
		AssertOpen();
		IntegerType uval = value;
		if (uval<0) uval = -(uval+1);
		BOOL negative = value<0;
		UInt8 b1 = uval&0x3F;
		uval >>= 6;
		if (negative) b1 |= 0x40;
		if (uval) b1 |= 0x80;
		WriteByte(b1);
		while (uval) {
			UInt8 b = uval&0x7F;
			uval >>= 7;
			if (uval) b |= 0x80;
			WriteByte(b);
		}
	}

template <typename UIntegerType>
	void O3BufferedWriter::WriteUCInt(UIntegerType value) {
		O3BufferedWriterDebugLog(@"WriteUIntAsUCInt(0x%qX==%qi)", (UInt64)value, (UInt64)value);
		AssertOpen();
		if (!value) WriteByte(0);
		while (value) {
			UInt8 b = value&0x7F;
			value >>= 7;
			if (value) b |= 0x80;
			WriteByte(b);
		}
	}
#endif /*defined(__cplusplus)*/