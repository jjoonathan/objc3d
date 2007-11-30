/**
 *  @file O3Utilities.mm
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
NSOpenGLContext* gO3DefaultGLContext;
 
void O3FailAssertt() {
}

void O3FailAssert() {
}

void O3Break() {
	NSLog(@"Set a breakpoint on O3Break() for manual breaks. One was just hit.");
}

O3EXTERN_C void O3Init() {
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
}

O3EXTERN_C void O3GLBreak() {
	glMap1f(GL_ZERO, 0., 0., 0, 0, NULL);
}