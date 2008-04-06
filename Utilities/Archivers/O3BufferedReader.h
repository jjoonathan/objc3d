/**
 *  @file O3BufferedReader.h
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#pragma once
#ifdef __cplusplus
	#include <vector>
	#include <map>
	using namespace std;
	class O3BufferedReader;
#endif /*defined(__cplusplus)*/
#include "O3ArchiveFormat.h"


@protocol O3UnarchiverCallbackable
///Allows the coder specified in ReadObject(overrides, coder) to read directories (dictionaries) in a custom manner (often lazy loading). 
///@returns a new autoreleased dictionary-like (KVCable) object if you have handled the reading and have seeked past the dictionary or nil if the BufferedReader should use its default implementation (read recursively into a plain NSDictionary).
#ifdef __cplusplus
- (NSObject*)readO3ADictionaryFrom:(O3BufferedReader*)reader size:(UIntP)size;
- (NSArray*)readO3AArrayFrom:(O3BufferedReader*)reader size:(UIntP)size;
- (id)readO3AObjectOfClass:(NSString*)className from:(O3BufferedReader*)reader size:(UIntP)size;
#endif
@end 


#ifdef __cplusplus
class O3BufferedReader {
public:
	NSFileHandle* mHandle; //If NULL, data only comes from the data

//private: //only public for debug puruposes	
	unsigned mBlockSize;
	NSData* mBlockData;
	UInt8* mBlockBytes;
	UIntP mBlockBytesRemaining;
	UIntP mOffset;
	
	typedef void* (*mBlockData_bytes_t)(NSData* self, SEL cmd);
	typedef unsigned (*mBlockData_length_t)(NSData* self, SEL cmd);
	typedef NSData* (*mHandle_readDataOfLength_t)(NSFileHandle* self, SEL cmd, unsigned len);
	mBlockData_bytes_t			mBlockData_bytes;
	mBlockData_length_t			mBlockData_length;
	mHandle_readDataOfLength_t	mHandle_readDataOfLength_;
	
public:
	O3BufferedReader(NSFileHandle* handle);
	O3BufferedReader(NSData* data);
	~O3BufferedReader();
	
	void SeekToOffset(unsigned long long offset);
	unsigned long long Offset();
	BOOL IsAtEnd();
	UInt64 TotalLength();
	void Close();
	
	UInt8 ReadByte();
	Int32 ReadBytesAsInt32(int bytes=4);
	Int64 ReadBytesAsInt64(int bytes=8);
	UInt32 ReadBytesAsUInt32(int bytes=4);
	UInt64 ReadBytesAsUInt64(int bytes=8);
	Int32 ReadCIntAsInt32();
	Int64 ReadCIntAsInt64();
	UInt32 ReadUCIntAsUInt32();
	UInt64 ReadUCIntAsUInt64();
	float ReadFloat();
	double ReadDouble();
	NSString* ReadCCString(enum O3CCSTableType = O3CCSStringTable);
	void* ReadBytes(UInt64 len, UInt64 extra_bytes=0);
	void ReadBytesInto(void* b, UInt64 len);
	NSData* ReadData(UInt64 len);
	NSData* ReadDataNoCopy(UInt64 len); ///<Only works if the receiver is based on an NSData*, and the returned data will only be valid as long as the input data is alive. Use with caution.
	O3ChildEnt ReadChildEnt();
	std::vector<O3ChildEnt> ReadChildEntsOfTotalLength(UIntP len, BOOL have_keys);
	id O3BufferedReader::ReadObject(NSCoder<O3UnarchiverCallbackable>* coder, NSZone* z, O3ChildEnt& ent);
	
	NSArray* mKT; ///<The Key Table. Note that this is a public var, and the assigner is therefore also responsible for disposal.
	NSArray* mCT; ///<The ClassName Table. Note that this is a public var, and the assigner is therefore also responsible for disposal.
	NSArray* mST; ///<The String Table. Note that this is a public var, and the assigner is therefore also responsible for disposal.
		
private:	
	inline void AssertOpen() {
		O3Assert(mHandle || mBlockData, @"O3BufferedReader 0x%X has probably closed prematurely.", this);
	}
	inline void FetchNextBlockOrThrow();
	inline BOOL BytesLeft(UInt64 bytes); ///<Bytes left in the current block
	inline void Advance(UInt64 bytes); //Returns 0
	inline void Init();
};

inline void O3BufferedReader::Init() {
	mBlockBytesRemaining = 0;
	mBlockData = nil;
	mBlockSize = 10000;
	mBlockData_bytes = nil;
	mBlockData_length = nil;
	mHandle = nil;
	mHandle_readDataOfLength_ = nil;
	mKT = mST = mCT = nil;
}
#endif /*defined(__cplusplus)*/
