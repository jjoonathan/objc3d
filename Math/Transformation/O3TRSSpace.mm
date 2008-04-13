/**
 *  @file O3Space.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 2/5/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3TRSSpace.h"
#import "O3KeyedArchiver.h"
#import <iostream>
using namespace std;
using namespace ObjC3D::Math;

@implementation O3TRSSpace
O3DefaultO3InitializeImplementation

+ (void)o3init {
}

/************************************/ #pragma mark Initialization /************************************/
- (O3Space*)init {
	O3SuperInitOrDie();
	mIsTRSSpace = YES;
	O3Asrt(mScale[0]);
	return self;
}

- (id)initWithCoder:(NSCoder*)coder {
	O3SuperInitOrDie();
	mTranslation.SetValue([coder decodeObjectForKey:@"translation"]);
	O3Vec3f eulerRot; eulerRot.SetValue([coder decodeObjectForKey:@"rotation"]);
	mRotation.Set(eulerRot[0], eulerRot[1], eulerRot[2]);
	mScale.SetValue([coder decodeObjectForKey:@"scale"]);
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
	angle roll, pitch, yaw; mRotation.GetEulerAngles(&roll, &pitch, &yaw);
	[coder encodeVec3d:mTranslation forKey:@"translation"];
	[coder encodeVec3f:O3Vec3f(roll,pitch,yaw) forKey:@"rotation"];
	[coder encodeVec3f:mScale forKey:@"scale"];
}

/************************************/ #pragma mark Movement /************************************/
- (void)moveTo:(O3Vec3d)amount inPOVOf:(id<O3Spatial>)pov {
	if (pov==mSuperspace) {
		mTranslation.Set(amount);
		return;
	}
	[self setTransformation:O3Translation3(amount).GetMatrix() inSpace:[pov space]];
}

- (void)rotateBy:(angle)theta over:(O3Vec3d)axis inPOVOf:(id<O3Spatial>)pov {
	if (pov==mSuperspace) {
		mRotation.Set(theta, axis);
		return;
	}
	if (pov==self) {
		mRotation+=O3Rotation3(theta, axis);
		return;
	}
	[self setTransformation:O3Rotation3(theta,axis).GetMatrix() inSpace:[pov space]];
}

- (void)resize:(O3Vec3d)amount inPOVOf:(id<O3Spatial>)pov {
	if (pov==self) {
		mScale*=amount;
		return;
	}
	[self setTransformation:O3Scale3(amount).GetMatrix() inSpace:[pov space]];
}




/************************************/ #pragma mark Component Access /************************************/
- (void)clear {
	mTranslation.Set(0);
	mRotation.Set();
	mScale.Set(1.);
}

- (O3Vec3d)rotation {
	angle roll, pitch, yaw;
	mRotation.GetEulerAngles(&roll, &pitch, &yaw);
	return O3Vec3d(roll, pitch, yaw);
}

- (void)setRotation:(O3Vec3d)newrot {
	mRotation.Set(newrot[0], newrot[1], newrot[2]);
}

- (O3Vec3d)translation {
	return mTranslation;
}

- (void)setTranslation:(O3Vec3d)newTrans {
	mTranslation.Set(newTrans);
}

- (O3Vec3f)scale {
	return mScale;
}

- (void)setScale:(O3Vec3f)ns {
	mScale.Set(ns);
}

- (O3Rotation3)quatRotation {
	return mRotation;
}

- (void)setQuatRotation:(O3Rotation3)rot {
	mRotation.Set(rot);
}

- (void)setMatrixToSuper:(O3Mat4x4d)mat {
	mTranslation.SetMat(mat);
	mRotation.SetMat(mat);
	mScale.SetMat(mat);
}




/************************************/ #pragma mark Use /************************************/
O3Mat4x4d O3TRSSpaceMatToSuper(O3TRSSpace* self) {
	//S*R*T
	O3Mat4x4d ret;
	ret.SetUpperLeft(self->mRotation.GetMatrix());
	ret(3,0) = self->mTranslation[0];
	ret(3,1) = self->mTranslation[1];
	ret(3,2) = self->mTranslation[2];
	double s0 = self->mScale[0];
	double s1 = self->mScale[1];
	double s2 = self->mScale[2];
	ret(0,0)*=s0; ret(0,1)*=s0; ret(0,2)*=s0;
	ret(1,0)*=s1; ret(1,1)*=s1; ret(1,2)*=s1;
	ret(2,0)*=s2; ret(2,1)*=s2; ret(2,2)*=s2;
	return ret;
}

O3Mat4x4d O3TRSSpaceMatFromSuper(O3TRSSpace* self) {
	//(S*R*T)^-1 = T^-1 * R^-1 * S^-1
	O3Mat4x4d ret;
	ret.SetUpperLeft((-self->mRotation).GetMatrix());
	double s0 = 1./(self->mScale[0]);
	double s1 = 1./(self->mScale[1]);
	double s2 = 1./(self->mScale[2]);
	ret(0,0)*=s0; ret(0,1)*=s1; ret(0,2)*=s2;
	ret(1,0)*=s0; ret(1,1)*=s1; ret(1,2)*=s2;
	ret(2,0)*=s0; ret(2,1)*=s1; ret(2,2)*=s2;
	double tx = -self->mTranslation[0];
	double ty = -self->mTranslation[1];
	double tz = -self->mTranslation[2];
	ret(3,0) = ret(0,0)*tx + ret(1,0)*ty + ret(2,0)*tz;
	ret(3,1) = ret(0,1)*tx + ret(1,1)*ty + ret(2,1)*tz;
	ret(3,2) = ret(0,2)*tx + ret(1,2)*ty + ret(2,2)*tz;
	return ret;
}

- (O3Mat4x4d)matrixFromSuper {
	return O3TRSSpaceMatFromSuper(self);
}

- (O3Mat4x4d)matrixToSuper {
	return O3TRSSpaceMatToSuper(self);
}

- (void)pushSpace:(O3RenderContext*)ctx {
	glPushMatrix();
	glMultMatrixd(O3TRSSpaceMatToSuper(self));
}

- (void)popSpace:(O3RenderContext*)ctx {
	glPopMatrix();
}



/************************************/ #pragma mark Debug /************************************/
- (void)drawOrthoBasis:(O3RenderContext*)ctx {
	glPushAttrib(GL_CURRENT_BIT | GL_ENABLE_BIT);
	glDisable(GL_DEPTH_TEST);
	glDisable(GL_LIGHTING);
	glDisable(GL_FRAGMENT_PROGRAM_ARB);
	glDisable(GL_VERTEX_PROGRAM_ARB);
	glEnable(GL_BLEND);
	[self push:ctx];
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
	[self pop:ctx];
	glPopAttrib();
}

inline void O3PointToSuper(O3Vec4d& p, O3TRSSpace* self) {
	if (!(self->mIsTRSSpace)) {
		O3Mat4x4d tm = [self matrixFromSuper];
		p = p*tm;
		return;
	}
	p[0] *= self->mScale[0];
	p[1] *= self->mScale[1];
	p[2] *= self->mScale[2];
	p = self->mRotation.RotatePoint(p);
	O3Vec3d tt = (self->mTranslation)*(p[3]);
	p = p+tt;
}

inline void O3PointFromSuper(O3Vec4d& p, O3TRSSpace* self) {
	if (!(self->mIsTRSSpace)) {
		O3Mat4x4d tm = [self matrixFromSuper];
		p = p*tm;
		return;
	}
	if (p[3]==1.) p -= self->mTranslation;
	else if (p[3]==0.) ; //No w means identity translation, we treat it as a directional vector
	else {
		p -= self->mTranslation / p[3];
	}
	p = (-self->mRotation).RotatePoint(p);
	p[0] /= self->mScale[0];
	p[1] /= self->mScale[1];
	p[2] /= self->mScale[2];
}

///@note Pass a 0 in the w component to have p treated like a directon vector
O3EXTERN_C O3Vec4d O3PointFromSpaceToSpace(const O3Vec4d& p, O3Space* from, O3Space* to) {
	if (from==to) return p;
	O3Vec4d newpt = p;
	
	//Transform into root
	O3Space* currentSpace = from;
	while (currentSpace) {
		O3PointToSuper(newpt, currentSpace);
		currentSpace = currentSpace->mSuperspace;
		if (currentSpace==to) return newpt;
	}
	
	//Build a list of spaces to transform into from root
	std::vector<O3Space*> to_stack;
	O3Space* toSpace = to;
	while (toSpace) {
		to_stack.push_back(toSpace);
		toSpace = toSpace->mSuperspace;
	}
	
	//And apply it ()
	std::vector<O3Space*>::reverse_iterator it=to_stack.rbegin(), e=to_stack.rend();
	for (; it!=e; it++) {
		currentSpace = *it;
		O3PointFromSuper(newpt, currentSpace);
	}
	
	return newpt;
}


/************************************/ #pragma mark Desc /************************************/
- (NSString*)description {
	double roll, pitch, yaw; mRotation.GetEulerAngles(&roll, &pitch, &yaw);
	return [NSString stringWithFormat:@"<O3TRSSpace: translation=%f,%f,%f roll:%f pitch:%f yaw:%f scale:%f,%f,%f>",
		mTranslation[0], mTranslation[1], mTranslation[2],
		roll, pitch, yaw,
		mScale[0], mScale[1], mScale[2]];
}



@end

