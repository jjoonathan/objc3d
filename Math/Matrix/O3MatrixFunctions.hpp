#ifdef __cplusplus
/**
 *  @file O3MatrixFunctions.hpp
 *  @license MIT License (see LICENSE.txt)
 *  @date 2/3/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#include "O3Rotation.h"
#include "O3Scale.h"
#include "O3Translation.h"

/*******************************************************************/ #pragma mark O3Mat-O3Vec Math /*******************************************************************/
template <typename TYPE, int R, int C>
O3Vec<TYPE, R> operator*(const O3Mat<TYPE, R, C>& m, const O3Vec<TYPE, C>& v) {
	int i,j;
	O3Vec<TYPE, R> to_return;
	for (i=0;i<R;i++) {
		TYPE accumulator = 0;
		for (j=0;j<C;j++)
			accumulator += m(i,j) * v[j];
		to_return[i] = accumulator;
	}
	return to_return;
}

template <typename TYPE, int R, int C>
O3Vec<TYPE, C> operator*(const O3Vec<TYPE, R>& v, const O3Mat<TYPE, R, C>& m) {
	int i,j;
	O3Vec<TYPE, C> to_return;
	for (i=0;i<C;i++) {
		TYPE accumulator = 0;
		for (j=0;j<R;j++)
			accumulator += m(j,i) * v[j];
		to_return[i] = accumulator;
	}
	return to_return;
}

/*******************************************************************/ #pragma mark Other O3Mat Functions /*******************************************************************/
///An efficient specialization of O3Swap for matricies
template<> template <typename TYPE, int ROWS, int COLUMNS> struct O3Swap_implementation<O3Mat<TYPE,ROWS,COLUMNS> > {
	static void swap(O3Mat<TYPE,ROWS,COLUMNS>& m1, O3Mat<TYPE,ROWS,COLUMNS>& m2) {
		int i;
		int j = ROWS*COLUMNS;
		for (i=0;i<j;i++) {
			TYPE TMP = m1(i);
			m1(i) = m2(i);
			m2(i) = TMP;
		}
	}
};

/*******************************************************************/ #pragma mark O3Translation /*******************************************************************/
template <typename TYPE>
O3Mat<TYPE, 4, 4> operator+(const O3Mat<TYPE, 4, 4>& mat, const O3Translation3& trans) {
	O3Mat<TYPE, 4, 4> to_return(mat); to_return.Zero();
	TYPE tx=trans.GetX(),  ty=trans.GetY(),  tz=trans.GetZ();
	
	TYPE mat33 = mat[3][3];
	if (O3Equals(mat33,1.,O3Epsilon(TYPE))) {
		to_return[3][0] += tx;
		to_return[3][1] += ty;
		to_return[3][2] += tz;
	} else {
		to_return[3][0] += tx*mat33;
		to_return[3][1] += ty*mat33;
		to_return[3][2] += tz*mat33;
	}
	
	TYPE mat30 = mat[0][3];
	if (!O3Equals(mat30, 0., 3*O3Epsilon(TYPE))) {
		to_return[0][0] += tx*mat30;
		to_return[0][1] += ty*mat30;
		to_return[0][2] += tz*mat30;
	}
	
	TYPE mat31 = mat[1][3];
	if (!O3Equals(mat31, 0., 3*O3Epsilon(TYPE))) {
		to_return[1][0] += tx*mat31;
		to_return[1][1] += ty*mat31;
		to_return[1][2] += tz*mat31;
	}
	
	TYPE mat32 = mat[2][3];
	if (!O3Equals(mat31, 0., 3*O3Epsilon(TYPE))) {
		to_return[2][0] += tx*mat32;
		to_return[2][1] += ty*mat32;
		to_return[2][2] += tz*mat32;
	}
	
	return to_return;
}

template <typename TYPE>
O3Mat<TYPE, 4, 4>& operator+=(O3Mat<TYPE, 4, 4>& mat, const O3Translation3& trans) {
	TYPE tx=trans.GetX(),  ty=trans.GetY(),  tz=trans.GetZ();

	TYPE mat33 = mat[3][3];
	if (O3Equals(mat33,1.,O3Epsilon(TYPE))) {
		mat[3][0] += tx;
		mat[3][1] += ty;
		mat[3][2] += tz;
	} else {
		mat[3][0] += tx*mat33;
		mat[3][1] += ty*mat33;
		mat[3][2] += tz*mat33;
	}
	
	TYPE mat30 = mat[0][3];
	if (!O3Equals(mat30, 0., 3*O3Epsilon(TYPE))) {
		mat[0][0] += tx*mat30;
		mat[0][1] += ty*mat30;
		mat[0][2] += tz*mat30;
	}
	
	TYPE mat31 = mat[1][3];
	if (!O3Equals(mat31, 0., 3*O3Epsilon(TYPE))) {
		mat[1][0] += tx*mat31;
		mat[1][1] += ty*mat31;
		mat[1][2] += tz*mat31;
	}
	
	TYPE mat32 = mat[2][3];
	if (!O3Equals(mat31, 0., 3*O3Epsilon(TYPE))) {
		mat[2][0] += tx*mat32;
		mat[2][1] += ty*mat32;
		mat[2][2] += tz*mat32;
	}
	
	return mat;
}

template <typename TYPE> O3Mat<TYPE, 4, 4> operator-(const O3Mat<TYPE, 4, 4> mat, const O3Translation3& trans) {return operator+(mat, (O3Translation3)-trans);}
template <typename TYPE> O3Mat<TYPE, 4, 4>& operator-=(O3Mat<TYPE, 4, 4>& mat, const O3Translation3& trans) {return operator+=(mat, (O3Translation3)-trans);}


/*******************************************************************/ #pragma mark Scaling /*******************************************************************/
template <typename TYPE>
O3Mat<TYPE, 4, 4> operator+(const O3Mat<TYPE, 4, 4>& mat, const O3Scale3& scale) {
	O3Mat<TYPE, 4, 4> to_return(mat); to_return.Zero();
	
	double x = scale.GetX();
	double y = scale.GetY();
	double z = scale.GetZ();
	
	to_return[0][0] *= x;
	to_return[0][1] *= y;
	to_return[0][2] *= z;
	
	to_return[1][0] *= x;
	to_return[1][1] *= y;
	to_return[1][2] *= z;
	
	to_return[1][0] *= x;
	to_return[1][1] *= y;
	to_return[1][2] *= z;
	
	to_return[1][0] *= x;
	to_return[1][1] *= y;
	to_return[1][2] *= z;
	
	return to_return;
}

template <typename TYPE>
O3Mat<TYPE, 4, 4>& operator+=(O3Mat<TYPE, 4, 4>& mat, const O3Scale3& scale) {	
	double x = scale.GetX();
	double y = scale.GetY();
	double z = scale.GetZ();
	
	mat[0][0] *= x;
	mat[0][1] *= y;
	mat[0][2] *= z;
	
	mat[1][0] *= x;
	mat[1][1] *= y;
	mat[1][2] *= z;
	
	mat[1][0] *= x;
	mat[1][1] *= y;
	mat[1][2] *= z;
	
	mat[1][0] *= x;
	mat[1][1] *= y;
	mat[1][2] *= z;
	
	return mat;
}

template <typename TYPE> O3Mat<TYPE, 4, 4> operator-(const O3Mat<TYPE, 4, 4>& mat, const O3Scale3& scale) {return operator+(mat, (O3Scale3)-scale);}
template <typename TYPE> O3Mat<TYPE, 4, 4>& operator-=(O3Mat<TYPE, 4, 4>& mat, const O3Scale3& scale)     {return operator+=(mat, (O3Scale3)-scale);}



/*******************************************************************/ #pragma mark Rotation /*******************************************************************/
template <typename TYPE>
O3Mat<TYPE, 4, 4> operator+(const O3Mat<TYPE, 4, 4>& mat, const O3Rotation3& rot) {
	return mat*rot.GetMatrix(YES);
}

template <typename TYPE>
O3Mat<TYPE, 4, 4>& operator+=(O3Mat<TYPE, 4, 4>& mat, const O3Rotation3& rot) {
	mat=mat*rot.GetMatrix(YES);
	return mat;
}

template <typename TYPE>
O3Mat<TYPE, 4, 4> operator-(const O3Mat<TYPE, 4, 4>& mat, const O3Rotation3& rot) {
	return mat*(-rot).GetMatrix(YES);
}

template <typename TYPE>
O3Mat<TYPE, 4, 4>& operator-=(O3Mat<TYPE, 4, 4>& mat, const O3Rotation3& rot) {
	mat=mat*(-rot).GetMatrix(YES);
	return mat;
}
#endif /*defined(__cplusplus)*/
