#pragma once
#ifdef __cplusplus
/**
 *  @file O3MatrixFunctions.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 2/3/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
template <typename TYPE, int D> class O3Translation;
typedef O3Translation<double,3> O3Translation3;
template <typename TYPE, int D> class O3Scale;
typedef O3Scale<double,3> O3Scale3;
class O3Rotation3;

template <typename TYPE, int SIZE>
O3Vec<TYPE, SIZE> operator*(const O3Mat<TYPE, SIZE, SIZE> m, const O3Vec<TYPE, SIZE> v);

/* Can't redeclare structs
template <typename TYPE, int ROWS, int COLUMNS> struct swap_implementation<O3Mat<TYPE,ROWS,COLUMNS> > {
	static void O3swap(O3Mat<TYPE,ROWS,COLUMNS>& m1, O3Mat<TYPE,ROWS,COLUMNS>& m2);
};*/

template <typename TYPE>	O3Mat<TYPE, 4, 4> operator+(const O3Mat<TYPE, 4, 4>& mat, const O3Translation3& trans);
template <typename TYPE>	O3Mat<TYPE, 4, 4>& operator+=(O3Mat<TYPE, 4, 4>& mat, const O3Translation3& trans);
template <typename TYPE>	O3Mat<TYPE, 4, 4> operator-(const O3Mat<TYPE, 4, 4> mat, const O3Translation3& trans);
template <typename TYPE>	O3Mat<TYPE, 4, 4>& operator-=(O3Mat<TYPE, 4, 4>& mat, const O3Translation3& trans);
template <typename TYPE>	O3Mat<TYPE, 4, 4> operator+(const O3Mat<TYPE, 4, 4>& mat, const O3Scale3& scale);
template <typename TYPE>	O3Mat<TYPE, 4, 4>& operator+=(O3Mat<TYPE, 4, 4>& mat, const O3Scale3& scale);
template <typename TYPE>	O3Mat<TYPE, 4, 4> operator-(const O3Mat<TYPE, 4, 4>& mat, const O3Scale3& scale);
template <typename TYPE>	O3Mat<TYPE, 4, 4>& operator-=(O3Mat<TYPE, 4, 4>& mat, const O3Scale3& scale);
template <typename TYPE>	O3Mat<TYPE, 4, 4> operator+(const O3Mat<TYPE, 4, 4>& mat, const O3Rotation3& rot);
template <typename TYPE>	O3Mat<TYPE, 4, 4>& operator+=(O3Mat<TYPE, 4, 4>& mat, const O3Rotation3& rot);
template <typename TYPE>	O3Mat<TYPE, 4, 4> operator-(const O3Mat<TYPE, 4, 4>& mat, const O3Rotation3& rot);
template <typename TYPE>	O3Mat<TYPE, 4, 4>& operator-=(O3Mat<TYPE, 4, 4>& mat, const O3Rotation3& rot);
#endif /*defined(__cplusplus)*/
