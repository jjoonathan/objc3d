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
NSOpenGLContext* gO3DefaultGLContext;
 
void O3FailAssertt() {
}

void O3FailAssert() {
}

O3EXTERN_C void O3Break() {
	NSLog(@"Set a breakpoint on O3Break() for manual breaks. One was just hit.");
}

O3EXTERN_C void O3Init() {
	NSAutoreleasePool* p = [[NSAutoreleasePool alloc] init];
	static int inited = 0;
	if (inited) return;
	inited++;
	
	gO3DefaultGLContext = [[NSOpenGLContext alloc] initWithFormat:[NSOpenGLView defaultPixelFormat] shareContext:nil];
	[gO3DefaultGLContext makeCurrentContext];
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
	[O3VecStructType o3init];
	[O3ScalarStructType o3init];
	[O3MatStructType o3init];
	[O3ResManager o3init];
	[p release];
}

O3EXTERN_C void O3GLBreak() {
	glMap1f(GL_ZERO, 0., 0., 0, 0, NULL);
}

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