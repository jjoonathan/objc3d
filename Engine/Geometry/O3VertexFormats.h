#pragma once
/**
 *  @file O3VertexFormats.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 12/27/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#define O3TypeNotRecognizedException @"O3 OpenGL type not recognized"
const extern NSString* O3VertexDataTypeUnrecognizedException; //In O3VertexData.mm
extern GLint gMaximumVertexAttributes; //In O3VertexData.mm

#define O3VertexAttributeDataType(n) (  (O3VertexDataType)( O3VertexAttribute0DataType+(n) )  )
#define O3VertexAttributeNumberForForDataType(n) (  (GLint)((int)(n) - (int)O3VertexAttribute0DataType)  )
#define O3TexCoordDataType(n) (  (O3VertexDataType)( O3TexCoord0DataType+(n) )  )
#define O3TexCoordNumberForForDataType(n) (  (GLint)((int)(n) - (int)O3TexCoord0DataType)  )
typedef enum O3VertexDataType {
	O3VertexLocationDataType=0,
	O3NormalDataType=1,
	O3ColorDataType=2,
	O3ColorIndexDataType=3,
	O3VertexLocationIndexDataType=8,
	O3EdgeFlagDataType=4,
	O3SecondaryColorDataType=5,
	O3FogCoordDataType=6,
	O3TexCoordDataType=7, ///<Olden, single texture coords. Use the new O3TextCoordNDataType series if possible
	//Note that 8 has been used (above)
	O3VertexAttribute0DataType=16,
	O3VertexAttribute1DataType=17,
	O3VertexAttribute2DataType=18,
	O3VertexAttribute3DataType=19,
	O3VertexAttribute4DataType=20,
	O3VertexAttribute5DataType=21,
	O3VertexAttribute6DataType=22,
	O3VertexAttribute7DataType=23,
	O3VertexAttribute8DataType=24,
	O3VertexAttribute9DataType=25,
	O3TexCoord0DataType=100,
	O3TexCoord1DataType=101,
	O3TexCoord2DataType=102,
	O3TexCoord3DataType=103,
	O3TexCoord4DataType=104,
	O3TexCoord5DataType=105,
	O3TexCoord6DataType=106,
	O3TexCoord7DataType=107,
	O3TexCoord8DataType=108,
	O3TexCoord9DataType=109,
} O3VertexDataType;
static const int O3VertexDataTypeCount = 9;

static inline BOOL O3VertexDataTypeIsVertexAttribute(O3VertexDataType type) {
	if (!gMaximumVertexAttributes) glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &gMaximumVertexAttributes);
	int offset = O3VertexAttributeNumberForForDataType(type);
	if (offset>0 && offset<gMaximumVertexAttributes) return YES;
	return NO;
}

static inline BOOL O3VertexDataTypeStoresIndicies(O3VertexDataType type) {
	if (type==O3VertexLocationIndexDataType) return YES;
	return NO;
}

static inline int O3SizeofGLType(GLenum type) {
	switch (type) {
		case GL_UNSIGNED_BYTE:
		case GL_BITMAP:
		case GL_BYTE:
			return 1;
		case GL_UNSIGNED_SHORT:
		case GL_SHORT:
			return 2;
		case GL_UNSIGNED_INT:
		case GL_INT:
		case GL_FLOAT:
			return 4;
		case GL_UNSIGNED_BYTE_3_3_2:
		case GL_UNSIGNED_BYTE_2_3_3_REV:
			return 1;
		case GL_UNSIGNED_SHORT_5_6_5:
		case GL_UNSIGNED_SHORT_5_6_5_REV:
		case GL_UNSIGNED_SHORT_4_4_4_4:
		case GL_UNSIGNED_SHORT_4_4_4_4_REV:
		case GL_UNSIGNED_SHORT_5_5_5_1:
		case GL_UNSIGNED_SHORT_1_5_5_5_REV:
			return 2;
		case GL_UNSIGNED_INT_8_8_8_8:
		case GL_UNSIGNED_INT_8_8_8_8_REV:
		case GL_UNSIGNED_INT_10_10_10_2:
		case GL_UNSIGNED_INT_2_10_10_10_REV:
			return 4;
		default:
			[NSException raise:O3TypeNotRecognizedException format:@"Didn't recognize OpenGL type %i in O3SizeofGLType(GLenum type), expected one of GL_BYTE, GL_FLOAT, etc", type];
	}
	return 0;
}
