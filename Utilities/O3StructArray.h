//
//  O3StructArray.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3VertexDataSource.h"
#import "O3CTypes.h"
@class O3StructType;

@interface O3StructArray : NSMutableArray <NSCopying, NSMutableCopying, NSCoding> {
	O3StructType* mStructType;
	NSMutableData* mData;
	UIntP mStructSize;
	NSRecursiveLock* mAccessLock;
	void* mScratchBuffer;
	BOOL mCheckSort:1; ///<Debug flag to double-check that sorting worked
}
//Init
- (O3StructArray*)initWithType:(O3StructType*)type;
- (O3StructArray*)initWithType:(O3StructType*)type rawData:(NSData*)dat;
- (O3StructArray*)initWithTypeNamed:(NSString*)name rawData:(NSData*)dat;
- (O3StructArray*)initWithType:(O3StructType*)type rawDataNoCopy:(NSMutableData*)dat;
- (O3StructArray*)initWithType:(O3StructType*)type portableData:(NSData*)dat;
- (O3StructArray*)initWithType:(O3StructType*)type capacity:(UIntP)countGuess;
- (O3StructArray*)initWithTypeNamed:(NSString*)name;
- (O3StructArray*)initByCompoundingArrays:(O3StructArray*)arr,...;

//Access
- (O3StructType*)structType; ///<The type of structure contained in the receiver
- (BOOL)setStructType:(O3StructType*)structType; ///<Tries to convert the receiver's contents to structType. Returns YES on success and NO on failure.
- (BOOL)setStructTypeName:(NSString*)newTypeName; ///<Convenience caller of setStructType:
- (NSMutableData*)rawData; ///<Access the data that backs the receiver
- (void)setRawData:(NSData*)newData; ///<Change the data that backs the receiver
- (void)setRawDataNoCopy:(NSMutableData*)newData;
- (NSData*)portableData; ///<Converts the receiver to its portable representation and returns it
- (void)setPortableData:(NSData*)pdat; ///<Sets the receiver's contents with a portable representation
- (void)getRawData:(out NSData**)dat
              type:(out O3StructType**)type
            format:(out GLenum*)format
        components:(out GLsizeiptr*)components
            offset:(out GLint*)offset
            stride:(out GLint*)stride
            normed:(out GLboolean*)normed
    vertsPerStruct:(out int*)vps
           forType:(in O3VertexDataType)type;
- (id)lowestValue;
- (id)highestValue;

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

//Convenience
- (void)mergeSort; //Ruby bridge doesn't like -sort?
- (UIntP*)sortedIndexesWithFunction:(O3StructArrayComparator)comp context:(void*)ctx;
- (void)uploadToGPU; //Converts data to O3GPUData, uploading it to the GPU (if necessary)
- (O3CType)setTypeToIntWithMaximum:(UInt64)maxval isSigned:(BOOL)isSigned;

//Operations
- (O3CType)compressIntegerType; ///Sets to the smallest integer type that can hold all the receiver's values
- (O3StructArray*)uniqueifyWithComparator:(O3StructArrayComparator)comp context:(void*)ctx; ///Uniqueifys each object in the receiver with the given comparator (or the default if nil), then returns a compacted index array that would give the original order of the receiver.
@end

typedef O3StructArray O3MutableStructArray;