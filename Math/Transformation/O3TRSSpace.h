/**
 *  @file O3Space.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 2/5/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3Space.h"
@class O3Camera;
#ifdef __cplusplus
using namespace ObjC3D::Math;
#endif

@interface O3TRSSpace : O3Space <NSCoding> {
#ifdef __cplusplus
	O3Translation3 mTranslation;
	O3Rotation3 mRotation;
	O3Scale3 mScale;
#else
	double mTranslation[3];
	double mRotation[4];
	float mScale[3];
#endif
}
- (void)moveTo:(O3Vec3d)amount inPOVOf:(id<O3Spatial>)pov;
- (void)rotateBy:(angle)theta over:(O3Vec3d)axis inPOVOf:(id<O3Spatial>)pov;
- (void)resize:(O3Vec3d)amount inPOVOf:(id<O3Spatial>)pov;

//Applied in scale, rotate, translate order
- (O3Vec3d)rotation; ///<Euler angles
- (void)setRotation:(O3Vec3d)newrot;
- (O3Vec3d)translation;
- (void)setTranslation:(O3Vec3d)newTrans;
- (O3Vec3f)scale;
- (void)setScale:(O3Vec3f)ns;
- (O3Rotation3)quatRotation; ///<Quaternion representation
- (void)setQuatRotation:(O3Rotation3)rot;

- (void)drawOrthoBasis:(O3RenderContext*)ctx;
@end
