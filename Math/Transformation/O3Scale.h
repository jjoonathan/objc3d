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
	
public: //Mutators
	O3Scale<TYPE,DIMENSIONS>& Set() {vec::Set(1); return *this;}
	template<typename TYPE2, int DIM2> O3Scale<TYPE, DIMENSIONS>& Set(const O3Scale<TYPE2,DIM2>& other) {vec::Set(other); return *this;}
	O3Scale<TYPE, DIMENSIONS>& Set(const O3DynamicVector& dvec) {vec::Set(dvec); return *this;}

	
public: //Operators
	bool operator==(const O3Scale& other_scale) {return vec::operator==(other_scale);};
	bool operator!=(const O3Scale& other_scale) {return vec::operator!=(other_scale);};
	O3Scale<TYPE,DIMENSIONS> operator-() const {
		O3Scale<TYPE,DIMENSIONS> to_return;
		int i;
		for (i=0;i<DIMENSIONS;i++) to_return[i] = O3recip(vec::operator[](i));
		return to_return;
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
