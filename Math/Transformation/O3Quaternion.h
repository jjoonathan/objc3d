#ifdef __cplusplus
#pragma once
/**
 *  @file O3Quaternion.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 10/20/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#include "O3Matrix.h"
#include "O3Vector.h"

class O3Quaternion : public O3Vec4d {	
public: //Constructors
	O3Quaternion() : O3Vec4d(0., 0., 0., 1.) {}; ///<Default constructor initializes the receiver to the quaternion multiplication identity (NOTE: THIS IS *NOT* THE ADDITION IDENTITY!)
	O3Quaternion(const O3Quaternion& other) : O3Vec4d(other) {}; ///<Copy constructor
	O3Quaternion(angle theta, O3Vec3d axis) {Set(theta, axis);}; ///<Constructs a quaternion from an axis and an angle
	O3Quaternion(angle x, angle y, angle z) {Set(x, y, z);};	///<Constructs a quaternion from a euler angle
	O3Quaternion(double x, double y, double z, double w) : O3Vec4d(x,y,z,w) {};	///<Constructs a quaternion from four elements
	O3Quaternion(const O3Mat3x3d& mat) {Set(mat);};	///<Constructs a quaternion from a rotation matrix
	O3Quaternion(const O3Mat4x4d& mat) {Set(mat);};	///<Constructs a quaternion from the rotation element of mat
	
public: //Setters
	void Set() {O3Vec4d(0., 0., 0., 1.); };								///<Sets the receiver to the quaternion multiplication identity (NOTE: THIS IS *NOT* THE ADDITION IDENTITY!)
	void Set(const O3Quaternion& other) {O3Vec4d::Set(other);};				///<Sets the receiver to the contents of other
	void Set(angle theta, O3Vec3d axis);									///<Sets the receiver to the rotation defined by the axis-angle pair
	void Set(angle x, angle y, angle z);						///<Sets the receiver to the euler angle defined by x/z/y (NOTE: Not doublely a great idea, be careful about gimbal lock)
	void Set(double x, double y, double z, double w) {O3Vec4d::Set(x,y,z,w); };	///<Sets the receiver to the quaternion components x, y, z, and w
	void SetMat(const O3Mat3x3d& mat); ///<Sets the receiver to the rotation represented by mat
	void SetMat(const O3Mat4x4d& mat); ///<Sets the receiver to the rotation component of mat
	
public: //Conversions
	angle GetAngle() const; ///<Efficently returns the angle for an axis-angle representation (i.e. ToAxisAngle speed wise = GetAxis + GetAngle)
	O3Vec3d GetAxis() const; ///<Efficently returns the axis for axis for an axis-angle representation (i.e. ToAxisAngle speed wise = GetAxis + GetAngle)
	void GetAxisAngle(angle* theta, O3Vec3d* axis) const; ///<Converts a quaternion to an axis-angle representation. Pass NULL if you don't want theta or axis.
	void GetAxisAngle(angle* theta, double* axis_x, double* axis_y, double* axis_z) const; ///<Converts a quaternion to an axis-angle representation. Pass NULL if you don't want any of theta, axis_x, axis_y, or axis_z.
	void GetAxisAngleA(angle* theta, double* axis_x, double* axis_y, double* axis_z) const; ///<Converts a quaternion to an axis-angle representation, but doesn't do safety checks to see if theta, axis_x, axis_y, or axis_z are NULL.
	void GetEuler(angle* x, angle* y, angle *z) const; ///<Converts a quaternion to a euler angle representation. Euler angles suck, and should not be used.
	O3Mat3x3d GetMatrix(bool normalize=false) const; ///<Gets a quaternion's matrix. If you want the matrix to be normalized, pass YES for \e normalize.
	operator O3Mat3x3r () const; ///<Convert to a 3x3 rotation matrix (probably better to use ToAxisAngle)
	
public: //Math Operators & Methods
	O3Quaternion& Invert();				///<Inverts the receiver
	O3Quaternion  GetInverted() const;	///<Returns a copy of the receiver that has been inverted
	O3Quaternion& Conjugate();			///<Conjugates the receiver
	O3Quaternion  GetConjugate() const; ///<Gets a copy of the receiver and conjugates it
	O3Quaternion  GetSlerped(scale amount, const O3Quaternion& q1, const O3Quaternion& q2) const; ///<Does a spherical linear interpolation along the shortest path between q1 and q2 (if amount = 1 it returns q2, if amount = 0 it returns q1)
	O3Quaternion  GetNlerped(scale amount, const O3Quaternion& q1, const O3Quaternion& q2) const; ///<Does a normalized linear interpolation along the shortest path between q1 and q2 (lower quality than slerp but faster) (if amount = 1 it returns q2, if amount = 0 it returns q1)
	O3Quaternion& operator*=(const O3Quaternion& q2); ///<In-place quaternion product of two quaternions (NOTE: This is premultiplication, i.e. it is done backwards from usual (not receiver=receiver*q2 but receiver=q2*receiver). This concatenates two rotations, with the receiver's being applied first.
	O3Quaternion  operator*(const O3Quaternion& q2) const; ///<Returns the quaternion product of two quaternions (in effect concatenating rotatations, where the rvalue would be applied first).
	O3Quaternion& operator/=(const O3Quaternion& q2); ///<In-place quaternion inverse-multiplication of two quaternions (NOTE: This is pre-inverse-multiplication, i.e. it is done backwards from usual (not receiver=receiver*1/q2 but receiver=q2*1/receiver). This essentially "undoes" q2's rotation.
	O3Quaternion  operator/(const O3Quaternion& q2) const; ///<O3Quaternion quotient: applies inverse 
	
public: //Use
	O3Vec3d RotatePoint(const O3Vec3d& p); //Use the receiver to rotate p. Note that if you are rotating many ps, its mor efficient to compute the matrix.

public: //Equality and assignment methods and operators
	bool operator==(const O3Quaternion& q) const;	///<Tests for exact (no epsilon tolerance) equality of two quaternions.
	bool operator!=(const O3Quaternion& q) const;	///<Tests for exact (no epsilon tolerance) inequality of two quaternions.
};
#else
//typedef struct {double v[4];} O3Quaternion;
#endif /*defined(__cplusplus)*/
