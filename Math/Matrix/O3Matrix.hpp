/**
 *  @file O3Matrix.hpp
 *  @license MIT License (see LICENSE.txt)
 *  @date 9/4/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
using namespace ObjC3D::Math;

/*******************************************************************/ #pragma mark Constructors /*******************************************************************/
O3Mat_TT
/*static*/ O3Mat_T  O3Mat_T::GetZero() {
	O3Mat_T to_return;
	to_return.Zero();
	return to_return;
}

///@note If there is a difference in dimensionality between \e array and the receiver, the receiver will fill as much of itself as it can from \e array, then pad the rest with identity values.
///@param arows If \e array has a different dimensionality than the receiver, specify the number of rows in \e array here.
///@param acols If \e array has a different dimensionality than the receiver, specify the number of columns in \e array here.
///@todo O3Optimizable()
O3Mat_TT2
O3Mat_T& O3Mat_T::Set(const TYPE2 *array, bool row_major, unsigned arows, unsigned acols) {
	if (!row_major || arows!=ROWS || acols!=COLUMNS) {
		int row, col;
		if (arows>ROWS) arows=ROWS;
		if (acols>COLUMNS) acols=COLUMNS;
		for (row=0;row<arows;row++)
			for (col=0;col<acols;col++)
				operator()(row,col) = (row_major)? array[row + col*arows] : array[col + row*acols];
		for (row=arows;row<ROWS;row++)
			for (col=acols;col<COLUMNS;col++)
				operator()(row, col) = (row==col)? 1 : 0;
	} else {
		int i;
		for (i=0;i<(ROWS*COLUMNS);i++)
			operator()(i) = array[i];
	}
	return *this;
}

O3Mat_TT2
O3Mat_T& O3Mat_T::Set(const O3Mat_T2& other_matrix) {
	int i;
	int j = ROWS * COLUMNS;
	const TYPE *other_mat = other_matrix.Values;
	for (i=0;i<j;i++) operator()(i) = other_mat(i);
	return *this;
}

/*******************************************************************/ #pragma mark Index Operators /*******************************************************************/
O3Mat_TT
typename O3Mat_T::RowAccessor O3Mat_T::operator[](int row) {
	return RowAccessor(this, row);
}

O3Mat_TT
const typename O3Mat_T::RowAccessor O3Mat_T::operator[](int row) const {
	return RowAccessor(const_cast<O3Mat*>(this), row);
}

///@note If you change these, you should change the accessor in DynamicMatrix as well
O3Mat_TT
TYPE& O3Mat_T::operator()(int row, int column) {
	return Values[ROWS * column + row];
}

///@note If you change these, you should change the accessor in DynamicMatrix as well
O3Mat_TT
const TYPE& O3Mat_T::operator()(int row, int column) const {
	return Values[ROWS * column + row];
}

O3Mat_TT
TYPE& O3Mat_T::operator()(int index) {
	return Values[index];
}

O3Mat_TT
const TYPE& O3Mat_T::operator()(int index) const {
	return Values[index];
}

/*******************************************************************/ #pragma mark Equality Operators /*******************************************************************/
O3Mat_TT
O3Mat_T& O3Mat_T::operator=(const O3Mat_T& m) {
	int i;
	for (i=0;i<(ROWS*COLUMNS);i++)
		operator()(i) = m(i);
}

O3Mat_TT
bool O3Mat_T::operator==(const O3Mat_T& m) const {
	int i;
	for (i=0;i<(ROWS*COLUMNS);i++) {
		if (operator()(i) != m(i)) return false;
	}
	return true;
}

O3Mat_TT
bool O3Mat_T::operator!=(const O3Mat_T& m) const {
	return !operator==(m);
}

/*******************************************************************/ #pragma mark O3Mat-Scalar Operators /*******************************************************************/
///Adds scalar to every element of m1.
template <typename TYPE, int ROWS, int COLUMNS>
O3Mat_T operator+(const O3Mat_T& m1, TYPE scalar) {
	int i;
	int j = ROWS*COLUMNS;
	O3Mat_T to_return;
	for (i=0;i<j;i++) to_return(i) = m1(i) + scalar;
	return to_return;
}

///Subtracts scalar from every element of m1.
template <typename TYPE, int ROWS, int COLUMNS>
O3Mat_T operator-(const O3Mat_T& m1, TYPE scalar) {
	int i;
	int j = ROWS*COLUMNS;
	O3Mat_T to_return;
	for (i=0;i<j;i++) to_return(i) = m1(i) - scalar;
	return to_return;
}

///Multiplies every element of m1 by scalar.
template <typename TYPE, int ROWS, int COLUMNS>
O3Mat_T operator*(const O3Mat_T& m1, TYPE scalar) {
	int i;
	int j = ROWS*COLUMNS;
	O3Mat_T to_return;
	for (i=0;i<j;i++) to_return(i) = m1(i) * scalar;
	return to_return;
}

///Divides every element of m1 by scalar.
template <typename TYPE, int ROWS, int COLUMNS>
O3Mat_T operator/(const O3Mat_T& m1, TYPE scalar) {
	int i;
	int j = ROWS*COLUMNS;
	O3Mat_T to_return;
	for (i=0;i<j;i++) to_return(i) = m1(i) / scalar;
	return to_return;
}

/*******************************************************************/ #pragma mark Scalar-O3Mat Operators /*******************************************************************/
///Adds scalar to every element of m1.
template <typename TYPE, int ROWS, int COLUMNS>
O3Mat_T operator+(TYPE scalar, const O3Mat_T& m1) {
	int i;
	int j = ROWS*COLUMNS;
	O3Mat_T to_return;
	for (i=0;i<j;i++) to_return(i) = scalar + m1(i);
	return to_return;
}

///Subtracts scalar from every element of m1.
template <typename TYPE, int ROWS, int COLUMNS>
O3Mat_T operator-(TYPE scalar, const O3Mat_T& m1) {
	int i;
	int j = ROWS*COLUMNS;
	O3Mat_T to_return;
	for (i=0;i<j;i++) to_return(i) = scalar - m1(i);
	return to_return;
}

///Multiplies every element of m1 by scalar.
template <typename TYPE, int ROWS, int COLUMNS>
O3Mat_T operator*(TYPE scalar, const O3Mat_T& m1) {
	int i;
	int j = ROWS*COLUMNS;
	O3Mat_T to_return;
	for (i=0;i<j;i++) to_return(i) = scalar * m1(i);
	return to_return;
}

///Divides scalar by every element of m1.
template <typename TYPE, int ROWS, int COLUMNS>
O3Mat_T operator/(TYPE scalar, const O3Mat_T& m1) {
	int i;
	int j = ROWS*COLUMNS;
	O3Mat_T to_return;
	for (i=0;i<j;i++) to_return(i) = scalar / m1(i);
	return to_return;
}

/*******************************************************************/ #pragma mark O3Mat-O3Mat Operators /*******************************************************************/
///Component-wise add m1 and m2.
template<typename TYPE, typename TYPE2, int ROWS, int COLUMNS>
O3Mat_T operator+(O3Mat_T& m1, const O3Mat_T2& m2) {
	int i;
	int j = ROWS*COLUMNS;
	O3Mat_T to_return;
	for (i=0;i<j;i++) to_return(i) = m1(i) + m2(i);
	return to_return;
}

///Component-wise subtract m1 and m2.
template<typename TYPE, typename TYPE2, int ROWS, int COLUMNS>
O3Mat_T operator-(O3Mat_T& m1, const O3Mat_T2& m2) {
	int i;
	int j = ROWS*COLUMNS;
	O3Mat_T to_return;
	for (i=0;i<j;i++) to_return(i) = m1(i) - m2(i);
	return to_return;
}

///O3Mat multiply m1 by m2.
template <typename TYPE, typename TYPE2, int ROWS, int INTERNAL, int COLUMNS>
O3Mat_T operator*(const O3Mat<TYPE, ROWS, INTERNAL>& m1, const O3Mat<TYPE2, INTERNAL, COLUMNS>& m2) {
	O3Mat_T to_return;
	to_return.Zero();
	int i, j, k;
	for (i=0;i<ROWS;i++)
		for (j=0;j<COLUMNS;j++)
			for (k=0;k<INTERNAL;k++) to_return(i,j) += m1(i, k) * m2(k, j);
	return to_return;
}

///Allows premultiplication of bigger matricies (say, 4x4) by smaller matricies (say, 3x3). The 3x3 matrix is placed in the upper left hand of a new 4x4 identity matrix. Useful for transformations (premultiplying a full homogenous 4x4 transformation by a 3x3 rotation matrix)
template <typename TYPE, typename TYPE2, int SIZE>
O3Mat<TYPE, SIZE, SIZE> operator*(const O3Mat<TYPE, SIZE-1, SIZE-1> m1, const O3Mat<TYPE2, SIZE, SIZE> m2) {
	O3Mat<TYPE, SIZE, SIZE> to_return;
	int i; for (i=0;i<SIZE;i++) to_return(SIZE-1, i) = m2(SIZE-1, i); //Copy in bottom row
	int row,col;
	int j = SIZE-1;
	for (row=0;row<j;row++)
		for (col=0;col<SIZE;col++) {
			TYPE& item = to_return(row, col);
			item = 0;
			for (i=0;i<j;i++) item += m1(row,i) * m2(i,col);
		}
	return to_return;
}

///Allows postmultiplication of bigger matricies (say, 4x4) by smaller matricies (say, 3x3). The 3x3 matrix is placed in the upper left hand of a new 4x4 identity matrix. Useful for transformations (premultiplying a full homogenous 4x4 transformation by a 3x3 rotation matrix)
template <typename TYPE, typename TYPE2, int SIZE>
O3Mat<TYPE, SIZE, SIZE> operator*(const O3Mat<TYPE, SIZE, SIZE> m1, const O3Mat<TYPE2, SIZE-1, SIZE-1> m2) {
	O3Mat<TYPE, SIZE, SIZE> to_return;
	int i; for (i=0;i<SIZE;i++) to_return(i, SIZE-1) = m1(i, SIZE-1); //Copy in right column
	int row,col;
	int j = SIZE-1;
	for (row=0;row<SIZE;row++)
		for (col=0;col<j;col++) {
			TYPE& item = to_return(row, col);
			item = 0;
			for (i=0;i<j;i++) item += m1(row,i) * m2(i,col);
		}
	return to_return;
}


/*******************************************************************/ #pragma mark O3Mat-Scalar In-Place Operators /*******************************************************************/
///Component-wise in-place add \e scalar to all elements of m.
template<typename TYPE, int ROWS, int COLUMNS>
O3Mat_T& operator+=(O3Mat_T& m, TYPE scalar) {
	int i;
	int j = ROWS*COLUMNS;
	for (i=0;i<j;i++) m(i) += scalar;
	return m;
}

///Component-wise in-place subtract \e scalar from all elements of m.
template<typename TYPE, int ROWS, int COLUMNS>
O3Mat_T& operator-=(O3Mat_T& m, TYPE scalar) {
	int i;
	int j = ROWS*COLUMNS;
	for (i=0;i<j;i++) m(i) = m(i) - scalar;
	return m;
}

///Component-wise in-place multiply \e scalar to all elements of m.
template<typename TYPE, int ROWS, int COLUMNS>
O3Mat_T& operator*=(O3Mat_T& m, TYPE scalar) {
	int i;
	int j = ROWS*COLUMNS;
	for (i=0;i<j;i++) m(i) *= scalar;
	return m;
}

///Component-wise in-place divide \e scalar from all elements of m.
template<typename TYPE, int ROWS, int COLUMNS>
O3Mat_T& operator/=(O3Mat_T& m, TYPE scalar) {
	int i;
	int j = ROWS*COLUMNS;
	for (i=0;i<j;i++) m(i) /= scalar;
	return m;
}

/*******************************************************************/ #pragma mark O3Mat-O3Mat In-Place Operators /*******************************************************************/
///Component-wise adds m1 and m2.
template<typename TYPE, typename TYPE2, int ROWS, int COLUMNS>
O3Mat_T& operator+=(O3Mat_T& m1, const O3Mat_T2& m2) {
	int i;
	int j = ROWS*COLUMNS;
	for (i=0;i<j;i++) m1(i) += m2(i);
	return m1;
}

///Component-wise subtracts m2 from m1.
template<typename TYPE, typename TYPE2, int ROWS, int COLUMNS>
O3Mat_T& operator-=(O3Mat_T& m1, const O3Mat_T2& m2) {
	int i;
	int j = ROWS*COLUMNS;
	for (i=0;i<j;i++) m1(i) -= m2(i);
	return m1;
}

///O3Mat postmultiplies  m1 by m2
template <typename TYPE, typename TYPE2, int ROWS, int INTERNAL, int COLUMNS>
O3Mat_T& operator*=(O3Mat<TYPE, ROWS, INTERNAL>& m1, const O3Mat<TYPE2, INTERNAL, COLUMNS>& m2) {
	return m1=m1*m2;
}

///<Premultiply a larger square matrix by a 1-smaller square matrix padded with identity components. In pseudocode, this is like m1=pad(m2)*m1.
template <typename TYPE, typename TYPE2, int SIZE> 
O3Mat<TYPE, SIZE, SIZE>& operator*=(O3Mat<TYPE, SIZE, SIZE> m2, const O3Mat<TYPE2, SIZE-1, SIZE-1> m1) {
	return m2=m1*m2;
}

/*******************************************************************/ #pragma mark Methods and method-accessors /*******************************************************************/
O3Mat_TT
O3Mat_T& O3Mat_T::SwapRows(int row1, int row2) {
	O3Assert(row1<ROWS, @"Cannot get row %i of %i rowed matrix for swapping.", row1,ROWS);
	O3Assert(row2<ROWS, @"Cannot get row %i of %i rowed matrix for swapping.", row2,ROWS);
	if (row1==row2) return *this;
	int i; for (i=0; i<COLUMNS; i++) 
		O3swap(operator()(row1, i), operator()(row2, i));
	return *this;
}

O3Mat_TT
O3Mat_T O3Mat_T::GetSwappedRows(int row1, int row2) const {
	return O3Mat_T(*this).SwapRows(row1, row2);
}

O3Mat_TT
O3Mat_T& O3Mat_T::SwapColumns(int column1, int column2) {
	O3Assert(column1<COLUMNS, @"Cannot get column %i of %i column matrix for swapping.", column1,COLUMNS);
	O3Assert(column2<COLUMNS, @"Cannot get column %i of %i column matrix for swapping.", column2,COLUMNS);
	if (column1==column2) return *this;
	int i; for (i=0; i<ROWS; i++)
		O3swap(operator()(i, column1), operator()(i, column2));
	return *this;
}

O3Mat_TT
O3Mat_T O3Mat_T::GetSwappedColumns(int column1, int column2) const {
	return O3Mat_T(*this).SwapColumns(column1, column2);
}

O3Mat_TT
O3Mat_T& O3Mat_T::Zero() {
	int j = ROWS*COLUMNS;
	int i; for (i=0;i<j;i++)
		operator()(i) = 0;
	return *this;
}

O3Mat_TT
O3Vec<TYPE, ROWS> O3Mat_T::GetColumn(int col) const {
	O3Vec<TYPE, ROWS> to_return;
	int i; for (i=0;i<ROWS;i++) 
		to_return[i] = operator()(i, col);
	return to_return;
}

O3Mat_TT
O3Vec<TYPE, COLUMNS> O3Mat_T::GetRow(int row) const {
	O3Vec<TYPE, COLUMNS> to_return;
	int i; for (i=0;i<COLUMNS;i++) 
		to_return[i] = operator()(row, i);
	return to_return;	
}

O3Mat_TT2
bool O3Mat_T::Equals(const O3Mat_T2& other, double tolerance) {
	int i;
	int j = ROWS*COLUMNS;
	for (i=0;i<j;i++)
		if (!O3Equals(operator()(i), other(i), tolerance)) return false;
	return true;
}

/*******************************************************************/ #pragma mark Accessors /*******************************************************************/
O3Mat_TT
int O3Mat_T::Rows() const {
	return ROWS;
}

O3Mat_TT
int O3Mat_T::Columns() const {
	return COLUMNS;
}

O3Mat_TT
const TYPE* O3Mat_T::Data(BOOL* row_major) const {
	if (row_major) row_major = YES;
	return Values;
}

/************************************/ #pragma mark Interface /************************************/
///Prints m in a human readable format to stream.
O3Mat_TT
std::ostream& operator<<(std::ostream &stream, const O3Mat_T &m) {
	stream<<"O3Mat<?,"<<ROWS<<", "<<COLUMNS<<"> {\n";
	int i,j;
	for (i=0;i<ROWS;i++)
		for (j=0;j<COLUMNS;j++) {
			stream<<m[i][j];
			stream<<((j==(COLUMNS-1))?";\n":",");
		}
	stream<<"}\n";
	return stream;
}

O3Mat_TT
std::string O3Mat_T::Description() const {
	std::ostringstream to_return;
	to_return<<"\n{";
	int i,j;
	for (i=0;i<ROWS;i++) {
		to_return<<"{";
		for (j=0;j<COLUMNS;j++) {
			to_return<<operator()(i,j);
			if (j!=(COLUMNS-1)) to_return<<", ";
		}
		if (i!=(ROWS-1))	to_return<<"}\n  ";
		else				to_return<<"}}\n";
	}
	return to_return.str();
}
