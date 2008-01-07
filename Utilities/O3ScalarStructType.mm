//
//  O3ScalarStructType.m
//  ObjC3D
//
//  Created by Jonathan deWerd on 1/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import "O3ScalarStructType.h"

#define DefType(NAME,TYPE,SNAME) O3ScalarStructType* g ## NAME; O3ScalarStructType* NAME () {return g ## NAME;}
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
	#define DefType(NAME,TYPE,SNAME) g ## NAME = [O3ScalarStructType scalarTypeWithElementType: TYPE name: SNAME];
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

- (NSMutableData*)portabalizeStructsAt:(const void*)at count:(UIntP)count stride:(UIntP)s {
	UIntP strSize = [self structSize];
	if (!s) s = strSize;
	NSMutableData* dat = [NSMutableData dataWithLength:strSize*count];
	const UInt8* bytes = (const UInt8*)at;
	UInt8* tbytes = (UInt8*)[dat mutableBytes];
	UIntP i;
	#define SwapVal(T) for (i=0; i<count; i++) *((T*)tbytes+i)=O3ByteswapHostToLittle(*(const T*)bytes+i); return dat;
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
	}
	#undef SwapVal
	O3AssertFalse(@"Unknown type \"%c\" in scalar struct type %@", mType, self);	
	return nil;
}

- (O3RawData)deportabalizeStructs:(NSData*)indata to:(void*)target stride:(UIntP)s {
	UIntP strSize = [self structSize];
	if (!s) s = strSize;
	UIntP count = [indata length]/strSize;
	const UInt8* bytes = (const UInt8*)[indata bytes];
	UInt8* tbytes = target? (UInt8*)target : (UInt8*)malloc(s*count);
	O3RawData ret = {tbytes,s*count};
	UIntP i;
	#define SwapVal(T) for (i=0; i<count; i++) *((T*)tbytes+i)=O3ByteswapLittleToHost(*(const T*)bytes+i); return ret;
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
	}
	#undef SwapVal
	O3AssertFalse(@"Unknown type \"%c\" in scalar struct type %@", mType, self);	
	return ret;
}

- (NSMutableData*)translateStructs:(NSData*)instructs stride:(UIntP)s toFormat:(O3StructType*)oformat {
	return nil;
}


/************************************/ #pragma mark GL /************************************/
- (GLenum)glFormatForType:(O3VertexDataType)type {
	switch (mType) {
		case O3VecStructFloatElement:  return GL_FLOAT;
		case O3VecStructDoubleElement: return GL_DOUBLE;
		case O3VecStructInt8Element:   return GL_BYTE;
		case O3VecStructInt16Element:  return GL_SHORT;
		case O3VecStructInt32Element:  return GL_INT;
		//case O3VecStructInt64Element:  return 0;
		case O3VecStructUInt8Element:  return GL_UNSIGNED_BYTE;
		case O3VecStructUInt16Element: return GL_UNSIGNED_SHORT;
		case O3VecStructUInt32Element: return GL_UNSIGNED_INT;
		//case O3VecStructUInt64Element: return 0;
	}
	O3AssertFalse(@"Unknown GL type for type \"%c\" in vec struct %@", mType, self);
	return 0;
}

- (GLint)glComponentCountForType:(O3VertexDataType)type {
	return 1;
}

- (GLsizeiptr)glOffsetForType:(O3VertexDataType)type {
	return 0;
}

- (GLsizeiptr)glStride {
	return O3ScalarStructSize(self);
}

- (GLboolean)glNormalizedForType:(O3VertexDataType)type {
	return GL_FALSE;
}

- (int)glVertsPerStruct {
	return 1;
}


@end
