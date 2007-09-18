/**
 *  @file O3TestScene.mm
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3Texture.h"
#import "O3Mesh.h"
#import "O3RawVertexDataSource.h"
#import "O3Light.h"
#import "O3CGEffect.h"
#import "O3Camera.h"
using namespace ObjC3D::Engine;
using namespace ObjC3D::Math;

O3Mesh* mesh;
O3Camera* cam;

void Render(CFRunLoopTimerRef timer, void *info);
void Init();
void MousePosCallback(int x, int y);

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
	//glfwDisable(GLFW_MOUSE_CURSOR);
	glfwSetMousePosCallback(MousePosCallback);
	glewInit();
	CFRunLoopTimerRef renderTimer = CFRunLoopTimerCreate(NULL, CFAbsoluteTimeGetCurrent(), 1/30., 0, 0, Render, NULL);
	CFRunLoopRef renderLoop = CFRunLoopGetCurrent();
	CFRunLoopAddTimer(renderLoop, renderTimer, kCFRunLoopDefaultMode);
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glEnable(GL_DEPTH_TEST);
	glClearColor(0.0, 0.0, 0.0, 0.0);
	float params[] = {1., 1., 1., 1.};
	glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, params);
	glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 1.);
	Init();
	[NSApp run];
	[pool release];
	return 0;
}

O3Mesh* CreateMesh(UInt8* bytes) {
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
	GLsizei vpp = 3;
	O3Mesh* to_return = [[O3Mesh alloc] initWithVerticies:vrt
												 indicies:idx
											primitiveType:GL_TRIANGLES
										   primitiveCount:indexCount/3
									verticiesPerPrimitive:&vpp
						primitivesHaveSameNumberVerticies:YES
												 material:nil];
	[to_return addVertexDataSource:nrm];
	[nrm release];
	[idx release];
	[vrt release];
	return to_return;
}	
	
void Init() {
	NSData* testData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"verts"]];
	UInt8* bytes = (UInt8*)[testData bytes];
	
	mesh = CreateMesh(bytes);
	O3CGEffect* eff = [[O3CGEffect alloc] initWithSource:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"cgfx"]]];
	[mesh setMaterial:eff];
	[eff release];
	
	cam = [[O3Camera alloc] initWithLocation:O3Point3d(0, 0, 1)
								   direction:O3Vec3d(0, 0, -1)
										  up:O3Vec3d(0, 1, 0)   ];
}

void DrawScene() {
	glTranslatef(0,0,-1);
	[mesh renderWithUserData:nil context:nil];
}


void Render(CFRunLoopTimerRef timer, void *info) {
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	[cam set];
	DrawScene();
	
	glfwSwapBuffers();
	glfwPollEvents();
	if (glfwGetKey(GLFW_KEY_ESC) || !glfwGetWindowParam(GLFW_OPENED)) {
		glfwTerminate();
		exit(0);
	}
	if (glfwGetKey('W')==GLFW_PRESS) [cam setCameraSpaceLocation:O3Point3d(0,0,.05)];
	if (glfwGetKey('S')==GLFW_PRESS) [cam setCameraSpaceLocation:O3Point3d(0,0,-.05)];
	if (glfwGetKey('A')==GLFW_PRESS) [cam setCameraSpaceLocation:O3Point3d(-.05,0,0)];
	if (glfwGetKey('D')==GLFW_PRESS) [cam setCameraSpaceLocation:O3Point3d(.05,0,0)];
	if (glfwGetKey('R')==GLFW_PRESS) [cam setCameraSpaceLocation:O3Point3d(0,.05,0)];
	if (glfwGetKey('F')==GLFW_PRESS) [cam setCameraSpaceLocation:O3Point3d(0,-.05,0)];
}

void MousePosCallback(int x, int y) {
	x -= 320;
	y -= 246;
	if (!x || !y) return;
	double mult = .03;
	static O3Rotation3 gCameraRot(0,0,0);
	gCameraRot = O3Rotation3(-y*mult, -x*mult, 0);
	[cam setRotation:gCameraRot];	
}
