/**
 *  @file O3Camera.mm
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3Camera.h"
#import "O3GLView.h"
#import "O3TRSSpace.h"
#import "O3MatrixSpace.h"
#define mLocation (*(self->mpLocation))
#define mDirection (*(self->mpDirection))
#define mUp (*(self->mpUp))
using namespace ObjC3D::Math;


@implementation O3Camera
O3DefaultO3InitializeImplementation

inline void initP(O3Camera* self) {
	self->mPostProjectionSpace = [[O3MatrixSpace alloc] init];
	[self->mPostProjectionSpace setSuperspaceWithoutAdjusting:self->mObjectSpace];
	self->mAspectRatio = 1.;
	self->mNearPlane = .1;
	self->mFarPlane = 100.;
	self->mFOVY = 90.; //Zomg, degrees?!
	self->mPostProjectionSpaceNeedsUpdate = YES;
	self->mFlySpeed = 2./3.;
	self->mRotRate = .015;
	self->mBarrelRate = 2.;
}

inline double aspectRatio(O3Camera* self) {
	return self->mAspectRatio;
}

inline O3MatrixSpace* mPostProjectionSpaceP(O3Camera* self) {
	if (!self->mPostProjectionSpaceNeedsUpdate) return self->mPostProjectionSpace;
	O3Mat4x4d themat;
	themat.SetPerspective(self->mFOVY, self->mAspectRatio, self->mNearPlane, self->mFarPlane);
	[self->mPostProjectionSpace setMatrixFromSuper:themat];
	return self->mPostProjectionSpace;
}

/************************************/ #pragma mark Initialization /************************************/
- (void)dealloc {
	O3Destroy(mPostProjectionSpace);
	[super dealloc];
}

- (O3Camera*)init {
	O3SuperInitOrDie();
	initP(self);
	return self;
}

- (id)initWithCoder:(NSCoder*)coder {
	[super initWithCoder:coder];
	O3Assert([coder allowsKeyedCoding], @"Cannot create an O3GLView from a non-keyed coder");
	initP(self);
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
- (double)aspectRatio {return aspectRatio(self);}

- (O3Mat4x4d)viewMatrix {
	return [mObjectSpace matrixToSpace:nil];
}

- (O3Mat4x4d)projectionMatrix {
	return [mPostProjectionSpaceP(self) matrixToSuper];
}

- (O3Mat4x4d)viewProjectionMatrix {
	return [mPostProjectionSpaceP(self) matrixToSpace:nil];
}

- (O3Space*)postProjectionSpace {
	return mPostProjectionSpaceP(self);
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
- (void)setProjectionMatrix {
	glMatrixMode(GL_PROJECTION);
	O3Mat4x4d projMat = [mPostProjectionSpace matrixFromSuper];
	projMat.SetPerspective(self->mFOVY, self->mAspectRatio, self->mNearPlane, self->mFarPlane);
	glLoadMatrixd(projMat);
	glMatrixMode(GL_MODELVIEW);
}

- (void)setViewMatrix {
	glLoadMatrixd([mObjectSpace matrixFromSuper]);
}

- (void)tickWithContext:(O3RenderContext*)context {
	double raw_t = context->elapsedTime;
	double t = raw_t * mFlySpeed;
	NSDictionary* d = [context->view viewState];
	if ([d objectForKey:@"flyingFast"]) t *= 10;
	if ([d objectForKey:@"flyingForward"])  {[self moveTo:O3Vec3d(0,0,-t) inPOVOf:self];}
	if ([d objectForKey:@"flyingBackward"]) {[self moveTo:O3Vec3d(0,0,t) inPOVOf:self]; }
	if ([d objectForKey:@"flyingLeft"])     {[self moveTo:O3Vec3d(-t,0,0) inPOVOf:self];}
	if ([d objectForKey:@"flyingRight"])    {[self moveTo:O3Vec3d(t,0,0) inPOVOf:self]; }
	if ([d objectForKey:@"flyingUp"])       {[self moveTo:O3Vec3d(0,t,0) inPOVOf:self]; }
	if ([d objectForKey:@"flyingDown"])     {[self moveTo:O3Vec3d(0,-t,0) inPOVOf:self];}
	if ([d objectForKey:@"barrelingLeft"])  {[self rotateTo:-mBarrelRate*raw_t over:O3Vec3d(0,0,-1) inPOVOf:self];}
	if ([d objectForKey:@"barrelingRight"]) {[self rotateTo:mBarrelRate*raw_t  over:O3Vec3d(0,0,-1) inPOVOf:self];}
}

- (void)rotateForMouseMoved:(O3Vec2d)amount {
	[self rotateTo:-mRotRate*amount[0] over:O3Vec3d(0,1,0) inPOVOf:self];
	[self rotateTo:-mRotRate*amount[1] over:O3Vec3d(1,0,0) inPOVOf:self];
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