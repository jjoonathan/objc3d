//
//  O3VecStructType.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3StructType.h"
#import "O3CTypes.h"
@class O3VecStruct;

#define O3VecStructTypeDefines   /*to add a new type, add a DefType(name) here, then init it inside o3init*/                   \
DefType(O3Vec3rType,real,O3VecStructrealElement,3);\
DefType(O3Index4x64Type,UInt64,O3VecStructUInt64Element,4);\
DefType(O3Index4x32Type,UInt32,O3VecStructUInt32Element,4);\
DefType(O3Index4x16Type,UInt16,O3VecStructUInt16Element,4);\
DefType(O3Index4x8Type,UInt8,O3VecStructUInt8Element,4);\
DefType(O3Index3x64Type,Int64,O3VecStructInt64Element,3);\
DefType(O3Index3x32Type,Int32,O3VecStructInt32Element,3);\
DefType(O3Index3x16Type,Int16,O3VecStructInt16Element,3);\
DefType(O3Index3x8Type,Int8,O3VecStructInt8Element,3);\
DefType(O3Scale3dType,double,O3VecStructDoubleElement,3);\
DefType(O3Point3fType,float,O3VecStructFloatElement,3);\
DefType(O3Rot3dType,double,O3VecStructDoubleElement,3);\
DefType(O3Vec4dType,double,O3VecStructDoubleElement,3);\
DefType(O3Vec4fType,float,O3VecStructFloatElement,4);\
DefType(O3Vec4rType,real,O3VecStructRealElement,4);\
DefType(O3Vec3dType,double,O3VecStructDoubleElement,3);\
DefType(O3Vec3fType,float,O3VecStructFloatElement,3);\
DefType(O3RGBA8Type,UInt8,O3VecStructUInt8Element,4);\
DefType(O3RGB8Type,UInt8,O3VecStructUInt8Element,3);

typedef enum {
	O3VecStructRotation=1,
	O3VecStructPoint=2,
	O3VecStructScale=3,
	O3VecStructIndex=4,
	O3VecStructVec=5,
	O3VecStructColor=6
} O3VecStructSpecificType;



@interface O3VecStructType : O3StructType {
	BOOL mFreePermsWhenDone:1;
	O3CType mElementType; ///<@dep O3FaceStructType.mm
	O3VecStructSpecificType mSpecificType;
	short mElementCount; ///<The number of elements
	double mMultiplier; ///<Amount to multiply each element by. Useful for normalized formats.
	UIntP* mPermutations; ///<mPermutations[visible_index]=stored_index
	O3StructArrayComparator mComp;
}
//Init
+ (O3VecStructType*)vecStructTypeWithElementType:(O3CType)type
                                    specificType:(O3VecStructSpecificType)stype
                                           count:(int)count
                                            name:(NSString*)name
									  comparator:(O3StructArrayComparator)comp;
- (O3VecStructType*)initWithElementType:(O3CType)type specificType:(O3VecStructSpecificType)stype count:(int)count name:(NSString*)name comparator:(O3StructArrayComparator)comp;

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

- (O3CType)elementType;
- (O3VecStructSpecificType)specificType;
- (short)elementCount;

//Private
+ (void)o3init;

@end

O3EXTERN_C_BLOCK
NSNumber* O3VecStructGetElement(O3VecStructType* self, UIntP i, const void* bytes);

#define DefType(NAME, TYPE, ETYPE, CT) O3VecStructType* NAME ();
O3VecStructTypeDefines
#undef DefType

UIntP* O3VecStructTypePermsAndMultiplier(O3VecStructType* self, double* multiplier); ///<Gets a vec struct type's permutation array and element multiplier
void O3VecStructTypeGetType_count_specificType_(O3VecStructType* self, O3CType* type, short* count, O3VecStructSpecificType* stype);
UIntP O3VecStructSize(O3VecStructType* type);
O3END_EXTERN_C
