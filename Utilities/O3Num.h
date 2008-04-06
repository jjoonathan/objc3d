//
//  O3Num.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 4/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

union O3NumValue {
	Int64 intVal;
	double doubleVal;
};

///Note that this class was designed for speed and is not type safe. It does not nicely cast ints to doubles. Use NSNumber for that.
@interface O3Num : NSObject {
	BOOL mIsFP;
	union O3NumValue mValue;
}
- (O3Num*)initWithInt64:(Int64)v;
- (O3Num*)initWithDouble:(double)v;
- (int)intValue;
- (Int64)int64Value;
- (float)floatValue;
- (double)doubleValue;
- (NSString*)stringValue;
@end

Int64 O3NumInt64Value(O3Num* self);
double O3NumDoubleValue(O3Num* self);
void O3NumSetInt64Value(O3Num* self, Int64 v);
void O3NumSetDoubleValue(O3Num* self, double v);
Int64 O3NumInc(O3Num* self); //Increments the receiver by 1 and returns the incremented number
Int64 O3NumDec(O3Num* self); //Decrements the receiver by 1 and returns the decremneted number
