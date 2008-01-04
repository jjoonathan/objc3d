//
//  O3StructArray.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
@class O3StructType;

@interface O3StructArray : NSMutableArray {
	O3StructType* mStructType;
	NSMutableData* mData;
	UIntP mStructSize;
	NSLock* mAccessLock;
	void* mScratchBuffer;
}
//Init
- (O3StructArray*)initWithType:(O3StructType*)type;
- (O3StructArray*)initWithType:(O3StructType*)type rawData:(NSData*)dat;
- (O3StructArray*)initWithType:(O3StructType*)type rawDataNoCopy:(NSMutableData*)dat;
- (O3StructArray*)initWithType:(O3StructType*)type portableData:(NSData*)dat;
- (O3StructArray*)initWithType:(O3StructType*)type capacity:(UIntP)countGuess;
- (O3StructArray*)initWithTypeNamed:(NSString*)name;
- (O3StructArray*)initByCompoundingArrays:(O3StructArray*)arr,...;

//Access
- (O3StructType*)structType; ///<The type of structure contained in the receiver
- (BOOL)setStructType:(O3StructType*)structType; ///<Tries to convert the receiver's contents to structType. Returns YES on success and NO on failure.
- (NSMutableData*)rawData; ///<Access the data that backs the receiver
- (void)setRawData:(NSData*)newData; ///<Change the data that backs the receiver
- (void)setRawDataNoCopy:(NSMutableData*)newData;
- (NSData*)portableData; ///<Converts the receiver to its portable representation and returns it
- (void)setPortableData:(NSData*)pdat; ///<Sets the receiver's contents with a portable representation

//C interface
- (NSData*)structAtIndex:(UIntP)idx;
- (void)getStruct:(void*)bytes atIndex:(UIntP)idx;
- (void)setStruct:(const void*)bytes atIndex:(UIntP)idx;
- (void)addStruct:(const void*)bytes;
- (void*)cPtr; ///<Returns a C pointer that can be used as a regular C array (after casting). Returns nil for GPU data (call rawData -bytes and -relinquishBytes manually)

//NSArray
- (UIntP)count;
- (NSDictionary*)objectAtIndex:(UIntP)idx; ///Returns a copy of the objet ad idx, not the object itself (for performance reasons, especially when dealing with O3GPUData)

//NSMutableArray
- (void)insertObject:(NSDictionary*)obj atIndex:(UIntP)idx;
- (void)removeObjectAtIndex:(UIntP)idx;
- (void)addObject:(NSDictionary*)obj;
- (void)removeLastObject;
- (void)replaceObjectAtIndex:(UIntP)idx withObject:(NSDictionary*)obj;

//GPU
- (void)uploadToGPU; //Converts data to O3GPUData, uploading it to the GPU (if necessary)
@end

typedef O3StructArray O3MutableStructArray;