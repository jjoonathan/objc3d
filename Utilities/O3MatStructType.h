//
//  O3MatStructType.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 2/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import "O3StructType.h"
#import "O3CTypes.h"

#define O3MatStructTypeDefines   /*to add a new type, add a DefType(name) here, then init it inside o3init*/                   \
	DefType(O3Mat4x4rType, 4, 4, real, @"rmat4x4r", YES);\
	DefType(O3Mat4x4fType, 4, 4, float, @"rmat4x4f", YES);\
	DefType(O3Mat4x4dType, 4, 4, double, @"rmat4x4d", YES);\
	DefType(O3Mat2x2fType, 2, 2, float, @"rmat2x2f", YES);\
	DefType(O3Mat2x2cdType, 2, 2, double, @"cmat2x2d", NO);

@interface O3MatStructType : O3StructType {
	O3StructType* mElementStructType;
	O3CType mType;
	UIntP mRows, mCols;
	UIntP mStructSize;
	BOOL mRowMajor;
}
+ (void)o3init;
- (O3MatStructType*)initWithName:(NSString*)name eleType:(O3CType)et rows:(UIntP)r cols:(UIntP)c rowMajor:(BOOL)rm;
@end

#define DefType(NAME, ROWS, COLS, TYPE, STRNAME, RMAJOR) O3MatStructType* NAME ();
O3MatStructTypeDefines
#undef DefType