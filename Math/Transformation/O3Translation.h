#ifdef __cplusplus
#pragma once
/**
 *  @file O3Translation.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 10/20/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#include "O3Vector.h"

///@class O3Translation
///@brief Represents a N dimensional translation
template <typename TYPE, int DIMENSIONS>
class O3Translation : public O3Vec<TYPE, DIMENSIONS> {
	typedef O3Vec<TYPE, DIMENSIONS> vec;
	
public: //Constructors
	O3Translation() {vec::Zero();}; ///<Constructs the identity translation.
	O3Translation(const vec& vector) : vec(vector) {}; ///<Constructs a translation from a vector
	O3Translation(const O3Translation& other_translation) : vec(other_translation) {}; ///<Copy constructor
	O3Translation(real x, real y)  : vec(x, y) {}; ///<Constructs a translation from x, y, and z.
	O3Translation(real x, real y, real z)  : vec(x, y, z) {}; ///<Constructs a translation from x, y, and z.

public: //Operators
	bool operator==(const O3Translation& other_translation) {return vec::operator==(other_translation);};
	bool operator!=(const O3Translation& other_translation) {return vec::operator!=(other_translation);};
	O3Translation<TYPE, DIMENSIONS> operator-() const {
		return vec::operator-(); //Preserves type
	}
	using vec::operator TYPE*;
	using vec::operator +=;
	using vec::operator ==;
	using vec::operator !=;
	
public: //Mutators
	O3Translation<TYPE, DIMENSIONS>& Set() {vec::Set(0.); return *this;}
	template<typename TYPE2, int DIM2> O3Translation<TYPE, DIMENSIONS>& Set(const O3Translation<TYPE2,DIM2>& other) {vec::Set(other); return *this;}
	template<typename TYPE2> O3Translation<TYPE, DIMENSIONS>& Set(const TYPE* arr, int count) {vec::Set(arr,count); return *this;}
	
public: //O3Mat construction
	O3Mat<TYPE,4,4> GetMatrix() { ///<Returns the matrix representing the receiver
		TYPE to_return_dat[] = {
			1,0,0,vec::GetX(),
			0,1,0,vec::GetY(),
			0,0,1,vec::GetZ(),
			0,0,0,1
			};
		return O3Mat<TYPE,4,4>(to_return_dat);
	}
};

typedef O3Translation<double, 3> O3Translation3;
typedef O3Translation<double, 2> O3Translation2;
#else
//This type is not legal in the bridge. Instead, you should allow the user to input a double[2] or double[3]. The types will be automatically converted in your objc code, and you will be able to use the less awkward [x,y,z] syntax in ruby code.
//typedef struct {double v[3];} O3Translation3;
//typedef struct {double v[2];} O3Translation2;
#endif /*defined(__cplusplus)*/