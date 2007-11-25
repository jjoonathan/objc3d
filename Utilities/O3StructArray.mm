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

- (O3MutableStructArray*)initWithType:(O3StructType*)type rawData:(NSData*)dat {
	O3SuperInitOrDie(); initP(self);
	[self setStructType:type];
	[self setRawData:dat];
	return self;
}

- (O3MutableStructArray*)initWithType:(O3StructType*)type portableData:(NSData*)dat {
	O3SuperInitOrDie(); initP(self);
	[self setStructType:type];
	[self setPortableData:dat];
	return self;
}


- (void)dealloc {
	[mData release];
	[mAccessLock release];
	if (mScratchBuffer) free(mScratchBuffer);
	O3SuperDealloc();
}

/************************************/ #pragma mark NSCoding /************************************/
- (id)initWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding]) {
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
		[self release];
		return nil;
	}
	return [self initWithType:O3StructTypeForName([coder decodeObjectForKey:@"type"])
	                                                           portableData:[coder decodeObjectForKey:@"data"]];
}

- (void)encodeWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding])
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
	[coder encodeObject:[self portableData] forKey:@"data"];
	[coder encodeObject:[mStructType name] forKey:@"type"];
}

/************************************/ #pragma mark GPU /************************************/
- (void)uploadToGPU {
	O3GPUData* newDat = [[O3GPUData alloc] initWithData:mData];
	O3Assign(newDat, mData);
	[newDat release];
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

- (NSMutableData*)rawData {
	return mData;
}

- (void)setRawData:(NSData*)newData {
	if ([newData length]%mStructSize) {
		[self release];
		O3LogWarn(@"The data a %@ was going to be initialized with (%@) was not a multiple of that struct type's length.", type, dat);
		return;
	}
	O3Assign([newData mutableCopy], mData);
	O3Release(mData);
}

- (NSData*)portableData {
	NSData* r = [NSMutableData dataWithBytesNoCopy:[mStructType portabalizeStructsAt:[mData bytes] count:[self count]]
	                                        length:[mData length] 
	                                  freeWhenDone:YES];
	return r;
}

- (void)setPortableData:(NSData*)pdat {
	UIntP len = [pdat length];
	if (len%mStructSize) {
		[self release];
		O3LogWarn(@"The data a %@ was going to be initialized with (%@) was not a multiple of that struct type's length.", type, dat);
		return;
	}
	void* newbuf = [mStructType deportabalizeStructsAt:[pdat bytes] count:len/mStructSize];
	O3Assign([NSMutableData dataWithBytesNoCopy:newbuf length:len freeWhenDone:YES], mData);
}


- (void)getStruct:(void*)bytes atIndex:(UIntP)idx {
	if (idx>=countP(self)) [NSException raise:NSRangeException format:@"tried to access index %i out of bounds %i",idx,countP(self)];
	[mData getBytes:bytes range:rangeOfIdx(self,idx)];
}

- (void)setStruct:(const void*)bytes atIndex:(UIntP)idx {
	if (idx>=countP(self)) [NSException raise:NSRangeException format:@"tried to access index %i out of bounds %i",idx,countP(self)];
	[mData replaceBytesInRange:rangeOfIdx(self,idx) withBytes:bytes];
}

- (void)addStruct:(const void*)bytes {
	[mData appendBytes:bytes length:mStructSize];
}

- (void*)cPtr {
	if ([mData isGPUData]) return nil;
	return [mData bytes];
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
