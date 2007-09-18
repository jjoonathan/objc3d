/**
 *  @file O3SpotLight.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 11/23/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import <Cocoa/Cocoa.h>
#import "O3Light.h"

@interface O3SpotLight : O3Light {
	O3Vec3r *direction;
	angle spreadAngle;
	float exponent;
}
- (O3Light*)initWithLocation:(O3Point3)aLocation ambient:(Color)ambientColor diffuse:(Color)diffuseColor specular:(Color)specularColor direction:(O3Vec3r)aDirection angle:(angle)spread blurriness:(float)exponent;
- (O3Light*)initWithLocation:(O3Point3)aLocation ambient:(Color)ambientColor diffuse:(Color)diffuseColor specular:(Color)specularColor attenuation:(QuadraticEquationR)reciprocalAttenuation direction:(O3Vec3r)aDirection angle:(angle)spread blurriness:(float)exponent;
- (O3Light*)initWithLocation:(O3Point3)aLocation ambient:(Color)ambientColor diffuse:(Color)diffuseColor specular:(Color)specularColor attenuation:(QuadraticEquationR)reciprocalAttenuation cutoff:(real)cutoff  direction:(O3Vec3r)aDirection angle:(angle)spread blurriness:(float)exponent;	///<Initializes the receiver, attaches it to the light list, and enables it.


@end
