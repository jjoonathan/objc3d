//
//  O3MatStructType.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 2/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import "O3MatStructType.h"
#import "O3ScalarStructType.h"
#import "O32DStructArray.h"
#import "O3GPUData.h"

#define DefType(NAME, ROWS, COLS, TYPE, STRNAME, RMAJOR) O3MatStructType* g ## NAME = nil; O3MatStructType* NAME () {return g ## NAME;}          
O3MatStructTypeDefines
#undef DefType




@implementation O3MatStructType
O3DefaultO3InitializeImplementation
#define structSizeP(SELF) (mRows*mCols*O3CTypeSize(SELF->mType))

/************************************/ #pragma mark Init /************************************/
+ (void)o3init {
	#define DefType(NAME, ROWS, COLS, TYPE, STRNAME, RMAJOR) g ## NAME = [[O3MatStructType alloc] initWithName:STRNAME eleType:O3CTypeEncoded(@encode(TYPE)) rows:ROWS cols:COLS rowMajor:RMAJOR];
	O3MatStructTypeDefines
	#undef DefType
}

- (O3MatStructType*)initWithName:(NSString*)name eleType:(O3CType)et rows:(UIntP)r cols:(UIntP)c rowMajor:(BOOL)rm {
	if (![super initWithName:name]) return nil;
	mType = et;
	mRows = r;
	mCols = c;
	mRowMajor = rm;
	O3Asrt(et && r && c);
	mStructSize = structSizeP(self);
	mElementStructType = [O3ScalarStructType scalarTypeWithCType:mType];
	return self;
}

/************************************/ #pragma mark Protocol /************************************/
- (UIntP)structSize {
	return mStructSize;
}

- (id)objectWithBytes:(const void*)bytes {
	O32DStructArray* obj = [[[O32DStructArray alloc] initWithBytes:O3MemDup(bytes, mStructSize) type:mElementStructType length:mStructSize] rows:mRows cols:mCols rowMajor:mRowMajor];
	return [obj autorelease];
}

- (void)writeObject:(id)obj toBytes:(void*)tbytes {
	UInt8* bytes = (UInt8*)tbytes;
	O3Asrt([obj isKindOfClass:[O32DStructArray class]]);
	O32DStructArray* arr = (O32DStructArray*)obj;
	O3Asrt(bytes);
	NSData* objd = [arr rawData];
	UIntP count = mRows*mCols; count;
	O3Asrt([arr count]==count);
	UInt8* frombytes = (UInt8*)[objd bytes];
	O3Asrt(frombytes);
	O3CType fromtype = [(O3ScalarStructType*)[arr structType] type];
	UIntP fromstride = O3CTypeSize(fromtype);
	UIntP tostride = O3CTypeSize(mType);
	
	BOOL transpose = (mRowMajor ^ [arr isRowMajor]);
	for (UIntP r=0; r<mRows; r++) {
		for (UIntP c=0; c<mCols; c++) {
			UIntP f = c+r*mCols;
			UIntP t = transpose? c*mRows+r : c+r*mRows;
			O3CTypeTranslateFromTo(fromtype, mType, frombytes+f*fromstride, bytes+tostride*t);
		}
	}
	
	[objd relinquishBytes];
}

+ (BOOL)selfTest {
	float arr[] = {1, 2, 3, 4};
	float arr2[] = {0, 0, 0, 0};
	O32DStructArray* arr_obj = (O32DStructArray*)[O3StructTypeForName(@"rmat2x2f") objectWithBytes:arr];
	if (![arr_obj isKindOfClass:[O32DStructArray class]]) return NO;
	if (![[arr_obj objectAtRow:0 col:0] intValue]!=1) return NO;
	if (![[arr_obj objectAtRow:0 col:1] intValue]!=2) return NO;
	if (![[arr_obj objectAtRow:1 col:0] intValue]!=3) return NO;
	if (![[arr_obj objectAtRow:1 col:1] intValue]!=4) return NO;
	[O3StructTypeForName(@"rmat2x2f") writeObject:arr_obj toBytes:arr2];
	if (arr[0]!=arr2[0]) return NO;
	if (arr[1]!=arr2[1]) return NO;
	if (arr[2]!=arr2[2]) return NO;
	if (arr[3]!=arr2[3]) return NO;
	double arr3[] = {0,0,0,0};
	[O3StructTypeForName(@"cmat2x2d") writeObject:arr_obj toBytes:arr2];
	if (O3Abs(arr[0]-arr3[0])>1e-5) return NO;
	if (O3Abs(arr[1]-arr3[2])>1e-5) return NO;
	if (O3Abs(arr[2]-arr3[1])>1e-5) return NO;
	if (O3Abs(arr[3]-arr3[3])>1e-5) return NO;
	return YES;
}

@end
