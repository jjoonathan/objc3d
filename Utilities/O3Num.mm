//
//  O3Num.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 4/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import "O3Num.h"

@implementation O3Num
- (O3Num*)initWithInt64:(Int64)v {if (!O3AllowInitHack) [super init]; mValue.intVal = v; return self;}
- (O3Num*)initWithDouble:(double)v {if (!O3AllowInitHack) [super init]; mValue.doubleVal = v; return self;}

- (int)intValue {return mValue.intVal;}
- (Int64)int64Value {return mValue.intVal;}
- (float)floatValue {return mValue.doubleVal;}
- (double)doubleValue {return mValue.doubleVal;}
- (NSString*)stringValue {return mIsFP?[NSString stringWithFormat:@"%f",mValue.doubleVal]:[NSString stringWithFormat:@"%q",mValue.intVal];}

Int64 O3NumInt64Value(O3Num* self) {return self->mValue.intVal;}
double O3NumDoubleValue(O3Num* self) {return self->mValue.doubleVal;}
void O3NumSetInt64Value(O3Num* self, Int64 v) {self->mValue.intVal = v;}
void O3NumSetDoubleValue(O3Num* self, double v) {self->mValue.doubleVal = v;}
Int64 O3NumInc(O3Num* self) {return ++(self->mValue.intVal);}
Int64 O3NumDec(O3Num* self) {return --(self->mValue.intVal);}

@end
