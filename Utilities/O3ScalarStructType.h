//
//  O3ScalarStructType.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 1/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import "O3StructType.h"
#import "O3VecStructType.h"

#define O3ScalarStructTypeDefines /*to add a new type, add a DefType(name) here*/                   \
DefType(O3FloatType,O3VecStructFloatElement,@"f"); \
DefType(O3DoubleType,O3VecStructDoubleElement,@"d");\
DefType(O3Int8Type,O3VecStructInt8Element,@"i8");\
DefType(O3Int16Type,O3VecStructInt16Element,@"i16");\
DefType(O3Int32Type,O3VecStructInt16Element,@"i32");\
DefType(O3Int64Type,O3VecStructInt16Element,@"i64");\
DefType(O3UInt8Type,O3VecStructUInt8Element,@"ui8");\
DefType(O3UInt16Type,O3VecStructUInt16Element,@"ui16");\
DefType(O3UInt32Type,O3VecStructUInt16Element,@"ui32");\
DefType(O3UInt64Type,O3VecStructUInt16Element,@"ui64");

@interface O3ScalarStructType : O3StructType {
	O3VecStructElementType mType;
}
+ (O3ScalarStructType*)scalarTypeWithElementType:(O3VecStructElementType)type name:(NSString*)name;
//Private
+ (void)o3init;
@end


#define DefType(NAME,TYPE,SNAME) O3ScalarStructType* NAME ();
O3ScalarStructTypeDefines
#undef DefType