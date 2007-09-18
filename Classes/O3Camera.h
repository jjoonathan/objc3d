/**
 *  @file O3Camera.h
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3Locateable.h"
using namespace ObjC3D::Math;

@interface NSObject (O3CameraAspectRatioSource) ///<An informal protocol with various ways of getting the aspect ratio (really width and height at this point)
- (NSSize)size;
- (NSRect)frame;
- (int)width;
- (int)height;
@end

enum O3CameraAspectRatioSourceType { ///<A private enum used internally by O3Camera for callbacks
	O3AutoDetectAspectRatio, ///<Used internally as kindof a NULL value
	O3SizeAspectRatio,  ///<Gets aspect ratio by calling -(NSSize)size
	O3FrameAspectRatio, ///<Gets aspect ratio by calling -(NSRect)frame.size
	O3WidthHeightAspectRatio ///<Gets aspect ratio by calling -(int)width / -(int)height
};

@interface O3Camera : O3Locateable {
	Space3* mPostProjectionSpace;
	BOOL mPostProjectionSpaceNeedsUpdate;
	double mAspectRatio;	///<Width/height of whatever is being rendered into
	id mAspectRatioSource;	///<The place the aspect ratio is computed from by calling -width and -height. Can be nil, in which case mAspectRatio is used directly.
	O3CameraAspectRatioSourceType mAspectRatioSourceType; ///<What method should be used to get the aspect ratio of the mAspectRatioSource
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
- (Space3*)postProjectionSpace; ///<Returns the post projective space (projection transform, superspace is camera space)

//Setters
- (void)setAspectRatio:(double)newAR;	///<Sets the aspect ratio (width/height) of the receiver
- (void)setAspectRatioSource:(id)newSource;	   ///<Sets the object that the receiver uses to calculate its aspect ratio (typically the view, window, or image being rendered to though anything that responds to -width and -height will work). Set to nil (default) if you want to set the aspect ratio manually.
- (void)setNearPlaneDistance:(double)newDist;	///<Sets how far away the near plane is
- (void)setFarPlaneDistance:(double)newDist;	///<Sets how far away the far plane is @note This change will not take effect until -(void)set is called (usually in the next frame). This behavior is usually desired.
- (void)setFovY:(double)newFOVY;			///<Sets the field of view in the Y direction (odd capitalization to maintain KVC compliance)

//Use
- (void)setViewMatrix; ///<Multiplies the current matrix by the receiver's view matrix @warning This method is a candidate for deprication.
- (void)setProjectionMatrix; ///<Multiplies the current matrix by the receiver's projection matrix @warning This method is a candidate for deprication.
//- (void)debugDraw; ///<Draw a wireframe model of the receiver
@end
