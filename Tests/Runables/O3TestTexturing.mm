/**
 *  @file O3TestTexturing.mm
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3Texture.h"

void Render(CFRunLoopTimerRef timer, void *info);
O3Texture *tex;

int main(int argc, char *argv[]) {
	[NSApplication sharedApplication];
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	glfwInit();
	glfwOpenWindow(/*width:*/		0,
				   /*height:*/		0,
				   /*redbits:*/		8,
				   /*greenbits:*/	8,
				   /*bluebits:*/	8,
				   /*alphabits:*/	8,
				   /*depthnbits:*/	32,
				   /*stencilbits:*/	0,
				   /*mode:*/		GLFW_WINDOW);    
	glewInit();
	CFRunLoopTimerRef renderTimer = CFRunLoopTimerCreate(NULL, CFAbsoluteTimeGetCurrent(), .025, 0, 0, Render, NULL);
	CFRunLoopRef renderLoop = CFRunLoopGetCurrent();
	CFRunLoopAddTimer(renderLoop, renderTimer, kCFRunLoopDefaultMode);
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	[NSApp run];
	[pool release];
	return 0;
}

void Render(CFRunLoopTimerRef timer, void *info) {
	if (!tex)  tex = [[O3Texture alloc] initWithImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"test"]] internalFormat:GL_RGBA8];
	glClearColor(0.0, 0.0, 0.0, 0.0);
	glClear(GL_COLOR_BUFFER_BIT);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluOrtho2D(0., 1., 0., 1.);
	glBindTexture(GL_TEXTURE_2D, [tex textureID]);
	
	glBegin(GL_QUADS);
		glTexCoord2f(0,0);		glVertex2f(0,0);
		glTexCoord2f(0,1);		glVertex2f(0,1);
		glTexCoord2f(1,1);		glVertex2f(1,1);
		glTexCoord2f(1,0);		glVertex2f(1,0);
	glEnd();
	
	glfwSwapBuffers();
	
	if (glfwGetKey(GLFW_KEY_ESC) || !glfwGetWindowParam(GLFW_OPENED)) {
		glfwTerminate();
		exit(0);
	}
}
