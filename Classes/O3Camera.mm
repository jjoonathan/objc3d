/**
 *  @file O3Camera.mm
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3Camera.h"
#import "O3GLView.h"
#define mLocation (*(self->mpLocation))
#define mDirection (*(self->mpDirection))
#define mUp (*(self->mpUp))
using namespace ObjC3D::Math;

@implementation O3Camera
O3DefaultO3InitializeImplementation

inline void O3Camera_init(O3Camera* self) {
	self->mPostProjectionSpace = new O3Space3(self->mSpace);
	self->mAspectRatio = 1.;
	self->mNearPlane = .1;
	self->mFarPlane = 100.;
	self->mFOVY = 90.; //In degrees?!
	self->mPostProjectionSpaceNeedsUpdate = YES;
	self->mFlySpeed = 2./3.;
	self->mRotRate = .015;
	self->mBarrelRate = 2.;
}

inline double O3Camera_aspectRatio(O3Camera* self) {
	return self->mAspectRatio;
}

inline O3Mat3x3d O3Camera_orthonormalBase(O3Camera* self) {
	const O3Mat4x4d& tmat = self->mSpace.MatrixFromSuper();
	O3Vec3d xcol(tmat.GetColumn(0));
	O3Vec3d ycol(tmat.GetColumn(1));
	O3Vec3d zcol(tmat.GetColumn(2));
	return O3Mat3x3d(xcol, ycol, zcol);
}

inline O3Space3* O3Camera_postProjectiveSpace(O3Camera* self) {
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

- (O3Camera*)init {
	O3SuperInitOrDie();
	O3Camera_init(self);
	return self;
}

- (O3Camera*)initWithCoder:(NSCoder*)coder {
	[super initWithCoder:coder];
	O3Assert([coder allowsKeyedCoding], @"Cannot create an O3GLView from a non-keyed coder");
	O3Camera_init(self);
	self->mAspectRatio = [coder decodeDoubleForKey:@"aspectRatio"];
	self->mNearPlane = [coder decodeDoubleForKey:@"nearPlane"];
	self->mFarPlane = [coder decodeDoubleForKey:@"farPlane"];
	self->mFOVY = [coder decodeDoubleForKey:@"fovYDegrees"];
	self->mFlySpeed = [coder decodeDoubleForKey:@"flySpeed"];
	self->mRotRate = [coder decodeDoubleForKey:@"rotRate"];
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
	[super encodeWithCoder:coder];
	[coder encodeDouble:mAspectRatio forKey:@"aspectRatio"];
	[coder encodeDouble:mNearPlane forKey:@"nearPlane"];
	[coder encodeDouble:mFarPlane forKey:@"farPlane"];
	[coder encodeDouble:mFOVY forKey:@"fovYDegrees"];	
	[coder encodeDouble:mFlySpeed forKey:@"flySpeed"];	
	[coder encodeDouble:mRotRate forKey:@"rotRate"];	
}

- (BOOL)isEqual:(O3Camera*)camera {
	if (mFOVY!=[camera fovY]) return NO;
	if (mNearPlane!=[camera nearPlaneDistance]) return NO;
	if (mFarPlane!=[camera farPlaneDistance]) return NO;
	if (mAspectRatio!=[camera aspectRatio]) return NO;
	return [super isEqual:camera];
}

/************************************/ #pragma mark Inspectors /************************************/
- (double)nearPlaneDistance {return mNearPlane;}
- (double)farPlaneDistance {return mFarPlane;}
- (double)nearToFarRatio {return mNearPlane/mFarPlane;}
- (double)fovY {return mFOVY;}
- (double)aspectRatio {return O3Camera_aspectRatio(self);}

- (O3Mat4x4d)viewMatrix {
	O3Camera_postProjectiveSpace(self);
	return mSpace.MatrixFromRoot();
}

- (O3Mat4x4d)projectionMatrix {
	return O3Camera_postProjectiveSpace(self)->MatrixFromSuper();
}

- (O3Mat4x4d)viewProjectionMatrix {
	return O3Camera_postProjectiveSpace(self)->MatrixFromRoot();
}

- (O3Space3*)postProjectionSpace {
	return O3Camera_postProjectiveSpace(self);
}

/************************************/ #pragma mark Mutators /************************************/
- (void)setAspectRatio:(double)newAR {mAspectRatio = newAR; mPostProjectionSpaceNeedsUpdate = YES;}	///<@note This change will not take effect until -(void)set is called (usually in the next frame). This behavior is usually desired but can cause confusion since the accessors will return the new value.
- (void)setNearPlaneDistance:(double)newDist {mNearPlane = newDist; mPostProjectionSpaceNeedsUpdate = YES;}	///<@note This change will not take effect until -(void)set is called (usually in the next frame). This behavior is usually desired but can cause confusion since the accessors will return the new value.
- (void)setFarPlaneDistance:(double)newDist {mFarPlane = newDist; mPostProjectionSpaceNeedsUpdate = YES;}	///<@note This change will not take effect until -(void)set is called (usually in the next frame). This behavior is usually desired but can cause confusion since the accessors will return the new value.
- (void)setFovY:(double)newFOVY {mFOVY = newFOVY; mPostProjectionSpaceNeedsUpdate = YES;}	///<@note This change will not take effect until -(void)set is called (usually in the next frame). This behavior is usually desired but can cause confusion since the accessors will return the new value.
- (float)flySpeed {return mFlySpeed;}
- (void)setFlySpeed:(float)fs {mFlySpeed = fs;}
- (float)rotRate {return mRotRate;}
- (void)setRotRate:(float)rr {mRotRate = rr;}
- (float)barrelRate {return mBarrelRate;}
- (void)setBarrelRate:(float)rr {mBarrelRate = rr;}

/************************************/ #pragma mark Use /************************************/
- (void)setViewMatrix {
	glMultMatrixd(mSpace.MatrixFromSuper());
}

- (void)setProjectionMatrix {
	glMatrixMode(GL_PROJECTION);
	glLoadMatrixd(O3Camera_postProjectiveSpace(self)->MatrixFromSuper());
	glMatrixMode(GL_MODELVIEW);
}

- (void)tickWithContext:(O3RenderContext*)context {
	double raw_t = context->elapsedTime;
	double t = raw_t * mFlySpeed;
	NSDictionary* d = [context->view viewState];
	if ([d objectForKey:@"flyingFast"]) t *= 10;
	if ([d objectForKey:@"flyingForward"])  {[self translateInObjectSpaceBy:O3Vec3d(0,0,t)];}
	if ([d objectForKey:@"flyingBackward"]) {[self translateInObjectSpaceBy:O3Vec3d(0,0,-t)]; }
	if ([d objectForKey:@"flyingLeft"])     {[self translateInObjectSpaceBy:O3Vec3d(t,0,0)];}
	if ([d objectForKey:@"flyingRight"])    {[self translateInObjectSpaceBy:O3Vec3d(-t,0,0)]; }
	if ([d objectForKey:@"flyingUp"])       {[self translateInObjectSpaceBy:O3Vec3d(0,-t,0)]; }
	if ([d objectForKey:@"flyingDown"])     {[self translateInObjectSpaceBy:O3Vec3d(0,t,0)];}
	if ([d objectForKey:@"barrelingLeft"])  {[self rotateOverOSAxis:O3Vec3d(0,0,-1) angle:-mBarrelRate*raw_t]; }
	if ([d objectForKey:@"barrelingRight"]) {[self rotateOverOSAxis:O3Vec3d(0,0,-1) angle:mBarrelRate*raw_t];}
}

- (void)rotateForMouseMoved:(O3Vec2d)amount {
	[self rotateOverOSAxis:O3Vec3d(0,1,0) angle:-mRotRate*amount[0]];
	[self rotateOverOSAxis:O3Vec3d(1,0,0) angle:-mRotRate*amount[1]];
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