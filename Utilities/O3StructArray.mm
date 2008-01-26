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
#import "O3ScalarStructType.h"

@implementation O3StructArray
O3DefaultO3InitializeImplementation

inline UIntP countP(O3StructArray* self) {
	if (!self->mData || !self->mStructSize) return 0;
	return [self->mData length] / self->mStructSize;
}

inline NSRange rangeOfIdx(O3StructArray* self, UIntP idx) {
	return NSMakeRange(self->mStructSize*idx, self->mStructSize);
}

inline void O3StructArrayLock(O3StructArray* self) {
	[self->mAccessLock lock];
}

inline void O3StructArrayUnlock(O3StructArray* self) {
	[self->mAccessLock unlock];
}

/************************************/ #pragma mark Init /************************************/
void initP(O3StructArray* self) {
	self->mAccessLock = [[NSRecursiveLock alloc] init];
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

- (id)copyWithZone:(NSZone*)z {
	return [[[self class] alloc] initWithType:mStructType rawData:mData];
}

- (id)mutableCopyWithZone:(NSZone*)z {
	return [[[self class] alloc] initWithType:mStructType rawData:mData];
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
	O3Asrt(structType!=nil);
	if (structType==mStructType) return YES;
	O3StructArrayLock(self);
	O3Assert(structType, @"Cannot change structure type from %@ to nil", mStructType);
	UIntP newStructSize = [structType structSize];
	if (mStructType&&mData) {
		NSMutableData* newData = [mStructType translateStructs:mData stride:0 toFormat:structType];
		if (!newData) {
			O3StructArrayUnlock(self);
			return NO;
		}
		O3Assign(newData, mData);
	}
	O3Assign(structType, mStructType);
	mStructSize = newStructSize;
	if (mScratchBuffer) free(mScratchBuffer);
	mScratchBuffer = malloc(newStructSize);
	O3StructArrayUnlock(self);
	return YES;
}

- (BOOL)setStructTypeName:(NSString*)newTypeName {
	if (!newTypeName) return NO;
	O3StructType* t = O3StructTypeForName(newTypeName);
	O3Assert(t,@"Couldn't find struct type named %@. Names: %@",newTypeName,[[O3StructTypeDict() allKeys] componentsJoinedByString:@", "]);
	return [self setStructType:t];
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

- (id)lowestValue {
	O3StructArrayLock(self);
	const void* str = nil;
	UIntP ct = [self count];
	[mStructType getLowest:&str highest:nil ofStructsAt:[mData bytes] stride:0 count:ct];
	id obj = str? [mStructType objectWithBytes:str] : nil;
	[mData relinquishBytes];
	O3StructArrayUnlock(self);
	return obj;
}

- (id)highestValue {
	O3StructArrayLock(self);
	const void* str = nil;
	UIntP ct = [self count];
	[mStructType getLowest:nil highest:&str ofStructsAt:[mData bytes] stride:0 count:ct];
	id obj = str? [mStructType objectWithBytes:str] : nil;
	[mData relinquishBytes];
	O3StructArrayUnlock(self);
	return obj;	
}

/************************************/ #pragma mark NSArray methods /************************************/
- (UIntP)count {
	return countP(self);
}

- (NSDictionary*)objectAtIndex:(UIntP)idx {
	O3StructArrayLock(self);
	if (idx>=countP(self)) {
		O3StructArrayUnlock(self);
		[NSException raise:NSRangeException format:@"Index %i out of array %@ bounds (%i)", idx, self, countP(self)];
	}
	[mData getBytes:mScratchBuffer range:rangeOfIdx(self, idx)];
	NSDictionary* ret = [mStructType objectWithBytes:mScratchBuffer];
	O3StructArrayUnlock(self);
	return ret;
}

- (O3StructArray*)sortedArrayUsingFunction:(O3StructArrayComparator)comp context:(void*)c {
	O3StructArray* r = [self mutableCopy];
	typedef int(*O3CocoaCompT)(id,id,void*);
	[r sortUsingFunction:(O3CocoaCompT)comp context:c];
	return [r autorelease];
}

#define CHUNK_SIZE 16
#define STRT_AT_IDX(i) (info->bytes+info->strsize*(i))

typedef struct {
	const UInt8* bytes;
	UInt8* scratch;
	UIntP strsize;
	void* ctx;
	O3StructArrayComparator comp;
	BOOL check_sort;
} merge_sort_info_t;

static UIntP* mergeSortH(const merge_sort_info_t* info, UIntP loc, UIntP len) {
	O3StructArrayComparator comp = info->comp;	
	if (len<=CHUNK_SIZE) {
		UIntP* idxs = (UIntP*)malloc(sizeof(UIntP)*len);
		UIntP i; for (i=0; i<len; i++) idxs[i] = loc+i;
		UIntP a=0,b=0;                                                      
		for (a=0; a<len; a++)                                                              
			for (b=a+1; b<len; b++) {
				if (comp(STRT_AT_IDX(idxs[a]),STRT_AT_IDX(idxs[b]),info->ctx)==NSOrderedDescending)
					O3Swap(idxs[a],idxs[b]);
			}
				                                                                    
		if (info->check_sort) for (i=0; i<len-1; i++) O3Asrt(comp(STRT_AT_IDX(idxs[i]),STRT_AT_IDX(idxs[i+1]),info->ctx)!=NSOrderedDescending);
		return idxs;
	} else {
		UIntP hlen = len>>1;
		UIntP aa=hlen;
		UIntP bb=len-hlen; //loc aa bb
		UIntP* la = mergeSortH(info, loc, aa);
		UIntP* lb = mergeSortH(info, loc+hlen, bb);
		UIntP* idxs = (UIntP*)malloc(len*sizeof(UIntP));
		UIntP a=0, b=0;
		UIntP i; for(i=0; i<len; i++) {
			if (a==aa) {
				for (; i<len; i++) idxs[i] = lb[b++];
				break;
			}
			if (b==bb) {
				for (; i<len; i++) idxs[i] = la[a++];
				break;
			}
			int order = comp(STRT_AT_IDX(la[a]),STRT_AT_IDX(lb[b]),info->ctx);
			BOOL left_is_less = (order==NSOrderedAscending);
			idxs[i] = left_is_less? la[a++] : lb[b++];
		}
		if (info->check_sort) for (i=0; i<len-1; i++) O3Asrt(comp(STRT_AT_IDX(idxs[i]),STRT_AT_IDX(idxs[i+1]),info->ctx)!=NSOrderedDescending);
		free(la);
		free(lb);
		return idxs;
	}
}

- (UIntP*)sortedIndexesWithFunction:(O3StructArrayComparator)comp context:(void*)ctx {
	O3StructArrayLock(self);
	if (!comp) comp = [mStructType defaultComparator];
	O3AssertArg(comp, @"Must have comparator function, or struct type must be able to provide a default one.");
	merge_sort_info_t info;
	info.bytes = (const UInt8*)[mData bytes];
	info.strsize = mStructSize;
	UIntP len = [mData length];
	UIntP count = len / info.strsize;
	info.scratch = (UInt8*)malloc(info.strsize);
	info.comp = comp;
	info.ctx = ctx;
	info.check_sort = mCheckSort;
	
	UIntP* idxs = mergeSortH(&info, 0, count);
	
	[mData relinquishBytes];
	O3StructArrayUnlock(self);
	free(info.scratch);
	return idxs;
}

///Pass nil for the comparator to use the default
- (void)sortUsingFunction:(O3StructArrayComparator)comp context:(void*)ctx {
	UIntP* idxs = [self sortedIndexesWithFunction:comp context:ctx];
	O3StructArrayLock(self);
	UIntP len = [mData length];
	UIntP count = len / mStructSize;
	UInt8* newbuf = (UInt8*)malloc(mStructSize*count);
	const UInt8* bytes = (const UInt8*)[mData bytes];
	UIntP i; for (i=0; i<count; i++) {
		const UInt8* src = bytes + mStructSize*idxs[i];
		UInt8* dst = newbuf+i*mStructSize;
		memcpy(dst, src, mStructSize);
	}

	[mData relinquishBytes];
	O3StructArrayUnlock(self);
	free(idxs);
	O3Assign([NSMutableData dataWithBytesNoCopy:newbuf length:len freeWhenDone:YES],mData);	
}

- (void)mergeSort {
	[self sortUsingFunction:nil context:nil];
}

- (O3CType)compressIntegerType {
	Int64 l = [[self lowestValue] longLongValue];
	Int64 h = [[self highestValue] longLongValue];
	return [self setTypeToIntWithMaximum:h isSigned:l<0];
}

- (O3StructArray*)uniqueify {return [self uniqueifyWithComparator:nil context:nil];}
- (O3StructArray*)uniqueifyWithComparator:(O3StructArrayComparator)comp context:(void*)ctx {
	O3StructArrayLock(self);
	comp = comp ?: [mStructType defaultComparator]; O3Asrt(comp);
	UIntP* old_idxs = [self sortedIndexesWithFunction:comp context:ctx];
	#define STR_AT_IDX(i) (old_data+old_idxs[i]*mStructSize)
	const UInt8* old_data = (const UInt8*)[mData bytes];
	UIntP old_len = [mData length];
	UIntP old_count = old_len / mStructSize;
	UIntP new_count = 1;
	for (UIntP i=1; i<old_count; i++) {
		const UInt8* s2 = STR_AT_IDX(i);
		const UInt8* s1 = STR_AT_IDX(i-1);
		int c = comp(s1, s2, ctx);
		if (c!=NSOrderedSame) new_count++;
	}
	UInt8* new_buffer = (UInt8*)malloc(new_count*mStructSize);
	UIntP* new_indexes = (UIntP*)malloc(sizeof(UIntP)*old_count);
	UIntP idx = 0;
	new_indexes[0] = idx;
	memcpy(new_buffer+(idx++)*mStructSize, STR_AT_IDX(0), mStructSize);
	for (UIntP i=1; i<old_count; i++) {
		const UInt8* s2 = STR_AT_IDX(i);
		const UInt8* s1 = STR_AT_IDX(i-1);
		int c = comp(s1, s2, ctx); 
		if (c!=NSOrderedSame) {
			O3Asrt(idx<new_count);
			memcpy(new_buffer+(idx++)*mStructSize, s2, mStructSize);
		}
		new_indexes[i] = idx-1; //idx is the next index to store a struct at
	}
	UIntP* old2new = (UIntP*)malloc(sizeof(UIntP)*old_count);	
	for (UIntP i=0; i<old_count; i++) {
		UIntP low=0;
		UIntP high=new_count;
		#define NSTR_AT_IDX(i) (new_buffer+i*mStructSize)
		const UInt8* s1 = (old_data+i*mStructSize);
		while (1) {
			UIntP mid = low + ((high-low)>>1);
			const UInt8* s2 = NSTR_AT_IDX(mid);
			int c = comp(s2, s1, ctx); 
			if (c==NSOrderedSame) {
				old2new[i] = mid; break;
			} else if (c==NSOrderedAscending)
				low=mid+1;
			else
				high=mid;
			if (low>high) O3AssertFalse(@"BSearch for old idx failed");
		}
	}
	[mData relinquishBytes];
	O3Assign([NSMutableData dataWithBytesNoCopy:new_buffer length:new_count*mStructSize freeWhenDone:YES], mData);
	O3StructType* stype = nil;
	int scsize = sizeof(UIntP); //Not great, but better than @encode, which could be ambiguous on LP64
	switch (scsize) {
		case 4: stype = O3UInt32Type(); break;
		case 8: stype = O3UInt64Type(); break;
		default:
		O3Assert(false, @"Unknown struct size %i", scsize);
		return nil;
	}
	NSMutableData* rdata = [NSMutableData dataWithBytesNoCopy:old2new length:old_count*sizeof(UIntP) freeWhenDone:YES];
	O3StructArray* ret = [[O3StructArray alloc] initWithType:stype rawDataNoCopy:rdata];
	free(old_idxs);
	free(new_indexes);
	O3StructArrayUnlock(self);
	return [ret autorelease];
}
#undef STR_AT_IDX
#undef NSTR_AT_IDX

/************************************/ #pragma mark NSMutableArray /************************************/
- (void)insertObject:(NSDictionary*)obj atIndex:(UIntP)idx {
	O3StructArrayLock(self);
	O3Assert(idx<=countP(self), @"Index %i for insertion out of array %@ bounds (%i)", idx, self, countP(self));
	[mStructType writeObject:obj toBytes:mScratchBuffer];
	[mData replaceBytesInRange:rangeOfIdx(self, idx) withBytes:mScratchBuffer length:mStructSize];
	O3StructArrayUnlock(self);
}

- (void)removeObjectAtIndex:(UIntP)idx {
	O3StructArrayLock(self);
	O3Assert(idx<=countP(self), @"Index %i for insertion out of array %@ bounds (%i)", idx, self, countP(self));
	[mData replaceBytesInRange:rangeOfIdx(self, idx) withBytes:self length:0];
	O3StructArrayUnlock(self);	
}

- (void)addObject:(NSDictionary*)obj {
	O3StructArrayLock(self);
	[mStructType writeObject:obj toBytes:mScratchBuffer];
	[mData appendBytes:mScratchBuffer length:mStructSize];
	O3StructArrayUnlock(self);	
}

- (void)addObjects:(NSArray*)arr {
	O3StructArrayLock(self);
	NSEnumerator* arrEnumerator = [arr objectEnumerator];
	while (id o = [arrEnumerator nextObject]) {
		[mStructType writeObject:o toBytes:mScratchBuffer];
		[mData appendBytes:mScratchBuffer length:mStructSize];	
	}
	O3StructArrayUnlock(self);	
}

- (void)removeLastObject {
	O3StructArrayLock(self);
	UIntP oldlen = [mData length];
	O3Assert(oldlen>mStructSize, @"Attempt to remove last object from empty array %@", self);
	[mData setLength:oldlen-mStructSize];
	O3StructArrayUnlock(self);	
}

- (void)replaceObjectAtIndex:(UIntP)idx withObject:(NSDictionary*)obj {
	O3StructArrayLock(self);
	O3Assert(idx<=countP(self), @"Index %i for insertion out of array %@ bounds (%i)", idx, self, countP(self));
	[mStructType writeObject:obj toBytes:mScratchBuffer];
	[mData replaceBytesInRange:rangeOfIdx(self, idx) withBytes:mScratchBuffer length:mStructSize];
	O3StructArrayUnlock(self);	
}

- (O3CType)setTypeToIntWithMaximum:(UInt64)maxval isSigned:(BOOL)isSigned {
	O3CType newType = O3CTypeWithMaxVal(maxval, isSigned);
	[self setStructType:[O3ScalarStructType scalarTypeWithCType:newType]];
	return newType;
}


@end
