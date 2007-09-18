/**
 *  @file O3TestPrimitiveShadows.mm
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
#import "O3CGParameter.h"
#import "O3Space.h"
#include <iostream>
#include <fstream>
using namespace std;
using namespace ObjC3D::Engine;
using namespace ObjC3D::Math;

typedef struct {
	O3Mesh* mesh;
	Space3  space;
	BOOL    casts_shadows;
	double	minz, maxz;
} RenderObj;
vector<RenderObj*> renderObjects;

RenderObj* monkey_obj;
RenderObj* terr_obj;

O3Camera* cam;
O3Camera* shadowCamera;
Space3* cameraSpace;

BOOL useShadowCameraAsMain;
O3FramebufferObject* shadowFBO;
O3Texture* shadowTexture;
O3Texture* colorTexture;

O3CGEffect* redEffect;
O3CGEffect* redTerrEffect;
O3CGEffect* srecEffect;
O3CGEffect* simpleShadowEffect;
BOOL simpleShadowing = NO;

int windowWidth = 1024;
int windowHeight = 1024;

void Render(CFRunLoopTimerRef timer, void *info);
void Init();
void MousePos(O3Camera* camera_to_move);
void WindowResize(int w, int h);
void MouseWheelCallback(int num);

double beam_offset=0;

int main(int argc, char *argv[]) {
	[NSApplication sharedApplication];
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	glfwInit();
	glfwOpenWindow(/*width:*/		windowWidth,
				   /*height:*/		windowHeight,
				   /*redbits:*/		8,
				   /*greenbits:*/	8,
				   /*bluebits:*/	8,
				   /*alphabits:*/	8,
				   /*depthnbits:*/	32,
				   /*stencilbits:*/	0,
				   /*mode:*/		GLFW_WINDOW);   
	//glfwDisable(GLFW_MOUSE_CURSOR);
	glewInit();
	CFRunLoopTimerRef renderTimer = CFRunLoopTimerCreate(NULL, CFAbsoluteTimeGetCurrent(), 1/30., 0, 0, Render, NULL);
	CFRunLoopRef renderLoop = CFRunLoopGetCurrent();
	CFRunLoopAddTimer(renderLoop, renderTimer, kCFRunLoopDefaultMode);
	//glEnable(GL_LIGHTING);
	//glEnable(GL_LIGHT0);
	glEnable(GL_DEPTH_TEST);
	//glEnable(GL_CULL_FACE);
	//glCullFace(GL_BACK);
	glPolygonOffset(0,0);
	glEnable(GL_POLYGON_OFFSET_FILL);
	glfwSetMousePos(840,525);
	glfwSetWindowSizeCallback(WindowResize);
	glfwSetMouseWheelCallback(MouseWheelCallback);
	glClearColor(0.0, 0.0, 0.0, 0.0);
	//float params[] = {1., 1., 1., 1.};
	//glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, params);
	//glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 1.);
	Init();
	[NSApp run];
	[pool release];
	return 0;
}

double DistanceBetweenBeamAndPlane() {
	double beammax = O3ConvertSpaceToRoot(O3Vec3d(0,0,monkey_obj->maxz), &monkey_obj->space).Z();
	double planemin = O3ConvertSpaceToRoot(O3Vec3d(0,0,terr_obj->minz), &terr_obj->space).Z();
	return planemin-beammax;
}

void SetBeamOffset(double offs) {
	beam_offset = offs;
	Space3& objspace = renderObjects.at(1)->space;
	objspace.Set();
	objspace += O3Translation3(0,0,2 + offs);
	//objspace += O3Scale3(1,1,1);
}

O3Mesh* CreateMesh(UInt8* bytes, double* minz, double* maxz) {
	unsigned* byteData = (unsigned*)bytes;
	unsigned vertCount = O3ByteswapBigToHost(byteData[0]);
	unsigned indexCount = O3ByteswapBigToHost(byteData[1]);
	unsigned normalCount = O3ByteswapBigToHost(byteData[2]);
	unsigned baseOffset = 3*sizeof(unsigned);
	unsigned vertSize = sizeof(float)*3*vertCount;
	unsigned indexSize = sizeof(UInt16)*indexCount;
	unsigned normalSize = sizeof(float)*3*normalCount;
	
	//Byteswap data
	unsigned i;
	UInt32* vertdata = (UInt32*)(bytes+baseOffset);
	UInt16* idxdata  = (UInt16*)(bytes+baseOffset+vertSize);
	UInt32* normdata = (UInt32*)(bytes+baseOffset+vertSize+indexSize);
	for (i=0; i<vertCount*3; i++)   vertdata[i] = O3ByteswapBigToHost(vertdata[i]);
	for (i=0; i<indexCount;  i++)   idxdata[i]  = O3ByteswapBigToHost(idxdata[i]);
	for (i=0; i<normalCount*3; i++) normdata[i] = O3ByteswapBigToHost(normdata[i]);
	
	//Find max/min Z
	float*  verts	 = (float*) (bytes+baseOffset);
	UInt16* indicies = (UInt16*)(bytes+baseOffset+vertSize);
	float*  norms	 = (float*) (bytes+baseOffset+vertSize+indexSize);
	if (minz) {
		*minz = O3TypeMax(double);
		for (i=2; i<vertCount*3; i+=3) *minz = O3Min(*minz, verts[i]);
	}
	if (maxz) {
		*maxz = -O3TypeMax(double);
		for (i=2; i<vertCount*3; i+=3) *maxz = O3Max(*maxz, verts[i]);
	}
	
	O3RawVertexDataSource* vrt = [[O3RawVertexDataSource alloc] initWitBytes:(UInt8*)verts
																  size:vertSize
															accessHint:nil //Defaults to GL_STATIC_DRAW or whatever
																  type:O3VertexLocationDataType
																format:GL_FLOAT
														componentCount:3];
	O3RawVertexDataSource* idx = [[O3RawVertexDataSource alloc] initWitBytes:(UInt8*)indicies
																  size:indexSize
															accessHint:nil //Defaults to GL_STATIC_DRAW or whatever
																  type:O3VertexLocationIndexDataType
																format:GL_UNSIGNED_SHORT
														componentCount:1];
	O3RawVertexDataSource* nrmidx = [[O3RawVertexDataSource alloc] initWithRawVertexData:[idx rawVertexData]
																					type:O3ColorIndexDataType
																				  format:GL_UNSIGNED_SHORT
																		  componentCount:1
																				  offset:0
																				  stride:0];
	O3RawVertexDataSource* nrm = [[O3RawVertexDataSource alloc] initWitBytes:(UInt8*)norms
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
	[to_return addVertexDataSource:nrmidx];
	[nrm release];
	[idx release];
	[vrt release];
	return to_return;
}	
	
void Init() {
	NSData* terr_dat = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test_terr" ofType:@"verts"]];
	double terr_min, terr_max;
	O3Mesh* terr_mesh = CreateMesh((UInt8*)[terr_dat bytes], &terr_min, &terr_max);
	srecEffect	= [[O3CGEffect alloc] initWithSource:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test_srec" ofType:@"cgfx"]]];
	redEffect	= [[O3CGEffect alloc] initWithSource:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"red" ofType:@"cgfx"]]];
	redTerrEffect	= [[O3CGEffect alloc] initWithSource:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"red_terr" ofType:@"cgfx"]]];
	simpleShadowEffect = [[O3CGEffect alloc] initWithSource:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"regular_shadow" ofType:@"cgfx"]]];
	[terr_mesh setMaterial:srecEffect];
	
	NSData* monkey_dat = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ibeam" ofType:@"verts"]];
	double monkey_min, monkey_max;
	O3Mesh* monkey_mesh = CreateMesh((UInt8*)[monkey_dat bytes], &monkey_min, &monkey_max);
	[monkey_mesh setMaterial:redEffect];
	
	cam = [[O3Camera alloc] init];
		[cam setTranslation:O3Translation3(-4.130176, 0.505340, 2.535293)];
		[cam rotateBy:O3Rotation3(0,3.973185,-1.343407)];
	shadowCamera = [[O3Camera alloc] init];
		[shadowCamera setTranslation:O3Translation3(-1.111101, -0.712656, 0.521761)];
		[shadowCamera setRotation:O3Rotation3(0.000000, -2.745000, -1.065000)];
	shadowTexture = [[O3Texture alloc] initWithData:nil format:GL_DEPTH_COMPONENT16_ARB width:1024 height:1024 depth:0];
		[[srecEffect parameterNamed:@"shadowMap"] setValue:shadowTexture];
		[[simpleShadowEffect parameterNamed:@"shadowMap"] setValue:shadowTexture];
	colorTexture = [[O3Texture alloc] initWithData:nil format:GL_RGBA8 width:1024 height:1024 depth:0];
	shadowFBO = [[O3FramebufferObject alloc] init];
		[shadowFBO attachObject:shadowTexture toPoint:GL_DEPTH_ATTACHMENT_EXT];
		[shadowFBO attachObject:colorTexture toPoint:GL_COLOR_ATTACHMENT0_EXT];
		//[shadowFBO createBufferWithFormat:GL_RGBA8 width:1024 height:1024 andAttachToPoint:GL_COLOR_ATTACHMENT0_EXT];
	
	terr_obj = new RenderObj();
		terr_obj->mesh = terr_mesh;
		terr_obj->space += O3Translation3(0,0,-1);
		terr_obj->space += O3Scale3(1,1,1);
		terr_obj->casts_shadows = NO; 
		terr_obj->minz = terr_min;
		terr_obj->maxz = terr_max;
		renderObjects.push_back(terr_obj);
	monkey_obj = new RenderObj();
		monkey_obj->mesh = monkey_mesh;
		monkey_obj->space += O3Translation3(0,0,2);
		monkey_obj->space += O3Scale3(1,1,1);
		monkey_obj->casts_shadows = YES; 
		monkey_obj->minz = monkey_min;
		monkey_obj->maxz = monkey_max;
		renderObjects.push_back(monkey_obj);
}


void DrawScene(O3CGEffect* eff, BOOL include_shadow_receivers) {
	vector<RenderObj*>::iterator it = renderObjects.begin();
	vector<RenderObj*>::iterator end = renderObjects.end();
	for(; it!=end; it++) {
		RenderObj* obj = *it;
		if (!include_shadow_receivers && !obj->casts_shadows) continue;
		glPushMatrix();			//Model transform
		O3Mat4x4d modelMatrix = obj->space.MatrixToSpace(cameraSpace);
 		glLoadMatrixd(modelMatrix);
		
		O3Mat4x4d shadowcam_mv = obj->space.MatrixToSpace([shadowCamera space]);
		const O3Mat4x4d& shadowcam_p = [shadowCamera postProjectionSpace]->MatrixFromSuper();
		const O3Mat4x4d& shadowcam_pi = [shadowCamera postProjectionSpace]->MatrixToSuper();
		O3CGEffect* terr_eff = [terr_obj->mesh material];
		[[terr_eff parameterNamed:@"shadowcam_mv_mat"] setDoubleMatrixValue:shadowcam_mv rows:4 columns:4];
		[[terr_eff parameterNamed:@"shadowcam_p_mat"] setDoubleMatrixValue:shadowcam_p rows:4 columns:4];
		[[terr_eff parameterNamed:@"shadowcam_pi_mat"] setDoubleMatrixValue:shadowcam_pi rows:4 columns:4];
		
		O3Mesh* themesh = obj->mesh;
		//[themesh setMaterial:eff];
		[themesh renderWithUserData:nil context:nil];
		
		glMatrixMode(GL_MODELVIEW);
		glPopMatrix();
	}
}

void DrawDirs() { //Draws the world space unit vectors
	glPushAttrib(GL_CURRENT_BIT | GL_ENABLE_BIT);
	glDisable(GL_DEPTH_TEST);
	glDisable(GL_LIGHTING);
	glDisable(GL_FRAGMENT_PROGRAM_ARB);
	glDisable(GL_VERTEX_PROGRAM_ARB);
	glEnable(GL_BLEND);
	glPushMatrix();
	glLoadMatrixd(cameraSpace->MatrixFromRoot());
	
	glBegin(GL_LINES);
	glColor4f(1,0,0,1);
	glVertex3f(0,0,0);
	glVertex3d(1,0,0);
	
	glColor4f(0,1,0,1);
	glVertex3f(0,0,0);
	glVertex3d(0,1,0);	
	
	glColor4f(0,0,1,1);
	glVertex3f(0,0,0);
	glVertex3d(0,0,1);		
	glEnd();
	
	glPopMatrix();
	glPopAttrib();
}

void ShowTex() {
	glDisable(GL_FRAGMENT_PROGRAM_ARB);
	glDisable(GL_VERTEX_PROGRAM_ARB);
	glEnable(GL_TEXTURE_2D);
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glOrtho(0,1024,0,1024,.1,1.1);
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
	[colorTexture bindToTextureUnit:0];
	glBegin(GL_QUADS);
	glTexCoord2i(0,0);
	glVertex2i(0,0);
	glTexCoord2i(1,0);
	glVertex2i(1024,0);
	glTexCoord2i(1,1);
	glVertex2i(1024,1024);
	glTexCoord2i(0,1);
	glVertex2i(0,1024);
	glEnd();
	[colorTexture unbindFromTextureUnit:0];
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);
	glPopMatrix();
}

void Render(CFRunLoopTimerRef timer, void *info) {
	[shadowFBO bind];
	glDrawBuffer(GL_COLOR_ATTACHMENT0_EXT);
	glReadBuffer(GL_NONE);
	glPushAttrib(GL_VIEWPORT_BIT);
	glViewport(0,0,1024,1024);
	[shadowCamera setProjectionMatrix];
	cameraSpace = [shadowCamera space];
	glClearDepth((simpleShadowing)?1.0:0.0);
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	glDepthFunc((simpleShadowing)?GL_LEQUAL:GL_GEQUAL);
	DrawScene(redEffect, false);
	[shadowFBO unbind];
	glPopAttrib();
	glDrawBuffer(GL_BACK);
	
	glClearDepth(1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glDepthFunc(GL_LEQUAL);
	[(useShadowCameraAsMain)?shadowCamera:cam setProjectionMatrix];
	cameraSpace = [(useShadowCameraAsMain)?shadowCamera:cam space];
	glViewport(0,0,windowWidth,windowHeight);
	DrawScene(srecEffect, true);
	[(useShadowCameraAsMain)?cam:shadowCamera debugDrawIntoSpace:cameraSpace];
	DrawDirs();
	
	if (glfwGetKey('2')==GLFW_PRESS) {
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		ShowTex();
	}

	glfwSwapBuffers();
	glfwPollEvents();
	if (glfwGetKey(GLFW_KEY_ESC) || !glfwGetWindowParam(GLFW_OPENED)) {
		glfwTerminate();
		exit(0);
	}
	useShadowCameraAsMain = (glfwGetKey('1')==GLFW_PRESS)?YES:NO;
	O3Camera* cameraToMove = (useShadowCameraAsMain||(glfwGetKey('3')==GLFW_PRESS))?shadowCamera:cam;
	MousePos(cameraToMove);
	if (glfwGetKey('W')==GLFW_PRESS) [cameraToMove translateInObjectSpaceBy:O3Translation3(0,0,.05)];
	if (glfwGetKey('S')==GLFW_PRESS) [cameraToMove translateInObjectSpaceBy:O3Translation3(0,0,-.05)];
	if (glfwGetKey('A')==GLFW_PRESS) [cameraToMove translateInObjectSpaceBy:O3Translation3(.05,0,0)];
	if (glfwGetKey('D')==GLFW_PRESS) [cameraToMove translateInObjectSpaceBy:O3Translation3(-.05,0,0)];
	if (glfwGetKey('R')==GLFW_PRESS) [cameraToMove translateInObjectSpaceBy:O3Translation3(0,-.05,0)];
	if (glfwGetKey('F')==GLFW_PRESS) [cameraToMove translateInObjectSpaceBy:O3Translation3(0,.05,0)];
	static BOOL r_pressed = NO;
	if (glfwGetKey(GLFW_KEY_RIGHT)==GLFW_PRESS && !r_pressed) {
		O3CGEffect* terr_effect = [terr_obj->mesh material];
		simpleShadowing = NO;
		if (terr_effect==srecEffect) {
				simpleShadowing = YES;
				[terr_obj->mesh setMaterial:simpleShadowEffect];
		} else if (terr_effect==simpleShadowEffect) {
			[terr_obj->mesh setMaterial:redTerrEffect];
		} else if (terr_effect==redTerrEffect) {
				[terr_obj->mesh setMaterial:srecEffect];
		}
		else    O3Assert(false , @"wth");
		r_pressed = YES;
	} else {
		r_pressed = glfwGetKey(GLFW_KEY_RIGHT);
	}
	
	static BOOL p_pressed = NO;
	if (glfwGetKey('P')==GLFW_PRESS && !p_pressed) {
		NSLog(@"o!");
		ofstream ofile("/Users/jon/dump.txt", ios_base::app);
		ofile<<[[[NSDate date] description] UTF8String]<<"<";
		O3CGEffect* terr_effect = [terr_obj->mesh material];
		if (terr_effect==srecEffect) {
			ofile<<"New Effect";
		} else if (terr_effect==simpleShadowEffect) {
			ofile<<"Plain Shadow";
		} else if (terr_effect==redTerrEffect) {
			ofile<<"Flat Lighting";
		}
		ofile<<">: "<<DistanceBetweenBeamAndPlane()<<"\n";
		ofile.close();
		p_pressed = YES;
	} else {
		p_pressed = glfwGetKey('P');
	}
	
	if (glfwGetKey(GLFW_KEY_SPACE)==GLFW_PRESS)
		SetBeamOffset(beam_offset-.001);
}

void MousePos(O3Camera* camera_to_change) {
	int x,y; glfwGetMousePos(&x,&y);
	x -= 320;
	y -= 246;
	if (!x || !y) return;
	double mult = .015;
	[camera_to_change setRotation:O3Rotation3(-y*mult, 0, x*mult)];	
}

void WindowResize(int w, int h) {
	windowWidth = w;
	windowHeight = h;
} 

void MouseWheelCallback(int num) {
	if (renderObjects.empty()) return;
	SetBeamOffset(.01*num);
}


