//
//  O3VecStructType.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3VecStructType.h"

O3EXTERN_C_BLOCK
O3VecStructType* gO3Vec3rType;   O3VecStructType* O3Vec3rType() {return gO3Vec3rType;}
O3VecStructType* gO3Vec3fType;   O3VecStructType* O3Vec3fType() {return gO3Vec3fType;}
O3VecStructType* gO3Vec3dType;   O3VecStructType* O3Vec3dType() {return gO3Vec3dType;}
O3VecStructType* gO3Vec4rType;   O3VecStructType* O3Vec4rType() {return gO3Vec4rType;}
O3VecStructType* gO3Vec4fType;   O3VecStructType* O3Vec4fType() {return gO3Vec4fType;}
O3VecStructType* gO3Vec4dType;   O3VecStructType* O3Vec4dType() {return gO3Vec4dType;}
O3VecStructType* gO3Rot3d;       O3VecStructType* O3Rot3dType()      {return gO3Rot3d;    }
//O3VecStructType* gO3Point3d;     O3VecStructType* O3Point3dType()    {return gO3Point3d;  }
O3VecStructType* gO3Point3f;     O3VecStructType* O3Point3fType()    {return gO3Point3f;  }
//O3VecStructType* gO3Point4d;     O3VecStructType* O3Point4dType()    {return gO3Point4d;  }
O3VecStructType* gO3Scale3d;     O3VecStructType* O3Scale3dType()    {return gO3Scale3d;  }
O3VecStructType* gO3Index3x8;    O3VecStructType* O3Index3x8Type()   {return gO3Index3x8; }
O3VecStructType* gO3Index3x16;   O3VecStructType* O3Index3x16Type()  {return gO3Index3x16;}
O3VecStructType* gO3Index3x32;   O3VecStructType* O3Index3x32Type()  {return gO3Index3x32;}
O3VecStructType* gO3Index3x64;   O3VecStructType* O3Index3x64Type()  {return gO3Index3x64;}
O3VecStructType* gO3Index4x8;    O3VecStructType* O3Index4x8Type()   {return gO3Index4x8; }
O3VecStructType* gO3Index4x16;   O3VecStructType* O3Index4x16Type()  {return gO3Index4x16;}
O3VecStructType* gO3Index4x32;   O3VecStructType* O3Index4x32Type()  {return gO3Index4x32;}
O3VecStructType* gO3Index4x64;   O3VecStructType* O3Index4x64Type()  {return gO3Index4x64;}
O3END_EXTERN_C_BLOCK

@implementation O3VecStructType

O3EXTERN_C_BLOCK
UIntP* O3VecStructTypePermsAndMultiplier(O3VecStructType* self, double* multiplier) {
	*multiplier = self->mMultiplier;
	return self->mPermutations;
}

void O3VecStructTypeGetType_count_specificType_(O3VecStructType* self, enum O3VecStructElementType* type, short* count, O3VecStructSpecificType* stype) {
	if (type) *type = self->mElementType;
	if (count) *count = self->mElementCount;
	if (stype) *stype = self->mSpecificType;
}

UIntP O3VecStructSize(O3VecStructType* type) {
	switch (type->mElementType) {
		case O3VecStructFloatElement:  return sizeof(float)*type->mElementCount;
		case O3VecStructDoubleElement: return sizeof(double)*type->mElementCount;
		case O3VecStructInt8Element:   return sizeof(Int8)*type->mElementCount;
		case O3VecStructInt16Element:  return sizeof(Int16)*type->mElementCount;
		case O3VecStructInt32Element:  return sizeof(Int32)*type->mElementCount;
		case O3VecStructInt64Element:  return sizeof(Int64)*type->mElementCount;
		case O3VecStructUInt8Element:  return sizeof(UInt8)*type->mElementCount;
		case O3VecStructUInt16Element: return sizeof(UInt16)*type->mElementCount;
		case O3VecStructUInt32Element: return sizeof(UInt32)*type->mElementCount;
		case O3VecStructUInt64Element: return sizeof(UInt64)*type->mElementCount;
	}
	O3AssertFalse(@"Unknown type \"%c\" in vec struct %@", type->mElementType, type);
	return 0;
}
O3END_EXTERN_C_BLOCK

/************************************/ #pragma mark Class Methods /************************************/
+ (void)load {
	O3CompileAssert(*@encode(real)=='f' || *@encode(real)=='d', @"O3VecStructType assumes that real is eather float or double");
	enum O3VecStructElementType rtype = *@encode(real)=='f'? O3VecStructFloatElement : O3VecStructDoubleElement;
	gO3Vec3rType = [[O3VecStructType alloc] initWithElementType:rtype                     specificType:O3VecStructVec count:3 name:@"vec3r"];
	gO3Vec3fType = [[O3VecStructType alloc] initWithElementType:O3VecStructFloatElement   specificType:O3VecStructVec count:3 name:@"vec3f"];
	gO3Vec3dType = [[O3VecStructType alloc] initWithElementType:O3VecStructDoubleElement  specificType:O3VecStructVec count:3 name:@"vec3d"];
	gO3Vec4rType = [[O3VecStructType alloc] initWithElementType:rtype                     specificType:O3VecStructVec count:4 name:@"vec4r"];
	gO3Vec4fType = [[O3VecStructType alloc] initWithElementType:O3VecStructFloatElement   specificType:O3VecStructVec count:4 name:@"vec4f"];
	gO3Vec4dType = [[O3VecStructType alloc] initWithElementType:O3VecStructDoubleElement  specificType:O3VecStructVec count:4 name:@"vec4d"];
	gO3Rot3d     = [[O3VecStructType alloc] initWithElementType:O3VecStructDoubleElement  specificType:O3VecStructRotation count:3 name:@"rot3d"];
	//gO3Point3d   = [[O3VecStructType alloc] initWithElementType:O3VecStructDoubleElement  specificType:O3VecStructPoint count:3 name:@"point3d"];
	gO3Point3f   = [[O3VecStructType alloc] initWithElementType:O3VecStructFloatElement   specificType:O3VecStructPoint count:3 name:@"point3f"];
	//gO3Point4d   = [[O3VecStructType alloc] initWithElementType:O3VecStructDoubleElement  specificType:O3VecStructPoint count:4 name:@"point4d"];
	gO3Scale3d   = [[O3VecStructType alloc] initWithElementType:O3VecStructDoubleElement  specificType:O3VecStructScale count:3 name:@"scale3d"];
	gO3Index3x8  = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt8Element   specificType:O3VecStructIndex count:3 name:@"scale3x8"];
	gO3Index3x16 = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt16Element  specificType:O3VecStructIndex count:3 name:@"scale3x16"];
	gO3Index3x32 = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt32Element  specificType:O3VecStructIndex count:3 name:@"scale3x32"];
	gO3Index3x64 = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt64Element  specificType:O3VecStructIndex count:3 name:@"scale3x64"];
	gO3Index4x8  = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt8Element   specificType:O3VecStructIndex count:4 name:@"scale4x8"];
	gO3Index4x16 = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt16Element  specificType:O3VecStructIndex count:4 name:@"scale4x16"];
	gO3Index4x32 = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt32Element  specificType:O3VecStructIndex count:4 name:@"scale4x32"];
	gO3Index4x64 = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt64Element  specificType:O3VecStructIndex count:4 name:@"scale4x64"];
}

+ (O3VecStructType*)vec3fType {return O3Vec3fType();}
+ (O3VecStructType*)vec3dType {return O3Vec3dType();}
+ (O3VecStructType*)vec3rType {return O3Vec3rType();}
+ (O3VecStructType*)vec4fType {return O3Vec4fType();}
+ (O3VecStructType*)vec4dType {return O3Vec4dType();}
+ (O3VecStructType*)vec4rType {return O3Vec4rType();}
+ (O3VecStructType*)rot3dType     {return O3Rot3dType();    }
//+ (O3VecStructType*)point3dType  {return O3Point3dType();  }
+ (O3VecStructType*)point3fType  {return O3Point3fType();  }
//+ (O3VecStructType*)point4dType  {return O3Point4dType();  }
+ (O3VecStructType*)scale3dType   {return O3Scale3dType();  }
+ (O3VecStructType*)index3x8Type  {return O3Index3x8Type(); }
+ (O3VecStructType*)index3x16Type {return O3Index3x16Type();}
+ (O3VecStructType*)index3x32Type {return O3Index3x32Type();}
+ (O3VecStructType*)index3x64Type {return O3Index3x64Type();}
+ (O3VecStructType*)index4x8Type  {return O3Index4x8Type(); }
+ (O3VecStructType*)index4x16Type {return O3Index4x16Type();}
+ (O3VecStructType*)index4x32Type {return O3Index4x32Type();}
+ (O3VecStructType*)index4x64Type {return O3Index4x64Type();}

///@returns a new autoreleased vector 
+ (O3VecStructType*)vecStructTypeWithElementType:(enum O3VecStructElementType)type
                                    specificType:(enum O3VecStructSpecificType)stype
                                           count:(int)count
                                            name:(NSString*)name {
	O3StructType* existingType = name? O3StructTypeForName(name) : nil;
	if (existingType) return (O3VecStructType*)existingType;
	return [[[self alloc] initWithElementType:type specificType:stype count:count name:name] autorelease];
}

/************************************/ #pragma mark Init /************************************/
- (O3VecStructType*)initWithElementType:(enum O3VecStructElementType)type specificType:(O3VecStructSpecificType)stype count:(int)count name:(NSString*)name {
	[super initWithName:name];
	mMultiplier = 1;
	mElementType = type;
	mElementCount = count;
	mSpecificType = stype;
	return self;
}

- (void)dealloc {
	if (mFreePermsWhenDone) free(mPermutations);
	O3SuperDealloc();
}

/************************************/ #pragma mark Custom Accessors /************************************/
- (enum O3VecStructElementType)elementType {
	return mElementType;
}

- (enum O3VecStructSpecificType)specificType {
	return mSpecificType;
}

- (short)elementCount {
	return mElementCount;
}

/************************************/ #pragma mark O3StructType /************************************/
- (UIntP)structSize {return O3VecStructSize(self);}

O3EXTERN_C NSNumber* O3VecStructGetElement(O3VecStructType* self, UIntP i, const void* bytes) {
	switch (self->mElementType) {
		case O3VecStructFloatElement: return [NSNumber numberWithFloat:*((float*)bytes+i)];
		case O3VecStructDoubleElement: return [NSNumber numberWithDouble:*((double*)bytes+i)];
		case O3VecStructInt8Element:  return [NSNumber numberWithInt:  *((Int8*)bytes+i)];
		case O3VecStructInt16Element: return [NSNumber numberWithInt:*((Int16*)bytes+i)];
		case O3VecStructInt32Element: return [NSNumber numberWithInt:*((Int32*)bytes+i)];
		case O3VecStructInt64Element: return [NSNumber numberWithLongLong:*((Int64*)bytes+i)];
		case O3VecStructUInt8Element:  return [NSNumber numberWithUnsignedInt:*((UInt8*)bytes+i)];
		case O3VecStructUInt16Element: return [NSNumber numberWithUnsignedInt:*((UInt16*)bytes+i)];
		case O3VecStructUInt32Element: return [NSNumber numberWithUnsignedInt:*((UInt32*)bytes+i)];
		case O3VecStructUInt64Element: return [NSNumber numberWithUnsignedLongLong:*((UInt64*)bytes+i)];
	}
	O3AssertFalse(@"Unknown type \"%c\" in vec struct %@", self->mElementType, self);
	return (NSNumber*)@"???";
}

- (NSDictionary*)dictWithBytes:(const void*)bytes {
	switch (mSpecificType) {
		case O3VecStructRotation: return [NSDictionary dictionaryWithObjectsAndKeys:O3VecStructGetElement(self, 0, bytes), @"roll", O3VecStructGetElement(self, 1, bytes), @"pitch", O3VecStructGetElement(self, 2, bytes), @"yaw", nil];
		case O3VecStructPoint:
		case O3VecStructIndex:
		case O3VecStructVec:
		case O3VecStructScale:
			if (mElementCount==2) return [NSDictionary dictionaryWithObjectsAndKeys:O3VecStructGetElement(self, 0, bytes), @"x", O3VecStructGetElement(self, 1, bytes), @"y", nil];
			if (mElementCount==3) return [NSDictionary dictionaryWithObjectsAndKeys:O3VecStructGetElement(self, 0, bytes), @"x", O3VecStructGetElement(self, 1, bytes), @"y", O3VecStructGetElement(self, 2, bytes), @"z", nil];
			if (mElementCount==4) return [NSDictionary dictionaryWithObjectsAndKeys:O3VecStructGetElement(self, 0, bytes), @"x", O3VecStructGetElement(self, 1, bytes), @"y", O3VecStructGetElement(self, 2, bytes), @"z", O3VecStructGetElement(self, 3, bytes), @"w", nil];
			O3AssertFalse(@"Unknown dimensionality for point (%i)", mElementCount);
		case O3VecStructColor:
			if (mElementCount==1) return [NSDictionary dictionaryWithObjectsAndKeys:O3VecStructGetElement(self, 0, bytes), @"r", nil];
			if (mElementCount==2) return [NSDictionary dictionaryWithObjectsAndKeys:O3VecStructGetElement(self, 0, bytes), @"r", O3VecStructGetElement(self, 1, bytes), @"g", nil];
			if (mElementCount==3) return [NSDictionary dictionaryWithObjectsAndKeys:O3VecStructGetElement(self, 0, bytes), @"r", O3VecStructGetElement(self, 1, bytes), @"g", O3VecStructGetElement(self, 2, bytes), @"b", nil];
			if (mElementCount==4) return [NSDictionary dictionaryWithObjectsAndKeys:O3VecStructGetElement(self, 0, bytes), @"r", O3VecStructGetElement(self, 1, bytes), @"g", O3VecStructGetElement(self, 2, bytes), @"b", O3VecStructGetElement(self, 3, bytes), @"a", nil];
			O3AssertFalse(@"Unknown dimensionality for point (%i)", mElementCount);
	}
	O3AssertFalse(@"Unknown specific type");
	return nil;
}

O3EXTERN_C void O3WriteNumberTo(O3VecStructElementType eleType, UIntP i, void* bytes, NSNumber* num) {
	switch (eleType) {
		case O3VecStructFloatElement: *((float*)bytes+i) = [num floatValue]; return;
		case O3VecStructDoubleElement: *((double*)bytes+i) = [num doubleValue]; return;
		case O3VecStructInt8Element:  *((Int8*)bytes+i) = [num intValue]; return;
		case O3VecStructInt16Element: *((Int16*)bytes+i) = [num shortValue]; return;
		case O3VecStructInt32Element: *((Int32*)bytes+i) = [num intValue]; return;
		case O3VecStructInt64Element: *((Int64*)bytes+i) = [num longLongValue]; return;
		case O3VecStructUInt8Element:  *((UInt8*)bytes+i) = [num unsignedIntValue]; return;
		case O3VecStructUInt16Element: *((UInt16*)bytes+i) = [num unsignedIntValue]; return;
		case O3VecStructUInt32Element: *((UInt32*)bytes+i) = [num unsignedIntValue]; return;
		case O3VecStructUInt64Element: *((UInt64*)bytes+i) = [num unsignedLongLongValue]; return;
	}
	O3AssertFalse(@"Unknown type \"%c\"", eleType);
}

- (void)writeDict:(NSDictionary*)dict toBytes:(void*)bytes {
	switch (mSpecificType) {
		case O3VecStructRotation: {
			O3WriteNumberTo(mElementType, 0, bytes, [dict objectForKey:@"roll"]);
			O3WriteNumberTo(mElementType, 1, bytes, [dict objectForKey:@"pitch"]);
			O3WriteNumberTo(mElementType, 2, bytes, [dict objectForKey:@"yaw"]);
			return;
		}
		case O3VecStructPoint:
		case O3VecStructIndex:
		case O3VecStructVec:
		case O3VecStructScale: {
			O3WriteNumberTo(mElementType, 0, bytes, [dict objectForKey:@"x"]);
			O3WriteNumberTo(mElementType, 1, bytes, [dict objectForKey:@"y"]);
			O3WriteNumberTo(mElementType, 2, bytes, [dict objectForKey:@"z"]);			
			O3WriteNumberTo(mElementType, 2, bytes, [dict objectForKey:@"w"]);			
			return;
		}
		case O3VecStructColor: {
			O3WriteNumberTo(mElementType, 0, bytes, [dict objectForKey:@"r"]);
			O3WriteNumberTo(mElementType, 1, bytes, [dict objectForKey:@"g"]);
			O3WriteNumberTo(mElementType, 2, bytes, [dict objectForKey:@"b"]);			
			O3WriteNumberTo(mElementType, 2, bytes, [dict objectForKey:@"a"]);						
			return;
		}
	}
	O3AssertFalse(@"Unknown specific type");
}

- (NSMutableData*)portabalizeStructs:(NSData*)indata {
	UIntP strSize = [self structSize];
	UIntP size = [indata length];
	UIntP count = size / strSize;
	NSMutableData* dat = [NSMutableData dataWithLength:size];
	void* bytes = [dat mutableBytes];
	UIntP j = mElementCount*count;
	UIntP i;
	switch (self->mElementType) {
		case O3VecStructFloatElement:
			for(i=0; i<j; i++) *((float*)bytes+i) = O3ByteswapHostToLittle(*((float*)bytes+i)); return dat;
		case O3VecStructDoubleElement:
			for(i=0; i<j; i++) *((double*)bytes+i) = O3ByteswapHostToLittle(*((double*)bytes+i)); return dat;
		case O3VecStructInt8Element:  
			for(i=0; i<j; i++) *((Int8*)bytes+i) = O3ByteswapHostToLittle(*((Int8*)bytes+i)); return dat;
		case O3VecStructInt16Element: 
			for(i=0; i<j; i++) *((Int16*)bytes+i) = O3ByteswapHostToLittle(*((Int16*)bytes+i)); return dat;
		case O3VecStructInt32Element: 
			for(i=0; i<j; i++) *((Int32*)bytes+i) = O3ByteswapHostToLittle(*((Int32*)bytes+i)); return dat;
		case O3VecStructInt64Element: 
			for(i=0; i<j; i++) *((Int64*)bytes+i) = O3ByteswapHostToLittle(*((Int64*)bytes+i)); return dat;
		case O3VecStructUInt8Element: 
			for(i=0; i<j; i++) *((UInt8*)bytes+i) = O3ByteswapHostToLittle(*((UInt8*)bytes+i)); return dat;
		case O3VecStructUInt16Element:
			for(i=0; i<j; i++) *((UInt16*)bytes+i) = O3ByteswapHostToLittle(*((UInt16*)bytes+i)); return dat;
		case O3VecStructUInt32Element:
			for(i=0; i<j; i++) *((UInt32*)bytes+i) = O3ByteswapHostToLittle(*((UInt32*)bytes+i)); return dat;
		case O3VecStructUInt64Element:
			for(i=0; i<j; i++) *((UInt64*)bytes+i) = O3ByteswapHostToLittle(*((UInt64*)bytes+i)); return dat;
	}
	O3AssertFalse(@"Unknown type \"%c\" in vec struct %@", self->mElementType, self);
	return dat;
}

- (NSMutableData*)deportabalizeStructs:(NSData*)indata {
	UIntP strSize = [self structSize];
	UIntP size = [indata length];
	UIntP count = size / strSize;
	NSMutableData* dat = [NSMutableData dataWithLength:size];
	void* bytes = [dat mutableBytes];
	UIntP j = mElementCount*count;
	UIntP i;
	switch (self->mElementType) {
		case O3VecStructFloatElement:
			for(i=0; i<j; i++) *((float*)bytes+i) = O3ByteswapLittleToHost(*((float*)bytes+i)); return dat;
		case O3VecStructDoubleElement:
			for(i=0; i<j; i++) *((double*)bytes+i) = O3ByteswapLittleToHost(*((double*)bytes+i)); return dat;
		case O3VecStructInt8Element:  
			for(i=0; i<j; i++) *((Int8*)bytes+i) = O3ByteswapLittleToHost(*((Int8*)bytes+i)); return dat;
		case O3VecStructInt16Element: 
			for(i=0; i<j; i++) *((Int16*)bytes+i) = O3ByteswapLittleToHost(*((Int16*)bytes+i)); return dat;
		case O3VecStructInt32Element: 
			for(i=0; i<j; i++) *((Int32*)bytes+i) = O3ByteswapLittleToHost(*((Int32*)bytes+i)); return dat;
		case O3VecStructInt64Element: 
			for(i=0; i<j; i++) *((Int64*)bytes+i) = O3ByteswapLittleToHost(*((Int64*)bytes+i)); return dat;
		case O3VecStructUInt8Element: 
			for(i=0; i<j; i++) *((UInt8*)bytes+i) = O3ByteswapLittleToHost(*((UInt8*)bytes+i)); return dat;
		case O3VecStructUInt16Element:
			for(i=0; i<j; i++) *((UInt16*)bytes+i) = O3ByteswapLittleToHost(*((UInt16*)bytes+i)); return dat;
		case O3VecStructUInt32Element:
			for(i=0; i<j; i++) *((UInt32*)bytes+i) = O3ByteswapLittleToHost(*((UInt32*)bytes+i)); return dat;
		case O3VecStructUInt64Element:
			for(i=0; i<j; i++) *((UInt64*)bytes+i) = O3ByteswapLittleToHost(*((UInt64*)bytes+i)); return dat;
	}
	O3AssertFalse(@"Unknown type \"%c\" in vec struct %@", self->mElementType, self);	
	return dat;
}

- (NSMutableData*)translateStructs:(NSData*)instructs toFormat:(O3StructType*)oformat {
	O3VecStructType* format = (O3VecStructType*)oformat;
	if (![format isKindOfClass:[self class]]||mElementCount!=[format elementCount]) return [super translateStructs:instructs toFormat:oformat];
	if (mElementCount!=[format elementCount]) return nil;
	UIntP count = [instructs length]/[self structSize];
	NSMutableData* ret = [NSMutableData dataWithLength:[oformat structSize]*count];
	void* returnbuf = [ret mutableBytes];
	const void* bytes = [instructs bytes];
	if (!mPermutations) {
		if (mElementType==O3VecStructUInt64Element) {
			UIntP i; UIntP j=count*mElementCount; for(i=0; i<j; i++)
				O3SetValueOfType_at_toUInt64_withIndex_([format elementType], returnbuf, O3UInt64ValueOfType_at_withIndex_(mElementType, bytes, i), i);
		} else if (mElementType==O3VecStructInt64Element) {
			UIntP i; UIntP j=count*mElementCount; for(i=0; i<j; i++)
				O3SetValueOfType_at_toInt64_withIndex_([format elementType], returnbuf, O3Int64ValueOfType_at_withIndex_(mElementType, bytes, i), i);		
		} else {
			UIntP i; UIntP j=count*mElementCount; for(i=0; i<j; i++)
				O3SetValueOfType_at_toDouble_withIndex_([format elementType], returnbuf, O3DoubleValueOfType_at_withIndex_(mElementType, bytes, i), i);	
		}
	} else {
		UIntP* otherPermArray = [format permutations];
		if (mElementType==O3VecStructUInt64Element) {
			UIntP i,j; for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) {
				UInt64 val = O3UInt64ValueOfType_at_withIndex_(mElementType, bytes, mElementCount*i + mPermutations[j]);
				O3SetValueOfType_at_toUInt64_withIndex_([format elementType], returnbuf, val, mElementCount*i + otherPermArray[j]);
			}
		} else if (mElementType==O3VecStructInt64Element) {
			UIntP i,j; for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) {
				double val = O3DoubleValueOfType_at_withIndex_(mElementType, bytes, mElementCount*i + mPermutations[j]);
				O3SetValueOfType_at_toDouble_withIndex_([format elementType], returnbuf, val, mElementCount*i + otherPermArray[j]);
			}
		} else {
			UIntP i,j; for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) {
				Int64 val = O3Int64ValueOfType_at_withIndex_(mElementType, bytes, mElementCount*i + mPermutations[j]);
				O3SetValueOfType_at_toInt64_withIndex_([format elementType], returnbuf, val, mElementCount*i + otherPermArray[j]);
			}
		}
	}
	return ret;
}

/************************************/ #pragma mark Special info /************************************/
- (double)multiplier {
	return mMultiplier;
}

- (void)setMultiplier:(double)newMult {
	mMultiplier = newMult;
}

///Overrides ignored
- (UIntP*)permutations {
	return mPermutations;
}

- (void)setPermutations:(UIntP*)newPerms freeWhenDone:(BOOL)fwd {
	if (mFreePermsWhenDone) free(mPermutations);
	mPermutations = newPerms;
	mFreePermsWhenDone = fwd;
}

- (GLenum)glFormatForType:(O3VertexDataType)type {
	switch (mElementType) {
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
	O3AssertFalse(@"Unknown GL type for type \"%c\" in vec struct %@", mElementType, self);
	return 0;
}

- (GLint)glComponentCountForType:(O3VertexDataType)type {
	return mElementCount;
}

- (GLsizeiptr)glOffsetForType:(O3VertexDataType)type {
	return 0;
}

- (GLsizeiptr)glStride {
	return O3VecStructSize(self);
}

- (GLboolean)glNormalizedForType:(O3VertexDataType)type {
	return mMultiplier<.5; //If the multiplier is shrinking things by more than a factor of two, it is probably normalized
}

- (int)glVertsPerStruct {
	return 1;
}

@end

double O3DoubleValueOfType_at_withIndex_(enum O3VecStructElementType type, const void* bytes, UIntP idx) {
	switch (type) {
		case O3VecStructFloatElement:  return *((float*)bytes+idx);
		case O3VecStructDoubleElement: return *((double*)bytes+idx);
		case O3VecStructInt8Element:   return *((Int8*)bytes+idx);
		case O3VecStructInt16Element:  return *((Int16*)bytes+idx);
		case O3VecStructInt32Element:  return *((Int32*)bytes+idx);
		case O3VecStructInt64Element:  return *((Int64*)bytes+idx);
		case O3VecStructUInt8Element:  return *((UInt8*)bytes+idx);
		case O3VecStructUInt16Element: return *((UInt16*)bytes+idx);
		case O3VecStructUInt32Element: return *((UInt32*)bytes+idx);
		case O3VecStructUInt64Element: return *((UInt64*)bytes+idx);
	}
	O3AssertFalse(@"Unknown type %i", (int)type);
	return 0;
}

Int64 O3Int64ValueOfType_at_withIndex_(enum O3VecStructElementType type, const void* bytes, UIntP idx) {
	switch (type) {
		case O3VecStructFloatElement:  return *((float*)bytes+idx);
		case O3VecStructDoubleElement: return *((double*)bytes+idx);
		case O3VecStructInt8Element:   return *((Int8*)bytes+idx);
		case O3VecStructInt16Element:  return *((Int16*)bytes+idx);
		case O3VecStructInt32Element:  return *((Int32*)bytes+idx);
		case O3VecStructInt64Element:  return *((Int64*)bytes+idx);
		case O3VecStructUInt8Element:  return *((UInt8*)bytes+idx);
		case O3VecStructUInt16Element: return *((UInt16*)bytes+idx);
		case O3VecStructUInt32Element: return *((UInt32*)bytes+idx);
		case O3VecStructUInt64Element: return *((UInt64*)bytes+idx);
	}
	O3AssertFalse(@"Unknown type %i", (int)type);
	return 0;
}

UInt64 O3UInt64ValueOfType_at_withIndex_(enum O3VecStructElementType type, const void* bytes, UIntP idx) {
	switch (type) {
		case O3VecStructFloatElement:  return *((float*)bytes+idx);
		case O3VecStructDoubleElement: return *((double*)bytes+idx);
		case O3VecStructInt8Element:   return *((Int8*)bytes+idx);
		case O3VecStructInt16Element:  return *((Int16*)bytes+idx);
		case O3VecStructInt32Element:  return *((Int32*)bytes+idx);
		case O3VecStructInt64Element:  return *((Int64*)bytes+idx);
		case O3VecStructUInt8Element:  return *((UInt8*)bytes+idx);
		case O3VecStructUInt16Element: return *((UInt16*)bytes+idx);
		case O3VecStructUInt32Element: return *((UInt32*)bytes+idx);
		case O3VecStructUInt64Element: return *((UInt64*)bytes+idx);
	}
	O3AssertFalse(@"Unknown type %i", (int)type);
	return 0;
}

void O3SetValueOfType_at_toDouble_withIndex_(enum O3VecStructElementType type, void* bytes, double v, UIntP idx) {
	switch (type) {
		case O3VecStructFloatElement:  *((float*)bytes+idx)  = v; return;  
		case O3VecStructDoubleElement: *((double*)bytes+idx) = v; return; 
		case O3VecStructInt8Element:   *((Int8*)bytes+idx)   = v; return;   
		case O3VecStructInt16Element:  *((Int16*)bytes+idx)  = v; return;  
		case O3VecStructInt32Element:  *((Int32*)bytes+idx)  = v; return;  
		case O3VecStructInt64Element:  *((Int64*)bytes+idx)  = v; return;  
		case O3VecStructUInt8Element:  *((UInt8*)bytes+idx)  = v; return;  
		case O3VecStructUInt16Element: *((UInt16*)bytes+idx) = v; return; 
		case O3VecStructUInt32Element: *((UInt32*)bytes+idx) = v; return; 
		case O3VecStructUInt64Element: *((UInt64*)bytes+idx) = v; return; 
	}
	O3AssertFalse("Unknown type \"%i\"", (int)type);
}

void O3SetValueOfType_at_toInt64_withIndex_(enum O3VecStructElementType type, void* bytes, Int64 v, UIntP idx) {
	switch (type) {
		case O3VecStructFloatElement:  *((float*)bytes+idx)  = v; return;  
		case O3VecStructDoubleElement: *((double*)bytes+idx) = v; return; 
		case O3VecStructInt8Element:   *((Int8*)bytes+idx)   = v; return;   
		case O3VecStructInt16Element:  *((Int16*)bytes+idx)  = v; return;  
		case O3VecStructInt32Element:  *((Int32*)bytes+idx)  = v; return;  
		case O3VecStructInt64Element:  *((Int64*)bytes+idx)  = v; return;  
		case O3VecStructUInt8Element:  *((UInt8*)bytes+idx)  = v; return;  
		case O3VecStructUInt16Element: *((UInt16*)bytes+idx) = v; return; 
		case O3VecStructUInt32Element: *((UInt32*)bytes+idx) = v; return; 
		case O3VecStructUInt64Element: *((UInt64*)bytes+idx) = v; return; 
	}
	O3AssertFalse("Unknown type \"%i\"", (int)type);	
}

void O3SetValueOfType_at_toUInt64_withIndex_(enum O3VecStructElementType type, void* bytes, UInt64 v, UIntP idx) {
	switch (type) {
		case O3VecStructFloatElement:  *((float*)bytes+idx)  = v; return;  
		case O3VecStructDoubleElement: *((double*)bytes+idx) = v; return; 
		case O3VecStructInt8Element:   *((Int8*)bytes+idx)   = v; return;   
		case O3VecStructInt16Element:  *((Int16*)bytes+idx)  = v; return;  
		case O3VecStructInt32Element:  *((Int32*)bytes+idx)  = v; return;  
		case O3VecStructInt64Element:  *((Int64*)bytes+idx)  = v; return;  
		case O3VecStructUInt8Element:  *((UInt8*)bytes+idx)  = v; return;  
		case O3VecStructUInt16Element: *((UInt16*)bytes+idx) = v; return; 
		case O3VecStructUInt32Element: *((UInt32*)bytes+idx) = v; return; 
		case O3VecStructUInt64Element: *((UInt64*)bytes+idx) = v; return; 
	}
	O3AssertFalse("Unknown type \"%i\"", (int)type);	
}
