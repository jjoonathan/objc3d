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

inline void O3Locateable_UpdateSpaceIfNecessary(O3Locateable* self) {
	if (!self->mSpaceNeedsUpdate) return;
	self->mSpace.Set(self->mTranslation, self->mRotation, self->mScale);
	self->mSpaceNeedsUpdate = NO;
}

/************************************/ #pragma mark Init /************************************/
- (id)initWithLocation:(O3Translation3)trans rotation:(O3Rotation3)rot scale:(O3Scale3)scale {
	O3SuperInitOrDie();
	mSpace.Set(trans, rot, scale);
	mRotation.Set(rot);
	mTranslation.Set(trans);
	mScale.Set(scale);
	return self;
}

- (O3Locateable*)initWithCoder:(NSCoder*)coder {
	O3SuperInitOrDie();
	O3Vec3d rot([coder decodeObjectForKey:@"rotation"]);
	mRotation.Set(rot.X(), rot.Y(), rot.Z());
 	mScale.SetValue([coder decodeObjectForKey:@"scale"]);
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
	angle roll, pitch, yaw;
	mRotation.GetEulerAngles(&roll, &pitch, &yaw);
	[coder encodeObject:O3Vec3d(roll,pitch,yaw).Value() forKey:@"rotation"];
	[coder encodeObject:mTranslation.Value() forKey:@"translation"];
	[coder encodeObject:mScale.Value() forKey:@"scale"];
}

- (BOOL)isEqual:(O3Locateable*)other {
	if (mRotation!=[other rotation]) return NO;
	if (mTranslation!=[other translation]) return NO;
	if (mScale!=[other scale]) return NO;
	return YES;
}

/************************************/ #pragma mark Accessors /************************************/
- (void)rotateBy:(O3Rotation3)relativeRotation {
	mRotation += relativeRotation;	
	mSpaceNeedsUpdate = YES;
	O3Locateable_UpdateSpaceIfNecessary(self);
}

- (void)translateBy:(O3Translation3)trans {
	mTranslation += trans;	
	mSpaceNeedsUpdate = YES;
	O3Locateable_UpdateSpaceIfNecessary(self);
}

- (void)translateInObjectSpaceBy:(O3Translation3)trans {
	O3Locateable_UpdateSpaceIfNecessary(self);
	const O3Mat4x4d themat = mSpace.MatrixToSuper();
	O3Vec3d corrtrans = themat*O3Vec4d(trans);
	mTranslation += corrtrans;
	mSpaceNeedsUpdate = YES;
}

- (void)scaleBy:(O3Scale3)scale {
	mScale += scale;	
	mSpaceNeedsUpdate = YES;
	O3Locateable_UpdateSpaceIfNecessary(self);
}

///Returns the receiver's space (object space)
- (Space3*)space {		
	O3Locateable_UpdateSpaceIfNecessary(self);
	return &mSpace;
}

- (Space3*)superspace {	///<Returns the receiver's superspace (space above object space)
	//O3Locateable_UpdateSpaceIfNecessary(self);
	return mSpace.Superspace();
}

- (O3Rotation3)rotation {
	return mRotation;
}

- (O3Translation3)translation {
	return mTranslation;
}

- (O3Scale3)scale {
	return mScale;
}

- (void)setSuperspace:(Space3*)space {
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

- (void)setTranslation:(O3Translation3)newTrans {
	mTranslation.Set(newTrans);
	mSpaceNeedsUpdate = YES;
	O3Locateable_UpdateSpaceIfNecessary(self);
}

- (void)setScale:(O3Scale3)newScale {
	mScale.Set(newScale);
	mSpaceNeedsUpdate = YES;
	O3Locateable_UpdateSpaceIfNecessary(self);
}

- (O3Mat4x4d)matrixToSpace:(Space3*)targetspace {
	O3Locateable_UpdateSpaceIfNecessary(self);
	O3Mat4x4d themat = mSpace.MatrixToSpace(targetspace);
	return themat;
}

- (O3Mat4x4d)matrixToSpaceOfLocateable:(O3Locateable*)locateable {
	O3Locateable_UpdateSpaceIfNecessary(self);
	return mSpace.MatrixToSpace([locateable space]);
}

- (void)setMatrixToSpace:(Space3*)targetspace {
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

- (void)debugDrawIntoSpace:(const Space3*)intospace {
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
