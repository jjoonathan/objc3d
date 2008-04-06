/**
 *  @file O3NonlinearWriter.h
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#ifdef __cplusplus
#pragma once
#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>
#include <vector>
#include <string>
#include "O3ArchiveFormat.h"
using namespace std;

#ifdef O3DEBUG
#define O3NonlinearWriterDebugLog(pattern, args...) ({ id self = nil; if (mDebug) O3LogDebug(pattern, args); })
#else
#define O3NonlinearWriterDebugLog(pattern, args...) 
#endif

//Combines contiguous writes
#define O3NonlinearWriterCombinationOptimization

class O3NonlinearWriter {
public:
	NSDictionary* mKT; ///<@note Not retained
	NSDictionary* mST; ///<@note Not retained
	NSDictionary* mCT; ///<@note Not retained
	
private: //Fast malloc memory
	static const int mBlockSize = 4096;
	std::vector<void*> mBuffers; //Buffers to be freed
	std::vector<NSObject*> mToRelease; //Objects to be released
	UInt8* mCurrentPos;
	UIntP mBytesLeft;
	UIntP mLastAllocationSize; //The size of the last allocation via AllocBytes
	void* mLastAllocation; //Last allocation via AllocBytes
	void* mLastAllocationBlock;

	UInt8* AllocBytes(UIntP bytes);
	void   RelinquishBytes(UIntP bytes);
	
private:
	std::vector<iovec> mChunksToWrite;
	void Init();
	void CheckPlaceholder(UIntP p) {
		O3Assert(!mChunksToWrite[p].iov_len, @"An attempt was made to write twice to placeholder %l.", (long)p);
	}

public:
	O3NonlinearWriter();
	~O3NonlinearWriter();
	
	UIntP ReservePlaceholder();
	template <typename IntegerType>	   UIntP WriteIntAsBytesAtPlaceholder(IntegerType value, int bytes, UIntP p);
	template <typename UIntegerType>   UIntP WriteUIntAsBytesAtPlaceholder(UIntegerType value, int bytes, UIntP p);
	template <typename IntegerType>	   UIntP WriteCIntAtPlaceholder(IntegerType value, UIntP p);
	template <typename UIntegerType>   UIntP WriteUCIntAtPlaceholder(UIntegerType value, UIntP p);
	UIntP WriteByteAtPlaceholder(UInt8 byte, UIntP p);
	UIntP WriteFloatAtPlaceholder(float value, UIntP p);
	UIntP WriteDoubleAtPlaceholder(double value, UIntP p);
	UIntP WriteCCStringAtPlaceholder(const char* str, UIntP p);
	UIntP WriteCCStringAtPlaceholder(NSString* str, UIntP p, O3CCSTableType tabletype = O3CCSStringTable);
	UIntP WriteDataAtPlaceholder(NSData* dat, UIntP p);
	UIntP WriteBytesAtPlaceholder(const void* bytes, UIntP len, UIntP p, BOOL freeWhenDone = NO);
	UIntP WriteChildrenHeaderAtPlaceholder(std::vector<O3ChildEnt>* children, UIntP p, NSDictionary* kt=nil, NSDictionary* ct=nil);
	UIntP WriteTypedObjectHeaderAtPlaceholder(NSString* className, UIntP size, enum O3PkgType type, UIntP placeholder);
	UIntP WriteStringArrayAtPlaceholder(const std::vector<std::string>& strings, UIntP placeholder);
	
	UIntP BytesWrittenInPlaceholderRange(IntP start, IntP length);
	UIntP BytesWrittenAfterPlaceholder(IntP p) {return BytesWrittenInPlaceholderRange(p+1, LastPlaceholder()-p);}
	IntP LastPlaceholder(); //-1 if no placeholders
	
	NSData* Data();
	void WriteToFileDescriptor(int descriptor);
	
	#ifdef O3DEBUG
	BOOL mDebug;
	#endif
};

template <typename IntegerType>
	UIntP O3NonlinearWriter::WriteIntAsBytesAtPlaceholder(IntegerType value, int bytes, UIntP p) {
		O3NonlinearWriterDebugLog(@"WriteIntAsBytesAtPlaceholder(%s0x%qX==%qi, %i)", (value<0)?"-":"", (Int64)value, (Int64)value, bytes);
		UInt8* wb = AllocBytes(bytes);
		O3WriteIntAsBytes(wb, value, bytes);
		WriteBytesAtPlaceholder(wb, bytes, p, NO);
		return bytes;
	}

template <typename UIntegerType>
	UIntP O3NonlinearWriter::WriteUIntAsBytesAtPlaceholder(UIntegerType value, int bytes, UIntP p) {
		O3NonlinearWriterDebugLog(@"WriteUIntAsBytesAtPlaceholder(0x%qX==%i, %i)", (UInt64)value, (UInt64)value, bytes);
		UInt8* wb = AllocBytes(bytes);
		O3WriteUIntAsBytes(wb, value, bytes);
		WriteBytesAtPlaceholder(wb, bytes, p, NO);
		return bytes;
	}

template <typename IntegerType>
	UIntP O3NonlinearWriter::WriteCIntAtPlaceholder(IntegerType value, UIntP p) {
		O3NonlinearWriterDebugLog(@"WriteCIntAtPlaceholder(%s0x%qX==%qi)", (value<0)?"-":"", (UInt64)value, (Int64)value);
		int maxbytes = sizeof(value)+1+sizeof(value)/7;
		UInt8* bytes = AllocBytes(maxbytes);
		int usedbytes = O3WriteCInt(bytes, value);
		RelinquishBytes(maxbytes-usedbytes);
		WriteBytesAtPlaceholder(bytes, usedbytes, p, NO);
		return usedbytes;
	}

template <typename UIntegerType>
	UIntP O3NonlinearWriter::WriteUCIntAtPlaceholder(UIntegerType value, UIntP p) {
		O3NonlinearWriterDebugLog(@"WriteCIntAtPlaceholder(%s0x%qX==%qi)", (value<0)?"-":"", (UInt64)value, (Int64)value);
		int maxbytes = sizeof(value)+1+sizeof(value)/7;
		UInt8* bytes = AllocBytes(maxbytes);
		int usedbytes = O3WriteUCInt(bytes, value);
		RelinquishBytes(maxbytes-usedbytes);
		WriteBytesAtPlaceholder(bytes, usedbytes, p, NO);
		return usedbytes;
	}
#endif /*defined(__cplusplus)*/