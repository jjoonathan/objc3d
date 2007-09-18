/*
 *  O3Transform.cpp
 *  ObjC3D
 *
 *  Created by Jonathan deWerd on 10/20/06.
 *  Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 *
 */

#include "O3Transformation.h"
#include <iostream>

using namespace std;

/*******************************************************************/ #pragma mark Constructors /*******************************************************************/
O3Transformation3& O3Transformation3::Set() {
	MyTransform.Identitize();
	MyInverseTransform.Identitize();
	return *this;
}

O3Transformation3& O3Transformation3::Set(const O3Scale3& scale) {
	MyTransform.Identitize();
	MyInverseTransform.Identitize();
	real x = scale.GetX();
	real y = scale.GetY();
	real z = scale.GetZ();
	MyTransform[0][0] = x;
	MyTransform[1][1] = y;
	MyTransform[2][2] = z;
	MyInverseTransform[0][0] = -x;
	MyInverseTransform[1][1] = -y;
	MyInverseTransform[2][2] = -z;
	return *this;
}

O3Transformation3& O3Transformation3::Set(const O3Rotation3& rot) {
	O3Mat3x3r rotmat = rot.GetMatrix();
	int i,j;
	for (i=0;i<3;i++)
		for (j=0;j<3;j++) {
			real val = rotmat(i,j);
			MyTransform(i,j) = val;
			MyInverseTransform(j,i) = val;
		}
	for (i=0;i<3;i++) {
		MyTransform(i,j) = 0;
		MyInverseTransform(j,i) = 0;
	}
	MyTransform(3,3) = 1;
	MyInverseTransform(3,3) = 1;	
	return *this;
}

O3Transformation3& O3Transformation3::Set(const O3Translation3& trans) {
	MyTransform.Identitize();
	MyInverseTransform.Identitize();
	real x = trans.GetX();
	real y = trans.GetY();
	real z = trans.GetZ();
	MyTransform[0][3] = x;
	MyTransform[1][3] = y;
	MyTransform[2][3] = z;
	MyInverseTransform[0][3] = -x;
	MyInverseTransform[1][3] = -y;
	MyInverseTransform[2][3] = -z;
	return *this;
}

O3Transformation3& O3Transformation3::Set(const O3Transformation3& transf) {
	MyTransform = transf.MyTransform;
	MyInverseTransform = transf.MyInverseTransform;
	return *this;
}

O3Transformation3& O3Transformation3::Set(const O3Mat3x3r ob, O3Translation3 tr) {
	MyTransform.Set(ob);
	MyTransform[0][2] = tr.GetX();
	MyTransform[1][2] = tr.GetX();
	MyTransform[2][2] = tr.GetX();
	MyInverseTransform = MyTransform.GetInverted();
	return *this;
}

O3Transformation3& O3Transformation3::Set(const O3Mat4x4d& trans) {
	MyTransform.Set(trans);
	MyInverseTransform.Set(trans.GetInverted());
	return *this;
}

O3Transformation3& O3Transformation3::Set(const O3Mat4x4d& trans, const O3Mat4x4d& invtrans) {
	MyTransform.Set(trans);
	MyInverseTransform.Set(invtrans);
	return *this;
}

/*******************************************************************/ #pragma mark Methods /*******************************************************************/
O3Transformation3& O3Transformation3::Invert() {
	O3swap(MyTransform, MyInverseTransform);
	return *this;
}
 
O3Transformation3 O3Transformation3::GetInverted() const {
	return O3Transformation3(MyInverseTransform, MyTransform);
}

/*******************************************************************/ #pragma mark Concatenations /*******************************************************************/
O3Transformation3& O3Transformation3::O3Scale(real x, real y, real z) {
	return operator+=(O3Scale3(x,y,z));
}

O3Transformation3& O3Transformation3::O3Scale(const O3Scale3& scale) {
	return operator+=(scale);
}

O3Transformation3& O3Transformation3::Rotate(real x, real y, real z) {
	return operator+=(O3Rotation3(x,y,z));
}

O3Transformation3& O3Transformation3::Rotate(angle theta, O3Vec3r axis) {
	return operator+=(O3Rotation3(theta, axis));
}

O3Transformation3& O3Transformation3::Rotate(angle theta, real x, real y, real z) {
	return operator+=(O3Rotation3(theta, O3Vec3r(x,y,z)));
}

O3Transformation3& O3Transformation3::Rotate(const O3Rotation3& rot) {
	return operator+=(rot);
}

O3Transformation3& O3Transformation3::Translate(real x, real y, real z) {
	return operator+=(O3Translation3(x,y,z));
	return *this;
}

O3Transformation3& O3Transformation3::Translate(const O3Translation3& trans) {
	return operator+=(trans);
	return *this;
}

O3Transformation3& O3Transformation3::Transform(const O3Transformation3& trans) {
	return operator+=(trans);
	return *this;
}

/*******************************************************************/ #pragma mark Operators /*******************************************************************/
//O3Scale
///@todo Optimize me!!!
O3Transformation3  O3Transformation3::operator+(const O3Scale3& scale) const {
	return O3Transformation3(MyTransform+scale, MyInverseTransform * (-scale).GetMatrix());
}

O3Transformation3& O3Transformation3::operator+=(const O3Scale3& scale) {
	MyTransform += scale;
	MyInverseTransform =  (-scale).GetMatrix() * MyInverseTransform;
	return *this;
}

O3Transformation3  O3Transformation3::operator-(const O3Scale3& scale) const {
	return O3Transformation3(MyTransform-scale, MyInverseTransform+scale);	
}

O3Transformation3& O3Transformation3::operator-=(const O3Scale3& scale) {
	MyTransform -= scale;
	MyInverseTransform += scale;	
	return *this;
}

//Rotation
O3Transformation3  O3Transformation3::operator+(const O3Rotation3& rot) const {
	O3Mat3x3r mat = rot.GetMatrix();
	return O3Transformation3(mat*MyTransform, (mat.Transpose())*MyInverseTransform);
}

O3Transformation3& O3Transformation3::operator+=(const O3Rotation3& rot) {
	O3Mat3x3r mat = rot.GetMatrix();
	MyTransform = mat*MyTransform;
	mat.Transpose();
	MyInverseTransform = MyInverseTransform*mat;
	return *this;
}

O3Transformation3  O3Transformation3::operator-(const O3Rotation3& rot) const {
	O3Mat3x3r mat = rot.GetMatrix();
	O3Mat4x4d inv   = mat*MyInverseTransform;
	O3Mat4x4d trans = MyTransform*(mat.Transpose());
	return O3Transformation3(trans, inv);
}

O3Transformation3& O3Transformation3::operator-=(const O3Rotation3& rot) {
	O3Mat3x3r mat = rot.GetMatrix();
	MyInverseTransform = mat*MyInverseTransform;
	MyTransform.Transpose();
	MyTransform = MyTransform*mat;
	return *this;
}

//O3Translation
O3Transformation3  O3Transformation3::operator+(const O3Translation3& trans) const {
	return O3Transformation3(MyTransform+trans, MyInverseTransform-trans);
}

O3Transformation3& O3Transformation3::operator+=(const O3Translation3& trans) {
	MyTransform += trans;
	MyInverseTransform -= trans;
	return *this;
}

O3Transformation3  O3Transformation3::operator-(const O3Translation3& trans) const {
	return O3Transformation3(MyTransform-trans, MyInverseTransform+trans);	
}

O3Transformation3& O3Transformation3::operator-=(const O3Translation3& trans) {
	MyTransform -= trans;
	MyInverseTransform += trans;	
	return *this;
}

//Transformation
O3Transformation3  O3Transformation3::operator+(const O3Transformation3& trans) const {
	return O3Transformation3(trans.MyTransform*MyTransform, trans.MyInverseTransform*MyInverseTransform);	
}

O3Transformation3& O3Transformation3::operator+=(const O3Transformation3& trans) {
	MyTransform *= trans.MyTransform;
	MyInverseTransform *= trans.MyInverseTransform;
	return *this;
}

O3Transformation3  O3Transformation3::operator-(const O3Transformation3& trans) const {
	return O3Transformation3(trans.MyInverseTransform*MyTransform, trans.MyTransform*MyInverseTransform);	
}

O3Transformation3& O3Transformation3::operator-=(const O3Transformation3& trans) {
	MyTransform *= trans.MyInverseTransform;
	MyInverseTransform *= trans.MyTransform;
	return *this;
}

//Matricies
O3Transformation3  O3Transformation3::operator+ (const O3Mat4x4d& mat) const {
	return O3Transformation3(
		/*MyTransform:*/			mat*MyTransform,
		/*MyInverseTransform:*/		mat.GetInverted(true)*MyInverseTransform
	);
}

O3Transformation3& O3Transformation3::operator+=(const O3Mat4x4d& mat) {
	MyTransform = mat*MyTransform;
	MyInverseTransform = mat.GetInverted()*MyInverseTransform;
	return *this;
}

O3Transformation3  O3Transformation3::operator- (const O3Mat4x4d& mat) const {
	return O3Transformation3(
		/*MyTransform:*/			mat.GetInverted(true)*MyTransform,
		/*MyInverseTransform:*/		mat*MyInverseTransform
	);
}

O3Transformation3& O3Transformation3::operator-=(const O3Mat4x4d& mat) {
	MyTransform = mat.GetInverted(true)*MyTransform;
	MyInverseTransform = mat*MyInverseTransform;
	return *this;
}
 
/*******************************************************************/ #pragma mark Accessors /*******************************************************************/
const O3Mat4x4d& O3Transformation3::O3Mat() const {
	return MyTransform;
}

const O3Mat4x4d& O3Transformation3::InverseMatrix() const {
	return MyInverseTransform;
}

O3Mat4x4d O3Transformation3::GetMatrix() const {
	return MyTransform;
}

O3Mat4x4d O3Transformation3::GetInverseMatrix() const {
	return MyInverseTransform;
}

/*******************************************************************/ #pragma mark Interface /*******************************************************************/
std::string O3Transformation3::Description() const {
	return MyTransform.Description();
}