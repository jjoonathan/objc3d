/**
 *  @file O3Light.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 11/22/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#include "O3Light.h"

@implementation O3Light

static std::vector<O3Light*>* gBoundLights;
static int gMaxLights;

/******************************************************************************************/
#pragma mark Initializers
/******************************************************************************************/
+ (void)initialize {
	[self setKeys:[NSArray arrayWithObjects:@"effectiveRadius",nil] triggerChangeNotificationsForDependentKey:@"cutoff"];
}

- (O3Light*)initWithLocation:(O3Point3)aLocation ambient:(Color)ambientColor diffuse:(Color)diffuseColor specular:(Color)specularColor {
	[self initWithLocation:aLocation 
				   ambient:ambientColor
				   diffuse:diffuseColor
				  specular:specularColor
			   attenuation:QuadraticEquationR(1,0,0)
					cutoff:.5/255 ];
	return self;
}

- (O3Light*)initWithLocation:(O3Point3)aLocation ambient:(Color)ambientColor diffuse:(Color)diffuseColor specular:(Color)specularColor attenuation:(QuadraticEquationR)reciprocalAttenuation {
	[self initWithLocation:aLocation 
				   ambient:ambientColor
				   diffuse:diffuseColor
				  specular:specularColor
			   attenuation:reciprocalAttenuation
					cutoff:.5/255 ];
	return self;
}

- (O3Light*)initWithLocation:(O3Point3)aLocation ambient:(Color)ambientColor diffuse:(Color)diffuseColor specular:(Color)specularColor attenuation:(QuadraticEquationR)reciprocalAttenuation cutoff:(real)cutoff {
	mLocation = new O3Point3(aLocation);
	mAmbient = new Color(ambientColor);
	mDiffuse = new Color(diffuseColor);
	mSpecular = new Color(specularColor);
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
	if (!gBoundLights) {
		gBoundLights = new std::vector<O3Light*>();
		GLint tmpMaxLights;
		glGetIntegerv(GL_MAX_LIGHTS, &tmpMaxLights);
		gMaxLights = tmpMaxLights;
		glEnable(GL_LIGHTING);
		bindIndex = 0;
	} else {
		int i;
		bindIndex = 0;
		int j = gBoundLights->size();
		for (i=0;i<j;i++) if (((gBoundLights->at(i))->mIndex)==bindIndex) bindIndex++;
	}
	if (mIndex>=gMaxLights) [NSException raise:O3EXCEPTION_LIGHT_OVERFLOW format:@"Attempt to attach more lights to the scene than this opengl implementation allows (%i max).", gMaxLights];
	mIndex = bindIndex;
	gBoundLights->push_back(self);
	sort(gBoundLights->begin(), gBoundLights->end());
	glEnable(GL_LIGHT0+mIndex);
	[self set];
}

- (void)detach {
	if (mIndex==-1) return;
	O3AssertInContext(mContext);
	
	glDisable(GL_LIGHT0+mIndex);
	std::vector<O3Light*>::iterator it = gBoundLights->begin();
	for (;(gBoundLights->end())!=it;it++) if ((*it)==self) {gBoundLights->erase(it); break;}
	mIndex = -1;
}

- (void)set {
	if (mIndex==-1) return;
	O3AssertInContext(mContext);
	
	GLenum light = GL_LIGHT0 + mIndex;
	GLfloat wPosition[] = {mLocation->GetX(), mLocation->GetY(), mLocation->GetZ(), 1.};
	glLightfv(light, GL_AMBIENT, *mAmbient);
	glLightfv(light, GL_DIFFUSE, *mDiffuse);
	glLightfv(light, GL_SPECULAR, *mSpecular);
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

- (void)setAmbient:(const Color*)newAmbient {
	*mAmbient= *newAmbient;
	if (mIndex==-1) return;
	int light = GL_LIGHT0+mIndex;
	glLightfv(light, GL_AMBIENT, *mAmbient);
}

- (void)setDiffuse:(const Color*)newDiffuse {
	*mDiffuse= *newDiffuse;
	if (mIndex==-1) return;
	int light = GL_LIGHT0+mIndex;
	glLightfv(light, GL_DIFFUSE, *mDiffuse);
}

- (void)setSpecular:(const Color*)newSpecular {
	*mSpecular= *newSpecular;
	if (mIndex==-1) return;
	int light = GL_LIGHT0+mIndex;
	glLightfv(light, GL_SPECULAR, *mSpecular);
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

- (const Color*)ambient {
	return mAmbient;
}

- (const Color*)diffuse {
	return mDiffuse;
}

- (const Color*)specular {
	return mSpecular;
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
	delete mLocation;		/*mLocation = NULL;*/
	delete mAmbient;		/*mAmbient = NULL;*/
	delete mSpecular;		/*mSpecular = NULL;*/
	delete mAttenuation;	/*mAttenuation = NULL;*/
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
