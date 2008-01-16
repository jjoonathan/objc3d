//
//  O3VecStructType.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3FaceStructType.h"
#import "O3VecStructType.h"
#import "O3GPUData.h"

O3EXTERN_C_BLOCK

#define DefType(NAME, TYPE, ETYPE, CT) O3VecStructType* g ## NAME;   O3VecStructType* NAME () {return g ## NAME;}
O3VecStructTypeDefines
#undef DefType

#define DefType(NAME, TYPE, ETYPE, CT) int NAME ## Comparator (void* a, void* b, void* ctx) {\
	TYPE* aa = (TYPE*)a;\
	TYPE* bb = (TYPE*)b;\
	UIntP i; for(i=0; i<CT; i++) {\
		if (aa[i]<bb[i]) return NSOrderedAscending;\
		if (aa[i]>bb[i]) return NSOrderedDescending;\
	}\
	return NSOrderedSame;\
}
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
	gO3Vec3rType = [[O3VecStructType alloc] initWithElementType:rtype                     specificType:O3VecStructVec count:3 name:@"vec3r" comparator:O3Vec3rTypeComparator];
	gO3Vec3fType = [[O3VecStructType alloc] initWithElementType:O3VecStructFloatElement   specificType:O3VecStructVec count:3 name:@"vec3f" comparator:O3Vec3fTypeComparator];
	gO3Vec3dType = [[O3VecStructType alloc] initWithElementType:O3VecStructDoubleElement  specificType:O3VecStructVec count:3 name:@"vec3d" comparator:O3Vec3dTypeComparator];
	gO3Vec4rType = [[O3VecStructType alloc] initWithElementType:rtype                     specificType:O3VecStructVec count:4 name:@"vec4r" comparator:O3Vec4rTypeComparator];
	gO3Vec4fType = [[O3VecStructType alloc] initWithElementType:O3VecStructFloatElement   specificType:O3VecStructVec count:4 name:@"vec4f" comparator:O3Vec4fTypeComparator];
	gO3Vec4dType = [[O3VecStructType alloc] initWithElementType:O3VecStructDoubleElement  specificType:O3VecStructVec count:4 name:@"vec4d" comparator:O3Vec4dTypeComparator];
	gO3RGBA8Type = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt8Element  specificType:O3VecStructVec count:4 name:@"RGBA8" comparator:O3RGBA8TypeComparator];
		[gO3RGBA8Type setMultiplier:1./255];
	gO3RGB8Type    = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt8Element  specificType:O3VecStructVec count:3 name:@"RGB8" comparator:O3RGB8TypeComparator];
		[gO3RGB8Type setMultiplier:1./255];
	gO3Rot3dType     = [[O3VecStructType alloc] initWithElementType:O3VecStructDoubleElement  specificType:O3VecStructRotation count:3 name:@"rot3d" comparator:O3Rot3dTypeComparator];
	//gO3Point3d   = [[O3VecStructType alloc] initWithElementType:O3VecStructDoubleElement  specificType:O3VecStructPoint count:3 name:@"point3d"];
	gO3Point3fType   = [[O3VecStructType alloc] initWithElementType:O3VecStructFloatElement   specificType:O3VecStructPoint count:3 name:@"point3f" comparator:O3Point3fTypeComparator];
	//gO3Point4d   = [[O3VecStructType alloc] initWithElementType:O3VecStructDoubleElement  specificType:O3VecStructPoint count:4 name:@"point4d"];
	gO3Scale3dType   = [[O3VecStructType alloc] initWithElementType:O3VecStructDoubleElement  specificType:O3VecStructScale count:3 name:@"scale3d" comparator:O3Scale3dTypeComparator];
	gO3Index3x8Type  = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt8Element   specificType:O3VecStructIndex count:3 name:@"idx3x8" comparator:O3Index3x8TypeComparator];
	gO3Index3x16Type = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt16Element  specificType:O3VecStructIndex count:3 name:@"idx3x16" comparator:O3Index3x16TypeComparator];
	gO3Index3x32Type = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt32Element  specificType:O3VecStructIndex count:3 name:@"idx3x32" comparator:O3Index3x32TypeComparator];
	gO3Index3x64Type = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt64Element  specificType:O3VecStructIndex count:3 name:@"idx3x64" comparator:O3Index3x64TypeComparator];
	gO3Index4x8Type  = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt8Element   specificType:O3VecStructIndex count:4 name:@"idx4x8" comparator:O3Index4x8TypeComparator];
	gO3Index4x16Type = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt16Element  specificType:O3VecStructIndex count:4 name:@"idx4x16" comparator:O3Index4x16TypeComparator];
	gO3Index4x32Type = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt32Element  specificType:O3VecStructIndex count:4 name:@"idx4x32" comparator:O3Index4x32TypeComparator];
	gO3Index4x64Type = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt64Element  specificType:O3VecStructIndex count:4 name:@"idx4x64" comparator:O3Index4x64TypeComparator];
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
                                            name:(NSString*)name 
                                      comparator:(O3StructArrayComparator)comp {
	O3StructType* existingType = name? O3StructTypeForName(name) : nil;
	if (existingType) return (O3VecStructType*)existingType;
	return [[[self alloc] initWithElementType:type specificType:stype count:count name:name comparator:comp] autorelease];
}

/************************************/ #pragma mark Init /************************************/
- (O3VecStructType*)initWithElementType:(O3VecStructElementType)type specificType:(O3VecStructSpecificType)stype count:(int)count name:(NSString*)name comparator:(O3StructArrayComparator)comp {
	[super initWithName:name];
	mMultiplier = 1;
	mElementType = type;
	mElementCount = count;
	mSpecificType = stype;
	mComp = comp;
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

- (NSData*)portabalizeStructsAt:(const void*)at count:(UIntP)count stride:(UIntP)s {
	UIntP strSize = [self structSize];
	if (!s) s = strSize;
	const UInt8* bytes = (const UInt8*)at;
	UInt8* tbytes = (UInt8*)malloc(strSize*count);
	UIntP i,j;
	#define Swap(type) for(i=0; i<count; i++) for(j=0; j<mElementCount; j++) *((type*)(tbytes+i*s)+j) = O3ByteswapHostToLittle(*((type*)(bytes+i*s)+j)); break;
	switch (self->mElementType) {
		case O3VecStructFloatElement: Swap(float);
		case O3VecStructDoubleElement: Swap(double);
		case O3VecStructInt8Element: Swap(Int8);
		case O3VecStructInt16Element: Swap(Int16);
		case O3VecStructInt32Element: Swap(Int32);
		case O3VecStructInt64Element: Swap(Int64);
		case O3VecStructUInt8Element: Swap(UInt8);
		case O3VecStructUInt16Element: Swap(UInt16);
		case O3VecStructUInt32Element: Swap(UInt32);
		case O3VecStructUInt64Element: Swap(UInt64);
		default: O3AssertFalse(@"Unknown type \"%c\" in vec struct %@", self->mElementType, self);	
	}
	#undef Swap
	return [NSData dataWithBytesNoCopy:tbytes length:strSize*count freeWhenDone:YES];
}

- (NSData*)deportabalizeStructs:(NSData*)indata to:(void*)target stride:(UIntP)s {
	if (!O3NeedByteswapToLittle && !target) return indata;
	UIntP size = [indata length];
	if (!s) s = [self structSize];
	UIntP count = size / s;
	BOOL had_to_malloc_target = target? NO : YES;
	if (!target) target = malloc(s*count);
	UInt8* tbytes = (UInt8*)target;
	const UInt8* fbytes = (const UInt8*)[indata bytes];
	UIntP i,j;
	#define Swap(type) for(i=0; i<count; i++) for(j=0; j<mElementCount; j++) *((type*)(tbytes+i*s)+j) = O3ByteswapLittleToHost(*((type*)(fbytes+i*s)+j)); break;
	switch (self->mElementType) {
		case O3VecStructFloatElement: Swap(float);
		case O3VecStructDoubleElement: Swap(double);
		case O3VecStructInt8Element: Swap(Int8);
		case O3VecStructInt16Element: Swap(Int16);
		case O3VecStructInt32Element: Swap(Int32);
		case O3VecStructInt64Element: Swap(Int64);
		case O3VecStructUInt8Element: Swap(UInt8)
		case O3VecStructUInt16Element: Swap(UInt16);
		case O3VecStructUInt32Element: Swap(UInt32);
		case O3VecStructUInt64Element: Swap(UInt64);
		default: O3AssertFalse(@"Unknown type \"%c\" in vec struct %@", self->mElementType, self);	
	}
	#undef Swap
	[indata relinquishBytes];
	return had_to_malloc_target? [NSData dataWithBytesNoCopy:target length:s*count freeWhenDone:YES] : nil;
}

- (NSMutableData*)translateStructs:(NSData*)instructs stride:(UIntP)s toFormat:(O3StructType*)oformat {
	O3VecStructType* format = (O3VecStructType*)oformat;
	if (![format isKindOfClass:[self class]]||mElementCount!=[format elementCount]) return [super translateStructs:instructs stride:s toFormat:oformat];
	if (mElementCount!=[format elementCount]) {
		if (mElementCount==1) O3LogWarn(@"@todo Packing data in struct array conversion from %@ to %@ in %@",self,oformat,instructs);
		else if ([format elementCount]==1) O3LogWarn(@"@todo Unpacking data in struct array conversion from %@ to %@ in %@",self,oformat,instructs);
		else if (mElementCount>[format elementCount]) O3LogWarn(@"@todo Truncating data in struct array conversion from %@ to %@ in %@",self,oformat,instructs);
		else if (mElementCount<[format elementCount]) O3LogWarn(@"@todo Zero-padding data in struct array conversion from %@ to %@ in %@",self,oformat,instructs);
	}
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

- (void)getFormat:(out GLenum*)format components:(out GLsizeiptr*)components offset:(out GLint*)offset stride:(out GLint*)stride normed:(out GLboolean*)normed vertsPerStruct:(out int*)vps forType:(in O3VertexDataType)type {
	if (format) {
	   switch (mElementType) {
	   	case O3VecStructFloatElement:  *format = GL_FLOAT; break;
	   	case O3VecStructDoubleElement: *format = GL_DOUBLE; break;
	   	case O3VecStructInt8Element:   *format = GL_BYTE; break;
	   	case O3VecStructInt16Element:  *format = GL_SHORT; break;
	   	case O3VecStructInt32Element:  *format = GL_INT; break;
	   	//case O3VecStructInt64Element:  return 0;
	   	case O3VecStructUInt8Element:  *format = GL_UNSIGNED_BYTE; break;
	   	case O3VecStructUInt16Element: *format = GL_UNSIGNED_SHORT; break;
		case O3VecStructUInt32Element: *format = GL_UNSIGNED_INT; break;
	   	//case O3VecStructUInt64Element: return 0;
		default: O3AssertFalse(@"Unknown GL type for type \"%c\" in vec struct %@", mElementType, self);
	   }
	   
	}
	if (components) *components = mElementCount;
	if (offset) *offset = 0;
	if (stride) *stride = O3VecStructSize(self);
	if (normed) *normed = (mMultiplier<.5)? GL_TRUE : GL_FALSE;
	if (vps) *vps = 1;
}

- (O3StructArrayComparator)defaultComparator {
	return mComp;
}

@end
