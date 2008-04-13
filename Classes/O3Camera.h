/**
 *  @file O3Camera.h
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3Locateable.h"
#ifdef __cplusplus
using namespace ObjC3D::Math;
#endif
@class O3Camera, O3MatrixSpace;

@interface O3Camera : O3Locateable <NSCoding> {
	O3MatrixSpace* mPostProjectionSpace;
	BOOL mPostProjectionSpaceNeedsUpdate;
	
	double mAspectRatio;	///<Width/height of whatever is being rendered into
	double mNearPlane, mFarPlane;	///<The near and far plane distances (like min and max Z values)
	double mFOVY;
	float mFlySpeed; ///<Units/sec
	float mRotRate;  ///<Rad/tick
	float mBarrelRate;  ///<Rad/sec
}

//Accessors
- (float)flySpeed; ///<Units/sec
- (void)setFlySpeed:(float)fs;
- (float)rotRate;  ///<Rad/tick
- (void)setRotRate:(float)rr;
- (float)barrelRate;  ///<Rad/sec
- (void)setBarrelRate:(float)rr;
- (double)aspectRatio;	///<Returns the aspect ratio (width/height) of the receiver.
- (double)nearPlaneDistance; ///<Returns how far away the near plane is
- (double)farPlaneDistance;  ///<Returns how far away the far plane is
- (double)nearToFarRatio;    ///<Returns the near-plane to far-plane ratio
- (double)fovY;				///<Returns the field of view in the Y direction in radians
- (O3Mat4x4d)viewMatrix;		///<Returns the view (look-at) matrix
- (O3Mat4x4d)projectionMatrix; ///<Returns the receiver's projection matrix
- (O3Mat4x4d)viewProjectionMatrix; ///<Returns the receiver's view*project matrix
- (O3Space*)postProjectionSpace; ///<Returns the post projective space (projection transform, superspace is camera space)

//Setters
- (void)rotateForMouseMoved:(O3Vec2d)amount;
- (void)setAspectRatio:(double)newAR;	///<Sets the aspect ratio (width/height) of the receiver.
- (void)setNearPlaneDistance:(double)newDist;	///<Sets how far away the near plane is
- (void)setFarPlaneDistance:(double)newDist;	///<Sets how far away the far plane is @note This change will not take effect until -(void)set is called (usually in the next frame). This behavior is usually desired.
- (void)setFovY:(double)newFOVY;			///<Sets the field of view in the Y direction (odd capitalization to maintain KVC compliance)

//Use
- (void)setProjectionMatrix; ///<Sets the projection matrix to the receiver's matrix. No pushing, since that would be pointless with a proj matrix.
- (void)setViewMatrix; ///<Sets the modelview matrix to be the matrix that transforms from worldspace into cameraspace.
//- (void)debugDraw; ///<Draw a wireframe model of the receiver
- (void)tickWithContext:(O3RenderContext*)context;
@end

@interface NSView (AspectRatio)
- (double)aspectRatio; //Lets O3Camera watch the aspect ratio
@end
