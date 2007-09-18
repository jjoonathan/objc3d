/**
 *  @file O3CGAutoSetParameters.h
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#pragma once

#import <Cg/cg.h>
#import <Cg/cgGL.h>

typedef struct {
	CGparameter param;
	CGGLenum matrix;
	CGGLenum transform;
} O3CGAutoSetParameter;

typedef struct {
	const char* name;
	CGGLenum matrix;
	CGGLenum transform;
} O3CGAutoSetParameterTemplate;

static int gNumCGAutoSetParamaterTemplates = 8;
static O3CGAutoSetParameterTemplate gCGAutoSetParamaterTemplates[] = {
	{"ModelViewMatrix", 					CG_GL_MODELVIEW_MATRIX, 			CG_GL_MATRIX_IDENTITY},
	{"InverseModelViewMatrix", 				CG_GL_MODELVIEW_MATRIX, 			CG_GL_MATRIX_INVERSE},
	{"TextureMatrix", 						CG_GL_TEXTURE_MATRIX, 				CG_GL_MATRIX_IDENTITY},
	{"InverseTextureMatrix", 				CG_GL_TEXTURE_MATRIX, 				CG_GL_MATRIX_INVERSE},
	{"ProjectionMatrix", 					CG_GL_PROJECTION_MATRIX,			CG_GL_MATRIX_IDENTITY},
	{"InverseProjectionMatrix",				CG_GL_PROJECTION_MATRIX,			CG_GL_MATRIX_INVERSE},
	{"ModelViewProjectionMatrix", 			CG_GL_MODELVIEW_PROJECTION_MATRIX,	CG_GL_MATRIX_IDENTITY},
	{"InverseModelViewProjectionMatrix", 	CG_GL_MODELVIEW_PROJECTION_MATRIX,	CG_GL_MATRIX_INVERSE}
};
static void gCGAutoSetParamaterTemplatesDummyUser() {gCGAutoSetParamaterTemplates; gNumCGAutoSetParamaterTemplates;}
