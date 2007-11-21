/**
 *  @file O3Light.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 11/22/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#include "O3Light.h"
#include <vector>

@implementation O3Light

static std::vector<UIntP>* gFreeLights; ///<Free light indexes. NOT thread safe

/******************************************************************************************/
#pragma mark Initializers
/******************************************************************************************/
+ (void)initialize {
	[self setKeys:[NSArray arrayWithObjects:@"effectiveRadius",nil] triggerChangeNotificationsForDependentKey:@"cutoff"];
}

- (O3Light*)initWithLocation:(O3Point3)aLocation ambient:(NSColor*)ambientColor diffuse:(NSColor*)diffuseColor specular:(NSColor*)specularColor {
	[self initWithLocation:aLocation 
				   ambient:ambientColor
				   diffuse:diffuseColor
				  specular:specularColor
			   attenuation:QuadraticEquationR(1,0,0)
					cutoff:.5/255 ];
	return self;
}

- (O3Light*)initWithLocation:(O3Point3)aLocation ambient:(NSColor*)ambientColor diffuse:(NSColor*)diffuseColor specular:(NSColor*)specularColor attenuation:(QuadraticEquationR)reciprocalAttenuation {
	[self initWithLocation:aLocation 
				   ambient:ambientColor
				   diffuse:diffuseColor
				  specular:specularColor
			   attenuation:reciprocalAttenuation
					cutoff:.5/255 ];
	return self;
}

- (O3Light*)initWithLocation:(O3Point3)aLocation ambient:(NSColor*)ambientColor diffuse:(NSColor*)diffuseColor specular:(NSColor*)specularColor attenuation:(QuadraticEquationR)reciprocalAttenuation cutoff:(real)cutoff {
	mLocation = new O3Point3(aLocation);
	[self setAmbient:ambientColor];
	[self setDiffuse:diffuseColor];
	[self setSpecular:specularColor];
	mAttenuation = new QuadraticEquationR(reciprocalAttenuation);
	mEffectiveRadius = mAttenuation->GetHighXIntercept(cutoff);
	[self attach];
	return self;
}

/******************************************************************************************/
#pragma mark Bind/unbind, turn on/off, and test for enabled-ness
/******************************************************************************************/
- (void)attach {
	if (!mContext) mContext = [NSOpenGLContext currentContext];
	O3AssertInContext(mContext);
	if (mIndex!=-1) return;
	if (!mContext) [NSException raise:O3BadContextException format:@"There was no suitable OpenGL mContext for light %@ to attach to.", self];

	int bindIndex = -1;
	if (!gFreeLights) {
		gFreeLights = new std::vector<UIntP>();
		GLint tmpMaxLights;
		glGetIntegerv(GL_MAX_LIGHTS, &tmpMaxLights);
		UIntP i; for(i=0; i<tmpMaxLights; i++) gFreeLights->push_back(i);
		glEnable(GL_LIGHTING);
	}
	if (!gFreeLights->size()) {
		GLint tmpMaxLights;
		glGetIntegerv(GL_MAX_LIGHTS, &tmpMaxLights);
		[NSException raise:O3EXCEPTION_LIGHT_UNDERFLOW format:@"Attempt to attach more lights to the scene than this opengl implementation allows (%i max).", tmpMaxLights];
	}
	O3Assert(gFreeLights.size(), @"Light stack underflow (too many lights active at once)");
	bindIndex = gFreeLights->back(); gFreeLights->pop_back();
	mIndex = bindIndex;
	glEnable(GL_LIGHT0+mIndex);
	[self set];
}

- (void)detach {
	if (mIndex==-1) return;
	O3AssertInContext(mContext);
	
	glDisable(GL_LIGHT0+mIndex);
	gFreeLights->push_back(mIndex);
	mIndex = -1;
}

- (void)set {
	if (mIndex==-1) return;
	O3AssertInContext(mContext);
	
	GLenum light = GL_LIGHT0 + mIndex;
	GLfloat wPosition[] = {mLocation->GetX(), mLocation->GetY(), mLocation->GetZ(), 1.};
	glLightfv(light, GL_AMBIENT, mColors+0);
	glLightfv(light, GL_DIFFUSE, mColors+4);
	glLightfv(light, GL_SPECULAR, mColors+8);
	glLightfv(light, GL_POSITION, wPosition);
	glLightf(light, GL_CONSTANT_ATTENUATION, mAttenuation->GetC());
	glLightf(light, GL_LINEAR_ATTENUATION, mAttenuation->GetB());
	glLightf(light, GL_QUADRATIC_ATTENUATION, mAttenuation->GetA());
}

- (void)enable {
	if (mIndex==-1) [self attach];
	O3AssertInContext(mContext);
	
	glEnable(GL_LIGHT0+mIndex);
}
	
- (void)disable {
	if (mIndex==-1) return;
	O3AssertInContext(mContext);
	
	glDisable(GL_LIGHT0+mIndex);
}

/******************************************************************************************/
#pragma mark Setters
/******************************************************************************************/
- (void)setContext:(NSOpenGLContext*)newContex {
	BOOL shouldEnable = [self isEnabled];
	[self detach];
	mContext = newContex;
	if (shouldEnable) [self enable];
}

- (void)setLocation:(O3Point3)newLocation {
	*mLocation= newLocation;
	if (mIndex==-1) return;
	int light = GL_LIGHT0+mIndex;
	GLfloat wPosition[] = {mLocation->GetX(), mLocation->GetY(), mLocation->GetZ(), 1.};
	glLightfv(light, GL_POSITION, wPosition);
}

- (void)setAmbient:(NSColor*)newAmbient {
	[newAmbient getRed:mColors green:mColors+1 blue:mColors+2 alpha:mColors+3];
	if (mIndex==-1) return;
	int light = GL_LIGHT0+mIndex;
	glLightfv(light, GL_AMBIENT, mColors+0);
}

- (void)setDiffuse:(NSColor*)newDiffuse {
	[newDiffuse getRed:mColors+4 green:mColors+5 blue:mColors+6 alpha:mColors+7];
	if (mIndex==-1) return;
	int light = GL_LIGHT0+mIndex;
	glLightfv(light, GL_DIFFUSE, mColors+4);
}

- (void)setSpecular:(NSColor*)newSpecular {
	[newSpecular getRed:mColors+8 green:mColors+9 blue:mColors+10 alpha:mColors+11];
	if (mIndex==-1) return;
	int light = GL_LIGHT0+mIndex;
	glLightfv(light, GL_SPECULAR, mColors+8);
}

- (void)setAttenuation:(const QuadraticEquationR*)newAttenuation {
	*mAttenuation= *newAttenuation;
	if (mIndex==-1) return;
	int light = GL_LIGHT0+mIndex;
	glLightf(light, GL_CONSTANT_ATTENUATION, mAttenuation->GetC());
	glLightf(light, GL_LINEAR_ATTENUATION, mAttenuation->GetB());
	glLightf(light, GL_QUADRATIC_ATTENUATION, mAttenuation->GetA());
}

- (void)setCutoff:(double)newCutoff {
	[self setEffectiveRadius:mAttenuation->GetHighXIntercept(newCutoff)];
}

- (void)setEffectiveRadius:(real)newRadius {
	mEffectiveRadius= newRadius;
}

/******************************************************************************************/
#pragma mark Inspectors
/******************************************************************************************/
- (BOOL)isEnabled {
	if (mIndex==-1) return NO;
	GLboolean enabled; glGetBooleanv(GL_LIGHT0+mIndex, &enabled);
	return enabled;
}

- (NSOpenGLContext*)context {
	return mContext;
}

- (int)openGLLightIndex {
	return mIndex;
}

- (const O3Point3*)location {
	return mLocation;
}

- (NSColor*)ambient {
	return [NSColor colorWithCalibratedRed:mColors[0] green:mColors[1] blue:mColors[2] alpha:mColors[3]];
}

- (NSColor*)diffuse {
	return [NSColor colorWithCalibratedRed:mColors[4] green:mColors[5] blue:mColors[6] alpha:mColors[7]];
}

- (NSColor*)specular {
	return [NSColor colorWithCalibratedRed:mColors[8] green:mColors[9] blue:mColors[10] alpha:mColors[11]];
}

- (double)cutoff {
	return (*mAttenuation)(mEffectiveRadius);
}

- (real)effectiveRadius {
	return mEffectiveRadius;
}


/******************************************************************************************/
#pragma mark Deallocation
/******************************************************************************************/
- (void)dealloc {
	if (mIndex!=-1) [self detach];
	[super dealloc];
}

/******************************************************************************************/
#pragma mark KVO
/******************************************************************************************/
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey {
	NSArray *automaticallyObservedKeys = [NSArray arrayWithObjects:@"context", @"location", @"ambient", @"diffuse", @"specular", @"attenutation", @"effectiveRadius", nil];
	if ([automaticallyObservedKeys indexOfObjectIdenticalTo:theKey]!=NSNotFound) return YES;
	return [super automaticallyNotifiesObserversForKey:theKey];
}

@end 
