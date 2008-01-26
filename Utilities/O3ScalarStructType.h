//
//  O3ScalarStructType.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 1/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import "O3StructType.h"
#import "O3CTypes.h"
#import "O3VecStructType.h"

#define O3ScalarStructTypeDefines /*to add a new type, add a DefType(name) here*/                   \
DefType(O3FloatType,O3FloatCType,@"f",float); \
DefType(O3DoubleType,O3DoubleCType,@"d",double);\
DefType(O3Int8Type,O3Int8CType,@"i8",Int8);\
DefType(O3Int16Type,O3Int16CType,@"i16",Int16);\
DefType(O3Int32Type,O3Int32CType,@"i32",Int32);\
DefType(O3Int64Type,O3Int64CType,@"i64",Int64);\
DefType(O3UInt8Type,O3UInt8CType,@"ui8",UInt8);\
DefType(O3UInt16Type,O3UInt16CType,@"ui16",UInt16);\
DefType(O3UInt32Type,O3UInt32CType,@"ui32",UInt32);\
DefType(O3UInt64Type,O3UInt64CType,@"ui64",UInt64);

@interface O3ScalarStructType : O3StructType {
	O3CType mType;
}
+ (O3ScalarStructType*)scalarTypeWithElementType:(O3CType)type name:(NSString*)name;
+ (O3ScalarStructType*)scalarTypeWithCType:(O3CType)t;
- (O3CType)type;
//Private
+ (void)o3init;
@end


#define DefType(NAME,TYPE,SNAME,CTYPE) O3ScalarStructType* NAME ();
O3ScalarStructTypeDefines
#undef DefType