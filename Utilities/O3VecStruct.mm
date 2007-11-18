//
//  O3VecStruct.m
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3VecStruct.h"

@implementation O3VecStruct
/************************************/ #pragma mark KVC /************************************/
+ (void)initialize {
	[self setKeys:[NSArray arrayWithObjects:@"r", @"roll", nil] triggerChangeNotificationsForDependentKey:@"x"];
	[self setKeys:[NSArray arrayWithObjects:@"x", @"roll", nil] triggerChangeNotificationsForDependentKey:@"r"];
	[self setKeys:[NSArray arrayWithObjects:@"x", @"r", nil] triggerChangeNotificationsForDependentKey:@"roll"];
	
	[self setKeys:[NSArray arrayWithObjects:@"g", @"pitch", nil] triggerChangeNotificationsForDependentKey:@"y"];
	[self setKeys:[NSArray arrayWithObjects:@"y", @"pitch", nil] triggerChangeNotificationsForDependentKey:@"g"];
	[self setKeys:[NSArray arrayWithObjects:@"y", @"g", nil] triggerChangeNotificationsForDependentKey:@"pitch"];
	
	[self setKeys:[NSArray arrayWithObjects:@"b", @"yaw", nil] triggerChangeNotificationsForDependentKey:@"z"];
	[self setKeys:[NSArray arrayWithObjects:@"z", @"yaw", nil] triggerChangeNotificationsForDependentKey:@"b"];
	[self setKeys:[NSArray arrayWithObjects:@"z", @"b", nil] triggerChangeNotificationsForDependentKey:@"yaw"];
	
	[self setKeys:[NSArray arrayWithObject:@"w"] triggerChangeNotificationsForDependentKey:@"a"];
	[self setKeys:[NSArray arrayWithObject:@"a"] triggerChangeNotificationsForDependentKey:@"w"];
}

/************************************/ #pragma mark C Accessors /************************************/
double O3VecStructValueAtIndex(O3VecStruct* self, UIntP idx) {
	enum O3VecStructElementType t;
	short c;
	O3VecStructTypeGetType_count_specificType_((O3VecStructType*)self->mType, &t, &c, nil); O3Assert(c>idx, @"Attempt to access struct element %i outside of bounds %i.", (int)idx, (int)c);
	return O3DoubleValueOfType_at_withIndex_(t, self->mBytes, c);
}

Int64 O3VecStructInt64ValueAtIndex(O3VecStruct* self, UIntP idx) {
	enum O3VecStructElementType t;
	short c;
	O3VecStructTypeGetType_count_specificType_((O3VecStructType*)self->mType, &t, &c, nil); O3Assert(c>idx, @"Attempt to access struct element %i outside of bounds %i.", (int)idx, (int)c);
	return O3Int64ValueOfType_at_withIndex_(t, self->mBytes, c);
}

UInt64 O3VecStructUInt64ValueAtIndex(O3VecStruct* self, UIntP idx) {
	enum O3VecStructElementType t;
	short c;
	O3VecStructTypeGetType_count_specificType_((O3VecStructType*)self->mType, &t, &c, nil); O3Assert(c>idx, @"Attempt to access struct element %i outside of bounds %i.", (int)idx, (int)c);
	return O3UInt64ValueOfType_at_withIndex_(t, self->mBytes, c);
}

void O3VecStructSetDoubleValueAtIndex(O3VecStruct* self, UIntP idx, double v) {
	enum O3VecStructElementType t;
	short c;
	O3VecStructTypeGetType_count_specificType_((O3VecStructType*)self->mType, &t, &c, nil); O3Assert(c>idx, @"Attempt to access struct element %i outside of bounds %i.", (int)idx, (int)c);
	O3SetValueOfType_at_toDouble_withIndex_(t, self->mBytes, v, idx);
}

void O3VecStructSetInt64ValueAtIndex(O3VecStruct* self, UIntP idx, Int64 v) {
	enum O3VecStructElementType t;
	short c;
	O3VecStructTypeGetType_count_specificType_((O3VecStructType*)self->mType, &t, &c, nil); O3Assert(c>idx, @"Attempt to access struct element %i outside of bounds %i.", (int)idx, (int)c);
	O3SetValueOfType_at_toInt64_withIndex_(t, self->mBytes, v, idx);
}

void O3VecStructSetUInt64ValueAtIndex(O3VecStruct* self, UIntP idx, UInt64 v) {
	enum O3VecStructElementType t;
	short c;
	O3VecStructTypeGetType_count_specificType_((O3VecStructType*)self->mType, &t, &c, nil); O3Assert(c>idx, @"Attempt to access struct element %i outside of bounds %i.", (int)idx, (int)c);
	O3SetValueOfType_at_toUInt64_withIndex_(t,self->mBytes, v, idx);
}

/************************************/ #pragma mark Access /************************************/
- (double)x {
	short c; O3VecStructTypeGetType_count_specificType_(mType, nil, &c, nil); O3Assert(c>0, @"Attempt to access element 0 of %i element struct", c);
	return O3VecStructValueAtIndex(self, 0);
}

- (double)y {
	short c; O3VecStructTypeGetType_count_specificType_(mType, nil, &c, nil); O3Assert(c>1, @"Attempt to access element 1 of %i element struct", c);
	return O3VecStructValueAtIndex(self, 1);
}

- (double)z {
	short c; O3VecStructTypeGetType_count_specificType_(mType, nil, &c, nil); O3Assert(c>2, @"Attempt to access element 2 of %i element struct", c);
	return O3VecStructValueAtIndex(self, 2);
}

- (double)w {
	short c; O3VecStructTypeGetType_count_specificType_(mType, nil, &c, nil); O3Assert(c>3, @"Attempt to access element 3 of %i element struct", c);
	return O3VecStructValueAtIndex(self, 3);
}

- (void)setX:(double)v {
	short c; O3VecStructTypeGetType_count_specificType_(mType, nil, &c, nil); O3Assert(c>0, @"Attempt to access element 0 of %i element struct", c);
	O3VecStructSetDoubleValueAtIndex(self, 0, v);
}

- (void)setY:(double)v {
	short c; O3VecStructTypeGetType_count_specificType_(mType, nil, &c, nil); O3Assert(c>1, @"Attempt to access element 1 of %i element struct", c);
	O3VecStructSetDoubleValueAtIndex(self, 1, v);
}

- (void)setZ:(double)v {
	short c; O3VecStructTypeGetType_count_specificType_(mType, nil, &c, nil); O3Assert(c>2, @"Attempt to access element 2 of %i element struct", c);
	O3VecStructSetDoubleValueAtIndex(self, 2, v);	
}

- (void)setW:(double)v {
	short c; O3VecStructTypeGetType_count_specificType_(mType, nil, &c, nil); O3Assert(c>3, @"Attempt to access element 3 of %i element struct", c);
	O3VecStructSetDoubleValueAtIndex(self, 3, v);
}




- (double)r {
	short c; O3VecStructTypeGetType_count_specificType_(mType, nil, &c, nil); O3Assert(c>0, @"Attempt to access element 0 of %i element struct", c);
	return O3VecStructValueAtIndex(self, 1);
}

- (double)g {
	short c; O3VecStructTypeGetType_count_specificType_(mType, nil, &c, nil); O3Assert(c>1, @"Attempt to access element 1 of %i element struct", c);
	return O3VecStructValueAtIndex(self, 2);
}

- (double)b {
	short c; O3VecStructTypeGetType_count_specificType_(mType, nil, &c, nil); O3Assert(c>2, @"Attempt to access element 2 of %i element struct", c);
	return O3VecStructValueAtIndex(self, 3);
}

- (double)a {
	short c; O3VecStructTypeGetType_count_specificType_(mType, nil, &c, nil); O3Assert(c>3, @"Attempt to access element 3 of %i element struct", c);
	return O3VecStructValueAtIndex(self, 4);
}

- (void)setR:(double)v {
	short c; O3VecStructTypeGetType_count_specificType_(mType, nil, &c, nil); O3Assert(c>0, @"Attempt to access element 0 of %i element struct", c);
	O3VecStructSetDoubleValueAtIndex(self, 0, v);
}

- (void)setG:(double)v {
	short c; O3VecStructTypeGetType_count_specificType_(mType, nil, &c, nil); O3Assert(c>1, @"Attempt to access element 1 of %i element struct", c);
	O3VecStructSetDoubleValueAtIndex(self, 1, v);
}

- (void)setB:(double)v {
	short c; O3VecStructTypeGetType_count_specificType_(mType, nil, &c, nil); O3Assert(c>2, @"Attempt to access element 2 of %i element struct", c);
	O3VecStructSetDoubleValueAtIndex(self, 2, v);
}

- (void)setA:(double)v {
	short c; O3VecStructTypeGetType_count_specificType_(mType, nil, &c, nil); O3Assert(c>3, @"Attempt to access element 3 of %i element struct", c);
	O3VecStructSetDoubleValueAtIndex(self, 3, v);
}




- (double)roll {
	short c; O3VecStructTypeGetType_count_specificType_(mType, nil, &c, nil); O3Assert(c>0, @"Attempt to access element 0 of %i element struct", c);
	return O3VecStructValueAtIndex(self, 1);
}

- (double)pitch {
	short c; O3VecStructTypeGetType_count_specificType_(mType, nil, &c, nil); O3Assert(c>1, @"Attempt to access element 1 of %i element struct", c);
	return O3VecStructValueAtIndex(self, 2);
}

- (double)yaw {
	short c; O3VecStructTypeGetType_count_specificType_(mType, nil, &c, nil); O3Assert(c>2, @"Attempt to access element 2 of %i element struct", c);
	return O3VecStructValueAtIndex(self, 3);
}

- (void)setRoll:(double)v {
	short c; O3VecStructTypeGetType_count_specificType_(mType, nil, &c, nil); O3Assert(c>0, @"Attempt to access element 0 of %i element struct", c);
	O3VecStructSetDoubleValueAtIndex(self, 0, v);
}

- (void)setPitch:(double)v {
	short c; O3VecStructTypeGetType_count_specificType_(mType, nil, &c, nil); O3Assert(c>1, @"Attempt to access element 1 of %i element struct", c);
	O3VecStructSetDoubleValueAtIndex(self, 1, v);
}

- (void)setYaw:(double)v {
	short c; O3VecStructTypeGetType_count_specificType_(mType, nil, &c, nil); O3Assert(c>2, @"Attempt to access element 2 of %i element struct", c);
	O3VecStructSetDoubleValueAtIndex(self, 2, v);
}

- (void)setValue:(double)v atIndex:(UIntP)idx {
	short c; O3VecStructTypeGetType_count_specificType_(mType, nil, &c, nil); O3Assert(c>idx, @"Attempt to access struct element %i outside of bounds %i.", (int)idx, (int)c);
	O3VecStructSetDoubleValueAtIndex(self, idx, v);
}

- (double)valueAtIndex:(UIntP)idx {
	short c; O3VecStructTypeGetType_count_specificType_(mType, nil, &c, nil); O3Assert(c>idx, @"Attempt to access struct element %i outside of bounds %i.", (int)idx, (int)c);
	return O3VecStructValueAtIndex(self, idx);
}

@end
