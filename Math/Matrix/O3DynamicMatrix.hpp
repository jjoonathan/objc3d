#pragma once
/**
 *  @file O3DynamicMatrix.hpp
 *  @license MIT License (see LICENSE.txt)
 *  @date 9/4/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
template <typename T, int R, int C>
O3DynamicMatrix::O3DynamicMatrix(const O3Mat<T,R,C>& mat) {
	SetISA();
	mMatrixData = mat.Data();
	mType = NULL;
	mElementType = @encode(T);
	mRows = R;
	mColumns = C;
	mSize = sizeof(mat.Values);
	mShouldFreeMatrixDat =  NO;
	mShouldFreeType      =  NO;
	mShouldFreeEleType   =  NO;
}

template <typename T, int COLS>
O3DynamicMatrix::O3DynamicMatrix(const O3Vec<T, COLS>& vec) {
	SetISA();
	mMatrixData = (void*)vec.Data();
	mType = NULL;
	mElementType = @encode(T);
	mRows = 1;
	mColumns = vec.Size();
	mSize = sizeof(vec.Values);			
	mShouldFreeMatrixDat =  NO;
	mShouldFreeType      =  NO;
	mShouldFreeEleType   =  NO;
}

///Access elements of the matrix as so: <code>O3DynamicMatrix mat(stuff); mat.ElementOfTypeAt<double>(row,col);</code>. Replace "double" with the actual type of data you want to get out of it.
template <typename T>
const T O3DynamicMatrix::ElementOfTypeAt(int row, int col) const {
	O3Assert(row<mRows && col<mColumns, @"Cannot access item (%i,%i) of dynamic matrix with dimensions (%i,%i).",row,col,mRows,mColumns);
	int x = mRows*col + row; //This dependency on the major-ness of O3Matrix is reflected in the O3Matrix comments, and is therefore OK.
	switch (mElementType[0]) {
		case 'f':
			return ((float*)mMatrixData)[x];
		case 'd':
			return ((double*)mMatrixData)[x];
		case 'i':
			return ((int*)mMatrixData)[x];
		case 'c':
			return ((char*)mMatrixData)[x];
		case 's':
			return ((short*)mMatrixData)[x];
		case 'l':
			return ((long*)mMatrixData)[x];
		case 'q':
			return ((long long*)mMatrixData)[x];
		case 'C':
			return ((unsigned char*)mMatrixData)[x];
		case 'I':
			return ((unsigned int*)mMatrixData)[x];
		case 'S':
			return ((unsigned short*)mMatrixData)[x];
		case 'L':
			return ((unsigned long*)mMatrixData)[x];
		case 'Q':
			return ((unsigned long long*)mMatrixData)[x];
		default:
			O3Assert(false , @"Unknown objective C type encoding for DynamicVector element fetcher");
	}
	return 0;
}

template <typename T, int R, int C>
O3Mat<T,R,C>::operator const O3DynamicMatrix() const {	
	return O3DynamicMatrix(*this);
}

template <typename T, int S>
O3Mat<T,S,S>::operator const O3DynamicMatrix() const {	
	return O3DynamicMatrix(*this);
}

O3Mat_sq_TT
O3Mat_sq_T& O3Mat_sq_T::Set(const O3DynamicMatrix& dynm) {
	int rr = dynm.Rows();
	int cc = dynm.Columns();
	switch(*dynm.ElementType()) {
		case 'c':
			Set((const char*)dynm.MatrixData(), true, rr, cc);
			break;
		case 'C':
			Set((const unsigned char*)dynm.MatrixData(), true, rr, cc);
			break;				
		case 'i':
			Set((const int*)dynm.MatrixData(), true, rr, cc);
			break;
		case 'I':
			Set((const unsigned int*)dynm.MatrixData(), true, rr, cc);
			break;	
		case 's':
			Set((const short*)dynm.MatrixData(), true, rr, cc);
			break;
		case 'S':
			Set((const unsigned short*)dynm.MatrixData(), true, rr, cc);
			break;				
		case 'l':
			Set((const long*)dynm.MatrixData(), true, rr, cc);
			break;
		case 'L':
			Set((const unsigned long*)dynm.MatrixData(), true, rr, cc);
			break;	
		case 'q':
			Set((const long long*)dynm.MatrixData(), true, rr, cc);
			break;
		case 'Q':
			Set((const unsigned long long*)dynm.MatrixData(), true, rr, cc);
			break;	
		case 'f':
			Set((const float*)dynm.MatrixData(), true, rr, cc);
			break;
		case 'd':
			Set((const double*)dynm.MatrixData(), true, rr, cc);
			break;
		default:
			O3Assert(false , @"Unknown data type \"%s\" in dynamic matrix -> square matrix", dynm.ElementType());
	}
	return *this;
}

O3Mat_TT
O3Mat_T& O3Mat_T::Set(const O3DynamicMatrix& dynm) {
	int rr = dynm.Rows();
	int cc = dynm.Columns();
	switch(*dynm.ElementType()) {
		case 'c':
			Set((const char*)dynm.MatrixData(), true, rr, cc);
			break;
		case 'C':
			Set((const unsigned char*)dynm.MatrixData(), true, rr, cc);
			break;				
		case 'i':
			Set((const int*)dynm.MatrixData(), true, rr, cc);
			break;
		case 'I':
			Set((const unsigned int*)dynm.MatrixData(), true, rr, cc);
			break;	
		case 's':
			Set((const short*)dynm.MatrixData(), true, rr, cc);
			break;
		case 'S':
			Set((const unsigned short*)dynm.MatrixData(), true, rr, cc);
			break;				
		case 'l':
			Set((const long*)dynm.MatrixData(), true, rr, cc);
			break;
		case 'L':
			Set((const unsigned long*)dynm.MatrixData(), true, rr, cc);
			break;	
		case 'q':
			Set((const long long*)dynm.MatrixData(), true, rr, cc);
			break;
		case 'Q':
			Set((const unsigned long long*)dynm.MatrixData(), true, rr, cc);
			break;	
		case 'f':
			Set((const float*)dynm.MatrixData(), true, rr, cc);
			break;
		case 'd':
			Set((const double*)dynm.MatrixData(), true, rr, cc);
			break;
		default:
			O3Assert(false , @"Unknown element type \"%s\" in dynamic matrix -> square matrix", dynm.ElementType());
	}
	return *this;
}

template <typename T> void O3DynamicMatrix::SetElementAtTo(int row, int col, T val) {
	O3Assert(row<mRows && col<mColumns, @"Cannot access item (%i,%i) of dynamic matrix with dimensions (%i,%i).",row,col,mRows,mColumns);
	int x = mRows*col + row; //This dependency on the major-ness of O3Mat is reflected in the O3Mat  comments, and is therefore OK. There is another below.
	switch(*ElementType()) {
		case 'c':
			((const char*)MatrixData())[x] = val;
			break;
		case 'C':
			((const unsigned char*)MatrixData())[x] = val;
			break;				
		case 'i':
			((const int*)MatrixData())[x] = val;
			break;
		case 'I':
			((const unsigned int*)MatrixData())[x] = val;
			break;	
		case 's':
			((const short*)MatrixData())[x] = val;
			break;
		case 'S':
			((const unsigned short*)MatrixData())[x] = val;
			break;				
		case 'l':
			((const long*)MatrixData())[x] = val;
			break;
		case 'L':
			((const unsigned long*)MatrixData())[x] = val;
			break;	
		case 'q':
			((const long long*)MatrixData())[x] = val;
			break;
		case 'Q':
			((const unsigned long long*)MatrixData())[x] = val;
			break;	
		case 'f':
			((const float*)MatrixData())[x] = val;
			break;
		case 'd':
			((const double*)MatrixData())[x] = val;
			break;
		default:
			O3Assert(false , @"Unknown element type \"%s\" in O3DynamicMatrix::SetElementAtTo()", ElementType());
	}
}

template <typename T>
void O3DynamicMatrix::SetToType(const O3DynamicMatrix& other) {
	int r,c;
	int rr = O3Min(Rows(), other.Rows());
	int cc = O3Min(Columns(), other.Columns());
	T* dat = (T*)MatrixData();
	for (r=0; r<rr; r++) {
		for (c=0; c<cc; c++) {
			dat[mRows*c+r] = other.ElementOfTypeAt<T>(r,c); //This dependency on the major-ness of O3Mat is reflected in the O3Mat  comments.
		}
	}
	for (; r<mRows; r++) for (c=0; c<cc; c++) dat[mRows*c+r] = 0; //Fill in empty space with 0s
	for (c=cc; c<mColumns; c++) for (r=0; r<mRows; r++) dat[mRows*c+r] = 0;
	if (mRows==mColumns) {
		r = mRows;
		c = mColumns;
		while (--r>=rr && --c>=cc) dat[mRows*c+r] = 1; //Fill in diagonal with 1s
	}	
}
