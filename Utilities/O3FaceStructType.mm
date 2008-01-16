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

#define DefType(NAME, TYPE, CT) int NAME ## Comparator (void* a, void* b, void* ctx) {\
	TYPE* aa = (TYPE*)a;\
	TYPE* bb = (TYPE*)b;\
	UIntP i; for(i=0; i<CT; i++) {\
		if (aa[i]<bb[i]) return NSOrderedAscending;\
		if (aa[i]>bb[i]) return NSOrderedDescending;\
	}\
	return NSOrderedSame;\
}
DefType(O3Tri3x3fType, float, 9);
#undef DefType

@implementation O3TriFaceStructType
+ (void)load {
	gO3Triangle3x3fType = [[O3TriFaceStructType alloc] initWithElementType:O3VecStructFloatElement
															  specificType:O3VecStructIndex
																	 count:9
																	  name:@"tri3x3f"
																	  comparator:O3Tri3x3fTypeComparator];
}

- (void)getFormat:(out GLenum*)format components:(out GLsizeiptr*)components offset:(out GLint*)offset stride:(out GLint*)stride normed:(out GLboolean*)normed vertsPerStruct:(out int*)vps forType:(in O3VertexDataType)type {
	if (format) {
		switch (mElementType) {
			case O3VecStructFloatElement:  *format = GL_FLOAT; break;
			//case O3VecStructDoubleElement: *format = GL_DOUBLE; break;
			//case O3VecStructInt8Element:   *format = GL_BYTE; break;
			//case O3VecStructInt16Element:  *format = GL_SHORT; break;
			//case O3VecStructInt32Element:  *format = GL_INT; break;
			//case O3VecStructInt64Element:  return 0;
			case O3VecStructUInt8Element:  *format = GL_UNSIGNED_BYTE; break;
			case O3VecStructUInt16Element: *format = GL_UNSIGNED_SHORT; break;
			case O3VecStructUInt32Element: *format = GL_UNSIGNED_INT; break;
			//case O3VecStructUInt64Element: return 0;
			default: O3Asrt(NO);
		}
	}
	if (components) *components = 3;
	if (offset) *offset = 0;
	if (stride) *stride = O3VecStructSize(self)/3; //3 verts per face
	if (normed) *normed = GL_FALSE;
	if (vps) *vps = 3;
}

@end

/************************************/ #pragma mark Defined Types /************************************/
O3VecStructType* O3Triangle3x3fType() {return gO3Triangle3x3fType;}
O3VecStructType* O3IndexedTriangle3cType() {return gO3IndexedTriangle3cType;}
O3VecStructType* O3IndexedTriangle3sType() {return gO3IndexedTriangle3sType;}
O3VecStructType* O3IndexedTriangle3iType() {return gO3IndexedTriangle3iType;}