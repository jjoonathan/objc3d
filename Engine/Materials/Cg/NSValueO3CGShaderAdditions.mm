/**
 *  @file NSValueO3CGShaderAdditions.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 1/11/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "NSValueO3CGShaderAdditions.h"


@implementation NSValue (O3CGShader)

inline char* NSValue_O3CGShader_EncodeStringForScalar(CGtype scalarType) {
	if (scalarType==CG_FLOAT)	return @encode(float);
	if (scalarType==CG_HALF)	return @encode(float);
	if (scalarType==CG_INT)		return @encode(int);
	if (scalarType==CG_BOOL)	return @encode(int);
	O3Assert(false , @"CG Scalar type not recognized");
	return NULL;
}

inline char* NSValue_O3CGShader_EncodeStringForMatrix(CGtype vectorType) {
	int rows, cols; cgGetTypeSizes(vectorType, &rows, &cols);
	CGtype base_type = cgGetTypeBase(vectorType);
	if (rows==1) {
		if (cols==1) return NSValue_O3CGShader_EncodeStringForScalar(base_type);
		char* to_return; 
		asprintf(&to_return, "[%i%s]", cols, NSValue_O3CGShader_EncodeStringForScalar(base_type));
		return to_return;
	} else {
		char* to_return; 
		asprintf(&to_return, "[%i[%i%s]]", cols, rows, NSValue_O3CGShader_EncodeStringForScalar(base_type));
		return to_return;		
	}
}

+ (NSValue*)valueWithBytes:(const void*)bytes cgType:(CGtype)type {
	char* type_encoding = NSValue_O3CGShader_EncodeStringForMatrix(type);
	NSValue* to_return = [NSValue valueWithBytes:bytes objCType:type_encoding];
	free(type_encoding);  //Can we do this?
	return to_return;
}

@end
