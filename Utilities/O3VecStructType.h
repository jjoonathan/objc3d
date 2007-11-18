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
	O3VecStructRotation,
	O3VecStructPoint,
	O3VecStructScale,
	O3VecStructIndex,
	O3VecStructVec,
	O3VecStructColor
};

enum O3VecStructElementType {
	O3VecStructFloatElement,
	O3VecStructDoubleElement,
	O3VecStructInt8Element,
	O3VecStructInt16Element,
	O3VecStructInt32Element,
	O3VecStructInt64Element,
	O3VecStructUInt8Element,
	O3VecStructUInt16Element,
	O3VecStructUInt32Element,
	O3VecStructUInt64Element,
};

@interface O3VecStructType : O3StructType {
	enum O3VecStructElementType mElementType;
	enum O3VecStructSpecificType mSpecificType;
	short mElementCount; ///<The number of elements
}
+ (O3VecStructType*)vecStructTypeWithElementType:(enum O3VecStructElementType)type
                                    specificType:(enum O3VecStructSpecificType)stype
                                           count:(int)count
                                            name:(NSString*)name;
- (O3VecStructType*)initWithElementType:(enum O3VecStructElementType)type specificType:(O3VecStructSpecificType)stype count:(int)count name:(NSString*)name;

+ (O3VecStructType*)vec3fType;     //Convenience method to return a commonly used struct type (use function instead if possible)
+ (O3VecStructType*)vec3dType;     //Convenience method to return a commonly used struct type (use function instead if possible)
+ (O3VecStructType*)vec3rType;     //Convenience method to return a commonly used struct type (use function instead if possible)
+ (O3VecStructType*)vec4fType;     //Convenience method to return a commonly used struct type (use function instead if possible)
+ (O3VecStructType*)vec4dType;     //Convenience method to return a commonly used struct type (use function instead if possible)
+ (O3VecStructType*)vec4rType;     //Convenience method to return a commonly used struct type (use function instead if possible)
+ (O3VecStructType*)rot3dType;     //Convenience method to return a commonly used struct type (use function instead if possible)
+ (O3VecStructType*)point3dTsype;     //Convenience method to return a commonly used struct type (use function instead if possible)
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

//O3StructType protocol
- (UIntP)structSize;
- (NSArray*)structKeys;
- (void)portabalizeStructsAt:(void*)bytes count:(UIntP)count;
- (void)deportabalizeStructsAt:(void*)bytes count:(UIntP)conut;
- (void*)translateStructsAt:(const void*)bytes count:(UIntP)count toFormat:(O3StructType*)oformat;

@end

O3VecStructType* O3Vec3fType(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Vec3dType(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Vec3rType(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Vec4fType(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Vec4dType(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Vec4rType(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Rot3dType(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Point3dType(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Scale3dType(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Index3x8Type(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Index3x16Type(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Index3x32Type(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Index3x64Type(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Index4x8Type(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Index4x16Type(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Index4x32Type(); ///<Convenience function to return a commonly used type
O3VecStructType* O3Index4x64Type(); ///<Convenience function to return a commonly used type

void O3VecStructTypeGetType_count_specificType_(O3VecStructType* self, enum O3VecStructElementType* type, short* count, O3VecStructSpecificType* stype);
UIntP O3VecStructSize(O3VecStructType* type);