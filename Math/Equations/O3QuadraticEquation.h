#ifdef __cplusplus
/**
 *  @file O3QuadraticEquation.h
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#pragma once
#include "O3Vector.h"

template <typename TYPE>
class O3QuadraticEquation : protected O3Vec<TYPE, 3> {
	typedef O3Vec<TYPE, 3> vec;
	
public: //Constructors
	O3QuadraticEquation(TYPE a, TYPE b, TYPE c): vec(a,b,c) {};
	O3QuadraticEquation(const O3QuadraticEquation& other): vec(other) {};
	O3QuadraticEquation(TYPE y_intercept, TYPE high_x_intercept) {Set(y_intercept, high_x_intercept);} ///<Create a quadratic equation from an x and a y intercept (useful for lighting)
	
public: //Inspectors
	TYPE& A() {return vec::X();}
	TYPE& B() {return vec::Y();}
	TYPE& C() {return vec::Z();}
	TYPE GetA() const {return vec::GetX();}
	TYPE GetB() const {return vec::GetY();}
	TYPE GetC() const {return vec::GetZ();}
	void Get(TYPE* a, TYPE* b, TYPE* c) {vec::Get(a,b,c);}
	void GetA(TYPE* a, TYPE* b, TYPE* c) {vec::GetA(a,b,c);}
	
public: //Operators
	TYPE operator()(TYPE value) {return A()*value*value + B()*value + C();}
	
public: //Meta-accessors
	void GetXIntercepts(double* a, double* b, const double x = 0.) const; ///<Returns the points at which the receiver crosses the horizontal line y=x (x defaults to 0, or the X-axis).
	double GetHighXIntercept(const double x = 0.) const; //<Returns the higher point at which the receiver crosses the horizontal line y=x (x defaults to 0, or the X-axis).
	
public: //Setters
	O3QuadraticEquation& SetA(TYPE val) {vec::X() = val; return *this;}
	O3QuadraticEquation& SetB(TYPE val) {vec::Y() = val; return *this;}
	O3QuadraticEquation& SetC(TYPE val) {vec::Z() = val; return *this;}
	O3QuadraticEquation& Set(const TYPE a, const TYPE b, const TYPE c) {vec::Set(a,b,c); return *this;}
	O3QuadraticEquation& Set(TYPE high_x_intercept, TYPE y_intercept);
};

typedef O3QuadraticEquation<real> QuadraticEquationR;
#endif /*defined(__cplusplus)*/
