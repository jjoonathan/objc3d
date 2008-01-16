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

#define DefType(NAME,TYPE,SNAME,CTYPE) int NAME ## Comparator (void* a, void* b, void* ctx) {CTYPE aa=*(CTYPE*)a; CTYPE bb=*(CTYPE*)b; if (aa<bb) return NSOrderedAscending; if (aa>bb) return NSOrderedDescending; return NSOrderedSame;}
O3ScalarStructTypeDefines
#undef DefType


@implementation O3ScalarStructType

UIntP O3ScalarStructSize(O3ScalarStructType* type) {
	switch (type->mType) {
		case O3VecStructFloatElement:  return sizeof(float);
		case O3VecStructDoubleElement: return sizeof(double);
		case O3VecStructInt8Element:   return sizeof(Int8);
		case O3VecStructInt16Element:  return sizeof(Int16);
		case O3VecStructInt32Element:  return sizeof(Int32);
		case O3VecStructInt64Element:  return sizeof(Int64);
		case O3VecStructUInt8Element:  return sizeof(UInt8);
		case O3VecStructUInt16Element: return sizeof(UInt16);
		case O3VecStructUInt32Element: return sizeof(UInt32);
		case O3VecStructUInt64Element: return sizeof(UInt64);
	}
	O3AssertFalse(@"Unknown type \"%c\" in scalar struct %@", type->mType, type);
	return 0;
}

+ (void)o3init {
	#define DefType(NAME,TYPE,SNAME,CTYPE) g ## NAME = [O3ScalarStructType scalarTypeWithElementType: TYPE name: SNAME];
	O3ScalarStructTypeDefines
	#undef DefType
}

+ (O3ScalarStructType*)scalarTypeWithElementType:(O3VecStructElementType)type name:(NSString*)name {
	O3ScalarStructType* ret = [[O3ScalarStructType alloc] initWithName:name];
	ret->mType = type;
	return ret;
}

/************************************/ #pragma mark O3StructType /************************************/
- (UIntP)structSize {return O3ScalarStructSize(self);}

- (O3VecStructElementType)type {return mType;}

- (id)objectWithBytes:(const void*)bytes {
	#define MakeAndReturnNumber(NUM_METHOD,NUM_TYPE) return [NSNumber NUM_METHOD *(( NUM_TYPE *)bytes)];
	switch (mType) {
		case O3VecStructFloatElement:  MakeAndReturnNumber(numberWithFloat:, float);
		case O3VecStructDoubleElement: MakeAndReturnNumber(numberWithDouble:, double);
		case O3VecStructInt8Element:   MakeAndReturnNumber(numberWithInt:, Int8);
		case O3VecStructInt16Element:  MakeAndReturnNumber(numberWithInt:, Int16);
		case O3VecStructInt32Element:  MakeAndReturnNumber(numberWithInt:, Int32);
		case O3VecStructInt64Element:  MakeAndReturnNumber(numberWithLongLong:, Int64);
		case O3VecStructUInt8Element:  MakeAndReturnNumber(numberWithUnsignedInt:, UInt8);
		case O3VecStructUInt16Element: MakeAndReturnNumber(numberWithUnsignedInt:, UInt16);
		case O3VecStructUInt32Element: MakeAndReturnNumber(numberWithUnsignedInt:, UInt32);
		case O3VecStructUInt64Element: MakeAndReturnNumber(numberWithUnsignedLongLong:, UInt64);
	}
	#undef MakeAndReturnNumber
	O3AssertFalse(@"Unknown specific type");
	return nil;
}

- (void)writeObject:(id)dict toBytes:(void*)bytes {
	#define WriteNumber(NUM_METHOD,NUM_TYPE) *(( NUM_TYPE *)bytes) = [(NSNumber*)dict NUM_METHOD]; return;
	switch (mType) {
		case O3VecStructFloatElement:  WriteNumber(floatValue, float);
		case O3VecStructDoubleElement: WriteNumber(doubleValue, double);
		case O3VecStructInt8Element:   WriteNumber(intValue, Int8);
		case O3VecStructInt16Element:  WriteNumber(shortValue, Int16);
		case O3VecStructInt32Element:  WriteNumber(intValue, Int32);
		case O3VecStructInt64Element:  WriteNumber(longLongValue, Int64);
		case O3VecStructUInt8Element:  WriteNumber(unsignedIntValue, UInt8);
		case O3VecStructUInt16Element: WriteNumber(unsignedIntValue, UInt16);
		case O3VecStructUInt32Element: WriteNumber(unsignedIntValue, UInt32);
		case O3VecStructUInt64Element: WriteNumber(unsignedLongLongValue, UInt64);
	}
	#undef WriteNumber
	O3AssertFalse(@"Unknown specific type");
}

- (NSData*)portabalizeStructsAt:(const void*)at count:(UIntP)count stride:(UIntP)s {
	UIntP strSize = [self structSize];
	if (!s) s = strSize;
	if (!O3NeedByteswapToLittle && s==strSize) return [NSData dataWithBytesNoCopy:(void*)at length:strSize*count freeWhenDone:NO];
	const UInt8* fbytes = (const UInt8*)at;
	UInt8* tbytes = (UInt8*)malloc(strSize*count);
	UIntP i;
	#define SwapVal(T) for (i=0; i<count; i++) *((T*)tbytes+i)=O3ByteswapHostToLittle(*(const T*)fbytes+i); break;
	switch (mType) {
		case O3VecStructFloatElement:  SwapVal(float);
		case O3VecStructDoubleElement: SwapVal(double);
		case O3VecStructInt8Element:   SwapVal(Int8);
		case O3VecStructInt16Element:  SwapVal(Int16);
		case O3VecStructInt32Element:  SwapVal(Int32);
		case O3VecStructInt64Element:  SwapVal(Int64);
		case O3VecStructUInt8Element:  SwapVal(UInt8);
		case O3VecStructUInt16Element: SwapVal(UInt16);
		case O3VecStructUInt32Element: SwapVal(UInt32);
		case O3VecStructUInt64Element: SwapVal(UInt64);
		default: O3AssertFalse(@"Unknown type \"%c\" in scalar struct type %@", mType, self);
	}
	#undef SwapVal
	return [NSMutableData dataWithBytesNoCopy:tbytes length:strSize*count freeWhenDone:YES];
}

- (NSData*)deportabalizeStructs:(NSData*)indata to:(void*)target stride:(UIntP)s {
	if (!target && !O3NeedByteswapToLittle) return indata;
	UIntP strSize = [self structSize];
	if (!s) s = strSize;
	UIntP count = [indata length]/strSize;
	const UInt8* bytes = (const UInt8*)[indata bytes];
	BOOL had_to_malloc_target = target? NO : YES;
	UInt8* tbytes = target? (UInt8*)target : (UInt8*)malloc(s*count);
	UIntP i;
	#define SwapVal(T) for (i=0; i<count; i++) *((T*)tbytes+i)=O3ByteswapLittleToHost(*(const T*)bytes+i); break;
	switch (mType) {
		case O3VecStructFloatElement:  SwapVal(float);
		case O3VecStructDoubleElement: SwapVal(double);
		case O3VecStructInt8Element:   SwapVal(Int8);
		case O3VecStructInt16Element:  SwapVal(Int16);
		case O3VecStructInt32Element:  SwapVal(Int32);
		case O3VecStructInt64Element:  SwapVal(Int64);
		case O3VecStructUInt8Element:  SwapVal(UInt8);
		case O3VecStructUInt16Element: SwapVal(UInt16);
		case O3VecStructUInt32Element: SwapVal(UInt32);
		case O3VecStructUInt64Element: SwapVal(UInt64);
		default: O3AssertFalse(@"Unknown type \"%c\" in scalar struct type %@", mType, self);
	}
	#undef SwapVal
	return had_to_malloc_target? [NSData dataWithBytesNoCopy:tbytes length:s*count freeWhenDone:YES] : nil;
}

- (NSMutableData*)translateStructs:(NSData*)instructs stride:(UIntP)s toFormat:(O3StructType*)oformat {
	if (![oformat isKindOfClass:[self class]]) return nil;
	UIntP strSize = [self structSize];
	if (!s) s = strSize;
	UIntP count = [instructs length]/strSize;
	const UInt8* bytes = (const UInt8*)[instructs bytes];
	NSMutableData* mdat = [[[NSMutableData alloc] initWithLength:[oformat structSize]*count] autorelease];
	UInt8* tbytes = (UInt8*)[mdat mutableBytes];
	O3ScalarStructType* ot = (O3ScalarStructType*)oformat;
	O3VecStructElementType otype = [ot type];
	UIntP i;
	#define SwapVal(Tf,Tt) for (i=0; i<count; i++) *((Tt*)tbytes+i)=(*(const Tf*)bytes+i); goto fin;
	#define SwapFrom(Tf) switch (otype) {                      \
		case O3VecStructFloatElement:  SwapVal(Tf, float);     \
		case O3VecStructDoubleElement: SwapVal(Tf, double);    \
		case O3VecStructInt8Element:   SwapVal(Tf, Int8);      \
		case O3VecStructInt16Element:  SwapVal(Tf, Int16);     \
		case O3VecStructInt32Element:  SwapVal(Tf, Int32);     \
		case O3VecStructInt64Element:  SwapVal(Tf, Int64);     \
		case O3VecStructUInt8Element:  SwapVal(Tf, UInt8);     \
		case O3VecStructUInt16Element: SwapVal(Tf, UInt16);    \
		case O3VecStructUInt32Element: SwapVal(Tf, UInt32);    \
		case O3VecStructUInt64Element: SwapVal(Tf, UInt64);	   \
	}
	switch (mType) {
		case O3VecStructFloatElement:  SwapFrom(float);
		case O3VecStructDoubleElement: SwapFrom(double);
		case O3VecStructInt8Element:   SwapFrom(Int8);
		case O3VecStructInt16Element:  SwapFrom(Int16);
		case O3VecStructInt32Element:  SwapFrom(Int32);
		case O3VecStructInt64Element:  SwapFrom(Int64);
		case O3VecStructUInt8Element:  SwapFrom(UInt8);
		case O3VecStructUInt16Element: SwapFrom(UInt16);
		case O3VecStructUInt32Element: SwapFrom(UInt32);
		case O3VecStructUInt64Element: SwapFrom(UInt64);
	}
	#undef SwapVal
	#undef SwapFrom
	O3AssertFalse(@"Unknown GL type for type \"%c\" in vec struct %@", mType, self);
	return nil;
	fin:
	[instructs relinquishBytes];
	return mdat;
}


/************************************/ #pragma mark GL /************************************/
- (void)getFormat:(out GLenum*)format components:(out GLsizeiptr*)components offset:(out GLint*)offset stride:(out GLint*)stride normed:(out GLboolean*)normed vertsPerStruct:(out int*)vps forType:(in O3VertexDataType)type {
	if (format) {
		switch (mType) {
			case O3VecStructFloatElement:  *format = GL_FLOAT;
		    case O3VecStructDoubleElement: *format = GL_DOUBLE;
		    case O3VecStructInt8Element:   *format = GL_BYTE;
		    case O3VecStructInt16Element:  *format = GL_SHORT;
		    case O3VecStructInt32Element:  *format = GL_INT;
			//case O3VecStructInt64Element:  return 0;
			case O3VecStructUInt8Element:  *format = GL_UNSIGNED_BYTE;
			case O3VecStructUInt16Element: *format = GL_UNSIGNED_SHORT;
			case O3VecStructUInt32Element: *format = GL_UNSIGNED_INT;
			//case O3VecStructUInt64Element: return 0;
		}
		O3Asrt(NO);
	}
	if (components) *components = 1;
	if (offset) *offset = 0;
	if (stride) *stride = O3ScalarStructSize(self);
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
