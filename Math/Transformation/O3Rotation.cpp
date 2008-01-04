/*
 *  O3Rotation.cpp
 *  ObjC3D
 *
 *  Created by Jonathan deWerd on 10/20/06.
 *  Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 *
 */

#include "O3Rotation.h"

using namespace ObjC3D::Math;

/*******************************************************************/ #pragma mark Concatenations /*******************************************************************/
O3Rotation3& O3Rotation3::Rotate(const O3Rotation3& other) {
	MyQuat *= other.GetQuaternion();
	return *this;
}

O3Rotation3& O3Rotation3::Rotate(angle theta, O3Vec3d axis) {
	MyQuat *= O3Quaternion(theta, axis);
	return *this;
}

O3Rotation3& O3Rotation3::Rotate(const O3Quaternion& quat) {
	MyQuat *= quat;
	return *this;
}

O3Rotation3& O3Rotation3::Rotate(angle roll, angle pitch, angle yaw){
	MyQuat *= O3Quaternion(roll, pitch, yaw);
	return *this;
}

/*******************************************************************/ #pragma mark Operators /*******************************************************************/
O3Rotation3& O3Rotation3::Invert() {
	MyQuat.Conjugate();
	return *this;
}

O3Rotation3 O3Rotation3::operator+(const O3Rotation3& other) const {
	return O3Rotation3(MyQuat*other.GetQuaternion());
}

O3Rotation3& O3Rotation3::operator+=(const O3Rotation3& other) {
	MyQuat *= other.GetQuaternion();
	return *this;
}

O3Rotation3 O3Rotation3::operator-(const O3Rotation3& other) const {
	return O3Rotation3(MyQuat/other.GetQuaternion());	
}

O3Rotation3& O3Rotation3::operator-=(const O3Rotation3& other) {
	MyQuat /= other.GetQuaternion();
	return *this;
}

O3Rotation3 O3Rotation3::operator-() const {
	return O3Rotation3(MyQuat.GetInverted());
}

/*******************************************************************/ #pragma mark Inspectors /*******************************************************************/
O3Rotation3 O3Rotation3::GetInverse() {
	return O3Rotation3(MyQuat.GetConjugate());
}

O3Mat3x3d O3Rotation3::GetMatrix() const {
	return MyQuat.GetMatrix(true);
}

O3Quaternion O3Rotation3::GetQuaternion() const {
	return MyQuat;
}

void O3Rotation3::GetEulerAngles(angle* roll, angle* pitch, angle*yaw) const {
	MyQuat.GetEuler(roll, pitch, yaw);
}