//
//  O3StructArray.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3StructArray.h"
#import "O3Struct.h"

@implementation O3MutableStructArray

inline UIntP countP(O3MutableStructArray* self) {
	O3Assert(self->mData && self->mStructSize, @"Count requested of invalid mutable struct array %X", self);
	return [self->mData length] / self->mStructSize;
}

inline NSRange rangeOfIdx(O3MutableStructArray* self, UIntP idx) {
	return NSMakeRange(self->mStructSize*idx, self->mStructSize);
}

/************************************/ #pragma mark Init /************************************/
void initP(O3MutableStructArray* self) {
	self->mAccessLock = [[NSLock alloc] init];
}

- (O3MutableStructArray*)initWithType:(O3StructType*)type {
	O3SuperInitOrDie(); initP(self);
	[self setStructType:type];
	return self;
}

- (O3MutableStructArray*)initWithType:(O3StructType*)type capacity:(UIntP)countGuess {
	O3SuperInitOrDie(); initP(self);
	[self setStructType:type];
	mData = [[NSMutableData alloc] initWithCapacity:mStructSize*countGuess];
	return self;
}

- (void)dealloc {
	[mData release];
	[mAccessLock release];
	if (mScratchBuffer) free(mScratchBuffer);
	O3SuperDealloc();
}

/************************************/ #pragma mark Access /************************************/
- (O3StructType*)structType {
	return mStructType;
}

- (BOOL)setStructType:(O3StructType*)structType {
	if (structType==mStructType) return YES;
	[mAccessLock lock];
	O3Assert(structType, @"Cannot change structure type from %@ to nil", mStructType);
	UIntP newStructSize = [structType structSize];
	if (mStructType&&mData) {
		UIntP count = countP(self);
		void* newBuffer = [mStructType translateStructsAt:[mData mutableBytes] count:count toFormat:structType];
		if (!newBuffer) {
			[mAccessLock unlock];
			return NO;
		}
		O3Assign([NSData dataWithBytesNoCopy:newBuffer length:count*newStructSize freeWhenDone:YES], mData);
	}
	O3Assign(structType, mStructType);
	mStructSize = newStructSize;
	mInstanceClass = [structType instanceClass];
	if (mScratchBuffer) free(mScratchBuffer);
	mScratchBuffer = malloc(newStructSize);
	[mAccessLock unlock];
	return YES;
}

/************************************/ #pragma mark NSArray methods /************************************/
- (UIntP)count {
	return countP(self);
}

- (O3Struct*)objectAtIndex:(UIntP)idx {
	[mAccessLock lock];
	O3AssertIvar(mInstanceClass);
	O3Assert(idx<countP(self), @"Index %i out of array %@ bounds (%i)", idx, self, countP(self));
	void* b = malloc(mStructSize);
	[mData getBytes:b range:rangeOfIdx(self, idx)];
	O3Struct* ret = [(O3Struct*)[mInstanceClass alloc] initWithBytesNoCopy:b type:mStructType freeWhenDone:YES];
	[mAccessLock unlock];
	return ret;
}

/************************************/ #pragma mark NSMutableArray /************************************/
- (void)insertObject:(O3Struct*)obj atIndex:(UIntP)idx {
	[mAccessLock lock];
	O3Assert(idx<=countP(self), @"Index %i for insertion out of array %@ bounds (%i)", idx, self, countP(self));
	[obj writeToBytes:mScratchBuffer];
	[mData replaceBytesInRange:rangeOfIdx(self, idx) withBytes:mScratchBuffer length:mStructSize];
	[mAccessLock unlock];
}

- (void)removeObjectAtIndex:(UIntP)idx {
	[mAccessLock lock];
	O3Assert(idx<=countP(self), @"Index %i for insertion out of array %@ bounds (%i)", idx, self, countP(self));
	[mData replaceBytesInRange:rangeOfIdx(self, idx) withBytes:self length:0];
	[mAccessLock unlock];	
}

- (void)addObject:(O3Struct*)obj {
	[mAccessLock lock];
	[obj writeToBytes:mScratchBuffer];
	[mData appendBytes:mScratchBuffer length:mStructSize];
	[mAccessLock unlock];	
}

- (void)removeLastObject {
	[mAccessLock lock];
	UIntP oldlen = [mData length];
	O3Assert(oldlen>mStructSize, @"Attempt to remove last object from empty array %@", self);
	[mData setLength:oldlen-mStructSize];
	[mAccessLock unlock];	
}

- (void)replaceObjectAtIndex:(UIntP)idx withObject:(O3Struct*)obj {
	[mAccessLock lock];
	O3Assert(idx<=countP(self), @"Index %i for insertion out of array %@ bounds (%i)", idx, self, countP(self));
	[obj writeToBytes:mScratchBuffer];
	[mData replaceBytesInRange:rangeOfIdx(self, idx) withBytes:mScratchBuffer length:mStructSize];
	[mAccessLock unlock];	
}


@end
