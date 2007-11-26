/**
 *  @file O3Value.h
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#ifdef __cplusplus
class O3BufferedReader;
#endif

@interface O3Value : NSValue {
#ifdef __cplusplus
	O3DynamicMatrix* mDynamicMatrix;
#else
	void* mDynamicMatrix;
#endif
}
//Creation
#ifdef __cplusplus
+ (O3Value*)valueWithMatrix:(O3DynamicMatrix)mat;
+ (O3Value*)valueWithVector:(O3DynamicVector)vec;
+ (NSValue*)valueByReadingFrom:(O3BufferedReader*)br; ///<Cast the return value to O3Value* iff you are sure that the encoded value will not be a 0x0 matrix (which encodes an NSData)
- (id)initByReadingFrom:(O3BufferedReader*)br;
#endif
+ (O3Value*)valueWithPoint:(NSPoint)pt;
+ (O3Value*)valueWithRect:(NSRect)rect;
+ (O3Value*)valueWithSize:(NSSize)size;
+ (NSValue*)valueWithPortableData:(NSData*)dat;
- (id)initWithPortableData:(NSData*)dat;

//Inspectors
#ifdef __cplusplus
- (O3DynamicMatrix)matrixValue; ///<Gets the receiver's value as a matrix. Vectors are returned as column matricies. Use like <code>O3Mat4x4d transform_matrix([SomeO3Value matrixValue]);</code> or <code>my_matrix.Set([SomeO3Value matrixValue]);</code>.
- (O3DynamicVector)vectorValue; ///<Gets the receiver's value as a vector. Raises if the receiver represents a matrix. Use like <code>vec3r position([SomeO3Value vectorValue]);</code> or <code>some_vector.Set([SomeO3Value vectorValue]);</code>.
#endif
- (NSPoint)pointValue; ///<Gets the receiver's value as a point (x,y). Raises if the receiver represents a matrix.
- (NSRect)rectValue; ///<Gets the receiver's value as a rect (origin.x, origin.y, size.width, size.height). Raises if the receiver represents a matrix.
- (NSSize)sizeValue; ///<Gets the receiver's value as a size (width, height). Raises if the receiver represents a matrix.
- (NSString*)stringValue; ///<Just an alias to description
- (NSData*)portableData; ///<Data suitable for storage and reading
@end

@interface NSValue (O3ValueAdditions)
- (NSData*)portableData; ///<Data suitable for storage and reading
@end
