//
//  O3VecStructType.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3StructType.h"
@class O3VecStruct;

#define O3VecStructTypeDefines   /*to add a new type, add a DefType(name) here, then init it inside o3init*/                   \
DefType(O3Vec3rType); DefType(O3Index4x64Type); DefType(O3Index4x32Type); DefType(O3Index4x16Type); DefType(O3Index4x8Type);   \
DefType(O3Index3x64Type); DefType(O3Index3x32Type); DefType(O3Index3x16Type); DefType(O3Index3x8Type); DefType(O3Scale3dType); \
DefType(O3Point3fType); DefType(O3Rot3dType); DefType(O3Vec4dType); DefType(O3Vec4fType); DefType(O3Vec4rType);                \
DefType(O3Vec3dType); DefType(O3Vec3fType); DefType(O3RGBA8Type); DefType(O3RGB8Type);

typedef enum {
	O3VecStructRotation=1,
	O3VecStructPoint=2,
	O3VecStructScale=3,
	O3VecStructIndex=4,
	O3VecStructVec=5,
	O3VecStructColor=6
} O3VecStructSpecificType;

typedef enum {
	O3VecStructFloatElement=1,
	O3VecStructDoubleElement=2,
	O3VecStructInt8Element=3,
	O3VecStructInt16Element=4,
	O3VecStructInt32Element=5,
	O3VecStructInt64Element=6,
	O3VecStructUInt8Element=7,
	O3VecStructUInt16Element=8,
	O3VecStructUInt32Element=9,
	O3VecStructUInt64Element=10
} O3VecStructElementType;

@interface O3VecStructType : O3StructType {
	BOOL mFreePermsWhenDone:1;
	O3VecStructElementType mElementType;
	O3VecStructSpecificType mSpecificType;
	short mElementCount; ///<The number of elements
	double mMultiplier; ///<Amount to multiply each element by. Useful for normalized formats.
	UIntP* mPermutations; ///<mPermutations[visible_index]=stored_index
}
//Init
+ (O3VecStructType*)vecStructTypeWithElementType:(O3VecStructElementType)type
                                    specificType:(O3VecStructSpecificType)stype
                                           count:(int)count
                                            name:(NSString*)name;
- (O3VecStructType*)initWithElementType:(O3VecStructElementType)type specificType:(O3VecStructSpecificType)stype count:(int)count name:(NSString*)name;

//Special info
- (double)multiplier; ///<The amount by which each element is multiplied before being returned
- (void)setMultiplier:(double)newMult;
- (UIntP*)permutations; ///<The index-to-index mapping of element to element position in the receiver
- (void)setPermutations:(UIntP*)newPerms freeWhenDone:(BOOL)fwd; ///<Sets the permutation array to %newPerms, which will be freed when the receiver is

//Predefined types
+ (O3VecStructType*)vec3fType;     //Convenience method to return a commonly used struct type (use function instead if possible)
+ (O3VecStructType*)vec3dType;     //Convenience method to return a commonly used struct type (use function instead if possible)
+ (O3VecStructType*)vec3rType;     //Convenience method to return a commonly used struct type (use function instead if possible)
+ (O3VecStructType*)vec4fType;     //Convenience method to return a commonly used struct type (use function instead if possible)
+ (O3VecStructType*)vec4dType;     //Convenience method to return a commonly used struct type (use function instead if possible)
+ (O3VecStructType*)vec4rType;     //Convenience method to return a commonly used struct type (use function instead if possible)
+ (O3VecStructType*)rot3dType;     //Convenience method to return a commonly used struct type (use function instead if possible)
//+ (O3VecStructType*)point3dType;     //Convenience method to return a commonly used struct type (use function instead if possible)
+ (O3VecStructType*)point3fType;     //Convenience method to return a commonly used struct type (use function instead if possible)
//+ (O3VecStructType*)point4dType;     //Convenience method to return a commonly used struct type (use function instead if possible)
+ (O3VecStructType*)scale3dType;     //Convenience method to return a commonly used struct type (use function instead if possible)
+ (O3VecStructType*)index3x8Type;     //Convenience method to return a commonly used struct type (use function instead if possible)
+ (O3VecStructType*)index3x16Type;     //Convenience method to return a commonly used struct type (use function instead if possible)
+ (O3VecStructType*)index3x32Type;     //Convenience method to return a commonly used struct type (use function instead if possible)
+ (O3VecStructType*)index3x64Type;     //Convenience method to return a commonly used struct type (use function instead if possible)
+ (O3VecStructType*)index4x8Type;     //Convenience method to return a commonly used struct type (use function instead if possible)
+ (O3VecStructType*)index4x16Type;     //Convenience method to return a commonly used struct type (use function instead if possible)
+ (O3VecStructType*)index4x32Type;     //Convenience method to return a commonly used struct type (use function instead if possible)
+ (O3VecStructType*)index4x64Type;     //Convenience method to return a commonly used struct type (use function instead if possible)

- (O3VecStructElementType)elementType;
- (O3VecStructSpecificType)specificType;
- (short)elementCount;

//Private
+ (void)o3init;

@end

O3EXTERN_C_BLOCK
NSNumber* O3VecStructGetElement(O3VecStructType* self, UIntP i, const void* bytes);

#define DefType(NAME) O3VecStructType* NAME ();
O3VecStructTypeDefines
#undef DefType

UIntP* O3VecStructTypePermsAndMultiplier(O3VecStructType* self, double* multiplier); ///<Gets a vec struct type's permutation array and element multiplier
void O3VecStructTypeGetType_count_specificType_(O3VecStructType* self, O3VecStructElementType* type, short* count, O3VecStructSpecificType* stype);
UIntP O3VecStructSize(O3VecStructType* type);

void O3WriteNumberTo(O3VecStructElementType eleType, UIntP i, void* bytes, NSNumber* num, double rmul, UIntP* mPermutations);
O3END_EXTERN_C
