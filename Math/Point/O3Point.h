#pragma once
/**
 *  @file O3Point.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 10/4/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 *  @brief Holds the O3Point class.
 */
#include "O3Vector.h"
#include "Math.h"

#define O3Point_vec_T O3Vec<TYPE, DIMENSIONS>
#define O3Point_TT template <typename TYPE, int DIMENSIONS>
#define O3Point_T O3Point<TYPE, DIMENSIONS>

O3Point_TT class O3Point : public O3Point_vec_T {
  public:
  	O3Point() {};	///<Default constructor DOES NOT GUARENTEE ANYTHING! Values might not be 0,0,0!
	O3Point(const O3Point_vec_T& v) : O3Point_vec_T(v) {}; ///<Constructs a point from another point or vector
  	O3Point(const real* array) : O3Point_vec_T(array) {}; ///<Constructs a point from an array of reals
  	O3Point(real x, real y, real z) : O3Point_vec_T(x, y, z) {}; ///<Constructs a point from x, y, and z values
	
  public: //Setters
	O3Point_T& Set(const O3Point_vec_T& v) {O3Point_vec_T::Set(v); return *this;}; ///<Sets a point to the contents of another vector (or point).
  	O3Point_T& Set(const real* array) {O3Point_vec_T::Set(array); return *this;}; ///<Sets a point from an array of reals
  	O3Point_T& Set(real x, real y, real z) {O3Point_vec_T::Set(x,y,z); return *this;}; ///<Sets a point from x, y, and z values
	
  public: //Operators
	using O3Point_vec_T::operator TYPE*;			///<Allows implicit conversion to C arrays
	using O3Point_vec_T::operator const TYPE*;	///<Allows implicit conversion to C arrays
	using O3Point_vec_T::operator =;	///<Allows assigning
	operator O3Point_vec_T() {return *this;}	///<Allows implicit conversion to a vector
	bool operator==(const O3Point_T& other_point) {return O3Point_vec_T::operator==(other_point);}; ///<Tests exact equality of the receiver and other_point
	bool operator!=(const O3Point_T& other_point) {return O3Point_vec_T::operator!=(other_point);}; ///<Tests exact inequality of the receiver and other_point
};

typedef O3Point<real, 3> O3Point3;
typedef O3Point<real, 2> O3Point2;
typedef O3Point<double, 3> O3Point3d;
typedef O3Point<double, 2> O3Point2d;
