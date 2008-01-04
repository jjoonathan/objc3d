/*
 *  O3Space.cpp
 *  ObjC3D
 *
 *  Created by Jonathan deWerd on 2/1/07.
 *  Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 *
 */

#include "O3Space.h"
#include <iostream>
using namespace std;

namespace ObjC3D {
namespace Math {

/************************************/ #pragma mark Setters /************************************/
void Space3::DidChange() {
	if (!(mPseudohash%100)) {
		mFromRootspace.Validate();
		mFromSuperspace.Validate();
	}
}
		
/************************************/ #pragma mark Setters /************************************/
Space3& Space3::SetSuperspace(Space3* supers) {
	if (supers!=mSuperspace) mSuperPseudohash = 0;
	mSuperspace = supers;
	DidChange();
	return *this;	
}
	
Space3& Space3::Set() {
	Modified();
	mFromSuperspace.Set();
	DidChange();
	return *this;
}

Space3&	Space3::Set(const O3Mat4x4d& mat) {
	Modified();
	mFromSuperspace.Set(mat);
	DidChange();
	return *this;
}

Space3& Space3::Set(const O3Transformation3& trans) {
	Modified();
	mFromSuperspace.Set(trans);
	DidChange();
	return *this;
}

Space3& Space3::Set(const Space3& other) {
	Modified();
	mFromSuperspace.Set(other.mFromSuperspace);
	DidChange();
	return *this;
}

Space3& Space3::Set(const O3Translation3& trans, const O3Rotation3& rot, const O3Scale3& scale) {
	Modified();
	mFromSuperspace.Set(trans);
	mFromSuperspace+=rot;
	mFromSuperspace+=scale;
	DidChange();
	return *this;
}

/************************************/ #pragma mark Inspectors /************************************/
void Space3::UpdateRootspaceTransform() const { //I forsee looped spaces. mmm, fun.
	if (!mSuperspace) { //If we are root
		if (mSuperPseudohash!=mPseudohash && mSuperPseudohash) return;
		mFromRootspace = mFromSuperspace;
		mSuperPseudohash = mPseudohash;
		return;
	}
	mSuperspace->UpdateRootspaceTransform(); //GCC should optimize on higher O levels (2,3, and maybe 1?)
	if (mSuperPseudohash && mSuperPseudohash==mSuperspace->mPseudohash) return;
	const O3Mat4x4d& root_to_super = mSuperspace->MatrixFromRoot();
	const O3Mat4x4d& super_to_root = mSuperspace->MatrixToRoot();
	const O3Mat4x4d& super_to_self = mFromSuperspace.GetMatrix();
	const O3Mat4x4d& self_to_super = mFromSuperspace.GetInverseMatrix();
	mFromRootspace.Set(super_to_self*root_to_super, super_to_root*self_to_super);
	mSuperPseudohash = mSuperspace->mPseudohash;
	Modified();
}

const O3Mat4x4d& Space3::MatrixFromSuper() const {
	return mFromSuperspace.O3Mat();
}

const O3Mat4x4d& Space3::MatrixFromRoot() const {
	UpdateRootspaceTransform();
	return mFromRootspace.O3Mat();
}

O3Mat4x4d Space3::MatrixToSpace(const Space3* other) const {
	if (other->IsSame(mSuperspace))
		return mFromSuperspace.InverseMatrix();
	return other->MatrixFromRoot()*MatrixToRoot();
}

const O3Mat4x4d& Space3::MatrixToRoot() const {
	UpdateRootspaceTransform();
	return mFromRootspace.InverseMatrix();
}

const O3Mat4x4d& Space3::MatrixToSuper() const {
	return mFromSuperspace.InverseMatrix();
}

O3Vec3d Space3::VectorToSpace(const Space3* other, O3Vec3d oldvec) const {
	const O3Mat4x4d& mat = MatrixToSpace(other);
	return O3Vec3d(mat*O3Vec4d(oldvec));
}

O3Vec4d Space3::VectorToSpace(const Space3* other, O3Vec4d oldvec) const {
	const O3Mat4x4d& mat = MatrixToSpace(other);
	return mat*oldvec;	
}

O3Vec3d Space3::VectorToRoot(O3Vec3d oldvec) const {
	const O3Mat4x4d& mat = MatrixToRoot();
	O3Vec4d to_mult = O3Vec4d(oldvec.X(), oldvec.Y(), oldvec.Z(), 1.);
	return O3Vec3d(mat*to_mult);
}

O3Vec4d Space3::VectorToRoot(O3Vec4d oldvec) const {
	const O3Mat4x4d& mat = MatrixToRoot();
	return mat*oldvec;	
}

O3Vec3d Space3::VectorFromRoot(O3Vec3d oldvec) const {
	const O3Mat4x4d& mat = MatrixFromRoot();
	O3Vec4d to_mult = O3Vec4d(oldvec.X(), oldvec.Y(), oldvec.Z(), 1.);
	return O3Vec3d(mat*to_mult);
}

O3Vec4d Space3::VectorFromRoot(O3Vec4d oldvec) const {
	const O3Mat4x4d& mat = MatrixFromRoot();
	return mat*oldvec;	
}

/************************************/ #pragma mark Operators /************************************/
Space3& Space3::operator=(const Space3& other) {
	mFromSuperspace = other.mFromSuperspace;
	mPseudohash = mSuperPseudohash = 0;
	DidChange();
	return *this;
}

Space3& Space3::operator+=(const O3Scale3& scale) {
	Modified();
	mFromSuperspace += scale;
	DidChange();
	return *this;
}

Space3& Space3::operator-=(const O3Scale3& scale) {
	Modified();
	mFromSuperspace -= scale;
	DidChange();
	return *this;
}	

Space3& Space3::operator+=(const O3Rotation3& rot) {
	Modified();
	mFromSuperspace += rot;
	DidChange();
	return *this;
}

Space3& Space3::operator-=(const O3Rotation3& rot) {
	Modified();
	mFromSuperspace -= rot;
	DidChange();
	return *this;
}

Space3& Space3::operator+=(const O3Translation3& trans) {
	Modified();
	mFromSuperspace += trans;
	DidChange();
	return *this;
}

Space3& Space3::operator-=(const O3Translation3& trans) {
	Modified();
	mFromSuperspace -= trans;
	DidChange();
	return *this;
}

Space3& Space3::operator+=(const O3Transformation3& trans) {
	Modified();
	mFromSuperspace += trans;
	DidChange();
	return *this;
}

Space3& Space3::operator-=(const O3Transformation3& trans) {
	Modified();
	mFromSuperspace -= trans;
	DidChange();
	return *this;
}

Space3& Space3::operator+=(const O3Mat4x4d& mat) {
	Modified();
	mFromSuperspace += mat;
	DidChange();
	return *this;
}

Space3& Space3::operator-=(const O3Mat4x4d& mat) {
	Modified();
	mFromSuperspace -= mat;
	DidChange();
	return *this;
}


} // /Math
} // /ObjC3D