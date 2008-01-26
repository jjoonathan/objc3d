//
//  O3ScalarStructType.m
//  ObjC3D
//
//  Created by Jonathan deWerd on 1/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import "O3ScalarStructType.h"
#import "O3GPUData.h"

#define DefType(NAME,TYPE,SNAME,CTYPE) O3ScalarStructType* g ## NAME; O3ScalarStructType* NAME () {return g ## NAME;}
O3ScalarStructTypeDefines
#undef DefType

#define DefType(NAME,TYPE,SNAME,CTYPE) int NAME ## Comparator (const void* a, const void* b, void* ctx) {CTYPE aa=*(CTYPE*)a; CTYPE bb=*(CTYPE*)b; if (aa<bb) return NSOrderedAscending; if (aa>bb) return NSOrderedDescending; return NSOrderedSame;}
O3ScalarStructTypeDefines
#undef DefType

@implementation O3ScalarStructType
O3DefaultO3InitializeImplementation

+ (void)o3init {
	#define DefType(NAME,TYPE,SNAME,CTYPE) g ## NAME = [O3ScalarStructType scalarTypeWithElementType: TYPE name: SNAME];
	O3ScalarStructTypeDefines
	#undef DefType
}

+ (O3ScalarStructType*)scalarTypeWithElementType:(O3CType)type name:(NSString*)name {
	O3ScalarStructType* ret = [[O3ScalarStructType alloc] initWithName:name];
	ret->mType = type;
	return ret;
}

+ (O3ScalarStructType*)scalarTypeWithCType:(O3CType)t {
	switch (t) {
		#define DefType(NAME,TYPE,SNAME,CTYPE) case TYPE: return g ## NAME;
		O3ScalarStructTypeDefines
		#undef DefType
	}
	return nil;
}

/************************************/ #pragma mark O3StructType /************************************/
- (UIntP)structSize {return O3CTypeSize(mType);}

- (O3CType)type {return mType;}

- (id)objectWithBytes:(const void*)bytes {
	return O3CTypeNSValue(mType, bytes);
}

- (void)writeObject:(id)dict toBytes:(void*)bytes {
	O3CTypeSetNSValue(mType, bytes, dict);
}

- (NSData*)portabalizeStructsAt:(const void*)at count:(UIntP)count stride:(UIntP)s {
	UIntP strSize = [self structSize];
	if (!s) s = strSize;
	if (!O3NeedByteswapToLittle && s==strSize) return [NSData dataWithBytesNoCopy:(void*)at length:strSize*count freeWhenDone:NO];
	O3RawData rd = O3CTypePortabalize(mType, at, s, 1, count);
	if (!rd.length) return nil;
	return [NSMutableData dataWithBytesNoCopy:rd.bytes length:rd.length freeWhenDone:YES];
}

- (NSData*)deportabalizeStructs:(NSData*)indata to:(void*)target stride:(UIntP)s {
	if (!target && !O3NeedByteswapToLittle) return indata;
	if (!s) s = [self structSize];
	O3RawData rd = O3CTypeDeportabalize(mType, [indata bytes], target, s, [indata length]/s, 1);
	if (!rd.length) return nil;
	return [NSMutableData dataWithBytesNoCopy:rd.bytes length:rd.length freeWhenDone:YES];
}

- (NSMutableData*)translateStructs:(NSData*)instructs stride:(UIntP)in_stride toFormat:(O3StructType*)oformat {
	BOOL other_is_vec = [oformat isKindOfClass:[O3VecStructType class]];
	BOOL other_is_scalar = [oformat isKindOfClass:[self class]];
	if (!(other_is_vec ^ other_is_scalar)) return nil;
	
	in_stride = in_stride ?: [self structSize];
	UIntP incount = [instructs length]/in_stride;
	UIntP outelements = other_is_scalar? 1 : [(O3VecStructType*)oformat elementCount];
	UIntP outstride = [oformat structSize];
	UIntP out_ele_stride = outstride / outelements;
	if (other_is_vec) O3Asrt(outelements && !(incount%outelements));
	
	const UInt8* inbytes = (const UInt8*)[instructs bytes];
	NSMutableData* mdat = [[[NSMutableData alloc] initWithLength:outstride*incount] autorelease];
	UInt8* tbytes = (UInt8*)[mdat mutableBytes];
	O3CType otype = other_is_scalar? [(O3ScalarStructType*)oformat type] : [(O3VecStructType*)oformat elementType];
	
	O3CTypeTranslateFrom_at_stride_to_at_stride_count_(mType, inbytes, in_stride, otype, tbytes, out_ele_stride, incount);
	
	[instructs relinquishBytes];
	return mdat;
}


/************************************/ #pragma mark GL /************************************/
- (void)getFormat:(out GLenum*)format components:(out GLsizeiptr*)components offset:(out GLint*)offset stride:(out GLint*)stride normed:(out GLboolean*)normed vertsPerStruct:(out int*)vps forType:(in O3VertexDataType)type {
	if (format) *format = O3CTypeGLType(mType);
	if (components) *components = 1;
	if (offset) *offset = 0;
	if (stride) *stride = O3CTypeSize(mType);
	if (normed) *normed = GL_FALSE;
	if (vps) *vps = 0; //Perhaps implement fractions
}

- (O3StructArrayComparator)defaultComparator {
	switch (mType) {
		#define DefType(NAME,TYPE,SNAME,CTYPE) case TYPE:  return NAME ## Comparator;
		O3ScalarStructTypeDefines
		#undef DefType
	}
	O3Asrt(NO);
	return nil;
}

@end
