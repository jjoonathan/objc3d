/**
 *  @file O3Camera.h
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3Locateable.h"
using namespace ObjC3D::Math;

@interface O3Camera : O3Locateable {
	Space3* mPostProjectionSpace;
	BOOL mPostProjectionSpaceNeedsUpdate;
	double mAspectRatio;	///<Width/height of whatever is being rendered into
	double mNearPlane, mFarPlane;	///<The near and far plane distances (like min and max Z values)
	double mFOVY;
}

//Accessors
- (double)aspectRatio;	///<Returns the aspect ratio (width/height) of the receiver.
- (double)nearPlaneDistance; ///<Returns how far away the near plane is
- (double)farPlaneDistance;  ///<Returns how far away the far plane is
- (double)nearToFarRatio;    ///<Returns the near-plane to far-plane ratio
- (double)fovY;				///<Returns the field of view in the Y direction in radians
- (O3Mat4x4d)viewMatrix;		///<Returns the view (look-at) matrix
- (O3Mat4x4d)projectionMatrix; ///<Returns the receiver's projection matrix
- (O3Mat4x4d)viewProjectionMatrix; ///<Returns the receiver's projection matrix * its view matrix (view then project)
- (Space3*)postProjectionSpace; ///<Returns the post projective space (projection transform, superspace is camera space). @note the returned Space3 does not "synchronize" with its O3Camera until you call this method. For example, if you called [camera postProjectionSpace]; then [camera setAspectRatio:2];, the Space3 would not update until the next time you called [camera postProjectionSpace]. The return values of both methods would be the same, though.

//Setters
- (void)setAspectRatio:(double)newAR;	///<Sets the aspect ratio (width/height) of the receiver.
- (void)setNearPlaneDistance:(double)newDist;	///<Sets how far away the near plane is
- (void)setFarPlaneDistance:(double)newDist;	///<Sets how far away the far plane is @note This change will not take effect until -(void)set is called (usually in the next frame). This behavior is usually desired.
- (void)setFovY:(double)newFOVY;			///<Sets the field of view in the Y direction (odd capitalization to maintain KVC compliance)

//Use
- (void)setViewMatrix; ///<Multiplies the current matrix by the receiver's view matrix @warning This method is a candidate for deprication.
- (void)setProjectionMatrix; ///<Multiplies the current matrix by the receiver's projection matrix @warning This method is a candidate for deprication.
//- (void)debugDraw; ///<Draw a wireframe model of the receiver
@end

@interface NSView (AspectRatio)
- (double)aspectRatio; //Lets O3Camera watch the aspect ratio
@end