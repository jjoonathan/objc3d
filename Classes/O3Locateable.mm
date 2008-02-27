/**
 *  @file O3Locateable.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 2/5/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3Locateable.h"
#import <iostream>
using namespace std;
using namespace ObjC3D::Math;

@implementation O3Locateable
O3DefaultO3InitializeImplementation

inline void O3Locateable_UpdateSpaceIfNecessary(O3Locateable* self) {
	if (!self->mSpaceNeedsUpdate) return;
	self->mSpace.Set(self->mTranslation, self->mRotation, self->mScale);
	self->mSpaceNeedsUpdate = NO;
}

void O3LocateableBeginRender(O3Locateable* self, O3RenderContext* ctx) {
	O3Locateable_UpdateSpaceIfNecessary(self);
	O3Space3* cspace = [ctx->camera space];
	O3Mat4x4d mat = self->mSpace.MatrixToSpace(cspace);
	glLoadMatrixd(mat.Data());
}

/************************************/ #pragma mark Init /************************************/
- (id)init {
	O3SuperInitOrDie();
	mScale.Set(1., 1., 1.);
	return self;	
}

- (id)initWithLocation:(O3Translation3)trans rotation:(O3Rotation3)rot scale:(O3Scale3)scale {
	O3SuperInitOrDie();
	mSpace.Set(trans, rot, scale);
	mRotation.Set(rot);
	mTranslation.Set(trans);
	mScale.Set(scale);
	mSpaceNeedsUpdate = YES;
	return self;
}

- (O3Locateable*)initWithCoder:(NSCoder*)coder {
	O3SuperInitOrDie();
	id rot = [coder decodeObjectForKey:@"rotation"];
	id scale = [coder decodeObjectForKey:@"scale"];
	id trans = [coder decodeObjectForKey:@"translation"];
	if (scale) mScale.SetValue(scale); else mScale.Set(1., 1., 1.);
	if (trans) mTranslation.SetValue(trans);
	if (rot) {
		O3Vec3d rvec(rot);
		mRotation.Set(rvec[0], rvec[1], rvec[2]);
	}
	mSpaceNeedsUpdate = YES;
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
	angle roll, pitch, yaw;
	mRotation.GetEulerAngles(&roll, &pitch, &yaw);
	if (O3Equals(roll,0) && O3Equals(pitch,0) && O3Equals(yaw,0))
		[coder encodeObject:O3Vec3d(roll,pitch,yaw).Value() forKey:@"rotation"];
	if (mTranslation[0]||mTranslation[1]||mTranslation[2])
		[coder encodeObject:mTranslation.Value() forKey:@"translation"];
	if (O3Abs(mScale[0]-1.)+O3Abs(mScale[1]-1.)+O3Abs(mScale[2]-1.) > 1e-5)
		[coder encodeObject:mScale.Value() forKey:@"scale"];
}

- (BOOL)isEqual:(O3Locateable*)other {
	if (mRotation!=([other rotation])) return NO;
	if (!mTranslation.equals([other translation])) return NO;
	if (!mScale.equals([other scale])) return NO;
	return YES;
}

/************************************/ #pragma mark Accessors /************************************/
- (void)rotateBy:(O3Rotation3)relativeRotation {
	mRotation += relativeRotation;	
	mSpaceNeedsUpdate = YES;
	O3Locateable_UpdateSpaceIfNecessary(self);
}

- (void)translateBy:(O3Vec3d)trans {
	mTranslation += trans;	
	mSpaceNeedsUpdate = YES;
	O3Locateable_UpdateSpaceIfNecessary(self);
}

- (void)translateInObjectSpaceBy:(O3Vec3d)trans {
	O3Locateable_UpdateSpaceIfNecessary(self);
	const O3Mat4x4d& themat = mSpace.MatrixToSuper();
	O3Vec3d corrtrans = themat*O3Vec4d(trans[0],trans[1],trans[2],0);
	mTranslation += corrtrans;
	mSpaceNeedsUpdate = YES;
}

- (void)rotateOverAxis:(O3Vec3d)axis angle:(angle)theta {
	O3Locateable_UpdateSpaceIfNecessary(self);
	mRotation += O3Rotation3(theta, axis);
	mSpaceNeedsUpdate = YES;	
}

- (void)rotateOverOSAxis:(O3Vec3d)axis angle:(angle)theta {
	O3Locateable_UpdateSpaceIfNecessary(self);
	const O3Mat4x4d& themat = mSpace.MatrixToSuper();
	O3Vec3d corraxis = themat*O3Vec4d(axis[0],axis[1],axis[2],0);
	mRotation += O3Rotation3(theta, corraxis);
	mSpaceNeedsUpdate = YES;	
}

- (void)scaleBy:(O3Vec3d)scale {
	mScale += scale;	
	mSpaceNeedsUpdate = YES;
	O3Locateable_UpdateSpaceIfNecessary(self);
}

- (O3Vec3d)eulerRotation {
	double r,p,y;
	mRotation.GetEulerAngles(&r, &p, &y);
	return O3Vec3d(r,p,y);
}

- (void)setEulerRotation:(O3Vec3d)erot {
	[self setRotation:O3Rotation3(erot[0], erot[1], erot[2])];
}


///Returns the receiver's space (object space)
- (O3Space3*)space {		
	O3Locateable_UpdateSpaceIfNecessary(self);
	return &mSpace;
}

- (O3Space3*)superspace {	///<Returns the receiver's superspace (space above object space)
	//O3Locateable_UpdateSpaceIfNecessary(self);
	return mSpace.Superspace();
}

- (O3Rotation3)rotation {
	return mRotation;
}

- (O3Vec3d)translation {
	return mTranslation;
}

- (O3Vec3d)scale {
	return mScale;
}

- (void)setSuperspace:(O3Space3*)space {
	mSpace.SetSuperspace(space);
}

- (void)setSuperspaceToThatOfLocateable:(O3Locateable*)locateable {
	mSpace.SetSuperspace([locateable space]);
}

- (void)setRotation:(O3Rotation3)newRot {
	mRotation.Set(newRot);
	mSpaceNeedsUpdate = YES;
	O3Locateable_UpdateSpaceIfNecessary(self);
}

- (void)setTranslation:(O3Vec3d)newTrans {
	mTranslation.SetArray(newTrans);
	mSpaceNeedsUpdate = YES;
	O3Locateable_UpdateSpaceIfNecessary(self);
}

- (void)setScale:(O3Vec3d)newScale {
	mScale.SetArray(newScale);
	mSpaceNeedsUpdate = YES;
	O3Locateable_UpdateSpaceIfNecessary(self);
}

- (O3Mat4x4d)matrixToSpace:(O3Space3*)targetspace {
	O3Locateable_UpdateSpaceIfNecessary(self);
	O3Mat4x4d themat = mSpace.MatrixToSpace(targetspace);
	return themat;
}

- (O3Mat4x4d)matrixToSpaceOfLocateable:(O3Locateable*)locateable {
	O3Locateable_UpdateSpaceIfNecessary(self);
	return mSpace.MatrixToSpace([locateable space]);
}

- (void)setMatrixToSpace:(O3Space3*)targetspace {
	O3Locateable_UpdateSpaceIfNecessary(self);
	O3Mat4x4d themat = mSpace.MatrixToSpace(targetspace);
	glLoadMatrixd(themat);
}

- (NSString*)description {
	real x = mTranslation.GetX();
	real y = mTranslation.GetY();
	real z = mTranslation.GetZ();
	double rotx, roty, rotz;
	mRotation.GetEulerAngles(&rotx, &roty, &rotz);
	return [NSString stringWithFormat:@"{O3Locateable: x:%.6f y:%.6f z:%.6f xrot:%.6f yrot:%.6f zrot:%.6f xscl:%.6f yscl:%.6f zscl:%.6f}", x, y, z, rotx, roty, rotz, mScale.GetX(), mScale.GetY(), mScale.GetZ()];
}

- (void)debugDrawIntoSpace:(const O3Space3*)intospace {
	glPushAttrib(GL_CURRENT_BIT | GL_ENABLE_BIT);
	glDisable(GL_DEPTH_TEST);
	glDisable(GL_LIGHTING);
	glDisable(GL_FRAGMENT_PROGRAM_ARB);
	glDisable(GL_VERTEX_PROGRAM_ARB);
	glEnable(GL_BLEND);
	glPushMatrix();
	glLoadMatrixd(mSpace.MatrixToSpace(intospace));
	
	glBegin(GL_LINES);
		glColor4f(1,0,0,1);
		glVertex3f(0,0,0);
		glVertex3d(1,0,0);
		
		glColor4f(0,1,0,1);
		glVertex3f(0,0,0);
		glVertex3d(0,1,0);	
		
		glColor4f(0,0,1,1);
		glVertex3f(0,0,0);
		glVertex3d(0,0,1);		
	glEnd();
	
	glPopMatrix();
	glPopAttrib();
}


@end
