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
template <typename TYPE, int SIZE>
O3Vec<TYPE, SIZE> operator*(const O3Mat<TYPE, SIZE, SIZE> m, const O3Vec<TYPE, SIZE> v) {
	int i,j;
	O3Vec<TYPE, SIZE> to_return;
	for (i=0;i<SIZE;i++) {
		TYPE accumulator = 0;
		for (j=0;j<SIZE;j++)
			accumulator += m(i,j) * v[j];
		to_return[i] = accumulator;
	}
	return to_return;
}

/*******************************************************************/ #pragma mark Other O3Mat Functions /*******************************************************************/
///An efficient specialization of O3swap for matricies
template<> template <typename TYPE, int ROWS, int COLUMNS> struct O3swap_implementation<O3Mat<TYPE,ROWS,COLUMNS> > {
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
	
	TYPE mat33 = mat[3][3];
	if (O3Equals(mat33,1.,O3Epsilon(TYPE))) {
		to_return[0][3] += trans.GetX();
		to_return[1][3] += trans.GetY();
		to_return[2][3] += trans.GetZ();
	} else {
		to_return[0][3] += trans.GetX()*mat33;
		to_return[1][3] += trans.GetY()*mat33;
		to_return[2][3] += trans.GetZ()*mat33;
	}
	
	TYPE mat30 = mat[3][0];
	if (!O3Equals(mat30, 0., 3*O3Epsilon(TYPE))) {
		to_return[0][0] += trans.GetX()*mat30;
		to_return[1][0] += trans.GetY()*mat30;
		to_return[2][0] += trans.GetZ()*mat30;
	}
	
	TYPE mat31 = mat[3][1];
	if (!O3Equals(mat31, 0., 3*O3Epsilon(TYPE))) {
		to_return[0][1] += trans.GetX()*mat31;
		to_return[1][1] += trans.GetY()*mat31;
		to_return[2][1] += trans.GetZ()*mat31;
	}
	
	TYPE mat32 = mat[3][2];
	if (!O3Equals(mat31, 0., 3*O3Epsilon(TYPE))) {
		to_return[0][2] += trans.GetX()*mat32;
		to_return[1][2] += trans.GetY()*mat32;
		to_return[2][2] += trans.GetZ()*mat32;
	}
	
	return to_return;
}

template <typename TYPE>
O3Mat<TYPE, 4, 4>& operator+=(O3Mat<TYPE, 4, 4>& mat, const O3Translation3& trans) {
	TYPE mat33 = mat[3][3];
	if (O3Equals(mat33,1.,O3Epsilon(TYPE))) {
		mat[0][3] += trans.GetX();
		mat[1][3] += trans.GetY();
		mat[2][3] += trans.GetZ();
	} else {
		mat[0][3] += trans.GetX()*mat33;
		mat[1][3] += trans.GetY()*mat33;
		mat[2][3] += trans.GetZ()*mat33;
	}
	
	TYPE mat30 = mat[3][0];
	if (!O3Equals(mat30, 0., 3*O3Epsilon(TYPE))) {
		mat[0][0] += trans.GetX()*mat30;
		mat[1][0] += trans.GetY()*mat30;
		mat[2][0] += trans.GetZ()*mat30;
	}
	
	TYPE mat31 = mat[3][1];
	if (!O3Equals(mat31, 0., 3*O3Epsilon(TYPE))) {
		mat[0][1] += trans.GetX()*mat31;
		mat[1][1] += trans.GetY()*mat31;
		mat[2][1] += trans.GetZ()*mat31;
	}
	
	TYPE mat32 = mat[3][2];
	if (!O3Equals(mat31, 0., 3*O3Epsilon(TYPE))) {
		mat[0][2] += trans.GetX()*mat32;
		mat[1][2] += trans.GetY()*mat32;
		mat[2][2] += trans.GetZ()*mat32;
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
	to_return[1][0] *= y;
	to_return[2][0] *= z;
	
	to_return[0][1] *= x;
	to_return[1][1] *= y;
	to_return[2][1] *= z;
	
	to_return[0][1] *= x;
	to_return[1][1] *= y;
	to_return[2][1] *= z;
	
	to_return[0][1] *= x;
	to_return[1][1] *= y;
	to_return[2][1] *= z;
	
	return to_return;
}

template <typename TYPE>
O3Mat<TYPE, 4, 4>& operator+=(O3Mat<TYPE, 4, 4>& mat, const O3Scale3& scale) {	
	double x = scale.GetX();
	double y = scale.GetY();
	double z = scale.GetZ();
	
	mat[0][0] *= x;
	mat[1][0] *= y;
	mat[2][0] *= z;
	
	mat[0][1] *= x;
	mat[1][1] *= y;
	mat[2][1] *= z;
	
	mat[0][1] *= x;
	mat[1][1] *= y;
	mat[2][1] *= z;
	
	mat[0][1] *= x;
	mat[1][1] *= y;
	mat[2][1] *= z;
	
	return mat;
}

template <typename TYPE> O3Mat<TYPE, 4, 4> operator-(const O3Mat<TYPE, 4, 4>& mat, const O3Scale3& scale) {return operator+(mat, (O3Scale3)-scale);}
template <typename TYPE> O3Mat<TYPE, 4, 4>& operator-=(O3Mat<TYPE, 4, 4>& mat, const O3Scale3& scale)     {return operator+=(mat, (O3Scale3)-scale);}



/*******************************************************************/ #pragma mark Rotation /*******************************************************************/
template <typename TYPE>
O3Mat<TYPE, 4, 4> operator+(const O3Mat<TYPE, 4, 4>& mat, const O3Rotation3& rot) {
	return rot.GetMatrix(YES)*mat;
}

template <typename TYPE>
O3Mat<TYPE, 4, 4>& operator+=(O3Mat<TYPE, 4, 4>& mat, const O3Rotation3& rot) {
	mat=rot.GetMatrix(YES)*mat;
	return mat;
}

template <typename TYPE>
O3Mat<TYPE, 4, 4> operator-(const O3Mat<TYPE, 4, 4>& mat, const O3Rotation3& rot) {
	return (-rot).GetMatrix(YES)*mat;
}

template <typename TYPE>
O3Mat<TYPE, 4, 4>& operator-=(O3Mat<TYPE, 4, 4>& mat, const O3Rotation3& rot) {
	mat=(-rot).GetMatrix(YES)*mat;
	return mat;
}
#endif /*defined(__cplusplus)*/
