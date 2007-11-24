//
//  O3VecStruct.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3ByteStruct.h"

@interface O3VecStruct : O3ByteStruct {
}
//Custom init
- (O3VecStruct*)initWithType:(O3VecStructType*)type values:(double)val,...;

//Access
- (double)x;
- (double)y;
- (double)z;
- (double)w;

- (double)r;
- (double)g;
- (double)b;
- (double)a;

- (double)roll;
- (double)pitch;
- (double)yaw;

- (double)valueAtIndex:(UIntP)idx;

//Convenience (NOTE: many more types are available. These are simply commonly used)
O3VecStruct* O3Vec3dStruct(double x, double y, double z);
O3VecStruct* O3Point3dStruct(double x, double y, double z);
O3VecStruct* O3Point4dStruct(double x, double y, double z, double w);
O3VecStruct* O3Scale3dStruct(double x, double y, double z);

@end

double O3VecStructDoubleValueAtIndex(O3VecStruct* self, UIntP idx);
Int64 O3VecStructInt64ValueAtIndex(O3VecStruct* self, UIntP idx);
UInt64 O3VecStructUInt64ValueAtIndex(O3VecStruct* self, UIntP idx);
