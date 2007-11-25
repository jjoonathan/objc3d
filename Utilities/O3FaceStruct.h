//
//  O3FaceStruct.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#include "O3ByteStruct.h"

O3VecStructType* O3Triangle3x3fType();
O3VecStructType* O3IndexedTriangle3cType();
O3VecStructType* O3IndexedTriangle3sType();
O3VecStructType* O3IndexedTriangle3iType();

@interface O3FaceStruct : O3ByteStruct {
}
- (O3FaceStruct*)initWithV1:(O3Point3f)v1 v2:(O3Point3f)v2 v3:(O3Point3f)v3;
- (O3Point3f)v1;
- (O3Point3f)v2;
- (O3Point3f)v3;
//- (O3Point3f)v4;
@end
