/**
 *  @file O3TestEffect.mm
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3Texture.h"
#import "O3Mesh.h"
#import "O3RawVertexDataSource.h"
#import "O3Light.h"
#import "O3CGEffect.h"
using namespace ObjC3D::Engine;
using namespace ObjC3D::Math;

void Render(CFRunLoopTimerRef timer, void *info);
O3Mesh* mesh;

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
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glEnable(GL_DEPTH_TEST);
	glClearColor(0.0, 0.0, 0.0, 0.0);
	float params[] = {1., 1., 1., 1.};
	glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, params);
	glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 1.);
	[NSApp run];
	[pool release];
	return 0;
}

void Render(CFRunLoopTimerRef timer, void *info) {
	if (!mesh)  {
		NSData* testData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"verts"]];
		UInt8* bytes = (UInt8*)[testData bytes];
		unsigned* byteData = (unsigned*)bytes;
		unsigned vertCount = byteData[0];
		unsigned indexCount = byteData[1];
		unsigned normalCount = byteData[2];
		unsigned baseOffset = 3*sizeof(unsigned);
		unsigned vertSize = sizeof(float)*3*vertCount;
		unsigned indexSize = sizeof(UInt16)*indexCount;
		unsigned normalSize = sizeof(float)*3*normalCount;
		O3RawVertexDataSource* vrt = [[O3RawVertexDataSource alloc] initWitBytes:bytes+baseOffset
																	  size:vertSize
																accessHint:nil //Defaults to GL_STATIC_DRAW or whatever
																	  type:O3VertexLocationDataType
																	format:GL_FLOAT
															componentCount:3];
		O3RawVertexDataSource* idx = [[O3RawVertexDataSource alloc] initWitBytes:bytes+baseOffset+vertSize
																	  size:indexSize
																accessHint:nil //Defaults to GL_STATIC_DRAW or whatever
																	  type:O3IndexDataType
																	format:GL_UNSIGNED_SHORT
															componentCount:1];
		O3RawVertexDataSource* nrm = [[O3RawVertexDataSource alloc] initWitBytes:bytes+baseOffset+vertSize+indexSize
																	  size:normalSize
																accessHint:nil //Defaults to GL_STATIC_DRAW or whatever
																	  type:O3NormalDataType
																	format:GL_FLOAT
															componentCount:3];
		O3CGEffect* eff = [[O3CGEffect alloc] initWithSource:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"cgfx"]]];
		GLsizei vpp = 3;
		mesh = [[O3Mesh alloc] initWithVerticies:vrt
										indicies:idx
								   primitiveType:GL_TRIANGLES
								  primitiveCount:indexCount/3
						   verticiesPerPrimitive:&vpp
			   primitivesHaveSameNumberVerticies:YES
										material:eff];
		[mesh addVertexDataSource:nrm];
		[eff release];
		[nrm release];
		[idx release];
		[vrt release];
	}
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();
	glTranslatef(-.5,-.5,-3);
	static float angle = 0.;
	angle += .5;
	glRotatef(angle,1,0,0);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(90., 1., 1., 100.);
	glMatrixMode(GL_MODELVIEW);
	
	[mesh renderWithContext:nil];
	
	glfwSwapBuffers();
	
	if (glfwGetKey(GLFW_KEY_ESC) || !glfwGetWindowParam(GLFW_OPENED)) {
		glfwTerminate();
		exit(0);
	}
}
