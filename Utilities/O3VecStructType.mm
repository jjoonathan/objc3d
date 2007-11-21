//
//  O3VecStructType.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3VecStructType.h"
#import "O3VecStruct.h"

O3VecStructType* gO3Vec3rType;   O3VecStructType* O3Vec3rType() {return gO3Vec3rType;}
O3VecStructType* gO3Vec3fType;   O3VecStructType* O3Vec3fType() {return gO3Vec3fType;}
O3VecStructType* gO3Vec3dType;   O3VecStructType* O3Vec3dType() {return gO3Vec3dType;}
O3VecStructType* gO3Vec4rType;   O3VecStructType* O3Vec4rType() {return gO3Vec4rType;}
O3VecStructType* gO3Vec4fType;   O3VecStructType* O3Vec4fType() {return gO3Vec4fType;}
O3VecStructType* gO3Vec4dType;   O3VecStructType* O3Vec4dType() {return gO3Vec4dType;}
O3VecStructType* gO3Rot3d;       O3VecStructType* O3Rot3dType()      {return gO3Rot3d;    }
O3VecStructType* gO3Point3d;     O3VecStructType* O3Point3dType()    {return gO3Point3d;  }
O3VecStructType* gO3Scale3d;     O3VecStructType* O3Scale3dType()    {return gO3Scale3d;  }
O3VecStructType* gO3Index3x8;    O3VecStructType* O3Index3x8Type()   {return gO3Index3x8; }
O3VecStructType* gO3Index3x16;   O3VecStructType* O3Index3x16Type()  {return gO3Index3x16;}
O3VecStructType* gO3Index3x32;   O3VecStructType* O3Index3x32Type()  {return gO3Index3x32;}
O3VecStructType* gO3Index3x64;   O3VecStructType* O3Index3x64Type()  {return gO3Index3x64;}
O3VecStructType* gO3Index4x8;    O3VecStructType* O3Index4x8Type()   {return gO3Index4x8; }
O3VecStructType* gO3Index4x16;   O3VecStructType* O3Index4x16Type()  {return gO3Index4x16;}
O3VecStructType* gO3Index4x32;   O3VecStructType* O3Index4x32Type()  {return gO3Index4x32;}
O3VecStructType* gO3Index4x64;   O3VecStructType* O3Index4x64Type()  {return gO3Index4x64;}

@implementation O3VecStructType

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
	gO3Point3d   = [[O3VecStructType alloc] initWithElementType:O3VecStructDoubleElement  specificType:O3VecStructPoint count:3 name:@"point3d"];
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

///@returns a new autoreleased vector 
+ (O3VecStructType*)vecStructTypeWithElementType:(enum O3VecStructElementType)type
                                    specificType:(enum O3VecStructSpecificType)stype
                                           count:(int)count
                                            name:(NSString*)name {
	O3StructType* existingType = name? O3StructTypeForName(name) : nil;
	if (existingType) return (O3VecStructType*)existingType;
	return [[[self alloc] initWithElementType:type specificType:stype count:count name:name] autorelease];
}

- (O3VecStructType*)initWithElementType:(enum O3VecStructElementType)type specificType:(O3VecStructSpecificType)stype count:(int)count name:(NSString*)name {
	[super initWithName:name];
	mElementType = type;
	mElementCount = count;
	mSpecificType = stype;
	return self;
}

- (void)dealloc {
	if (mFreePermsWhenDone) free(mPermutations);
	O3SuperDealloc();
}

- (O3VecStruct*)structWithBytes:(const void*)bytes {
	return [[[O3VecStruct alloc] initWithBytes:bytes type:self] autorelease];
}

+ (O3VecStructType*)vec3fType {return O3Vec3fType();}
+ (O3VecStructType*)vec3dType {return O3Vec3dType();}
+ (O3VecStructType*)vec3rType {return O3Vec3rType();}
+ (O3VecStructType*)vec4fType {return O3Vec4fType();}
+ (O3VecStructType*)vec4dType {return O3Vec4dType();}
+ (O3VecStructType*)vec4rType {return O3Vec4rType();}
+ (O3VecStructType*)rot3dType     {return O3Rot3dType();    }
+ (O3VecStructType*)point3dTsype  {return O3Point3dType();  }
+ (O3VecStructType*)scale3dType   {return O3Scale3dType();  }
+ (O3VecStructType*)index3x8Type  {return O3Index3x8Type(); }
+ (O3VecStructType*)index3x16Type {return O3Index3x16Type();}
+ (O3VecStructType*)index3x32Type {return O3Index3x32Type();}
+ (O3VecStructType*)index3x64Type {return O3Index3x64Type();}
+ (O3VecStructType*)index4x8Type  {return O3Index4x8Type(); }
+ (O3VecStructType*)index4x16Type {return O3Index4x16Type();}
+ (O3VecStructType*)index4x32Type {return O3Index4x32Type();}
+ (O3VecStructType*)index4x64Type {return O3Index4x64Type();}


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

- (NSArray*)structKeys {
	switch (mSpecificType) {
		case O3VecStructRotation: return [NSArray arrayWithObjects:@"roll", @"pitch", @"yaw", nil];
		case O3VecStructPoint:
		case O3VecStructIndex:
		case O3VecStructVec:
		case O3VecStructScale:
			if (mElementCount==2) return [NSArray arrayWithObjects:@"x", @"y", nil];
			if (mElementCount==3) return [NSArray arrayWithObjects:@"x", @"y", @"z", nil];
			if (mElementCount==4) return [NSArray arrayWithObjects:@"x", @"y", @"z", @"w", nil];
			O3AssertFalse(@"Unknown dimensionality for point (%i)", mElementCount);
		case O3VecStructColor:
			if (mElementCount==1) return [NSArray arrayWithObjects:@"r", nil];
			if (mElementCount==2) return [NSArray arrayWithObjects:@"r", @"g", nil];
			if (mElementCount==3) return [NSArray arrayWithObjects:@"r", @"g", @"b", nil];
			if (mElementCount==4) return [NSArray arrayWithObjects:@"r", @"g", @"b", @"a", nil];
			O3AssertFalse(@"Unknown dimensionality for point (%i)", mElementCount);
	}
	O3AssertFalse(@"Unknown specific type");
	return nil;
}

- (void)portabalizeStructsAt:(void*)bytes count:(UIntP)count {
	UIntP j = mElementCount*count;
	UIntP i;
	switch (self->mElementType) {
		case O3VecStructFloatElement:
			for(i=0; i<j; i++) *((float*)bytes+i) = O3ByteswapHostToLittle(*((float*)bytes+i)); return;
		case O3VecStructDoubleElement:
			for(i=0; i<j; i++) *((double*)bytes+i) = O3ByteswapHostToLittle(*((double*)bytes+i)); return;
		case O3VecStructInt8Element:  
			for(i=0; i<j; i++) *((Int8*)bytes+i) = O3ByteswapHostToLittle(*((Int8*)bytes+i)); return;
		case O3VecStructInt16Element: 
			for(i=0; i<j; i++) *((Int16*)bytes+i) = O3ByteswapHostToLittle(*((Int16*)bytes+i)); return;
		case O3VecStructInt32Element: 
			for(i=0; i<j; i++) *((Int32*)bytes+i) = O3ByteswapHostToLittle(*((Int32*)bytes+i)); return;
		case O3VecStructInt64Element: 
			for(i=0; i<j; i++) *((Int64*)bytes+i) = O3ByteswapHostToLittle(*((Int64*)bytes+i)); return;
		case O3VecStructUInt8Element: 
			for(i=0; i<j; i++) *((UInt8*)bytes+i) = O3ByteswapHostToLittle(*((UInt8*)bytes+i)); return;
		case O3VecStructUInt16Element:
			for(i=0; i<j; i++) *((UInt16*)bytes+i) = O3ByteswapHostToLittle(*((UInt16*)bytes+i)); return;
		case O3VecStructUInt32Element:
			for(i=0; i<j; i++) *((UInt32*)bytes+i) = O3ByteswapHostToLittle(*((UInt32*)bytes+i)); return;
		case O3VecStructUInt64Element:
			for(i=0; i<j; i++) *((UInt64*)bytes+i) = O3ByteswapHostToLittle(*((UInt64*)bytes+i)); return;
	}
	O3AssertFalse(@"Unknown type \"%c\" in vec struct %@", self->mElementType, self);	
}

- (void)deportabalizeStructsAt:(void*)bytes count:(UIntP)conut {
	UIntP j = mElementCount*conut;
	UIntP i;
	switch (self->mElementType) {
		case O3VecStructFloatElement:
			for(i=0; i<j; i++) *((float*)bytes+i) = O3ByteswapLittleToHost(*((float*)bytes+i)); return;
		case O3VecStructDoubleElement:
			for(i=0; i<j; i++) *((double*)bytes+i) = O3ByteswapLittleToHost(*((double*)bytes+i)); return;
		case O3VecStructInt8Element:  
			for(i=0; i<j; i++) *((Int8*)bytes+i) = O3ByteswapLittleToHost(*((Int8*)bytes+i)); return;
		case O3VecStructInt16Element: 
			for(i=0; i<j; i++) *((Int16*)bytes+i) = O3ByteswapLittleToHost(*((Int16*)bytes+i)); return;
		case O3VecStructInt32Element: 
			for(i=0; i<j; i++) *((Int32*)bytes+i) = O3ByteswapLittleToHost(*((Int32*)bytes+i)); return;
		case O3VecStructInt64Element: 
			for(i=0; i<j; i++) *((Int64*)bytes+i) = O3ByteswapLittleToHost(*((Int64*)bytes+i)); return;
		case O3VecStructUInt8Element: 
			for(i=0; i<j; i++) *((UInt8*)bytes+i) = O3ByteswapLittleToHost(*((UInt8*)bytes+i)); return;
		case O3VecStructUInt16Element:
			for(i=0; i<j; i++) *((UInt16*)bytes+i) = O3ByteswapLittleToHost(*((UInt16*)bytes+i)); return;
		case O3VecStructUInt32Element:
			for(i=0; i<j; i++) *((UInt32*)bytes+i) = O3ByteswapLittleToHost(*((UInt32*)bytes+i)); return;
		case O3VecStructUInt64Element:
			for(i=0; i<j; i++) *((UInt64*)bytes+i) = O3ByteswapLittleToHost(*((UInt64*)bytes+i)); return;
	}
	O3AssertFalse(@"Unknown type \"%c\" in vec struct %@", self->mElementType, self);	
}

- (void*)translateStructsAt:(const void*)bytes count:(UIntP)count toFormat:(O3StructType*)oformat {
	O3VecStructType* format = (O3VecStructType*)oformat;
	if (![format isKindOfClass:[self class]]) return NO;
	if (mElementCount!=[format elementCount]) return NO;
	count *= mElementCount;
	void* returnbuf = malloc(O3VecStructSize(format)*count);
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
	return returnbuf;
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


@end
