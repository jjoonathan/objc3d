//
//  O3VecStruct.m
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3VecStruct.h"

/************************************/ #pragma mark Private C Functions /************************************/
//Private, since structs should be immutable.
//void O3VecStructSetDoubleValueAtIndex(O3VecStruct* self, UIntP idx, double v);
//void O3VecStructSetInt64ValueAtIndex(O3VecStruct* self, UIntP idx, Int64 v);
//void O3VecStructSetUInt64ValueAtIndex(O3VecStruct* self, UIntP idx, UInt64 v);

@implementation O3VecStruct
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
inline double accessIndexP(O3VecStruct* self, UIntP idx) {
	double mult; UIntP* perms = O3VecStructTypePermsAndMultiplier(self->mType, &mult);
	idx = perms? perms[idx] : idx;
	#ifdef O3DEBUG
	short c; O3VecStructTypeGetType_count_specificType_(self->mType, nil, &c, nil); O3Assert(c>=idx, @"Attempt to access element %i of %i element struct", c);
	#endif
	return mult * O3VecStructValueAtIndex(self, idx);
}

inline void setAtIndexP(O3VecStruct* self, UIntP idx, double val) {
	double mult; UIntP* perms = O3VecStructTypePermsAndMultiplier(self->mType, &mult);
	idx = perms? perms[idx] : idx;
	#ifdef O3DEBUG
	short c; O3VecStructTypeGetType_count_specificType_(self->mType, nil, &c, nil); O3Assert(c>=idx, @"Attempt to set element %i of %i element struct", c);
	#endif
	O3VecStructSetDoubleValueAtIndex(self, idx, val/mult);
}

- (double)x {return accessIndexP(self, 0);}
- (double)y {return accessIndexP(self, 1);}
- (double)z {return accessIndexP(self, 2);}
- (double)w {return accessIndexP(self, 3);}

- (double)r {return accessIndexP(self, 0);}
- (double)g {return accessIndexP(self, 1);}
- (double)b {return accessIndexP(self, 2);}
- (double)a {return accessIndexP(self, 3);}

- (double)roll {return accessIndexP(self, 0);}
- (double)pitch {return accessIndexP(self, 1);}
- (double)yaw {return accessIndexP(self, 2);}

- (double)valueAtIndex:(UIntP)idx {
	return accessIndexP(self, idx);
}

- (O3VecStruct*)initWithType:(O3VecStructType*)type values:(double)val,... {
	if (![super initWithType:type]) return nil;
	va_list argList;
	setAtIndexP(self, 0, val);
	short c; O3VecStructTypeGetType_count_specificType_(self->mType, nil, &c, nil);
	UIntP i; for(i=1; i<c; i++) {
		va_start(argList, val);
		setAtIndexP(self, i, va_arg(argList, double));
	}
	va_end(argList);
	return self;
}

@end
