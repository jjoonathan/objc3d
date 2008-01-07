//
//  O3VecStructType.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3VecStructType.h"

O3EXTERN_C_BLOCK
#define DefType(NAME) O3VecStructType* g ## NAME;   O3VecStructType* NAME () {return g ## NAME;}
O3VecStructTypeDefines
#undef DefType
O3END_EXTERN_C_BLOCK

@implementation O3VecStructType

O3EXTERN_C_BLOCK
UIntP* O3VecStructTypePermsAndMultiplier(O3VecStructType* self, double* multiplier) {
	*multiplier = self->mMultiplier;
	return self->mPermutations;
}

void O3VecStructTypeGetType_count_specificType_(O3VecStructType* self, O3VecStructElementType* type, short* count, O3VecStructSpecificType* stype) {
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

NSNumber* O3VecStructGetElement(O3VecStructType* self, UIntP i, const void* bytes) {
	if (self->mPermutations) i = self->mPermutations[i];
	O3Asrt(i<self->mElementCount);
	double mMultiplier = self->mMultiplier;
	switch (self->mElementType) {
		case O3VecStructFloatElement: return [NSNumber numberWithFloat:*((float*)bytes+i)*mMultiplier];
		case O3VecStructDoubleElement: return [NSNumber numberWithDouble:*((double*)bytes+i)*mMultiplier];
		case O3VecStructInt8Element:  return [NSNumber numberWithInt:  *((Int8*)bytes+i)*mMultiplier];
		case O3VecStructInt16Element: return [NSNumber numberWithInt:*((Int16*)bytes+i)*mMultiplier];
		case O3VecStructInt32Element: return [NSNumber numberWithInt:*((Int32*)bytes+i)*mMultiplier];
		case O3VecStructInt64Element: return [NSNumber numberWithLongLong:*((Int64*)bytes+i)*mMultiplier];
		case O3VecStructUInt8Element:  return [NSNumber numberWithUnsignedInt:*((UInt8*)bytes+i)*mMultiplier];
		case O3VecStructUInt16Element: return [NSNumber numberWithUnsignedInt:*((UInt16*)bytes+i)*mMultiplier];
		case O3VecStructUInt32Element: return [NSNumber numberWithUnsignedInt:*((UInt32*)bytes+i)*mMultiplier];
		case O3VecStructUInt64Element: return [NSNumber numberWithUnsignedLongLong:*((UInt64*)bytes+i)*mMultiplier];
	}
	O3AssertFalse(@"Unknown type \"%c\" in vec struct %@", self->mElementType, self);
	return (NSNumber*)@"???";
}

void O3WriteNumberTo(O3VecStructElementType eleType, UIntP i, void* bytes, NSNumber* num, double rmul, UIntP* mPermutations) {
	if (mPermutations) i = mPermutations[i];
	switch (eleType) {
		case O3VecStructFloatElement: *((float*)bytes+i) = [num floatValue]*rmul; return;
		case O3VecStructDoubleElement: *((double*)bytes+i) = [num doubleValue]*rmul; return;
		case O3VecStructInt8Element:  *((Int8*)bytes+i) = [num intValue]*rmul; return;
		case O3VecStructInt16Element: *((Int16*)bytes+i) = [num shortValue]*rmul; return;
		case O3VecStructInt32Element: *((Int32*)bytes+i) = [num intValue]*rmul; return;
		case O3VecStructInt64Element: *((Int64*)bytes+i) = [num longLongValue]*rmul; return;
		case O3VecStructUInt8Element:  *((UInt8*)bytes+i) = [num unsignedIntValue]*rmul; return;
		case O3VecStructUInt16Element: *((UInt16*)bytes+i) = [num unsignedIntValue]*rmul; return;
		case O3VecStructUInt32Element: *((UInt32*)bytes+i) = [num unsignedIntValue]*rmul; return;
		case O3VecStructUInt64Element: *((UInt64*)bytes+i) = [num unsignedLongLongValue]*rmul; return;
	}
	O3AssertFalse(@"Unknown type \"%c\"", eleType);
}
O3END_EXTERN_C_BLOCK

inline double O3DoubleValueOfType_at_withIndex_(O3VecStructElementType type, const void* bytes, UIntP idx) {
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

inline Int64 O3Int64ValueOfType_at_withIndex_(O3VecStructElementType type, const void* bytes, UIntP idx) {
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

inline UInt64 O3UInt64ValueOfType_at_withIndex_(O3VecStructElementType type, const void* bytes, UIntP idx) {
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

inline void O3SetValueOfType_at_toDouble_withIndex_(O3VecStructElementType type, void* bytes, double v, UIntP idx) {
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

inline void O3SetValueOfType_at_toInt64_withIndex_(O3VecStructElementType type, void* bytes, Int64 v, UIntP idx) {
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

inline void O3SetValueOfType_at_toUInt64_withIndex_(O3VecStructElementType type, void* bytes, UInt64 v, UIntP idx) {
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

/************************************/ #pragma mark Class Methods /************************************/
+ (void)o3init {
	O3CompileAssert(*@encode(real)=='f' || *@encode(real)=='d', @"O3VecStructType assumes that real is eather float or double");
	O3VecStructElementType rtype = *@encode(real)=='f'? O3VecStructFloatElement : O3VecStructDoubleElement;
	gO3Vec3rType = [[O3VecStructType alloc] initWithElementType:rtype                     specificType:O3VecStructVec count:3 name:@"vec3r"];
	gO3Vec3fType = [[O3VecStructType alloc] initWithElementType:O3VecStructFloatElement   specificType:O3VecStructVec count:3 name:@"vec3f"];
	gO3Vec3dType = [[O3VecStructType alloc] initWithElementType:O3VecStructDoubleElement  specificType:O3VecStructVec count:3 name:@"vec3d"];
	gO3Vec4rType = [[O3VecStructType alloc] initWithElementType:rtype                     specificType:O3VecStructVec count:4 name:@"vec4r"];
	gO3Vec4fType = [[O3VecStructType alloc] initWithElementType:O3VecStructFloatElement   specificType:O3VecStructVec count:4 name:@"vec4f"];
	gO3Vec4dType = [[O3VecStructType alloc] initWithElementType:O3VecStructDoubleElement  specificType:O3VecStructVec count:4 name:@"vec4d"];
	gO3RGBA8Type = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt8Element  specificType:O3VecStructVec count:4 name:@"RGBA8"];
		[gO3RGBA8Type setMultiplier:1./255];
	gO3RGB8Type    = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt8Element  specificType:O3VecStructVec count:3 name:@"RGB8"];
		[gO3RGB8Type setMultiplier:1./255];
	gO3Rot3dType     = [[O3VecStructType alloc] initWithElementType:O3VecStructDoubleElement  specificType:O3VecStructRotation count:3 name:@"rot3d"];
	//gO3Point3d   = [[O3VecStructType alloc] initWithElementType:O3VecStructDoubleElement  specificType:O3VecStructPoint count:3 name:@"point3d"];
	gO3Point3fType   = [[O3VecStructType alloc] initWithElementType:O3VecStructFloatElement   specificType:O3VecStructPoint count:3 name:@"point3f"];
	//gO3Point4d   = [[O3VecStructType alloc] initWithElementType:O3VecStructDoubleElement  specificType:O3VecStructPoint count:4 name:@"point4d"];
	gO3Scale3dType   = [[O3VecStructType alloc] initWithElementType:O3VecStructDoubleElement  specificType:O3VecStructScale count:3 name:@"scale3d"];
	gO3Index3x8Type  = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt8Element   specificType:O3VecStructIndex count:3 name:@"idx3x8"];
	gO3Index3x16Type = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt16Element  specificType:O3VecStructIndex count:3 name:@"idx3x16"];
	gO3Index3x32Type = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt32Element  specificType:O3VecStructIndex count:3 name:@"idx3x32"];
	gO3Index3x64Type = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt64Element  specificType:O3VecStructIndex count:3 name:@"idx3x64"];
	gO3Index4x8Type  = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt8Element   specificType:O3VecStructIndex count:4 name:@"idx4x8"];
	gO3Index4x16Type = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt16Element  specificType:O3VecStructIndex count:4 name:@"idx4x16"];
	gO3Index4x32Type = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt32Element  specificType:O3VecStructIndex count:4 name:@"idx4x32"];
	gO3Index4x64Type = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt64Element  specificType:O3VecStructIndex count:4 name:@"idx4x64"];
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
+ (O3VecStructType*)vecStructTypeWithElementType:(O3VecStructElementType)type
                                    specificType:(O3VecStructSpecificType)stype
                                           count:(int)count
                                            name:(NSString*)name {
	O3StructType* existingType = name? O3StructTypeForName(name) : nil;
	if (existingType) return (O3VecStructType*)existingType;
	return [[[self alloc] initWithElementType:type specificType:stype count:count name:name] autorelease];
}

/************************************/ #pragma mark Init /************************************/
- (O3VecStructType*)initWithElementType:(O3VecStructElementType)type specificType:(O3VecStructSpecificType)stype count:(int)count name:(NSString*)name {
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
- (O3VecStructElementType)elementType {
	return mElementType;
}

- (O3VecStructSpecificType)specificType {
	return mSpecificType;
}

- (short)elementCount {
	return mElementCount;
}

/************************************/ #pragma mark O3StructType /************************************/
- (UIntP)structSize {return O3VecStructSize(self);}

- (id)objectWithBytes:(const void*)bytes {
	NSMutableArray* to_return = [[[NSMutableArray alloc] initWithCapacity:mElementCount] autorelease];
	int j = mElementCount;
	if (mPermutations) {
		#define MakeAndReturnArray(NUM_METHOD,NUM_TYPE) for (int i=0; i<j; i++) [to_return addObject:[NSNumber NUM_METHOD *(( NUM_TYPE *)bytes+mPermutations[i]) * mMultiplier]]; return to_return;
		switch (mElementType) {
			case O3VecStructFloatElement:  MakeAndReturnArray(numberWithFloat:, float);
			case O3VecStructDoubleElement: MakeAndReturnArray(numberWithDouble:, double);
			case O3VecStructInt8Element:   MakeAndReturnArray(numberWithInt:, Int8);
			case O3VecStructInt16Element:  MakeAndReturnArray(numberWithInt:, Int16);
			case O3VecStructInt32Element:  MakeAndReturnArray(numberWithInt:, Int32);
			case O3VecStructInt64Element:  MakeAndReturnArray(numberWithLongLong:, Int64);
			case O3VecStructUInt8Element:  MakeAndReturnArray(numberWithUnsignedInt:, UInt8);
			case O3VecStructUInt16Element: MakeAndReturnArray(numberWithUnsignedInt:, UInt16);
			case O3VecStructUInt32Element: MakeAndReturnArray(numberWithUnsignedInt:, UInt32);
			case O3VecStructUInt64Element: MakeAndReturnArray(numberWithUnsignedLongLong:, UInt64);
		}
		#undef MakeAndReturnArray
	} else {
		#define MakeAndReturnArray(NUM_METHOD,NUM_TYPE) for (int i=0; i<j; i++) [to_return addObject:[NSNumber NUM_METHOD *(( NUM_TYPE *)bytes+i) * mMultiplier]]; return to_return;
		switch (mElementType) {
			case O3VecStructFloatElement:  MakeAndReturnArray(numberWithFloat:, float);
			case O3VecStructDoubleElement: MakeAndReturnArray(numberWithDouble:, double);
			case O3VecStructInt8Element:   MakeAndReturnArray(numberWithInt:, Int8);
			case O3VecStructInt16Element:  MakeAndReturnArray(numberWithInt:, Int16);
			case O3VecStructInt32Element:  MakeAndReturnArray(numberWithInt:, Int32);
			case O3VecStructInt64Element:  MakeAndReturnArray(numberWithLongLong:, Int64);
			case O3VecStructUInt8Element:  MakeAndReturnArray(numberWithUnsignedInt:, UInt8);
			case O3VecStructUInt16Element: MakeAndReturnArray(numberWithUnsignedInt:, UInt16);
			case O3VecStructUInt32Element: MakeAndReturnArray(numberWithUnsignedInt:, UInt32);
			case O3VecStructUInt64Element: MakeAndReturnArray(numberWithUnsignedLongLong:, UInt64);
		}
		#undef MakeAndReturnArray			
	}
	O3AssertFalse(@"Unknown specific type");
	return nil;
}

- (void)writeObject:(id)dict toBytes:(void*)bytes {
	O3Assert([dict respondsToSelector:@selector(objectAtIndex:)], @"Invalid conversion (%@ is not a valid struct of type %@)", dict, [self className]);
	int j = mElementCount;
	double rmul = 1./mMultiplier;
	if (mPermutations) {
		#define DumpArrayToData(NUM_METHOD,NUM_TYPE) for (int i=0; i<j; i++) *(( NUM_TYPE *)bytes+mPermutations[i]) = [[(NSArray*)dict objectAtIndex:i] NUM_METHOD]*rmul; return;
		switch (mElementType) {
			case O3VecStructFloatElement:  DumpArrayToData(floatValue, float);
			case O3VecStructDoubleElement: DumpArrayToData(doubleValue, double);
			case O3VecStructInt8Element:   DumpArrayToData(intValue, Int8);
			case O3VecStructInt16Element:  DumpArrayToData(shortValue, Int16);
			case O3VecStructInt32Element:  DumpArrayToData(intValue, Int32);
			case O3VecStructInt64Element:  DumpArrayToData(longLongValue, Int64);
			case O3VecStructUInt8Element:  DumpArrayToData(unsignedIntValue, UInt8);
			case O3VecStructUInt16Element: DumpArrayToData(unsignedIntValue, UInt16);
			case O3VecStructUInt32Element: DumpArrayToData(unsignedIntValue, UInt32);
			case O3VecStructUInt64Element: DumpArrayToData(unsignedLongLongValue, UInt64);
		}
		#undef DumpArrayToData
	} else {
		#define DumpArrayToData(NUM_METHOD,NUM_TYPE) for (int i=0; i<j; i++) *(( NUM_TYPE *)bytes+i) = [[(NSArray*)dict objectAtIndex:i] NUM_METHOD]*rmul; return;
		switch (mElementType) {
			case O3VecStructFloatElement:  DumpArrayToData(floatValue, float);
			case O3VecStructDoubleElement: DumpArrayToData(doubleValue, double);
			case O3VecStructInt8Element:   DumpArrayToData(intValue, Int8);
			case O3VecStructInt16Element:  DumpArrayToData(shortValue, Int16);
			case O3VecStructInt32Element:  DumpArrayToData(intValue, Int32);
			case O3VecStructInt64Element:  DumpArrayToData(longLongValue, Int64);
			case O3VecStructUInt8Element:  DumpArrayToData(unsignedIntValue, UInt8);
			case O3VecStructUInt16Element: DumpArrayToData(unsignedIntValue, UInt16);
			case O3VecStructUInt32Element: DumpArrayToData(unsignedIntValue, UInt32);
			case O3VecStructUInt64Element: DumpArrayToData(unsignedLongLongValue, UInt64);
		}
		#undef DumpArrayToData		
	}
	O3AssertFalse(@"Unknown specific type");
}

- (NSMutableData*)portabalizeStructsAt:(const void*)at count:(UIntP)count stride:(UIntP)s {
	UIntP strSize = [self structSize];
	if (!s) s = strSize;
	NSMutableData* dat = [NSMutableData dataWithLength:strSize*count];
	const UInt8* bytes = (const UInt8*)at;
	UInt8* tbytes = (UInt8*)[dat mutableBytes];
	UIntP i,j;
	switch (self->mElementType) {
		case O3VecStructFloatElement:
			for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) *((float*)(tbytes+i*s)+j) = O3ByteswapHostToLittle(*((float*)(bytes+i*s)+j)); return dat;
		case O3VecStructDoubleElement:
			for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) *((double*)(tbytes+i*s)+j) = O3ByteswapHostToLittle(*((double*)(bytes+i*s)+j)); return dat;
		case O3VecStructInt8Element:  
			for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) *((Int8*)(tbytes+i*s)+j) = O3ByteswapHostToLittle(*((Int8*)(bytes+i*s)+j)); return dat;
		case O3VecStructInt16Element: 
			for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) *((Int16*)(tbytes+i*s)+j) = O3ByteswapHostToLittle(*((Int16*)(bytes+i*s)+j)); return dat;
		case O3VecStructInt32Element: 
			for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) *((Int32*)(tbytes+i*s)+j) = O3ByteswapHostToLittle(*((Int32*)(bytes+i*s)+j)); return dat;
		case O3VecStructInt64Element: 
			for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) *((Int64*)(tbytes+i*s)+j) = O3ByteswapHostToLittle(*((Int64*)(bytes+i*s)+j)); return dat;
		case O3VecStructUInt8Element: 
			for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) *((UInt8*)(tbytes+i*s)+j) = O3ByteswapHostToLittle(*((UInt8*)(bytes+i*s)+j)); return dat;
		case O3VecStructUInt16Element:
			for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) *((UInt16*)(tbytes+i*s)+j) = O3ByteswapHostToLittle(*((UInt16*)(bytes+i*s)+j)); return dat;
		case O3VecStructUInt32Element:
			for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) *((UInt32*)(tbytes+i*s)+j) = O3ByteswapHostToLittle(*((UInt32*)(bytes+i*s)+j)); return dat;
		case O3VecStructUInt64Element:
			for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) *((UInt64*)(tbytes+i*s)+j) = O3ByteswapHostToLittle(*((UInt64*)(bytes+i*s)+j)); return dat;
	}
	O3AssertFalse(@"Unknown type \"%c\" in vec struct %@", self->mElementType, self);	
	return dat;
}

- (O3RawData)deportabalizeStructs:(NSData*)indata to:(void*)target stride:(UIntP)s {
	UIntP size = [indata length];
	UIntP count = size / s;
	if (!s) s = [self structSize];
	if (!target) target = malloc(s*count);
	UInt8* bytes = (UInt8*)target;
	const UInt8* fbytes = (const UInt8*)[indata bytes];
	O3RawData ret = {target, s*count};
	#ifdef O3NeedByteswapToLittle
	UIntP i,j;
	switch (self->mElementType) {
		case O3VecStructFloatElement:
			for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) *((float*)(bytes+i*s)+j) = O3ByteswapLittleToHost(*((float*)(fbytes+i*s)+j)); return ret;
		case O3VecStructDoubleElement:
			for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) *((double*)(bytes+i*s)+j) = O3ByteswapLittleToHost(*((double*)(fbytes+i*s)+j)); return ret;
		case O3VecStructInt8Element:  
			for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) *((Int8*)(bytes+i*s)+j) = O3ByteswapLittleToHost(*((Int8*)(fbytes+i*s)+j)); return ret;
		case O3VecStructInt16Element: 
			for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) *((Int16*)(bytes+i*s)+j) = O3ByteswapLittleToHost(*((Int16*)(fbytes+i*s)+j)); return ret;
		case O3VecStructInt32Element: 
			for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) *((Int32*)(bytes+i*s)+j) = O3ByteswapLittleToHost(*((Int32*)(fbytes+i*s)+j)); return ret;
		case O3VecStructInt64Element: 
			for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) *((Int64*)(bytes+i*s)+j) = O3ByteswapLittleToHost(*((Int64*)(fbytes+i*s)+j)); return ret;
		case O3VecStructUInt8Element: 
			for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) *((UInt8*)(bytes+i*s)+j) = O3ByteswapLittleToHost(*((UInt8*)(fbytes+i*s)+j)); return ret;
		case O3VecStructUInt16Element:
			for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) *((UInt16*)(bytes+i*s)+j) = O3ByteswapLittleToHost(*((UInt16*)(fbytes+i*s)+j)); return ret;
		case O3VecStructUInt32Element:
			for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) *((UInt32*)(bytes+i*s)+j) = O3ByteswapLittleToHost(*((UInt32*)(fbytes+i*s)+j)); return ret;
		case O3VecStructUInt64Element:
			for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) *((UInt64*)(bytes+i*s)+j) = O3ByteswapLittleToHost(*((UInt64*)(fbytes+i*s)+j)); return ret;
	}
	O3AssertFalse(@"Unknown type \"%c\" in vec struct %@", self->mElementType, self);
	#endif
	return ret;
}

- (NSMutableData*)translateStructs:(NSData*)instructs stride:(UIntP)s toFormat:(O3StructType*)oformat {
	O3VecStructType* format = (O3VecStructType*)oformat;
	if (![format isKindOfClass:[self class]]||mElementCount!=[format elementCount]) return [super translateStructs:instructs stride:s toFormat:oformat];
	if (mElementCount!=[format elementCount]) O3LogWarn(@"Truncating or zero-padding data in struct array conversion from %@ to %@ in %@",self,oformat,instructs);
	UIntP count = [instructs length]/s;
	NSMutableData* ret = [NSMutableData dataWithLength:[oformat structSize]*count];
	void* returnbuf = [ret mutableBytes];
	const void* bytes = [instructs bytes];
	O3VecStructElementType type = [format elementType];
	double mymul = mMultiplier;
	double rmul = 1./[(O3VecStructType*)oformat multiplier];
	if (!mPermutations) {
			UIntP i,j; for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) {
				double val = O3DoubleValueOfType_at_withIndex_(mElementType, (UInt8*)bytes+i*s, j)*mymul;
				O3SetValueOfType_at_toDouble_withIndex_(type, returnbuf, val*rmul, j);
			}
	} else {
		UIntP* otherPermArray = [format permutations];
			UIntP i,j; for(i=0; i<count; i++) for (j=0; j<mElementCount; j++) {
				double val = O3DoubleValueOfType_at_withIndex_(mElementType, (UInt8*)bytes+i*s, mPermutations[j])*mymul;
				O3SetValueOfType_at_toDouble_withIndex_(type, returnbuf, val*rmul, mElementCount*i + otherPermArray[j]);
			}
	}
	[instructs relinquishBytes];
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
