#ifdef __cplusplus
#pragma once
/**
 *  @file O3Scale.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 10/20/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
///@class O3Scale
///@brief Represents a N dimensional scale transformation
template <typename TYPE, int DIMENSIONS>
class O3Scale : public O3Vec<TYPE, DIMENSIONS> {
	typedef O3Vec<TYPE, DIMENSIONS> vec;
	
public: //Constructors
	O3Scale() {vec::Set(1);}; ///<Constructs the identity translation.
	O3Scale(const vec& vector) : vec(vector) {}; ///<Constructs a translation from a vector
	O3Scale(const O3Scale& other_scale) : vec(other_scale) {}; ///<Copy constructor
	O3Scale(real x, real y)  : vec(x, y) {}; ///<Constructs a scale with the scaling factors over the X and Y axis being x and y respectively.
	O3Scale(real x, real y, real z)  : vec(x, y, z) {}; ///<Constructs a scale with the scaling factors over the X, Y, and Z axis being x, y, and z respectively.
	template<class T2>
			O3Scale(const O3Mat<T2,4,4>& mat): vec(mat.GetRow(0).Length(),
			                                       mat.GetRow(1).Length(),
			                                       mat.GetRow(2).Length()) {}; ///<Extract a scale from a matrix
	
public: //Operators
	bool operator==(const O3Scale& other_scale) {return vec::operator==(other_scale);};
	bool operator!=(const O3Scale& other_scale) {return vec::operator!=(other_scale);};
	O3Scale<TYPE,DIMENSIONS> operator-() const {
		O3Scale<TYPE,DIMENSIONS> to_return;
		int i;
		for (i=0;i<DIMENSIONS;i++) to_return[i] = O3recip(vec::operator[](i));
		return to_return;
	}
	using vec::operator TYPE*;
	using vec::operator +=;
	using vec::operator ==;
	using vec::operator !=;
	using vec::operator [];
	template<class T2> O3Scale<TYPE,DIMENSIONS>& SetMat(const O3Mat<T2,4,4>& mat) { ///<Extract a scale from a matrix
		vec::Set(mat.GetRow(0).Length(),
	             mat.GetRow(1).Length(),
		         mat.GetRow(2).Length());
		return *this;
	}
	
public: //O3Mat construction
	O3Mat<TYPE,4,4> GetMatrix() { ///<Returns the matrix representing the receiver
		TYPE to_return_dat[] = {vec::GetX(),0,0,0,
								0,vec::GetY(),0,0,
								0,0,vec::GetZ(),0,
								0,0,0,1};
		return O3Mat<TYPE,4,4>(to_return_dat);
	}
};

typedef O3Scale<double, 2> O3Scale2;
typedef O3Scale<double, 3> O3Scale3;
typedef O3Scale<float, 3> O3Scale3f;
#else
//This type is not legal in the bridge. Instead, you should allow the user to input a double[2] or double[3]. The types will be automatically converted in your objc code, and you will be able to use the less awkward [x,y,z] syntax in ruby code.
typedef struct {double v[3];} O3Scale3;
typedef struct {double v[2];} O3Scale2;
#endif /*defined(__cplusplus)*/