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
#import "O3CompoundStructType.h"
#import "O3VertexFormats.h"

@implementation O3StructArray

inline UIntP countP(O3StructArray* self) {
	if (!self->mData || !self->mStructSize) return 0;
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

- (O3StructArray*)initWithTypeNamed:(NSString*)name rawData:(NSData*)dat {
	O3StructType* t = O3StructTypeForName(name);
	return [self initWithType:t rawData:dat];
}

- (O3StructArray*)initWithType:(O3StructType*)type rawDataNoCopy:(NSMutableData*)dat {
	O3SuperInitOrDie(); initP(self);
	[self setStructType:type];
	[self setRawDataNoCopy:dat];
	return self;
}

- (O3StructArray*)initWithType:(O3StructType*)type portableData:(NSData*)dat {
	O3SuperInitOrDie(); initP(self);
	[self setStructType:type];
	[self setPortableData:dat];
	return self;
}

- (O3StructArray*)initByCompoundingArrays:(O3StructArray*)arr,... {
	va_list arrs;
	O3StructArray* a;
	NSMutableArray* types = [[NSMutableArray alloc] init];
	UIntP stride = 0;
	UIntP firstCount = [arr count];
	va_start(arrs,arr);
	while (a=va_arg(arrs,O3StructArray*)) {
		O3StructType* t = [a structType];
		if ([a count]!=firstCount) {
			[NSException raise:NSInvalidArgumentException format:@"During initByCompoundingArrays:%@... array %@ had count != the count of the others (%@)", types, a, [a count], firstCount];
			[self release];
			return nil;
		}
		stride += [t structSize];
		[types addObject:t];
	}
	va_end(arrs);
	O3CompoundStructType* cst = [[O3CompoundStructType alloc] initWithName:nil types:types];
	NSMutableData* mdat = [[NSMutableData alloc] initWithLength:stride*firstCount];
	
	//copy in the data
	if (![self initWithType:cst rawDataNoCopy:mdat]) return nil;
	[mdat release];
	[cst release];
	[types release];
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

- (void)setRawDataNoCopy:(NSMutableData*)newData {
	if ([newData length]%mStructSize) {
		[self release];
		O3LogWarn(@"The data a %@ was going to be initialized with (%@) was not a multiple of that struct type's length.", mStructType, newData);
		return;
	}
	O3Assign(newData, mData);
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
	NSData* dat = [mStructType deportabalizeStructs:pdat];
	const void* cbytes = [dat bytes];
	UIntP dplen = [dat length];
	void* b = malloc(100); free(b);
	void* tbytes = malloc(dplen);
	memcpy(tbytes,cbytes,dplen);
	NSMutableData* newbuf = [[NSMutableData alloc] initWithBytesNoCopy:tbytes length:dplen freeWhenDone:YES];
	O3Assign(newbuf, mData);
	[newbuf release];
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

- (void)getRawData:(out NSData**)dat
              type:(out O3StructType**)type
            format:(out GLenum*)format
        components:(out GLsizeiptr*)components
            offset:(out GLint*)offset
            stride:(out GLint*)stride
            normed:(out GLboolean*)normed
    vertsPerStruct:(out int*)vps
           forType:(in O3VertexDataType)ftype {
	if (dat) *dat = mData;
	if (type) *type = mStructType;
	[mStructType getFormat:format
                components:components
                    offset:offset
                    stride:stride
                    normed:normed
            vertsPerStruct:vps
                   forType:ftype];
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
	NSDictionary* ret = [mStructType objectWithBytes:mScratchBuffer];
	[mAccessLock unlock];
	return ret;
}

- (O3StructArray*)sortedArrayUsingFunction:(O3StructArrayComparator)comp context:(void*)c {
	O3StructArray* r = [self mutableCopy];
	typedef int(*O3CocoaCompT)(id,id,void*);
	[r sortUsingFunction:(O3CocoaCompT)comp context:c];
	return [r autorelease];
}

#define CHUNK_SIZE 16
#define STRT_AT_IDX(byteptr,i) (byteptr+strsize*(i))
#define COPY_IDX(srcb,src,dstb,dest) memcpy(STRT_AT_IDX(dstb,dest),STRT_AT_IDX(srcb,src),strsize)

static UInt8* mergeSortH(UInt8* bytes,UInt8* scratch,UIntP strsize,void* ctx,O3StructArrayComparator comp, UIntP loc, UIntP len) {
	if (len<=CHUNK_SIZE) {
		UInt8* lc = (UInt8*)malloc(CHUNK_SIZE*strsize);
		memcpy(lc,bytes,CHUNK_SIZE*strsize);
		UIntP b, a = 0;                                                               
		UIntP end = a+len;                                                              
		for (; a<end; a++)                                                              
			for (b=a+1; b<end; b++)                                                     
				if (comp(STRT_AT_IDX(lc,a),STRT_AT_IDX(lc,b),ctx)==NSOrderedDescending) {
					COPY_IDX(lc,a,scratch,0);
					COPY_IDX(lc,b,lc,a);
					COPY_IDX(scratch,0,lc,b);
				}
				                                                                    
		//int i; for (i=0; i<len-1; i++) O3Asrt(comp(STRT_AT_IDX(lc,i),STRT_AT_IDX(lc,i+1),ctx)!=NSOrderedDescending);
		return lc;
	} else {
		UIntP hlen = len>>1;
		UIntP a=0, b=0;
		UIntP aa=hlen;
		UIntP bb=len-hlen;
		UInt8* la = mergeSortH(bytes,scratch,strsize,ctx,comp, a, aa);
		UInt8* lb = mergeSortH(bytes,scratch,strsize,ctx,comp, b, bb);
		UInt8* lc = (UInt8*)malloc(len*strsize);
		UIntP i; for(i=0; i<len; i++) {
			int order = comp(STRT_AT_IDX(la,a),STRT_AT_IDX(lb,b),ctx);
			BOOL left_is_less = (order==NSOrderedAscending);
			if (a==aa) {
				memcpy(STRT_AT_IDX(lc,i), STRT_AT_IDX(lb,b), strsize*(len-i));
				break;
			}
			if (b==bb) {
				memcpy(STRT_AT_IDX(lc,i), STRT_AT_IDX(la,a), strsize*(len-i));
				break;
			}
			if (left_is_less) COPY_IDX(la,a++, lc,i);
			else              COPY_IDX(lb,b++, lc,i);
		}
		//for (i=0; i<len-1; i++) O3Asrt(comp(STRT_AT_IDX(lc,i),STRT_AT_IDX(lc,i+1),ctx)!=NSOrderedDescending);
		free(la);
		free(lb);
		return lc;
	}
}

///Pass nil for the comparator to use the default
- (void)sortUsingFunction:(O3StructArrayComparator)comp context:(void*)ctx {
	if (!comp) comp = [mStructType defaultComparator];
	O3AssertArg(comp, @"Must have comparator function, or struct type must be able to provide a default one.");
	UInt8* bytes = (UInt8*)[mData mutableBytes];
	UIntP strsize = mStructSize;
	UIntP len = [mData length];
	UIntP count = len / strsize;
	UInt8* scratch = (UInt8*)malloc(strsize);
	
	UInt8* newbuf = mergeSortH(bytes,scratch,strsize,ctx,comp, 0, count);

	[mData relinquishBytes];
	free(scratch);
	O3Assign([NSMutableData dataWithBytesNoCopy:newbuf length:len freeWhenDone:YES],mData);	
}

- (void)sort {
	[self sortUsingFunction:nil context:nil];
}


/************************************/ #pragma mark NSMutableArray /************************************/
- (void)insertObject:(NSDictionary*)obj atIndex:(UIntP)idx {
	[mAccessLock lock];
	O3Assert(idx<=countP(self), @"Index %i for insertion out of array %@ bounds (%i)", idx, self, countP(self));
	[mStructType writeObject:obj toBytes:mScratchBuffer];
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
	[mStructType writeObject:obj toBytes:mScratchBuffer];
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
	[mStructType writeObject:obj toBytes:mScratchBuffer];
	[mData replaceBytesInRange:rangeOfIdx(self, idx) withBytes:mScratchBuffer length:mStructSize];
	[mAccessLock unlock];	
}


@end
