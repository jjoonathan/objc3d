#pragma once
/**
 *  @file O3Transformation.h
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @todo Template-ize this class to work with other dimensions
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#include "Math.h"
#include "O3Matrix.h"
#include "O3Vector.h"
#include "O3Scale.h"
#include "O3Translation.h"
#include "O3Rotation.h"
#include "O3Quaternion.h"

#define O3Transform_TT template <typename TYPE>
#define O3Transform_T Transform<TYPE>
#define O3Transform_mat_T O3Mat<TYPE, 4, 4>

/**
 * @brief Represents a 3 dimensional affine transformation as a 4x4 matrix of reals.
 *
 */
class O3Transformation3 {
	O3Mat4x4d MyTransform, MyInverseTransform;
	
public: //Constructors
	O3Transformation3() {Set();} ///<Default constructor returns identity transform.
	O3Transformation3(const O3Scale3& scale) {Set(scale);} ///<Create a transformation that scales using scale.
	O3Transformation3(const O3Rotation3& rot) {Set(rot);} ///<Create a transformation that represents rot
	O3Transformation3(const O3Mat4x4d& trans) : MyTransform(trans), MyInverseTransform(trans.GetInverted()) {}; ///<Create a transformation from a 4x4 matrix
	O3Transformation3(const O3Mat4x4d& trans, const O3Mat4x4d& invtrans) : MyTransform(trans), MyInverseTransform(invtrans) {}; ///<Create a transformation from a 4x4matrix and its inverse
	O3Transformation3(const O3Translation3& trans) {Set(trans);} ///<Create a transformation from a translation
	O3Transformation3(const O3Transformation3& transf) {Set(transf);} ///<Create a transformation from another transformation (copy constructor)
	O3Transformation3(const O3Mat3x3r ob, O3Translation3 tr) {Set(ob,tr);} ///<Create a transformation from an orthonormal base (ob) and a translation (tr)
	
public: //Setters
	O3Transformation3& Set(); ///<Sets to identity transform.
	O3Transformation3& Set(const O3Scale3& scale);
	O3Transformation3& Set(const O3Rotation3& rot);
	O3Transformation3& Set(const O3Mat4x4d& trans);
	O3Transformation3& Set(const O3Mat4x4d& trans, const O3Mat4x4d& invtrans);
	O3Transformation3& Set(const O3Translation3& trans);
	O3Transformation3& Set(const O3Transformation3& transf);
	O3Transformation3& Set(const O3Mat3x3r ob, O3Translation3 tr);
	
public: //Methods
	O3Transformation3& Invert();
	O3Transformation3 GetInverted() const;
	
public: //Concatenations
	O3Transformation3& O3Scale(real x, real y, real z);
	O3Transformation3& O3Scale(const O3Scale3& scale);
	O3Transformation3& Rotate(real x, real y, real z);
	O3Transformation3& Rotate(angle theta, O3Vec3r axis);
	O3Transformation3& Rotate(angle theta, real x, real y, real z);
	O3Transformation3& Rotate(const O3Rotation3& rot);
	O3Transformation3& Translate(real x, real y, real z);
	O3Transformation3& Translate(const O3Translation3& trans);
	O3Transformation3& Transform(const O3Transformation3& trans);
	
public: //Operators
	O3Transformation3& operator=(const O3Transformation3& other) {
		MyTransform = other.MyTransform;
		MyInverseTransform = other.MyInverseTransform;
		return *this;
	}
	
	O3Transformation3  operator+(const O3Scale3& scale) const;
	O3Transformation3& operator+=(const O3Scale3& scale);
	O3Transformation3  operator-(const O3Scale3& scale) const;
	O3Transformation3& operator-=(const O3Scale3& scale);	
	
	O3Transformation3  operator+(const O3Rotation3& rot) const;
	O3Transformation3& operator+=(const O3Rotation3& rot);
	O3Transformation3  operator-(const O3Rotation3& rot) const;
	O3Transformation3& operator-=(const O3Rotation3& rot);	

	O3Transformation3  operator+(const O3Translation3& trans) const;
	O3Transformation3& operator+=(const O3Translation3& trans);
	O3Transformation3  operator-(const O3Translation3& trans) const;
	O3Transformation3& operator-=(const O3Translation3& trans);	
	
	O3Transformation3  operator+(const O3Transformation3& trans) const;
	O3Transformation3& operator+=(const O3Transformation3& trans);
	O3Transformation3  operator-(const O3Transformation3& trans) const;
	O3Transformation3& operator-=(const O3Transformation3& trans);
	
	O3Transformation3  operator+ (const O3Mat4x4d& mat) const;
	O3Transformation3& operator+=(const O3Mat4x4d& mat);
	O3Transformation3  operator- (const O3Mat4x4d& mat) const;
	O3Transformation3& operator-=(const O3Mat4x4d& mat);
	
	bool operator==(const O3Transformation3& other) const {return MyTransform==other.MyTransform;}
	
public: //Other methods
	bool Equals(const O3Transformation3& other, double tolerance = O3Epsilon(real)) const {
		return MyTransform.Equals(other.MyTransform, tolerance);
	}
	
	bool IsEqual(const O3Transformation3& other, double tolerance = O3Epsilon(real)) const {
		return MyTransform.IsEqual(other.MyTransform, tolerance);
	}
	
	bool IsValid(double tolerance = 1.0e-4) {  ///<Checks to see weather MyTransform*MyInverseTransform is the identity within tolerance
		O3Mat4x4d should_be_identity = (MyTransform*MyInverseTransform);
		return should_be_identity.IsIdentity(tolerance);
	}
	
	void Validate() { //Recalculates the inverse matrix so it is the actual inverse matrix of the forward matrix
		MyInverseTransform = MyTransform.GetInverted();
	}
	
public: //Accessors
	const O3Mat4x4d& O3Mat() const; ///<Returns the matrix that the receive represents
	const O3Mat4x4d& InverseMatrix() const; ///<Returns the inverse of the matrix that the receiver represents
	O3Mat4x4d GetMatrix() const; ///<Returns a copy of the matrix that the receive represents
	O3Mat4x4d GetInverseMatrix() const; ///<Returns a copy of the inverse of the matrix that the receiver represents
	
public: //Interface
	std::string Description() const;
};
