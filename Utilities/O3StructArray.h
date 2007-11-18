//
//  O3StructArray.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
@class O3StructType, O3Struct;

@interface O3MutableStructArray : NSMutableArray {
	O3StructType* mStructType;
	NSMutableData* mData;
	UIntP mStructSize;
	Class mInstanceClass;
	NSLock* mAccessLock;
	void* mScratchBuffer;
}
//Init
- (O3MutableStructArray*)initWithType:(O3StructType*)type;
- (O3MutableStructArray*)initWithType:(O3StructType*)type capacity:(UIntP)countGuess;

//Access
- (O3StructType*)structType; ///<The type of structure contained in the receiver
- (BOOL)setStructType:(O3StructType*)structType; ///<Tries to convert the receiver's contents to structType. Returns YES on success and NO on failure.

//NSArray
- (UIntP)count;
- (O3Struct*)objectAtIndex:(UIntP)idx; ///Returns a copy of the objet ad idx, not the object itself (for performance reasons, especially when dealing with O3GPUData)

//NSMutableArray
- (void)insertObject:(O3Struct*)obj atIndex:(UIntP)idx;
- (void)removeObjectAtIndex:(UIntP)idx;
- (void)addObject:(O3Struct*)obj;
- (void)removeLastObject;
- (void)replaceObjectAtIndex:(UIntP)idx withObject:(O3Struct*)obj;
@end

typedef O3MutableStructArray O3StructArray;