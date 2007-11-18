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
//Access
- (double)x;
- (double)y;
- (double)z;
- (double)w;
- (void)setX:(double)v;
- (void)setY:(double)v;
- (void)setZ:(double)v;
- (void)setW:(double)v;

- (double)r;
- (double)g;
- (double)b;
- (double)a;
- (void)setR:(double)v;
- (void)setG:(double)v;
- (void)setB:(double)v;
- (void)setA:(double)v;

- (double)roll;
- (double)pitch;
- (double)yaw;
- (void)setRoll:(double)v;
- (void)setPitch:(double)v;
- (void)setYaw:(double)v;

- (double)valueAtIndex:(UIntP)idx;
- (void)setValue:(double)v atIndex:(UIntP)idx;
@end

double O3VecStructDoubleValueAtIndex(O3VecStruct* self, UIntP idx);
Int64 O3VecStructInt64ValueAtIndex(O3VecStruct* self, UIntP idx);
UInt64 O3VecStructUInt64ValueAtIndex(O3VecStruct* self, UIntP idx);

void O3VecStructSetDoubleValueAtIndex(O3VecStruct* self, UIntP idx, double v);
void O3VecStructSetInt64ValueAtIndex(O3VecStruct* self, UIntP idx, Int64 v);
void O3VecStructSetUInt64ValueAtIndex(O3VecStruct* self, UIntP idx, UInt64 v);