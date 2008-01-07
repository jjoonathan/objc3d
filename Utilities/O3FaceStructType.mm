//  O3FaceStruct.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3FaceStructType.h"
#import "O3VecStructType.h"

O3VecStructType* gO3Triangle3x3fType = nil;
O3VecStructType* gO3IndexedTriangle3cType = nil;
O3VecStructType* gO3IndexedTriangle3sType = nil;
O3VecStructType* gO3IndexedTriangle3iType = nil;

@implementation O3TriFaceStructType
+ (void)load {
	gO3Triangle3x3fType = [[O3TriFaceStructType alloc] initWithElementType:O3VecStructFloatElement
															  specificType:O3VecStructIndex
																	 count:9
																	  name:@"tri3x3f"];
	gO3IndexedTriangle3cType = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt8Element
															   specificType:O3VecStructIndex
																	  count:3
																	   name:@"tri3c"];
	gO3IndexedTriangle3sType = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt16Element
															   specificType:O3VecStructIndex
																	  count:3
																	   name:@"tri3c"];
	gO3IndexedTriangle3iType = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt32Element
															   specificType:O3VecStructIndex
																	  count:3
																	   name:@"tri3i"];																		   
}

- (GLenum)glFormatForType:(O3VertexDataType)type {
	return GL_FLOAT;
}

- (GLint)glComponentCountForType:(O3VertexDataType)type {
	return 3;
}

- (GLsizeiptr)glOffsetForType:(O3VertexDataType)type {
	return 0;
}

- (GLsizeiptr)glStride {
	return O3VecStructSize(self);
}

- (GLboolean)glNormalizedForType:(O3VertexDataType)type {
	return NO;
}

- (int)glVertsPerStruct {
	return 3;
}

- (void)writeObject:(id)dict toBytes:(void*)bytes {
	O3WriteNumberTo(mElementType, 0, bytes, [dict objectForKey:@"x1"], 1., NULL);
	O3WriteNumberTo(mElementType, 1, bytes, [dict objectForKey:@"x2"], 1., NULL);
	O3WriteNumberTo(mElementType, 2, bytes, [dict objectForKey:@"x3"], 1., NULL);
	O3WriteNumberTo(mElementType, 3, bytes, [dict objectForKey:@"x4"], 1., NULL);
	O3WriteNumberTo(mElementType, 4, bytes, [dict objectForKey:@"x5"], 1., NULL);
	O3WriteNumberTo(mElementType, 5, bytes, [dict objectForKey:@"x6"], 1., NULL);
	O3WriteNumberTo(mElementType, 6, bytes, [dict objectForKey:@"x7"], 1., NULL);
	O3WriteNumberTo(mElementType, 7, bytes, [dict objectForKey:@"x8"], 1., NULL);
	O3WriteNumberTo(mElementType, 8, bytes, [dict objectForKey:@"x9"], 1., NULL);
}

- (id)objectWithBytes:(const void*)bytes {
	return [NSDictionary dictionaryWithObjectsAndKeys:O3VecStructGetElement(self, 0, bytes), @"x1",
	                                                 O3VecStructGetElement(self, 2, bytes), @"x2",
	                                                 O3VecStructGetElement(self, 3, bytes), @"x3",
	                                                 O3VecStructGetElement(self, 4, bytes), @"x4",
	                                                 O3VecStructGetElement(self, 5, bytes), @"x5",
	                                                 O3VecStructGetElement(self, 6, bytes), @"x6",
	                                                 O3VecStructGetElement(self, 7, bytes), @"x7",
	                                                 O3VecStructGetElement(self, 8, bytes), @"x8",
	                                                 O3VecStructGetElement(self, 9, bytes), @"x9", nil ];
}

@end

/************************************/ #pragma mark Defined Types /************************************/
O3VecStructType* O3Triangle3x3fType() {return gO3Triangle3x3fType;}
O3VecStructType* O3IndexedTriangle3cType() {return gO3IndexedTriangle3cType;}
O3VecStructType* O3IndexedTriangle3sType() {return gO3IndexedTriangle3sType;}
O3VecStructType* O3IndexedTriangle3iType() {return gO3IndexedTriangle3iType;}