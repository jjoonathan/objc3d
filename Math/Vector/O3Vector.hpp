#pragma once
/**
 *  @file O3Vector.hpp
 *  @license MIT License (see LICENSE.txt)
 *  @date 8/27/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#include "O3Functions.h"
#include <cmath>
using namespace ObjC3D::Math;

/*******************************************************************/ #pragma mark DEPRICATED /*******************************************************************/
O3Vec_TT
TYPE O3Vec_T::Distance(const O3Vec_T &v) {
	O3Vec_T difference = *this - v;
	return difference.Length();
}

O3Vec_TT
TYPE O3Vec_T::DistanceSquared(const O3Vec_T &v) {
	O3Vec_T difference = *this - v;
	return difference.LengthSquared();	
}

/*******************************************************************/ #pragma mark Setters /*******************************************************************/
///Fills all elements of a vector with the value x.
O3Vec_TT O3Vec_T& O3Vec_T::Set(TYPE x) {
	int i; for (i=0;i<NUMBER;i++) Values[i]=x;
	return *this;
}

///Zero fills any elements not specified. You cannot specify more elements than are in a vector.
O3Vec_TT O3Vec_T& O3Vec_T::Set(TYPE x, TYPE y) {
	O3CompileAssert(NUMBER>=2, "Must have 2 or more dimensions to set a x and a y");
	Values[0]=x; 
	Values[1]=y; 
	int i; for (i=2;i<NUMBER;i++) Values[i]=0;
	return *this;
}

///Zero fills any elements not specified. You cannot specify more elements than are in a vector.
O3Vec_TT O3Vec_T& O3Vec_T::Set(TYPE x, TYPE y, TYPE z) {
	O3CompileAssert(NUMBER>=3, "Must have 3 or more dimensions to set a x, y, and z");
	Values[0]=x; 
	Values[1]=y; 
	Values[2]=z;
	int i; for (i=3;i<NUMBER;i++) Values[i]=0;
	return *this;
}

///Zero fills any elements not specified. You cannot specify more elements than are in a vector.
O3Vec_TT O3Vec_T& O3Vec_T::Set(TYPE x, TYPE y, TYPE z, TYPE w) {
	O3CompileAssert(NUMBER>=4, "Must have 4 or more dimensions to set a x, y, z, and w");
	Values[0]=x; 
	Values[1]=y; 
	Values[2]=z; 
	Values[3]=w; 
	int i; for (i=4;i<NUMBER;i++) Values[i]=0;
	return *this;
}

///Zero fills any elements not specified. You can specify more elements than are in a vector.
O3Vec_TT template <typename TYPE2> 
O3Vec_T& O3Vec_T::Set(const TYPE2 *array, unsigned arraylen) {
	int i;
	int j = O3Min(arraylen, NUMBER);
	for (i=0;i<j;i++) Values[i] = array[i];
	for (i=j;i<NUMBER;i++) Values[i] = 0;
	return *this;
}

///Sets the receiver's elements to the values of \e v's elements, filling in 0 anywhere where v doesn't have a corresponding element
O3Vec_TT
template <typename TYPE2, int SIZE2>
O3Vec_T& O3Vec_T::Set(const O3Vec<TYPE2, SIZE2> &v) {
	int i; for (i=0;i<SIZE2;i++) Values[i] = v[i];
	for (; i<NUMBER;i++)Values[i] = 0;
	return *this;
}

/*******************************************************************/ #pragma mark Meta-Attributes /*******************************************************************/
O3Vec_TT
TYPE O3Vec_T::Length() const {
	TYPE sum = 0;
	int i; for (i=0;i<NUMBER;i++) {
		TYPE value = Values[i];
		sum += value*value;
	}
	return sqrt(sum);
}

O3Vec_TT
TYPE O3Vec_T::LengthSquared() const {
	TYPE sum = 0;
	int i; for (i=0;i<NUMBER;i++) {
		TYPE value = Values[i];
		sum += value*value;
	}
	return sum;
}

O3Vec_TT
bool O3Vec_T::IsNormalized() const {
	TYPE lengthsq = LengthSquared();
	TYPE tolerance = O3Epsilon(TYPE)*2;
	return O3Equals(lengthsq, 1., tolerance);
}

O3Vec_TT
bool O3Vec_T::IsNormalized(TYPE tolerance) const {
	TYPE lengthsq = LengthSquared();
	return O3Equals(lengthsq, 1., tolerance*2); //Not Strictly Correct
}

O3Vec_TT
bool O3Vec_T::IsZero() const {
	TYPE lengthsq = LengthSquared();
	TYPE tolerance = O3Epsilon(TYPE) * 2;
	return O3Equals(lengthsq, 0., tolerance);
}

O3Vec_TT
bool O3Vec_T::IsZero(TYPE tolerance) const {
	TYPE lengthsq = LengthSquared();
	return O3Equals(lengthsq, 0., tolerance*2); //Not Strictly Correct
}

O3Vec_TT
bool O3Vec_T::IsEqualTo(const O3Vec_T& v, TYPE tolerance = O3Epsilon(TYPE)) const {
	id self = nil; O3Optimizable();
	TYPE lengthsq = (*this-v).LengthSquared();
	return O3Equals(lengthsq, 0., tolerance*2); //Not Strictly Correct
}

O3Vec_TT
double O3Vec_T::Angle(const O3Vec_T& v) const {
	double cos_a = ((*this)|v) / sqrt(Length()*v.Length());
	return abs(acos(cos_a));
}

/*******************************************************************/ #pragma mark Index Operators /*******************************************************************/
O3Vec_TT
TYPE &O3Vec_T::operator[](int index) {
	O3Assert(index<NUMBER, @"Attempt to access index %i of vector with size %i", index, NUMBER);
	return Values[index];
}

O3Vec_TT
const TYPE &O3Vec_T::operator[](int index) const {
	O3Assert(index<NUMBER, @"Attempt to access index %i of vector with size %i", index, NUMBER);
	return Values[index];
}

/*******************************************************************/ #pragma mark Assignment Operator /*******************************************************************/
O3Vec_TT
template <typename TYPE2>
O3Vec_T& O3Vec_T::operator=(const O3Vec<TYPE2, NUMBER>& v2) {
	int i; for (i=0;i<NUMBER;i++) Values[i] = v2[i];
	return *this;
}

/*******************************************************************/ #pragma mark Equality Operators /*******************************************************************/
O3Vec_TT
bool  O3Vec_T::operator==(const O3Vec_T& v) const {
	int i; for (i=0;i<NUMBER;i++) if (Values[i] != v[i]) return false;
	return true;
}

O3Vec_TT
bool  O3Vec_T::operator!=(const O3Vec_T& v) const {
	int i; for (i=0;i<NUMBER;i++) if (Values[i] == v[i]) return false;
	return true;
}

/*******************************************************************/ #pragma mark O3Vec Products /*******************************************************************/
O3Vec_TT
TYPE O3Vec_T::operator|(const O3Vec_T &v) const { //Dot product
	O3Vec_T
v2; 	//We do it this way in order to allow the compiler to parallelize the following code
	int i; for (i=0;i<NUMBER;i++) v2[i] = v[i] * Values[i];
	TYPE total = 0.0; for (i=0;i<NUMBER;i++) total += Values[i];
	return total;
}


O3Vec_TT
O3Vec_T O3Vec_T::operator^(const O3Vec_T &v) const { //Cross product
	O3CompileAssert(NUMBER==3, "Cannot cross non-3D vectors. Fix if you need to.");
	int X=0, Y=1, Z=2;
	return O3Vec_T(	Values[Y] * v[Z] - Values[Z] * v[Y],
									Values[Z] * v[X] - Values[X] * v[Z],
									Values[X] * v[Y] - Values[Y] * v[X]  );
}

/*******************************************************************/ #pragma mark O3Vec In-Place Products /*******************************************************************/
O3Vec_TT
O3Vec_T& O3Vec_T::operator^=(const O3Vec_T &v) { //Cross product
	O3CompileAssert(NUMBER==3, "Cannot cross non-3D vectors. Fix if you need to.");
	TYPE NewX = Values[Y] * v[Z] - Values[Z] * v[Y];
	TYPE NewY = Values[Z] * v[X] - Values[X] * v[Z];
	TYPE NewZ = Values[X] * v[Y] - Values[Y] * v[X];
	Values[X] = NewX;
	Values[Y] = NewY;
	Values[Z] = NewZ;
}

/*******************************************************************/ #pragma mark O3Vec Unary Operators /*******************************************************************/
O3Vec_TT
O3Vec_T O3Vec_T::operator+() const {
	O3Vec_T
to_return;
	int i; for (i=0;i<NUMBER;i++) to_return[i] = abs(Values[i]);
	return to_return;
}

O3Vec_TT
O3Vec_T O3Vec_T::operator-() const {
	O3Vec_T
to_return;
	int i; for (i=0;i<NUMBER;i++) to_return[i] = -Values[i];
	return to_return;
}

/*******************************************************************/ #pragma mark O3Vec - Scaler Operators /*******************************************************************/
O3Vec_TT
O3Vec_T O3Vec_T::operator+(const TYPE scalar) const {
	O3Vec_T
to_return; 
	int i; for (i=0;i<NUMBER;i++) to_return[i] = Values[i] + scalar; 
	return to_return;
}

O3Vec_TT
O3Vec_T O3Vec_T::operator-(const TYPE scalar) const {
	O3Vec_T
to_return; 
	int i; for (i=0;i<NUMBER;i++) to_return[i] = Values[i] - scalar; 
	return to_return;
}

O3Vec_TT
O3Vec_T O3Vec_T::operator*(const TYPE scalar) const {
	O3Vec_T
to_return; 
	int i; for (i=0;i<NUMBER;i++) to_return[i] = Values[i] * scalar; 
	return to_return;
}

O3Vec_TT
O3Vec_T O3Vec_T::operator/(const TYPE scalar) const {
	O3Vec_T
to_return; 
	TYPE reciprocal = O3recip(scalar);
	int i; for (i=0;i<NUMBER;i++) to_return[i] = Values[i] * reciprocal; 
	return to_return;
}

/*******************************************************************/ #pragma mark O3Vec - Scaler In-Place Operators /*******************************************************************/
O3Vec_TT
O3Vec_T& O3Vec_T::operator+=(const TYPE scalar) {
	int i; for (i=0;i<NUMBER;i++) Values[i] += scalar; 
	return *this;
}

O3Vec_TT
O3Vec_T& O3Vec_T::operator-=(const TYPE scalar) {
	int i; for (i=0;i<NUMBER;i++) Values[i] -= scalar; 
	return *this;
}

O3Vec_TT
O3Vec_T& O3Vec_T::operator*=(const TYPE scalar) {
	int i; for (i=0;i<NUMBER;i++) Values[i] *= scalar; 
	return *this;
}

O3Vec_TT
O3Vec_T& O3Vec_T::operator/=(const TYPE scalar) {
	int i; for (i=0;i<NUMBER;i++) Values[i] /= scalar; 
	return *this;
}

/*******************************************************************/ #pragma mark Scalar - O3Vec Operators /*******************************************************************/
O3Vec_TT
O3Vec_T operator+(const TYPE scalar, const O3Vec_T& v) {
	O3Vec_T
to_return; 
	int i; for (i=0;i<NUMBER;i++) to_return[i] = v[i] + scalar; 
	return to_return;
}

O3Vec_TT
O3Vec_T operator-(const TYPE scalar, const O3Vec_T& v) {
	O3Vec_T
to_return; 
	int i; for (i=0;i<NUMBER;i++) to_return[i] = scalar - v[i]; 
	return to_return;
}

O3Vec_TT
O3Vec_T operator*(const TYPE scalar, const O3Vec_T& v) {
	O3Vec_T
to_return; 
	int i; for (i=0;i<NUMBER;i++) to_return[i] = scalar * v[i]; 
	return to_return;
}

O3Vec_TT
O3Vec_T operator/(const TYPE scalar, const O3Vec_T& v) {
	O3Vec_T
to_return; 
	int i; for (i=0;i<NUMBER;i++) to_return[i] = scalar / v[i]; 
	return to_return;
}

/*******************************************************************/ #pragma mark O3Vec - O3Vec Operators /*******************************************************************/
O3Vec_TT
O3Vec_T O3Vec_T::operator+(const O3Vec_T& v) const {
	O3Vec_T
to_return; 
	int i; for (i=0;i<NUMBER;i++) to_return[i] = Values[i] + v[i]; 
	return to_return;
}

O3Vec_TT
O3Vec_T O3Vec_T::operator-(const O3Vec_T& v) const {
	O3Vec_T
to_return; 
	int i; for (i=0;i<NUMBER;i++) to_return[i] = Values[i] - v[i]; 
	return to_return;
}

O3Vec_TT
O3Vec_T O3Vec_T::operator*(const O3Vec_T& v) const {
	O3Vec_T
to_return; 
	int i; for (i=0;i<NUMBER;i++) to_return[i] = Values[i] * v[i]; 
	return to_return;
}

O3Vec_TT
O3Vec_T O3Vec_T::operator/(const O3Vec_T& v) const {
	O3Vec_T
to_return; 
	int i; for (i=0;i<NUMBER;i++) to_return[i] = Values[i] / v[i]; 
	return to_return;
}

/*******************************************************************/ #pragma mark O3Vec - O3Vec In-Place Operators /*******************************************************************/
O3Vec_TT
O3Vec_T& O3Vec_T::operator+=(const O3Vec_T& v) {
	int i; for (i=0;i<NUMBER;i++) Values[i] += v[i]; 
	return *this;
}

O3Vec_TT
O3Vec_T& O3Vec_T::operator-=(const O3Vec_T& v) {
	int i; for (i=0;i<NUMBER;i++) Values[i] -= v[i]; 
	return *this;
}

O3Vec_TT
O3Vec_T& O3Vec_T::operator*=(const O3Vec_T& v) {
	int i; for (i=0;i<NUMBER;i++) Values[i] *= v[i]; 
	return *this;
}

O3Vec_TT
O3Vec_T& O3Vec_T::operator/=(const O3Vec_T& v) {
	int i; for (i=0;i<NUMBER;i++) Values[i] /= v[i]; 
	return *this;
}

/*******************************************************************/ #pragma mark Accessors /*******************************************************************/
O3Vec_TT
void O3Vec_T::Get(TYPE* x, TYPE* y) const {
	if (x) *x = Values[0];
	if (y) *y = Values[1];
}	

O3Vec_TT
void O3Vec_T::Get(TYPE* x, TYPE* y, TYPE* z) const {
	if (x) *x = Values[0];
	if (y) *y = Values[1];
	if (z) *z = Values[2];
}

O3Vec_TT
void O3Vec_T::Get(TYPE* x, TYPE* y, TYPE* z, TYPE* w) const {
	if (x) *x = Values[0];
	if (y) *y = Values[1];
	if (z) *z = Values[2];
	if (w) *w = Values[3];
}

O3Vec_TT
void O3Vec_T::GetA(TYPE* x, TYPE* y) const {
	*x = Values[0];
	*y = Values[1];
}	

O3Vec_TT
void O3Vec_T::GetA(TYPE* x, TYPE* y, TYPE* z) const {
	*x = Values[0];
	*y = Values[1];
	*z = Values[2];
}

O3Vec_TT
void O3Vec_T::GetA(TYPE* x, TYPE* y, TYPE* z, TYPE* w) const {
	*x = Values[0];
	*y = Values[1];
	*z = Values[2];
	*w = Values[3];
}

/*******************************************************************/ #pragma mark Methods and Method-accessors /*******************************************************************/
O3Vec_TT
O3Vec_T& O3Vec_T::Zero() {
	int i; for (i=0;i<NUMBER;i++) Values[i] = 0.;
	return *this;
}

O3Vec_TT
O3Vec_T& O3Vec_T::Normalize() {
	TYPE len = Length();
	TYPE rlength = O3recip(len);
	int i; for (i=0;i<NUMBER;i++) Values[i] = rlength*(Values[i]);
	return *this;
}

O3Vec_TT
O3Vec_T O3Vec_T::GetNormalized() const {
	O3Vec_T
to_return;
	TYPE rlength = O3recip(Length());
	int i; for (i=0;i<NUMBER;i++) to_return[i] = rlength*(Values[i]);
	return to_return;
}

O3Vec_TT
O3Vec_T& O3Vec_T::Floor() {
	int i; for (i=0;i<NUMBER;i++) Values[i] = floor(Values[i]);
	return *this;
}

O3Vec_TT
O3Vec_T O3Vec_T::GetFloored() const {
	O3Vec_T
to_return;
	int i; for (i=0;i<NUMBER;i++) to_return[i] = floor(Values[i]);
	return to_return;
}

O3Vec_TT
O3Vec_T& O3Vec_T::Ceil() {
	int i; for (i=0;i<NUMBER;i++) Values[i] = ceil(Values[i]);
	return *this;
}

O3Vec_TT
O3Vec_T O3Vec_T::GetCeiled() const {
	O3Vec_T
to_return;
	int i; for (i=0;i<NUMBER;i++) to_return[i] = ceil(Values[i]);
	return to_return;
}

O3Vec_TT
O3Vec_T& O3Vec_T::Round() {
	int i; for (i=0;i<NUMBER;i++) Values[i] = round(Values[i]);
	return *this;
}

O3Vec_TT
O3Vec_T O3Vec_T::GetRounded() const {
	O3Vec_T
to_return;
	int i; for (i=0;i<NUMBER;i++) to_return[i] = round(Values[i]);
	return to_return;
}

O3Vec_TT
O3Vec_T& O3Vec_T::Clamp(TYPE min, TYPE max) {
	int i; for (i=0;i<NUMBER;i++) Values[i] = clamp(Values[i], min, max);
	return *this;
}

O3Vec_TT
O3Vec_T O3Vec_T::GetClamped(TYPE min, TYPE max) const {
	O3Vec_T
to_return;
	int i; for (i=0;i<NUMBER;i++) to_return[i] = clamp(Values[i], min, max);
	return to_return;
}

O3Vec_TT
O3Vec_T& O3Vec_T::Abs() {
	int i; for (i=0;i<NUMBER;i++) Values[i] = abs(Values[i]);
	return *this;
}

O3Vec_TT
O3Vec_T O3Vec_T::GetAbs() const {
	O3Vec_T
to_return;
	int i; for (i=0;i<NUMBER;i++) to_return[i] = abs(Values[i]);
	return to_return;
}

O3Vec_TT
O3Vec_T& O3Vec_T::Negate() {
	int i; for (i=0;i<NUMBER;i++) Values[i] = -Values[i];
	return *this;
}

O3Vec_TT
O3Vec_T O3Vec_T::GetNegated() const {
	O3Vec_T
to_return;
	int i; for (i=0;i<NUMBER;i++) to_return[i] = -Values[i];
	return to_return;
}

/************************************/ #pragma mark Interface /************************************/
O3Vec_TT
std::string O3Vec_T::Description() const {
	std::ostringstream to_return;
	to_return<<"{";
	int i; for (i=0;i<NUMBER;i++) {
		to_return<<operator[](i);
		if (i!=(NUMBER-1)) to_return<<", ";
	}
	to_return<<"}";
	return to_return.str();
}
