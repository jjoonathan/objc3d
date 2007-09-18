/*
 *  O3Space.cpp
 *  ObjC3D
 *
 *  Created by Jonathan deWerd on 2/1/07.
 *  Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 *
 */
///@todo fixme!

#include "O3TRSSpace.h"

namespace ObjC3D {
namespace Math {
		
/************************************/ #pragma mark Setters /************************************/
void TRSSpace3::Init() {
	mTRSPseudohash = 0;
}

TRSSpace3& TRSSpace3::Set() {
	Modified();
	mTranslation.Set();
	mRotation.Set();
	mScale.Set();
	return *this;
}

TRSSpace3& TRSSpace3::Set(const TRSSpace3& other) {
	Modified();
	mTranslation.Set(other.O3Translation());
	mRotation.Set(other.Rotation());
	mScale.Set(other.O3Scale());
	return *this;
}

TRSSpace3& TRSSpace3::Set(const O3Translation3& trans, const O3Rotation3& rot, const O3Scale3& scale) {
	Modified();
	mTranslation.Set(trans);
	mRotation.Set(rot);
	mScale.Set(scale);
	return *this;
}

/************************************/ #pragma mark Inspectors /************************************/
void TRSSpace3::UpdateSuperspaceTransform() const {
	if (mTRSPseudohash==mLastTRSPseudohash && mTRSPseudohash) return;
	O3Optimizable();
	mFromSuperspace.Set(mTranslation);
	mFromSuperspace += mRotation;
	mFromSuperspace += mScale;
	mLastTRSPseudohash = mTRSPseudohash;
}

const O3Mat4x4d& TRSSpace3::MatrixFromSuper() const {
	UpdateSuperspaceTransform();
	return mFromSuperspace.O3Mat();
}

const O3Mat4x4d& TRSSpace3::MatrixFromRoot() const {
	UpdateRootspaceTransform();
	return mFromRootspace.O3Mat();
}

O3Mat4x4d TRSSpace3::MatrixToSpace(const Space3& other) const {
	if (other.IsSame(mSuperspace))
		return mFromSuperspace.InverseMatrix();
	return other.MatrixFromRoot()*MatrixToRoot();
}

const O3Mat4x4d& TRSSpace3::MatrixToRoot() const {
	UpdateRootspaceTransform();
	return mFromRootspace.InverseMatrix();
}

const O3Mat4x4d& TRSSpace3::MatrixToSuper() const {
	UpdateSuperspaceTransform();
	return mFromSuperspace.InverseMatrix();
}

TRSSpace3& TRSSpace3::SetTranslation(const O3Translation3& trans) {
	mTranslation.Set(trans);
	return *this;
}

TRSSpace3& TRSSpace3::SetRotation(const O3Rotation3& rot) {
	mRotation.Set(rot);
	return *this;
}

TRSSpace3& TRSSpace3::SetScale(const O3Scale3& scale) {
	mScale.Set(scale);
	return *this;
}


/************************************/ #pragma mark Operators /************************************/
TRSSpace3& TRSSpace3::operator+=(const O3Scale3& scale) {
	Modified();
	mScale += scale;
	return *this;
}

TRSSpace3& TRSSpace3::operator-=(const O3Scale3& scale) {
	Modified();
	mScale -= scale;
	return *this;
}	

TRSSpace3& TRSSpace3::operator+=(const O3Rotation3& rot) {
	Modified();
	mRotation += rot;
	return *this;
}

TRSSpace3& TRSSpace3::operator-=(const O3Rotation3& rot) {
	Modified();
	mRotation -= rot;
	return *this;
}

TRSSpace3& TRSSpace3::operator+=(const O3Translation3& trans) {
	Modified();
	mTranslation += trans;
	return *this;
}

TRSSpace3& TRSSpace3::operator-=(const O3Translation3& trans) {
	Modified();
	mTranslation -= trans;
	return *this;
}

} // /Math
} // /ObjC3D