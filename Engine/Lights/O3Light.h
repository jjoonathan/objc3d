/**
 *  @file O3Light.h
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#ifdef __cplusplus
using namespace ObjC3D::Math;
#endif

#define O3EXCEPTION_LIGHT_UNDERFLOW @"ObjC3D Light Stack Underflow"

@interface O3Light : NSObject {	
	int mIndex;			//The light index (in the form of GL_LIGHT0+index). -1 if the light is currently unbound to a GL_LIGHT.
	/*O3WEAK*/ NSOpenGLContext *mContext;
	float mColors[12]; ///<Stores ambient, diffuse, and specular
#ifdef __cplusplus
	O3Point3* mLocation;
	QuadraticEquationR* mAttenuation;
#else
	void* mLocation;
	void* mAttenuation;
#endif
	real mEffectiveRadius; 
}

//Initializers
#ifdef __cplusplus
- (O3Light*)initWithLocation:(O3Point3)aLocation ambient:(NSColor*)ambientColor diffuse:(NSColor*)diffuseColor specular:(NSColor*)specularColor;
- (O3Light*)initWithLocation:(O3Point3)aLocation ambient:(NSColor*)ambientColor diffuse:(NSColor*)diffuseColor specular:(NSColor*)specularColor attenuation:(QuadraticEquationR)reciprocalAttenuation;
- (O3Light*)initWithLocation:(O3Point3)aLocation ambient:(NSColor*)ambientColor diffuse:(NSColor*)diffuseColor specular:(NSColor*)specularColor attenuation:(QuadraticEquationR)reciprocalAttenuation cutoff:(real)cutoff;	///<Initializes the receiver, attaches it to the light list, and enables it.
#endif

//Light attachers
- (void)enable;	///<Turns the receiver "on", attaching it to the current OpenGL context if its context hasn't been specified.
- (void)disable; ///<Turns the receiver "off (does not touch the light list and siply returns if the light isn't attached to an OpenGL context.
- (void)attach;	///<Finds a light slot for the receiver in the current OpenGL context and attaches to it.
- (void)detach;	///<Detaches from a light slot (if the receiver is bound to one), essentially turning the light "off". The light is automatically removed from the light list on dealloc, so you shouldn't have to use this.

//Inspectors
- (BOOL)isEnabled; ///<Returns weather or not the light will be visible in the current OpenGL context
- (NSOpenGLContext*)context; ///<Returns the OpenGL context the receiver is currently bound to (or nil)
- (int)openGLLightIndex; ///<Returns the index (in the form GL_LIGHT0+return_value) of the receiver
- (NSColor*)ambient; ///<Returns the ambient color of the receiver
- (NSColor*)diffuse; ///<Returns the ambient color of the receiver
- (NSColor*)specular; ///<Returns the ambient color of the receiver
- (double)cutoff;		 ///<Returns the value at which the light's contribution can be assumed to be 0
- (real)effectiveRadius; ///<Returns the minimum distance at which the light's contribution can be assumed to be 0

//Setters
- (void)setContext:(NSOpenGLContext*)newContext; ///<Sets the OpenGL context of the receiver
- (void)setAmbient:(NSColor*)newAmbient;
- (void)setDiffuse:(NSColor*)newDiffuse;
- (void)setSpecular:(NSColor*)newSpecular;
- (void)setCutoff:(double)newCutoff;
- (void)setEffectiveRadius:(real)newRadius;

//C++ Accessors
#ifdef __cplusplus
- (const O3Point3*)location; ///<Returns the location of the receiver by const reference
- (void)setLocation:(O3Point3)newLocation; ///<Changes the location in worldspace of the receiver
- (void)setAttenuation:(const QuadraticEquationR*)newAttenuation;
#endif

//Private methods
- (void)set;	///<Copies the receiver's attributes to the opengl light GL_LIGHT0+mIndex.
@end
