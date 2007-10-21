/**
 *  @file O3Camera.mm
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3Camera.h"
#define mLocation (*(self->mpLocation))
#define mDirection (*(self->mpDirection))
#define mUp (*(self->mpUp))
using namespace ObjC3D::Math;

@implementation O3Camera

inline void O3Camera_init(O3Camera* self) {
	self->mPostProjectionSpace = new Space3(self->mSpace);
	self->mAspectRatio = 1.;
	self->mNearPlane = .1;
	self->mFarPlane = 100.;
	self->mFOVY = 90.; //In degrees?!
	self->mPostProjectionSpaceNeedsUpdate = YES;
}

inline double O3Camera_aspectRatio(O3Camera* self) {
	return self->mAspectRatio;
}

inline O3Mat3x3d O3Camera_orthonormalBase(O3Camera* self) {
	const O3Mat4x4d& tmat = self->mSpace->MatrixFromSuper();
	O3Vec3d xcol(tmat.GetColumn(0));
	O3Vec3d ycol(tmat.GetColumn(1));
	O3Vec3d zcol(tmat.GetColumn(2));
	return O3Mat3x3d(xcol, ycol, zcol);
}

inline Space3* O3Camera_postProjectiveSpace(O3Camera* self) {
	if (!self->mPostProjectionSpaceNeedsUpdate) return self->mPostProjectionSpace;
	O3Mat4x4d themat;
	themat.SetPerspective(self->mFOVY, self->mAspectRatio, self->mNearPlane, self->mFarPlane);
	self->mPostProjectionSpace->Set(themat);
	self->mPostProjectionSpaceNeedsUpdate = NO;
	return self->mPostProjectionSpace;
}

/************************************/ #pragma mark Initialization /************************************/
- (void)dealloc {
	if (mPostProjectionSpace) delete mPostProjectionSpace; /*mPostProjectionSpace = NULL;*/
	[super dealloc];
}

- (id)init {
	O3SuperInitOrDie();
	O3Camera_init(self);
	return self;
}


/************************************/ #pragma mark Inspectors /************************************/
- (double)nearPlaneDistance {return mNearPlane;}
- (double)farPlaneDistance {return mFarPlane;}
- (double)nearToFarRatio {return mNearPlane/mFarPlane;}
- (double)fovY {return mFOVY;}
- (double)aspectRatio {return O3Camera_aspectRatio(self);}

- (O3Mat4x4d)viewMatrix {
	O3Camera_postProjectiveSpace(self);
	return mSpace->MatrixFromRoot();
}

- (O3Mat4x4d)projectionMatrix {
	return O3Camera_postProjectiveSpace(self)->MatrixFromSuper();
}

- (O3Mat4x4d)viewProjectionMatrix {
	return O3Camera_postProjectiveSpace(self)->MatrixFromRoot();
}

- (Space3*)postProjectionSpace {
	return O3Camera_postProjectiveSpace(self);
}

/************************************/ #pragma mark Mutators /************************************/
- (void)setAspectRatio:(double)newAR {mAspectRatio = newAR; mPostProjectionSpaceNeedsUpdate = YES;}	///<@note This change will not take effect until -(void)set is called (usually in the next frame). This behavior is usually desired but can cause confusion since the accessors will return the new value.
- (void)setNearPlaneDistance:(double)newDist {mNearPlane = newDist; mPostProjectionSpaceNeedsUpdate = YES;}	///<@note This change will not take effect until -(void)set is called (usually in the next frame). This behavior is usually desired but can cause confusion since the accessors will return the new value.
- (void)setFarPlaneDistance:(double)newDist {mFarPlane = newDist; mPostProjectionSpaceNeedsUpdate = YES;}	///<@note This change will not take effect until -(void)set is called (usually in the next frame). This behavior is usually desired but can cause confusion since the accessors will return the new value.
- (void)setFovY:(double)newFOVY {mFOVY = newFOVY; mPostProjectionSpaceNeedsUpdate = YES;}	///<@note This change will not take effect until -(void)set is called (usually in the next frame). This behavior is usually desired but can cause confusion since the accessors will return the new value.

/************************************/ #pragma mark Use /************************************/
- (void)setViewMatrix {
	glMultMatrixd(mSpace->MatrixFromSuper());
}

- (void)setProjectionMatrix {
	glMatrixMode(GL_PROJECTION);
	glLoadMatrixd(O3Camera_postProjectiveSpace(self)->MatrixFromSuper());
	glMatrixMode(GL_MODELVIEW);
}

@end



@implementation NSView (AspectRatio)
- (double)aspectRatio {
	NSRect fr = [self frame];
	return (double)fr.size.width/fr.size.height;
}
@end

///NSViewAspectRatioLoader is a dummy class to make aspectRatio dependant on frame in NSView
@interface NSViewAspectRatioLoader
@end

@implementation NSViewAspectRatioLoader
+ (void)init {
	[NSView setKeys:[NSArray arrayWithObject:@"frame"] triggerChangeNotificationsForDependentKey:@"aspectRatio"];
}
@end