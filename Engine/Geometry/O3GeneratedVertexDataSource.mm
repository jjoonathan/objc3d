/**
 *  @file O3GeneratedVertexDataSource.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 1/21/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3GeneratedVertexDataSource.h"
#import "O3Camera.h"

@implementation O3GeneratedVertexDataSource

inline int O3TexCoordIndex(GLenum coord) {
	switch (coord) {
		case GL_S: return 0;
		case GL_T: return 1;
		case GL_R: return 2;
		case GL_Q: return 3;
		default: O3Assert(NO , @"O3TexCoordIndex was passes a bad coord");
	}
	return 0x9817A /*==622970*/;  //Pseudo random value should hopefully be caught :)
}

#define mPlane(x) self->mPlanes[O3TexCoordIndex((x))]
#define mPlaneEnabled(x) self->mPlanesEnabled[O3TexCoordIndex((x))]
#define mPlaneER(x) self->mEyePlanes[O3TexCoordIndex((x))]
#define mSPlane self->mPlanes[O3TexCoordIndex(GL_S)]
#define mTPlane self->mPlanes[O3TexCoordIndex(GL_T)]
#define mRPlane self->mPlanes[O3TexCoordIndex(GL_R)]
#define mQPlane self->mPlanes[O3TexCoordIndex(GL_Q)]
#define mSPlaneEnabled self->mPlanesEnabled[O3TexCoordIndex(GL_S)]
#define mTPlaneEnabled self->mPlanesEnabled[O3TexCoordIndex(GL_T)]
#define mRPlaneEnabled self->mPlanesEnabled[O3TexCoordIndex(GL_R)]
#define mQPlaneEnabled self->mPlanesEnabled[O3TexCoordIndex(GL_Q)]
#define mSPlaneER self->mEyePlanes[O3TexCoordIndex(GL_S)]
#define mTPlaneER self->mEyePlanes[O3TexCoordIndex(GL_T)]
#define mRPlaneER self->mEyePlanes[O3TexCoordIndex(GL_R)]
#define mQPlaneER self->mEyePlanes[O3TexCoordIndex(GL_Q)]

/************************************/ #pragma mark Setters /************************************/
inline void setPlanesFromMatrix(O3GeneratedVertexDataSource* self, O3Mat4x4d mat) {
	mSPlane = mat.GetRow(0);
	mTPlane = mat.GetRow(1);
	mRPlane = mat.GetRow(2);
	mQPlane = mat.GetRow(3);
}

inline void setType(O3GeneratedVertexDataSource* self, O3VertexDataType type) {
	[self willChangeValueForKey:@"type"];
	self->mType = type;
	[self didChangeValueForKey:@"type"];
}

inline void setMode(O3GeneratedVertexDataSource* self, GLenum mode) {
	[self willChangeValueForKey:@"mode"];
	self->mMode = mode;
	[self didChangeValueForKey:@"mode"];
}

inline void updateDynamicCameraIfNecessary(O3GeneratedVertexDataSource* self) {
	if (self->mCamera)
		setPlanesFromMatrix(self, [self->mCamera viewProjectionMatrix]);
}

///@note Does not implicitly enable \e plane
///@note If the receiver is currently bound, changes take effect immediately
- (void)setPlane:(Plane)plane forCoord:(GLenum)coord eyeRelative:(BOOL)relativeToCamera {
	mPlane(coord) = plane;
	mPlaneER(coord) = relativeToCamera;
	if (mBound) [self bind];
}

///@note Implicitly sets mode to GL_OBJECT_LINEAR
///@note If the receiver is currently bound, changes take effect immediately
- (void)setPlanesFromCamera:(O3Camera*)camera {
	if (!camera) return;
	setMode(self, GL_OBJECT_LINEAR);
	setPlanesFromMatrix(self, [mCamera viewProjectionMatrix]);
	mSPlaneER = mTPlaneER = mRPlaneER = mQPlaneER = NO;
	if (mBound) [self bind];
}

///@note Implicitly sets mode to GL_OBJECT_LINEAR
///@note If the receiver is currently bound, changes take effect immediately
- (void)setPlanesFromMatrix:(O3Mat4x4d)mat {
	setMode(self, GL_OBJECT_LINEAR);
	setPlanesFromMatrix(self, mat);
	mSPlaneER = mTPlaneER = mRPlaneER = mQPlaneER = NO;
	if (mBound) [self bind]; //Apply if necessary
}

///@note If the receiver is currently bound, changes take effect immediately
- (void)setCamera:(O3Camera*)camera {
	if (mCamera==camera) return;
	if (mCamera) [mCamera autorelease];
	mCamera = [camera retain];
	if (mBound) [self bind]; //Apply if necessary
}

///@note If the receiver is currently bound, changes take effect immediately
- (void)setType:(O3VertexDataType)type {
	setType(self, type);
	if (mBound) [self bind]; //Apply if necessary
}

///@note If the receiver is currently bound, changes take effect immediately
- (void)setMode:(GLenum)mode {
	setMode(self, mode);
	if (mBound) [self bind]; //Apply if necessary
}

- (void)setPlaneForCoord:(GLenum)coord enabled:(BOOL)enabled {
	if (mPlaneEnabled(coord)!=enabled) {
		mPlaneEnabled(coord) = enabled;
		if (mBound) [self bind]; //Apply if necessary
	}
}

/************************************/ #pragma mark Accessors /************************************/
- (Plane)planeForCoord:(GLenum)coord {
	updateDynamicCameraIfNecessary(self);
	return mPlane(coord);
}

- (O3Camera*)camera {
	return mCamera;
}

- (O3VertexDataType)type {
	return mType;
}

- (BOOL)planeEnabledForCoord:(GLenum)coord {
	return mPlaneEnabled(coord);
}

- (GLenum)mode {
	return mMode;
}

/************************************/ #pragma mark Use /************************************/
///@note This -(void)bind can be called multiple times in succession to update values. For instance, if you changed a plane when the generated data source was bound you could call bind again to apply the change.
- (void)bind {
	updateDynamicCameraIfNecessary(self);
	
	BOOL s = mSPlaneEnabled;
	BOOL t = mTPlaneEnabled;
	BOOL r = mRPlaneEnabled;
	BOOL q = mQPlaneEnabled;

	if (sizeof(mSPlane.GetA())==sizeof(GLfloat)) {
        if (s) glTexGenfv(GL_S, mSPlaneER?GL_EYE_PLANE:GL_OBJECT_PLANE, (const GLfloat*)mSPlane.Data());
        if (t) glTexGenfv(GL_T, mTPlaneER?GL_EYE_PLANE:GL_OBJECT_PLANE, (const GLfloat*)mTPlane.Data());
        if (r) glTexGenfv(GL_R, mRPlaneER?GL_EYE_PLANE:GL_OBJECT_PLANE, (const GLfloat*)mRPlane.Data());
        if (q) glTexGenfv(GL_Q, mQPlaneER?GL_EYE_PLANE:GL_OBJECT_PLANE, (const GLfloat*)mQPlane.Data());
    } else if (sizeof(mSPlane.GetA())==sizeof(double)) {
        if (s) glTexGendv(GL_S, mSPlaneER?GL_EYE_PLANE:GL_OBJECT_PLANE, (const GLdouble*)mSPlane.Data());
        if (t) glTexGendv(GL_T, mTPlaneER?GL_EYE_PLANE:GL_OBJECT_PLANE, (const GLdouble*)mTPlane.Data());
        if (r) glTexGendv(GL_R, mRPlaneER?GL_EYE_PLANE:GL_OBJECT_PLANE, (const GLdouble*)mRPlane.Data());
        if (q) glTexGendv(GL_Q, mQPlaneER?GL_EYE_PLANE:GL_OBJECT_PLANE, (const GLdouble*)mQPlane.Data());
    } else O3AssertFalse();
	
    if (s) {glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, mMode); glEnable(GL_TEXTURE_GEN_S);}
    if (t) {glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, mMode); glEnable(GL_TEXTURE_GEN_T);}
    if (r) {glTexGeni(GL_R, GL_TEXTURE_GEN_MODE, mMode); glEnable(GL_TEXTURE_GEN_R);}
    if (q) {glTexGeni(GL_Q, GL_TEXTURE_GEN_MODE, mMode); glEnable(GL_TEXTURE_GEN_Q);}
	
	mBound = YES;
}

- (void)unbind {
	if (!mBound) return;
	glDisable(GL_TEXTURE_GEN_S);
	glDisable(GL_TEXTURE_GEN_T);
	glDisable(GL_TEXTURE_GEN_R);
	glDisable(GL_TEXTURE_GEN_Q);
}

/************************************/ #pragma mark Initialization & Destruction /************************************/
/**
 * Defaults:
 * mode is GL_OBJECT_LINEAR
 * planes constructed from an identity 4x4 matrix
 * all planes enabled
 * type is O3TexCoordDataType
*/
inline void O3GeneratedVertexDataSource_init(O3GeneratedVertexDataSource* self) {
	self->mMode = GL_OBJECT_LINEAR;
	mSPlane.Set(1,0,0,0);
	mTPlane.Set(0,1,0,0);
	mRPlane.Set(0,0,1,0);
	mQPlane.Set(0,0,0,1);
	mSPlaneEnabled = YES;
	mTPlaneEnabled = YES;
	mRPlaneEnabled = YES;
	mQPlaneEnabled = YES;
	self->mType = O3TexCoordDataType;
}

- (id)init {
	O3SuperInitOrDie();
	O3GeneratedVertexDataSource_init(self);
	return self;
}

- (id)initWithType:(O3VertexDataType)type camera:(O3Camera*)camera {
	O3SuperInitOrDie();
	O3GeneratedVertexDataSource_init(self);
	mType = type;
	mCamera = [camera retain];
	return self;
}

- (id)initWithType:(O3VertexDataType)type matrix:(O3Mat4x4d)mat {
	O3SuperInitOrDie();
	O3GeneratedVertexDataSource_init(self);
	mType = type;
	setPlanesFromMatrix(self, mat);
	return self;
}

- (id)initWithType:(O3VertexDataType)type mode:(GLenum)mode sPlane:(const Plane*)s tPlane:(const Plane*)t rPlane:(const Plane*)r qPlane:(const Plane*)q {
	O3SuperInitOrDie();
	O3GeneratedVertexDataSource_init(self);
	mType = type;
	mMode = mode;
	mSPlane = *s;
	mTPlane = *t;
	mRPlane = *r;
	mQPlane = *q;
	return self;
}

@end
