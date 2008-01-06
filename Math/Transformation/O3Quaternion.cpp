/*
 *  O3Quaternion.cpp
 *  ObjC3D
 *
 *  Created by Jonathan deWerd on 10/20/06.
 *  Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 *
 */
#include "O3Quaternion.h"
#include <cmath>
using namespace ObjC3D::Math;
using namespace std;

/*******************************************************************/ #pragma mark Constructors /*******************************************************************/
void O3Quaternion::Set(angle theta, O3Vec3d axis) {
	axis.Normalize();
	double half_theta = theta * .5;
	double sin_half_theta = sin(half_theta);
	W() = cos(half_theta);
	X() = axis.GetX() * sin_half_theta;
	Y() = axis.GetY() * sin_half_theta;
	Z() = axis.GetZ() * sin_half_theta;
}

void O3Quaternion::Set(const O3Mat3x3d& mat) {	
    double w = 0.5 * sqrt( max(0.0, 1.0 + mat(0,0) + mat(1,1) + mat(2,2) ) );
    double x = 0.5 * sqrt( max(0.0, 1.0 + mat(0,0) - mat(1,1) - mat(2,2) ) );
    double y = 0.5 * sqrt( max(0.0, 1.0 - mat(0,0) + mat(1,1) - mat(2,2) ) );
    double z = 0.5 * sqrt( max(0.0, 1.0 - mat(0,0) - mat(1,1) + mat(2,2) ) );
	
	W() = w;
    X() = copysign(	x, mat(2,1) - mat(1,2)	);
    Y() = copysign(	y, mat(2,0) - mat(0,2)	);
    Z() = copysign(	z, mat(1,0) - mat(0,1)	);
}

void O3Quaternion::Set(const O3Mat4x4d& mat) {	
    double w = 0.5 * sqrt( max(0.0, 1.0 + mat(0,0) + mat(1,1) + mat(2,2) ) );
    double x = 0.5 * sqrt( max(0.0, 1.0 + mat(0,0) - mat(1,1) - mat(2,2) ) );
    double y = 0.5 * sqrt( max(0.0, 1.0 - mat(0,0) + mat(1,1) - mat(2,2) ) );
    double z = 0.5 * sqrt( max(0.0, 1.0 - mat(0,0) - mat(1,1) + mat(2,2) ) );
	
	W() = w;
    X() = copysign(	x, mat(2,1) - mat(1,2)	);
    Y() = copysign(	y, mat(2,0) - mat(0,2)	);
    Z() = copysign(	z, mat(1,0) - mat(0,1)	);
}

void O3Quaternion::Set(angle x, angle y, angle z) {
   double half_x = x * .5;
   double half_z = z * .5;
   double half_y = y * .5;
   double c1 = cos(half_y);
   double s1 = sin(half_y);
   double c2 = cos(half_z);
   double s2 = sin(half_z);
   double c3 = cos(half_x);
   double s3 = sin(half_x);
   double c1c2 = c1*c2;
   double s1s2 = s1*s2;
  	X() = c1c2*s3  + s1s2*c3;
	Y() = s1*c2*c3 + c1*s2*s3;
	Z() = c1*s2*c3 - s1*c2*s3;
    W() = c1c2*c3  - s1s2*s3;
}

/*******************************************************************/ #pragma mark Conversions /*******************************************************************/
angle O3Quaternion::GetAngle() const {
	return 2.*acos(GetW());
}

O3Vec3d O3Quaternion::GetAxis() const {
	double x = GetX();
	double y = GetY();
	double z = GetZ();
	double rlen = O3rsqrt(x*x + y*y + z*z);
	return O3Vec3d(x*rlen, y*rlen, z*rlen);
}

void O3Quaternion::GetAxisAngle(angle* theta, O3Vec3d* axis) const {
	if (theta) *theta = 2.*acos(GetW());
	if (axis) {
		double x = GetX();
		double y = GetY();
		double z = GetZ();
		double rlen = O3rsqrt(x*x + y*y + z*z);
		(*axis).Set(x*rlen, y*rlen, z*rlen);
	}
}

void O3Quaternion::GetAxisAngle(angle* theta, double* axis_x, double* axis_y, double* axis_z) const {
	if (theta) *theta = 2.*acos(GetW());
	double x = GetX();
	double y = GetY();
	double z = GetZ();
	double rlen = O3rsqrt(x*x + y*y + z*z);
	if (axis_x) *axis_x = x*rlen;
	if (axis_y) *axis_y = y*rlen;
	if (axis_z) *axis_z = z*rlen;
}

void O3Quaternion::GetAxisAngleA(angle* theta, double* axis_x, double* axis_y, double* axis_z) const {
	*theta = 2.*acos(GetW());
	double x = GetX();
	double y = GetY();
	double z = GetZ();
	double rlen = O3rsqrt(x*x + y*y + z*z);
	*axis_x = x*rlen;
	*axis_y = y*rlen;
	*axis_z = z*rlen;
}


void O3Quaternion::GetEuler(angle* x, angle* y, angle *z) const { ///<@note Euler rotations are applied in xyz order (like VRML not NASA standard)
  	double qx = GetX();
  	double qy = GetY();
  	double qz = GetZ();
  	double qw = GetW();	
	double qzqz2 = 2*qz*qz;
	double qxqy2_qzqw2 = 2. * (qx*qy + qz*qw);
	if (z) *z = asin(qxqy2_qzqw2);
	if (O3Equals(qxqy2_qzqw2, 1., .00001)) {
		if (y) *y = 2*atan2(qx,qw);
		if (x) *x = 0.;
		return;
	}
	if (O3Equals(qxqy2_qzqw2, -1., .00001)) {
		if (y) *y = -2*atan2(qx,qw);
		if (x) *x = 0.;
		return;
	}
	if (x) *x = atan2(2.*(qx*qw-qy*qz) , 1 - 2*qx*qx - qzqz2);
	if (y) *y = atan2(2.*(qy*qw-qx*qz) , 1 - 2*qy*qy - qzqz2); 
}

O3Mat3x3d O3Quaternion::GetMatrix(bool normalize) const {
	double x,y,z,w=0;
	if (normalize) {
		O3Quaternion norm_cpy(*this);
		norm_cpy.Normalize();
		norm_cpy.GetA(&x, &y, &z, &w);
	} else {
		GetA(&x, &y, &z, &w);
	}
		
	double x2 = x*x*2;
	double y2 = y*y*2;
	double z2 = z*z*2;
	double xy2 = 2*x*y;
	double wz2 = 2*w*z;
	double xz2 = 2*x*z;
	double wy2 = 2*w*y;
	double yz2 = 2*z*y;
	double wx2 = 2*w*x;
	double to_return[9] = { //Row-major
		1. - y2 - z2,   xy2 - wz2,   xz2 + wy2,
		xy2 + wz2,      1 - x2 - z2, yz2 - wx2,
		xz2 - wy2,      yz2 + wx2,   1 - x2 - y2
	};
	return O3Mat3x3d(to_return, true);
}

O3Quaternion::operator O3Mat3x3r () const {
	return GetMatrix();
}

/*******************************************************************/ #pragma mark Math Operators & Methods /*******************************************************************/
O3Quaternion& O3Quaternion::Invert() {
	double l = LengthSquared();
	if (!l) return *this;
	Conjugate();
	l = O3recip(l);
	X() *= l;
	Y() *= l;
	Z() *= l;
	W() *= l;
	return *this;
}

O3Quaternion O3Quaternion::GetInverted() const {
	double l = LengthSquared();
	if (!l) return O3Quaternion(*this);
	O3Quaternion to_return = GetConjugate();
	l = O3recip(l);
	to_return.X() *= l;
	to_return.Y() *= l;
	to_return.Z() *= l;
	to_return.W() *= l;
	return *this;
}

O3Quaternion& O3Quaternion::Conjugate() {
	X() = -X();
	Y() = -Y();
	Z() = -Z();
	W() = -W();
	return *this;
}

O3Quaternion  O3Quaternion::GetConjugate() const {
	return O3Quaternion(-GetX(), -GetY(), -GetZ(), GetW());
}

O3Quaternion O3Quaternion::GetSlerped(scale amount, const O3Quaternion& q1, const O3Quaternion& q2) const {
	double lerpdifference = O3Epsilon(double); //The point at which lerp can be used without visible artifacts
	double extraspin = 0.;
	
	double costheta = q1|q2;
	double flip = costheta >= 0; //sign = 1 if no signhack
	costheta = std::abs(costheta); //no abs if no signhack
	
	double c1, c2;
	if (O3Equals(1., costheta, lerpdifference)) { //=-1 if no flip hack
		c1 = 1. - amount;
		c2 = amount;
	} else {
		double theta = acos(costheta);
		double rsintheta = O3recip(sin(theta));
		double spin = theta + extraspin * M_PI;
		c1 = sin(theta - lerpdifference * spin) * rsintheta;
		c2 = sin(amount * spin) * rsintheta;
	}
	
	c2 *= flip;
	return O3Quaternion(  c1*q1.GetX() + c2*q2.GetX(),
	                      c1*q1.GetY() + c2*q2.GetY(),
	                      c1*q1.GetZ() + c2*q2.GetZ(),
	                      c1*q1.GetW() + c2*q2.GetW()  );
}

O3Quaternion O3Quaternion::GetNlerped(scale amount, const O3Quaternion& q1, const O3Quaternion& q2) const {
	double costheta = q1|q2;
	double flip = costheta >= 0; //sign = 1 if no signhack
	costheta = std::abs(costheta); //no abs if no signhack
	
	double c1, c2;
	c1 = 1. - amount;
	c2 = amount;
	
	c2 *= flip;
	O3Quaternion to_return = O3Quaternion(	c1*q1.GetX() + c2*q2.GetX(),
										c1*q1.GetY() + c2*q2.GetY(),
										c1*q1.GetZ() + c2*q2.GetZ(),
										c1*q1.GetW() + c2*q2.GetW()  );
	to_return.Normalize();
	return to_return;
}

O3Quaternion O3Quaternion::operator*(const O3Quaternion& q2) const {
	double x, y, z, w, qx, qy, qz, qw;
	GetA(&x, &y, &z, &w);
	q2.GetA(&qx, &qy, &qz, &qw);
	return O3Quaternion(  w*qx + x*qw + y*qz - z*qy,
						  w*qy + y*qw + z*qx - x*qz,
						  w*qz + z*qw + x*qy - y*qx,
						  w*qw - x*qx - y*qy - z*qz  );
}

O3Quaternion& O3Quaternion::operator*=(const O3Quaternion& q2) {
	double x, y, z, w, qx, qy, qz, qw;
	q2.GetA(&x, &y, &z, &w);			//Flipped, turning *= into premultiplication
	GetA(&qx, &qy, &qz, &qw);
	X() = w*qx + x*qw + y*qz - z*qy;
	Y() = w*qy + y*qw + z*qx - x*qz;
	Z() = w*qz + z*qw + x*qy - y*qx;
	W() = w*qw - x*qx - y*qy - z*qz;
	return *this;
}

O3Quaternion O3Quaternion::operator/(const O3Quaternion& q2) const {
	O3Quaternion inv = q2.GetInverted();
	return operator*(inv);
}

O3Quaternion& O3Quaternion::operator/=(const O3Quaternion& q2) {
	O3Quaternion inv = q2.GetInverted();
	return (*this)*=inv;
}

/*******************************************************************/ #pragma mark Equality & Assignment /*******************************************************************/
bool O3Quaternion::operator==(const O3Quaternion& q) const {
	if (O3Vec4d::operator==(q)) return true;
	if (O3Vec4d::operator==(-q)) return true;
	return false;
}

bool O3Quaternion::operator!=(const O3Quaternion& q) const {
	if (O3Vec4d::operator==(q)) return false;
	if (O3Vec4d::operator==(-q)) return false;
	return true;	
}