/**
 *  @file O3Utilities.mm
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3VecStructType.h"
#import "O3ScalarStructType.h"
#import "O3MatStructType.h"
#import "O3ResManager.h"
#import "O3GPUData.h"
#import "O3CGEffect.h"
#import "O3Space.h"
 
void O3FailAssertt() {
}

void O3FailAssert() {
}

O3EXTERN_C void O3Break() {
	NSLog(@"Set a breakpoint on O3Break() for manual breaks. One was just hit.");
}

CGcontext gO3GlobalCGContext = nil;
CGcontext O3GlobalCGContext() {
	O3Init();
	return gO3GlobalCGContext;
}

NSOpenGLContext* gO3GLResourceContext = nil;
NSOpenGLContext* O3GLResourceContext() {
	O3Init();
	return gO3GLResourceContext;
}

void O3CGErrorCallback() {
	NSLog(@"%s\n", cgGetErrorString(cgGetError()));
}

O3EXTERN_C void O3Init() {
	NSAutoreleasePool* p = [[NSAutoreleasePool alloc] init];
	static int inited = 0;
	if (inited) return;
	inited++;
	BOOL l = NO;
	
	////OpenGL
	if (l) NSLog(@"Starting OpenGL");
	BOOL skip_gl_init = [[[NSBundle mainBundle] bundleIdentifier] isEqual:@"org.blenderfoundation.blender"];
	gO3GLResourceContext = [[NSOpenGLContext alloc] initWithFormat:[NSOpenGLView defaultPixelFormat] shareContext:nil];
	if (skip_gl_init) {
		NSLog(@"**** ObjC3D Dirty Hack Alert ****");
		NSLog(@"**** All ObjC3D OpenGL calls won't work. ****");
		NSLog(@"**** Blender & ObjC3D don't like to share contexts. ****");
		O3Destroy(gO3GLResourceContext);
	}
	
	O3BeginGLRes();
	////CG
	if (l) NSLog(@"Starting Cg");
	gO3GlobalCGContext = cgCreateContext();
	cgGLSetManageTextureParameters(gO3GlobalCGContext, CG_TRUE);
	cgSetErrorCallback(O3CGErrorCallback);
	cgGLRegisterStates(gO3GlobalCGContext);
	cgGLSetOptimalOptions(CG_PROFILE_ARBVP1);
    cgGLSetOptimalOptions(CG_PROFILE_ARBFP1);
	
	////GLEW
	if (l) NSLog(@"Starting GLEW");
	GLenum glewState = glewInit();
	if (glewState != GLEW_OK) {
		NSString* desc = @"an unknown error occured.";
		switch (glewState) {
			case GLEW_ERROR_NO_GL_VERSION:
				desc = @"there was no OpenGL context to initialize in (no version reported).";
				break;
		}
		NSLog(@"ObjC3D could not be initialized because GLEW could not be initialized because %@", desc);
	}
	O3EndGLRes();
	
	////Log4Cocoa
	if (l) NSLog(@"Starting L4C");
	[[L4Logger rootLogger] addAppender:[L4ConsoleAppender standardErrWithLayout:[L4Layout simpleLayout]]];
	[[L4Logger rootLogger] setLevel:[L4Level info]];
	
	////Misc
	if (l) NSLog(@"Starting misc");
	[O3VecStructType o3init];
	[O3ScalarStructType o3init];
	[O3MatStructType o3init];
	[O3ResManager o3init];
	[O3CGEffect o3init];
	//[O3Space o3init];
	
	if (l) NSLog(@"Cleaning Up");
	[p release];
}

O3EXTERN_C void O3GLBreak() {
	glMap1f(GL_ZERO, 0., 0., 0, 0, NULL);
}


#ifdef O3UseCoreGraphics
#include <OpenGL/CGLCurrent.h>
static CGLContextObj globalCtx = NULL;
static CGLContextObj oldCtx = NULL;
O3EXTERN_C void O3BeginGLRes() {
	NSOpenGLContext* rc = O3GLResourceContext();
	if (!rc) {
		O3CLogWarn(@"No ObjC3D resource context has been created, but one was used.%s", CGLGetCurrentContext()? " Using previously existing context." : "Using no context.");
		return;
	}
	if (!globalCtx) {globalCtx = (CGLContextObj)[rc CGLContextObj];}
	CGLContextObj thisctx = CGLGetCurrentContext();
	if (thisctx!=globalCtx) {
		O3Asrt(!oldCtx);
		oldCtx = thisctx;
		CGLSetCurrentContext(globalCtx);
	}
}

O3EXTERN_C void O3EndGLRes() {
	if (oldCtx) {
		CGLSetCurrentContext(oldCtx);
		oldCtx = NULL;
	}
}
#else
static NSOpenGLContext* oldCtx = NULL;
O3EXTERN_C void O3BeginGLRes() {
	if ([NSOpenGLContext currentContext]!=O3GLResourceContext()) {
		O3Asrt(!oldCtx);
		oldCtx = cctx;
		[O3GLResourceContext() makeCurrentContext];
	}
}

O3EXTERN_C void O3EndGLRes() {
	if (oldCtx) [oldCtx makeCurrentContext];
	oldCtx = NULL;
}
#endif


O3EXTERN_C void* O3NSDataDup(NSData* dat) {
	if (!dat) return nil;
	UIntP len = [dat length];
	void* r = malloc(len);
	memcpy(r, [dat bytes], len);
	[dat relinquishBytes];
	return r;
}

O3EXTERN_C void* O3MemDup(const void* mem, UIntP len) {
	void* ret = malloc(len);
	memcpy(ret, mem, len);
	return ret;
}

O3EXTERN_C id O3Descriptify(id bridge_object) {
	if (![[bridge_object className] hasPrefix:@"OC_"]) return bridge_object;
	static Class pyarr_class = nil;
	if (!pyarr_class) pyarr_class = NSClassFromString(@"OC_PythonArray");
	if ([bridge_object isMemberOfClass:pyarr_class]) {
		NSMutableArray* ret = [[[NSMutableArray alloc] initWithCapacity:[bridge_object count]] autorelease];
		NSEnumerator* bridge_objectEnumerator = [bridge_object objectEnumerator];
		while (id o = [bridge_objectEnumerator nextObject]) {
			[ret addObject:O3Descriptify(o)];
		}
		return ret;
	}
	O3CLogWarn(@"Un-depythonifiable obj %@", bridge_object);
	return nil;
}