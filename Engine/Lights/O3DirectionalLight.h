/**
 *  @file O3DirectionalLight.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 11/23/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3Light.h"

@interface O3DirectionalLight : O3Light {
}
//Initializers
#ifdef __cplusplus
- (O3Light*)initWithLightOriginDirection:(O3Vec3r)aLocation ambient:(NSColor*)ambientColor diffuse:(NSColor*)diffuseColor specular:(NSColor*)specularColor;
- (O3Light*)initWithLightOriginDirection:(O3Vec3r)aLocation ambient:(NSColor*)ambientColor diffuse:(NSColor*)diffuseColor specular:(NSColor*)specularColor attenuation:(QuadraticEquationR)reciprocalAttenuation;
- (O3Light*)initWithLightOriginDirection:(O3Vec3r)aLocation ambient:(NSColor*)ambientColor diffuse:(NSColor*)diffuseColor specular:(NSColor*)specularColor attenuation:(QuadraticEquationR)reciprocalAttenuation cutoff:(real)cutoff;
#endif
@end
