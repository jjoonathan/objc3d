/**
 *  @file O3SpotLight.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 11/23/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3SpotLight.h"


@implementation O3SpotLight
O3DefaultO3InitializeImplementation

- (O3Light*)initWithLocation:(O3Point3)aLocation ambient:(NSColor*)ambientColor diffuse:(NSColor*)diffuseColor specular:(NSColor*)specularColor direction:(O3Vec3r)aDirection angle:(angle)spread blurriness:(float)theExponent {
	[self initWithLocation:(O3Point3)aLocation 
				   ambient:ambientColor
				   diffuse:diffuseColor
				  specular:specularColor
			   attenuation:QuadraticEquationR(1,0,0)
					cutoff:.5/255
				 direction:aDirection
					 angle:spread 
				  blurriness:theExponent ];
	return self;
}

- (O3Light*)initWithLocation:(O3Point3)aLocation ambient:(NSColor*)ambientColor diffuse:(NSColor*)diffuseColor specular:(NSColor*)specularColor attenuation:(QuadraticEquationR)reciprocalAttenuation direction:(O3Vec3r)aDirection angle:(angle)spread blurriness:(float)theExponent {
	[self initWithLocation:(O3Point3)aLocation 
				   ambient:ambientColor
				   diffuse:diffuseColor
				  specular:specularColor
			   attenuation:reciprocalAttenuation
					cutoff:.5/255
				   direction:aDirection
					   angle:spread
				  blurriness:theExponent ];
	return self;
}

- (O3Light*)initWithLocation:(O3Point3)aLocation ambient:(NSColor*)ambientColor diffuse:(NSColor*)diffuseColor specular:(NSColor*)specularColor attenuation:(QuadraticEquationR)reciprocalAttenuation cutoff:(real)cutoff  direction:(O3Vec3r)aDirection angle:(angle)spread blurriness:(float)theExponent {
	direction = new O3Vec3r(aDirection);
	spreadAngle = spread;
	exponent = theExponent;
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
	GLenum light = GL_LIGHT0 + mIndex;
	GLfloat wPosition[] = {mLocation->GetX(), mLocation->GetY(), mLocation->GetZ(), 1.};
	glLightfv(light, GL_AMBIENT, mColors);
	glLightfv(light, GL_DIFFUSE, mColors+4);
	glLightfv(light, GL_SPECULAR, mColors+8);
	glLightfv(light, GL_POSITION, wPosition);
	glLightf(light, GL_CONSTANT_ATTENUATION, mAttenuation->GetC());
	glLightf(light, GL_LINEAR_ATTENUATION, mAttenuation->GetB());
	glLightf(light, GL_QUADRATIC_ATTENUATION, mAttenuation->GetA());
	
	glLightfv(light, GL_SPOT_DIRECTION, *direction);
	glLightf(light, GL_SPOT_EXPONENT, exponent);
	glLightf(light, GL_SPOT_CUTOFF, spreadAngle);
}

- (void)dealloc {
	delete direction; /*direction = NULL*/
	[super dealloc];
}
	
@end
