//
//  O3VecStructType.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3StructType.h"
@class O3VecStruct;

enum O3VecStructSpecificType {
	O3VecStructRotation=1,
	O3VecStructPoint=2,
	O3VecStructScale=3,
	O3VecStructIndex=4,
	O3VecStructVec=5,
	O3VecStructColor=6
};

enum O3VecStructElementType {
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
};

@interface O3VecStructType : O3StructType {
	BOOL mFreePermsWhenDone:1;
	enum O3VecStructElementType mElementType;
	enum O3VecStructSpecificType mSpecificType;
	short mElementCount; ///<The number of elements
	double mMultiplier; ///<Amount to multiply each element by. Useful for normalized formats.
	UIntP* mPermutations; ///<mPermutations[i] is the raw index of the element at normal index i. For instance, 2,1,0,3 would be the permutation array for a RGBA color
}
//Init
+ (O3VecStructType*)vecStructTypeWithElementType:(enum O3VecStructElementType)type
                                    specificType:(enum O3VecStructSpecificType)stype
                                           count:(int)count
                                            name:(NSString*)name;
- (O3VecStructType*)initWithElementType:(enum O3VecStructElementType)type specificType:(enum O3VecStructSpecificType)stype count:(int)count name:(NSString*)name;

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

- (enum O3VecStructElementType)elementType;
- (enum O3VecStructSpecificType)specificType;
- (short)elementCount;

@end

O3EXTERN_C_BLOCK
O3VecStructType* O3Vec3fType(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Vec3dType(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Vec3rType(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Vec4fType(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Vec4dType(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Vec4rType(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Rot3dType(); ///<Convenience function to return a commonly used type
//O3VecStructType* O3Point3dType(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Point3fType(); ///<Convenience function to return a commonly used type
//O3VecStructType* O3Point4dType(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Scale3dType(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Index3x8Type(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Index3x16Type(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Index3x32Type(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Index3x64Type(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Index4x8Type(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Index4x16Type(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Index4x32Type(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Index4x64Type(); ///<Convenience function to return a commonly used type

UIntP* O3VecStructTypePermsAndMultiplier(O3VecStructType* self, double* multiplier); ///<Gets a vec struct type's permutation array and element multiplier
void O3VecStructTypeGetType_count_specificType_(O3VecStructType* self, enum O3VecStructElementType* type, short* count, enum O3VecStructSpecificType* stype);
UIntP O3VecStructSize(O3VecStructType* type);

NSNumber* O3VecStructGetElement(O3VecStructType* self, UIntP i, const void* bytes);
void O3WriteNumberTo(O3VecStructElementType eleType, UIntP i, void* bytes, NSNumber* num);
O3END_EXTERN_C

#ifdef __cplusplus
double O3DoubleValueOfType_at_withIndex_(enum O3VecStructElementType type, const void* bytes, UIntP idx = 0);
Int64 O3Int64ValueOfType_at_withIndex_(enum O3VecStructElementType type, const void* bytes, UIntP idx = 0);
UInt64 O3UInt64ValueOfType_at_withIndex_(enum O3VecStructElementType type, const void* bytes, UIntP idx = 0);
void O3SetValueOfType_at_toDouble_withIndex_(enum O3VecStructElementType type, void* bytes, double v, UIntP idx = 0);
void O3SetValueOfType_at_toInt64_withIndex_(enum O3VecStructElementType type, void* bytes, Int64 v, UIntP idx = 0);
void O3SetValueOfType_at_toUInt64_withIndex_(enum O3VecStructElementType type, void* bytes, UInt64 v, UIntP idx = 0);
#endif
