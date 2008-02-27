#pragma once
#ifdef __cplusplus
/**
 *  @file O3Vector.hpp
 *  @license MIT License (see LICENSE.txt)
 *  @date 8/27/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#include <ctype.h>
#include "O3Functions.h"
using namespace ObjC3D::Math;

/*******************************************************************/ #pragma mark DEPRICATED /*******************************************************************/
O3Vec_TT
TYPE O3Vec_T::Distance(const O3Vec_T &vec) {
	O3Vec_T difference = *this - vec;
	return difference.Length();
}

O3Vec_TT
TYPE O3Vec_T::DistanceSquared(const O3Vec_T &vec) {
	O3Vec_T difference = *this - vec;
	return difference.LengthSquared();	
}

/*******************************************************************/ #pragma mark Setters /*******************************************************************/
///Leniantly interperets objc encodings: don't pass it a value that isn't an array of some primitive type or it'll barf
O3Vec_TT O3Vec_T& O3Vec_T::SetValue(NSArray* val) {
	if (!val) return Set(0);
	UIntP ct = [val count];
	void* b = [val bytesOfType:O3ScalarStructTypeOf(TYPE)];
	SetArray((TYPE*)b, ct);
	free(b);
	return *this;
}

///Fills all elements of a vector with the value x.
O3Vec_TT O3Vec_T& O3Vec_T::Set(TYPE x) {
	int i; for (i=0;i<NUMBER;i++) v[i]=x;
	return *this;
}

///Zero fills any elements not specified. You cannot specify more elements than are in a vector.
O3Vec_TT O3Vec_T& O3Vec_T::Set(TYPE x, TYPE y) {
	O3CompileAssert(NUMBER>=2, "Must have 2 or more dimensions to set a x and a y");
	v[0]=x; 
	v[1]=y; 
	int i; for (i=2;i<NUMBER;i++) v[i]=0;
	return *this;
}

///Zero fills any elements not specified. You cannot specify more elements than are in a vector.
O3Vec_TT O3Vec_T& O3Vec_T::Set(TYPE x, TYPE y, TYPE z) {
	O3CompileAssert(NUMBER>=3, "Must have 3 or more dimensions to set a x, y, and z");
	v[0]=x; 
	v[1]=y; 
	v[2]=z;
	int i; for (i=3;i<NUMBER;i++) v[i]=0;
	return *this;
}

///Zero fills any elements not specified. You cannot specify more elements than are in a vector.
O3Vec_TT O3Vec_T& O3Vec_T::Set(TYPE x, TYPE y, TYPE z, TYPE w) {
	O3CompileAssert(NUMBER>=4, "Must have 4 or more dimensions to set a x, y, z, and w");
	v[0]=x; 
	v[1]=y; 
	v[2]=z; 
	v[3]=w; 
	int i; for (i=4;i<NUMBER;i++) v[i]=0;
	return *this;
}

O3Vec_TT template <typename TYPE2> 
O3Vec_T& O3Vec_T::SetArray(const TYPE2 array, unsigned arraylen) {
	int i;
	int j = O3Min(arraylen, NUMBER);
	for (i=0;i<j;i++) v[i] = array[i];
	for (i=j;i<NUMBER;i++) v[i] = 0;
	return *this;
}

///Sets the receiver's elements to the values of \e vec's elements, filling in 0 anywhere where vec doesn't have a corresponding element
O3Vec_TT
template <typename TYPE2, int SIZE2>
O3Vec_T& O3Vec_T::Set(const O3Vec<TYPE2, SIZE2> &vec) {
	int i; for (i=0;i<SIZE2;i++) v[i] = vec[i];
	for (; i<NUMBER;i++)v[i] = 0;
	return *this;
}

/*******************************************************************/ #pragma mark Meta-Attributes /*******************************************************************/
O3Vec_TT
TYPE O3Vec_T::Length() const {
	TYPE sum = 0;
	int i; for (i=0;i<NUMBER;i++) {
		TYPE value = v[i];
		sum += value*value;
	}
	return sqrt(sum);
}

O3Vec_TT
TYPE O3Vec_T::LengthSquared() const {
	TYPE sum = 0;
	int i; for (i=0;i<NUMBER;i++) {
		TYPE value = v[i];
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

O3Vec_TT template<class T2>
bool O3Vec_T::IsEqualTo(const T2& vec, TYPE tolerance = O3Epsilon(TYPE)) const {
	id self = nil; //O3Optimizable();
	TYPE lengthsq = (*this-vec).LengthSquared();
	return O3Equals(lengthsq, 0., tolerance*2); //Not Strictly Correct
}

O3Vec_TT
double O3Vec_T::Angle(const O3Vec_T& vec) const {
	double cos_a = ((*this)|vec) / sqrt(Length()*vec.Length());
	return abs(acos(cos_a));
}

/*******************************************************************/ #pragma mark Index Operators /*******************************************************************/
O3Vec_TT
TYPE &O3Vec_T::operator[](int index) {
	O3Assert(index<NUMBER, @"Attempt to access index %i of vector with size %i", index, NUMBER);
	return v[index];
}

O3Vec_TT
const TYPE &O3Vec_T::operator[](int index) const {
	O3Assert(index<NUMBER, @"Attempt to access index %i of vector with size %i", index, NUMBER);
	return v[index];
}

/*******************************************************************/ #pragma mark Assignment Operator /*******************************************************************/
O3Vec_TT
template <typename TYPE2>
O3Vec_T& O3Vec_T::operator=(const O3Vec<TYPE2, NUMBER>& v2) {
	int i; for (i=0;i<NUMBER;i++) v[i] = v2[i];
	return *this;
}

/*******************************************************************/ #pragma mark Equality Operators /*******************************************************************/
O3Vec_TT
bool  O3Vec_T::operator==(const O3Vec_T& vec) const {
	int i; for (i=0;i<NUMBER;i++) if (v[i] != vec[i]) return false;
	return true;
}

O3Vec_TT
bool  O3Vec_T::operator!=(const O3Vec_T& vec) const {
	int i; for (i=0;i<NUMBER;i++) if (v[i] == vec[i]) return false;
	return true;
}

O3Vec_TT template <class T2> bool O3Vec_T::equals(const T2 vec) const {
	int i; for (i=0;i<NUMBER;i++) if (v[i] != vec[i]) return false;
	return true;
}


/*******************************************************************/ #pragma mark O3Vec Products /*******************************************************************/
O3Vec_TT
TYPE O3Vec_T::operator|(const O3Vec_T &vec) const { //Dot product
	O3Vec_T
v2; 	//We do it this way in order to allow the compiler to parallelize the following code
	int i; for (i=0;i<NUMBER;i++) v2[i] = vec[i] * v[i];
	TYPE total = 0.0; for (i=0;i<NUMBER;i++) total += v[i];
	return total;
}


O3Vec_TT
O3Vec_T O3Vec_T::operator^(const O3Vec_T &vec) const { //Cross product
	O3CompileAssert(NUMBER==3, "Cannot cross non-3D vectors. Fix if you need to.");
	int X=0, Y=1, Z=2;
	return O3Vec_T(	v[Y] * vec[Z] - v[Z] * vec[Y],
									v[Z] * vec[X] - v[X] * vec[Z],
									v[X] * vec[Y] - v[Y] * vec[X]  );
}

/*******************************************************************/ #pragma mark O3Vec In-Place Products /*******************************************************************/
O3Vec_TT
O3Vec_T& O3Vec_T::operator^=(const O3Vec_T &vec) { //Cross product
	O3CompileAssert(NUMBER==3, "Cannot cross non-3D vectors. Fix if you need to.");
	TYPE NewX = v[Y] * vec[Z] - v[Z] * vec[Y];
	TYPE NewY = v[Z] * vec[X] - v[X] * vec[Z];
	TYPE NewZ = v[X] * vec[Y] - v[Y] * vec[X];
	v[X] = NewX;
	v[Y] = NewY;
	v[Z] = NewZ;
}

/*******************************************************************/ #pragma mark O3Vec Unary Operators /*******************************************************************/
O3Vec_TT
O3Vec_T O3Vec_T::operator+() const {
	O3Vec_T
to_return;
	int i; for (i=0;i<NUMBER;i++) to_return[i] = abs(v[i]);
	return to_return;
}

O3Vec_TT
O3Vec_T O3Vec_T::operator-() const {
	O3Vec_T
to_return;
	int i; for (i=0;i<NUMBER;i++) to_return[i] = -v[i];
	return to_return;
}

/*******************************************************************/ #pragma mark O3Vec - Scaler Operators /*******************************************************************/
O3Vec_TT
O3Vec_T O3Vec_T::operator+(const TYPE scalar) const {
	O3Vec_T
to_return; 
	int i; for (i=0;i<NUMBER;i++) to_return[i] = v[i] + scalar; 
	return to_return;
}

O3Vec_TT
O3Vec_T O3Vec_T::operator-(const TYPE scalar) const {
	O3Vec_T
to_return; 
	int i; for (i=0;i<NUMBER;i++) to_return[i] = v[i] - scalar; 
	return to_return;
}

O3Vec_TT
O3Vec_T O3Vec_T::operator*(const TYPE scalar) const {
	O3Vec_T
to_return; 
	int i; for (i=0;i<NUMBER;i++) to_return[i] = v[i] * scalar; 
	return to_return;
}

O3Vec_TT
O3Vec_T O3Vec_T::operator/(const TYPE scalar) const {
	O3Vec_T
to_return; 
	TYPE reciprocal = O3recip(scalar);
	int i; for (i=0;i<NUMBER;i++) to_return[i] = v[i] * reciprocal; 
	return to_return;
}

/*******************************************************************/ #pragma mark O3Vec - Scaler In-Place Operators /*******************************************************************/
O3Vec_TT
O3Vec_T& O3Vec_T::operator+=(const TYPE scalar) {
	int i; for (i=0;i<NUMBER;i++) v[i] += scalar; 
	return *this;
}

O3Vec_TT
O3Vec_T& O3Vec_T::operator-=(const TYPE scalar) {
	int i; for (i=0;i<NUMBER;i++) v[i] -= scalar; 
	return *this;
}

O3Vec_TT
O3Vec_T& O3Vec_T::operator*=(const TYPE scalar) {
	int i; for (i=0;i<NUMBER;i++) v[i] *= scalar; 
	return *this;
}

O3Vec_TT
O3Vec_T& O3Vec_T::operator/=(const TYPE scalar) {
	int i; for (i=0;i<NUMBER;i++) v[i] /= scalar; 
	return *this;
}

/************************************/ #pragma mark C Array Operators /************************************/
O3Vec_TT
O3Vec_T& O3Vec_T::operator+=(const TYPE* carr) {
	int i; for (i=0;i<NUMBER;i++) v[i] += carr[i]; 
	return *this;
}

/*******************************************************************/ #pragma mark Scalar - O3Vec Operators /*******************************************************************/
O3Vec_TT
O3Vec_T operator+(const TYPE scalar, const O3Vec_T& vec) {
	O3Vec_T
to_return; 
	int i; for (i=0;i<NUMBER;i++) to_return[i] = vec[i] + scalar; 
	return to_return;
}

O3Vec_TT
O3Vec_T operator-(const TYPE scalar, const O3Vec_T& vec) {
	O3Vec_T
to_return; 
	int i; for (i=0;i<NUMBER;i++) to_return[i] = scalar - vec[i]; 
	return to_return;
}

O3Vec_TT
O3Vec_T operator*(const TYPE scalar, const O3Vec_T& vec) {
	O3Vec_T
to_return; 
	int i; for (i=0;i<NUMBER;i++) to_return[i] = scalar * vec[i]; 
	return to_return;
}

O3Vec_TT
O3Vec_T operator/(const TYPE scalar, const O3Vec_T& vec) {
	O3Vec_T
to_return; 
	int i; for (i=0;i<NUMBER;i++) to_return[i] = scalar / vec[i]; 
	return to_return;
}

/*******************************************************************/ #pragma mark O3Vec - O3Vec Operators /*******************************************************************/
O3Vec_TT
O3Vec_T O3Vec_T::operator+(const O3Vec_T& vec) const {
	O3Vec_T
to_return; 
	int i; for (i=0;i<NUMBER;i++) to_return[i] = v[i] + vec[i]; 
	return to_return;
}

O3Vec_TT
O3Vec_T O3Vec_T::operator-(const O3Vec_T& vec) const {
	O3Vec_T
to_return; 
	int i; for (i=0;i<NUMBER;i++) to_return[i] = v[i] - vec[i]; 
	return to_return;
}

O3Vec_TT
O3Vec_T O3Vec_T::operator*(const O3Vec_T& vec) const {
	O3Vec_T
to_return; 
	int i; for (i=0;i<NUMBER;i++) to_return[i] = v[i] * vec[i]; 
	return to_return;
}

O3Vec_TT
O3Vec_T O3Vec_T::operator/(const O3Vec_T& vec) const {
	O3Vec_T
to_return; 
	int i; for (i=0;i<NUMBER;i++) to_return[i] = v[i] / vec[i]; 
	return to_return;
}

/*******************************************************************/ #pragma mark O3Vec - O3Vec In-Place Operators /*******************************************************************/
O3Vec_TT
O3Vec_T& O3Vec_T::operator+=(const O3Vec_T& vec) {
	int i; for (i=0;i<NUMBER;i++) v[i] += vec[i]; 
	return *this;
}

O3Vec_TT
O3Vec_T& O3Vec_T::operator-=(const O3Vec_T& vec) {
	int i; for (i=0;i<NUMBER;i++) v[i] -= vec[i]; 
	return *this;
}

O3Vec_TT
O3Vec_T& O3Vec_T::operator*=(const O3Vec_T& vec) {
	int i; for (i=0;i<NUMBER;i++) v[i] *= vec[i]; 
	return *this;
}

O3Vec_TT
O3Vec_T& O3Vec_T::operator/=(const O3Vec_T& vec) {
	int i; for (i=0;i<NUMBER;i++) v[i] /= vec[i]; 
	return *this;
}

/*******************************************************************/ #pragma mark Accessors /*******************************************************************/
O3Vec_TT
void O3Vec_T::Get(TYPE* x, TYPE* y) const {
	if (x) *x = v[0];
	if (y) *y = v[1];
}	

O3Vec_TT
void O3Vec_T::Get(TYPE* x, TYPE* y, TYPE* z) const {
	if (x) *x = v[0];
	if (y) *y = v[1];
	if (z) *z = v[2];
}

O3Vec_TT
void O3Vec_T::Get(TYPE* x, TYPE* y, TYPE* z, TYPE* w) const {
	if (x) *x = v[0];
	if (y) *y = v[1];
	if (z) *z = v[2];
	if (w) *w = v[3];
}

O3Vec_TT
void O3Vec_T::GetA(TYPE* x, TYPE* y) const {
	*x = v[0];
	*y = v[1];
}	

O3Vec_TT
void O3Vec_T::GetA(TYPE* x, TYPE* y, TYPE* z) const {
	*x = v[0];
	*y = v[1];
	*z = v[2];
}

O3Vec_TT
void O3Vec_T::GetA(TYPE* x, TYPE* y, TYPE* z, TYPE* w) const {
	*x = v[0];
	*y = v[1];
	*z = v[2];
	*w = v[3];
}

/*******************************************************************/ #pragma mark Methods and Method-accessors /*******************************************************************/
O3Vec_TT
O3Vec_T& O3Vec_T::Zero() {
	int i; for (i=0;i<NUMBER;i++) v[i] = 0.;
	return *this;
}

O3Vec_TT
O3Vec_T& O3Vec_T::Normalize() {
	TYPE len = Length();
	TYPE rlength = O3recip(len);
	int i; for (i=0;i<NUMBER;i++) v[i] = rlength*(v[i]);
	return *this;
}

O3Vec_TT
O3Vec_T O3Vec_T::GetNormalized() const {
	O3Vec_T
to_return;
	TYPE rlength = O3recip(Length());
	int i; for (i=0;i<NUMBER;i++) to_return[i] = rlength*(v[i]);
	return to_return;
}

O3Vec_TT
O3Vec_T& O3Vec_T::Floor() {
	int i; for (i=0;i<NUMBER;i++) v[i] = floor(v[i]);
	return *this;
}

O3Vec_TT
O3Vec_T O3Vec_T::GetFloored() const {
	O3Vec_T
to_return;
	int i; for (i=0;i<NUMBER;i++) to_return[i] = floor(v[i]);
	return to_return;
}

O3Vec_TT
O3Vec_T& O3Vec_T::Ceil() {
	int i; for (i=0;i<NUMBER;i++) v[i] = ceil(v[i]);
	return *this;
}

O3Vec_TT
O3Vec_T O3Vec_T::GetCeiled() const {
	O3Vec_T
to_return;
	int i; for (i=0;i<NUMBER;i++) to_return[i] = ceil(v[i]);
	return to_return;
}

O3Vec_TT
O3Vec_T& O3Vec_T::Round() {
	int i; for (i=0;i<NUMBER;i++) v[i] = round(v[i]);
	return *this;
}

O3Vec_TT
O3Vec_T O3Vec_T::GetRounded() const {
	O3Vec_T
to_return;
	int i; for (i=0;i<NUMBER;i++) to_return[i] = round(v[i]);
	return to_return;
}

O3Vec_TT
O3Vec_T& O3Vec_T::Clamp(TYPE min, TYPE max) {
	int i; for (i=0;i<NUMBER;i++) v[i] = clamp(v[i], min, max);
	return *this;
}

O3Vec_TT
O3Vec_T O3Vec_T::GetClamped(TYPE min, TYPE max) const {
	O3Vec_T
to_return;
	int i; for (i=0;i<NUMBER;i++) to_return[i] = clamp(v[i], min, max);
	return to_return;
}

O3Vec_TT
O3Vec_T& O3Vec_T::Abs() {
	int i; for (i=0;i<NUMBER;i++) v[i] = abs(v[i]);
	return *this;
}

O3Vec_TT
O3Vec_T O3Vec_T::GetAbs() const {
	O3Vec_T
to_return;
	int i; for (i=0;i<NUMBER;i++) to_return[i] = abs(v[i]);
	return to_return;
}

O3Vec_TT
O3Vec_T& O3Vec_T::Negate() {
	int i; for (i=0;i<NUMBER;i++) v[i] = -v[i];
	return *this;
}

O3Vec_TT
O3Vec_T O3Vec_T::GetNegated() const {
	O3Vec_T
to_return;
	int i; for (i=0;i<NUMBER;i++) to_return[i] = -v[i];
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
#endif /*defined(__cplusplus)*/
