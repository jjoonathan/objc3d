#ifdef __cplusplus
/**
 *  @file O3QuadraticEquation.hpp
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
template <typename TYPE>
void O3QuadraticEquation<TYPE>::GetXIntercepts(double* r1, double* r2, const double x) const {
	double a=GetA(), b=GetB(), c=GetC()-x;
	double sqrt_b2_minus_4ac = sqrt((b*b)-(4*a*c));
	double recip_2a = O3recip(2*a);
	if (r1) *r1 = (-b + sqrt_b2_minus_4ac) * recip_2a;
	if (r2) *r2 = (-b - sqrt_b2_minus_4ac) * recip_2a;
}

template <typename TYPE>
double O3QuadraticEquation<TYPE>::GetHighXIntercept(const double x) const {
	double a=GetA(), b=GetB(), c=GetC()-x;
	double sqrt_b2_minus_4ac = sqrt((b*b)-(4*a*c));
	double recip_2a = O3recip(2*a);
	return (-b - sqrt_b2_minus_4ac) * recip_2a;
}

template <typename TYPE>
O3QuadraticEquation<TYPE>& O3QuadraticEquation<TYPE>::Set(TYPE high_x_intercept, TYPE y_intercept) {
	double x_sq = -( O3recip(high_x_intercept*high_x_intercept) ) * y_intercept;
	double constant = y_intercept;
	SetA(x_sq);
	SetB(0);
	SetC(constant);
	return *this;
}
#endif /*defined(__cplusplus)*/
