/**
 *  @file O3DirectionalLight.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 11/23/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3DirectionalLight.h"


@implementation O3DirectionalLight
O3DefaultO3InitializeImplementation

/******************************************************************************************/
#pragma mark Initializers
/******************************************************************************************/
- (O3Light*)initWithLightOriginDirection:(O3Vec3r)aLocation ambient:(NSColor*)ambientColor diffuse:(NSColor*)diffuseColor specular:(NSColor*)specularColor {
	[super initWithLocation:(O3Point3)aLocation 
					ambient:ambientColor
					diffuse:diffuseColor
				   specular:specularColor
				attenuation:QuadraticEquationR(1,0,0)
					 cutoff:.5/255 ];
	return self;
}

- (O3Light*)initWithLightOriginDirection:(O3Vec3r)aLocation ambient:(NSColor*)ambientColor diffuse:(NSColor*)diffuseColor specular:(NSColor*)specularColor attenuation:(QuadraticEquationR)reciprocalAttenuation {
	[super initWithLocation:(O3Point3)aLocation 
					ambient:ambientColor
					diffuse:diffuseColor
				   specular:specularColor
				attenuation:reciprocalAttenuation
					 cutoff:.5/255 ];
	return self;
}

- (O3Light*)initWithLightOriginDirection:(O3Vec3r)aLocation ambient:(NSColor*)ambientColor diffuse:(NSColor*)diffuseColor specular:(NSColor*)specularColor attenuation:(QuadraticEquationR)reciprocalAttenuation cutoff:(real)cutoff {
	[super initWithLocation:(O3Point3)aLocation 
					ambient:ambientColor
					diffuse:diffuseColor
				   specular:specularColor
				attenuation:reciprocalAttenuation
					 cutoff:cutoff ];
	return self;
}

- (void)set {
	if (mIndex==-1) return;
	O3AssertInContext(mContext);
	
	GLenum light = GL_LIGHT0 + mIndex;
	GLfloat wPosition[] = {mLocation->GetX(), mLocation->GetY(), mLocation->GetZ(), 0.};
	glLightfv(light, GL_AMBIENT, mColors);
	glLightfv(light, GL_DIFFUSE, mColors+4);
	glLightfv(light, GL_SPECULAR, mColors+8);
	glLightfv(light, GL_POSITION, wPosition);
	glLightf(light, GL_CONSTANT_ATTENUATION, mAttenuation->GetC());
	glLightf(light, GL_LINEAR_ATTENUATION, mAttenuation->GetB());
	glLightf(light, GL_QUADRATIC_ATTENUATION, mAttenuation->GetA());
}


@end
