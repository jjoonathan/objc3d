//
//  O3StructArray.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3GPUData.h"
#import "O3StructArray.h"
#import "O3StructType.h"

@implementation O3StructArray

inline UIntP countP(O3StructArray* self) {
	O3Assert(self->mData && self->mStructSize, @"Count requested of invalid mutable struct array %X", self);
	return [self->mData length] / self->mStructSize;
}

inline NSRange rangeOfIdx(O3StructArray* self, UIntP idx) {
	return NSMakeRange(self->mStructSize*idx, self->mStructSize);
}

/************************************/ #pragma mark Init /************************************/
void initP(O3StructArray* self) {
	self->mAccessLock = [[NSLock alloc] init];
	self->mData = [[NSMutableData alloc] init];
}

- (O3StructArray*)initWithType:(O3StructType*)type {
	O3SuperInitOrDie(); initP(self);
	if (!type) {
		[self release];
		return nil;
	}
	[self setStructType:type];
	return self;
}

- (O3StructArray*)initWithTypeNamed:(NSString*)name {
	O3StructType* t = O3StructTypeForName(name);
	return [self initWithType:t];
}

- (O3StructArray*)initWithType:(O3StructType*)type capacity:(UIntP)countGuess {
	O3SuperInitOrDie(); initP(self);
	[self setStructType:type];
	mData = [[NSMutableData alloc] initWithCapacity:mStructSize*countGuess];
	return self;
}

- (O3StructArray*)initWithType:(O3StructType*)type rawData:(NSData*)dat {
	O3SuperInitOrDie(); initP(self);
	[self setStructType:type];
	[self setRawData:dat];
	return self;
}

- (O3StructArray*)initWithType:(O3StructType*)type portableData:(NSData*)dat {
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
		NSMutableData* newData = [mStructType translateStructs:mData stride:0 toFormat:structType];
		if (!newData) {
			[mAccessLock unlock];
			return NO;
		}
		O3Assign(newData, mData);
	}
	O3Assign(structType, mStructType);
	mStructSize = newStructSize;
	if (mScratchBuffer) free(mScratchBuffer);
	mScratchBuffer = malloc(newStructSize);
	[mAccessLock unlock];
	return YES;
}

- (BOOL)setStructTypeName:(NSString*)newTypeName {
	if (!newTypeName) return NO;
	return [self setStructType:O3StructTypeForName(newTypeName)];
} 

- (NSMutableData*)rawData {
	return mData;
}

- (void)setRawData:(NSData*)newData {
	if ([newData length]%mStructSize) {
		[self release];
		O3LogWarn(@"The data a %@ was going to be initialized with (%@) was not a multiple of that struct type's length.", mStructType, newData);
		return;
	}
	O3Assign([newData mutableCopy], mData);
	O3Release(mData);
}

- (NSData*)portableData {
	return [mStructType portabalizeStructs:mData];
}

- (void)setPortableData:(NSData*)pdat {
	UIntP len = [pdat length];
	if (len%mStructSize) {
		[self release];
		O3LogWarn(@"The data a %@ was going to be initialized with (%@) was not a multiple of that struct type's length.", mStructType, pdat);
		return;
	}
	void* newbuf = [mStructType deportabalizeStructs:pdat];
	O3Assign([NSMutableData dataWithBytesNoCopy:newbuf length:len freeWhenDone:YES], mData);
}

- (NSData*)structAtIndex:(UIntP)idx {
	if (idx>=countP(self)) [NSException raise:NSRangeException format:@"tried to access index %i out of bounds %i",idx,countP(self)];
	return [mData subdataWithRange:rangeOfIdx(self,idx)];
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
	return [mData mutableBytes];
}

/************************************/ #pragma mark NSArray methods /************************************/
- (UIntP)count {
	return countP(self);
}

- (NSDictionary*)objectAtIndex:(UIntP)idx {
	[mAccessLock lock];
	if (idx>=countP(self)) {
		[mAccessLock unlock];
		[NSException raise:NSRangeException format:@"Index %i out of array %@ bounds (%i)", idx, self, countP(self)];
	}
	[mData getBytes:mScratchBuffer range:rangeOfIdx(self, idx)];
	NSDictionary* ret = [mStructType dictWithBytes:mScratchBuffer];
	[mAccessLock unlock];
	return ret;
}

/************************************/ #pragma mark NSMutableArray /************************************/
- (void)insertObject:(NSDictionary*)obj atIndex:(UIntP)idx {
	[mAccessLock lock];
	O3Assert(idx<=countP(self), @"Index %i for insertion out of array %@ bounds (%i)", idx, self, countP(self));
	[mStructType writeDict:obj toBytes:mScratchBuffer];
	[mData replaceBytesInRange:rangeOfIdx(self, idx) withBytes:mScratchBuffer length:mStructSize];
	[mAccessLock unlock];
}

- (void)removeObjectAtIndex:(UIntP)idx {
	[mAccessLock lock];
	O3Assert(idx<=countP(self), @"Index %i for insertion out of array %@ bounds (%i)", idx, self, countP(self));
	[mData replaceBytesInRange:rangeOfIdx(self, idx) withBytes:self length:0];
	[mAccessLock unlock];	
}

- (void)addObject:(NSDictionary*)obj {
	[mAccessLock lock];
	[mStructType writeDict:obj toBytes:mScratchBuffer];
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

- (void)replaceObjectAtIndex:(UIntP)idx withObject:(NSDictionary*)obj {
	[mAccessLock lock];
	O3Assert(idx<=countP(self), @"Index %i for insertion out of array %@ bounds (%i)", idx, self, countP(self));
	[mStructType writeDict:obj toBytes:mScratchBuffer];
	[mData replaceBytesInRange:rangeOfIdx(self, idx) withBytes:mScratchBuffer length:mStructSize];
	[mAccessLock unlock];	
}


@end
