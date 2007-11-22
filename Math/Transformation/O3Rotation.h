#ifdef __cplusplus
#pragma once
/**
 *  @file O3Rotation.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 10/20/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#include "O3Matrix.h"
#include "O3Quaternion.h"

class O3Rotation3 {
	O3Quaternion MyQuat;
	
public: //Constructors
	O3Rotation3() : MyQuat() {};													///<Initialize to an identity transformation (no transformation).
	O3Rotation3(const O3Rotation3& other): MyQuat(other.GetQuaternion()) {};		///<Initialize to the value of another rotation
	O3Rotation3(const O3Quaternion& quat): MyQuat(quat) {};							///<Initialize a rotation with a quaternion
	O3Rotation3(angle theta, O3Vec3d axis): MyQuat(theta, axis) {};					///<Initialize to another rotation
	O3Rotation3(angle roll, angle pitch, angle yaw): MyQuat(roll, pitch, yaw) {};	///<Initialize with the euler angles roll, pitch, and yaw. NOTE: internal gimbal lock won't happen, but you still have to be careful here.
	O3Rotation3(const O3Mat3x3d& mat) {Set(mat);};	///<Constructs a rotation from a rotation matrix
	O3Rotation3(const O3Mat4x4d& mat) {Set(mat);};	///<Constructs a rotation from the rotation element of mat
	
public: //Setters
	O3Rotation3& Set() {MyQuat.Set(); return *this;};												///<Set the receiver to the identity rotation (no rotation)
	O3Rotation3& Set(const O3Rotation3& other) {MyQuat.Set(other.GetQuaternion()); return *this;};	///<Make the receiver a copy of other
	O3Rotation3& Set(angle theta, O3Vec3d axis) {MyQuat.Set(theta, axis); return *this;};			///<Set the receiver to the rotation described by the axis-angle pair theta and axis.
	O3Rotation3& Set(const O3Quaternion& quat) {MyQuat.Set(quat); return *this;};					///<Set the receiver to the rotation represented by quat
	O3Rotation3& Set(angle roll, angle pitch, angle yaw) {MyQuat.Set(roll, pitch, yaw); return *this;}; ///<Set the receiver to the rotation represented by roll, pitch, and yaw (NOTE: though internally O3Rotation3 is not suceptible to gimbal lock, the euler representation is, so be careful.)
	O3Rotation3& Set(const O3Mat3x3d& mat) {MyQuat.Set(mat); return *this;}; ///<Sets the receiver to the rotation represented by mat
	O3Rotation3& Set(const O3Mat4x4d& mat) {MyQuat.Set(mat); return *this;}; ///<Sets the receiver to the rotation component of mat
	
public: //Concatenations        
	O3Rotation3& Rotate(const O3Rotation3& other);	///<Rotate the receiver by the rotation specified by other
	O3Rotation3& Rotate(angle theta, O3Vec3d axis);	///<Add the axis-angle rotation defined by theta and axis to the receiver
	O3Rotation3& Rotate(const O3Quaternion& quat);	///<Rotate the receiver by the quaternion quat
	O3Rotation3& Rotate(angle roll, angle pitch, angle yaw); ///<Rotate the receiver by the rotation represented by roll, pitch, and yaw (NOTE: though internally O3Rotation3 is not suceptible to gimbal lock, the euler representation is, so be careful.)

public: //Operators & Methods
	O3Rotation3& Invert();
	O3Rotation3 operator+(const O3Rotation3& other) const;	///<Add two rotations
	O3Rotation3& operator+=(const O3Rotation3& other);		///<In-place add two rotations
	O3Rotation3 operator-(const O3Rotation3& other) const;	///<Subtract two rotations
	O3Rotation3& operator-=(const O3Rotation3& other);		///<In-place subtract two rotations
	O3Rotation3 operator-() const;						///<Gets an inverted copy of the receiver.
	
public: //Inspectors
	O3Rotation3 GetInverse();
	O3Mat3x3d GetMatrix() const;			///<Gets the 3x3 matrix that performs the receiver's rotation
	O3Quaternion GetQuaternion() const;	///<Gets the receiver's quaternion representation
	void GetEulerAngles(angle* roll, angle* pitch, angle*yaw) const;	///<Gets the euler angles that compose the receiver's rotation (pass NULL if you don't want one of them)
};
#endif /*defined(__cplusplus)*/
