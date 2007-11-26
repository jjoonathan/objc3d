//
//  O3Struct.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3VecStructType.h"

/**
 * Represents an instance of a particular struct type. This is a mostly abstract class. 
 * You only have to implement one set of primitive methods and you get the others for free, though you can implement them all for efficiency.
 * Set 1: -initWithData:type:, -bytesAsData, -structSize
 * Set 2: -initWithBytesNoCopy:type:freeWhenDone:, -writeToBytes, -structSize
 * Set 2 is more efficient than set one, generally speaking, though it may be impossible through a scripting bridge.
 * @warning The default implementation of the public init methods simply call eachother. If you subclass O3Struct, do not simply call super, call [super initWithType:].
 * @warning Also note that structs should not be mutable.
 */
@interface O3Struct : NSObject { //Subclass to O3ByteStruct, provide default imps of initWithBytes, etc.
	O3StructType* mType;
}
- (O3Struct*)initWithData:(NSData*)data type:(O3StructType*)type;
- (O3Struct*)initWithBytes:(const void*)bytes type:(O3StructType*)type;
- (O3Struct*)initWithBytesNoCopy:(void*)bytes type:(O3StructType*)type freeWhenDone:(BOOL)fwd;

- (O3StructType*)structType;
- (void)writeToBytes:(void*)bytes;
- (NSData*)bytesAsData;
- (UIntP)structSize;
- (NSArray*)structKeys;

//Protected
- (O3Struct*)initWithType:(O3StructType*)type; ///<This is the designated initializer.
@end

#ifdef __cplusplus
double O3DoubleValueOfType_at_withIndex_(enum O3VecStructElementType type, const void* bytes, UIntP idx = 0);
Int64 O3Int64ValueOfType_at_withIndex_(enum O3VecStructElementType type, const void* bytes, UIntP idx = 0);
UInt64 O3UInt64ValueOfType_at_withIndex_(enum O3VecStructElementType type, const void* bytes, UIntP idx = 0);
void O3SetValueOfType_at_toDouble_withIndex_(enum O3VecStructElementType type, void* bytes, double v, UIntP idx = 0);
void O3SetValueOfType_at_toInt64_withIndex_(enum O3VecStructElementType type, void* bytes, Int64 v, UIntP idx = 0);
void O3SetValueOfType_at_toUInt64_withIndex_(enum O3VecStructElementType type, void* bytes, UInt64 v, UIntP idx = 0);
#endif