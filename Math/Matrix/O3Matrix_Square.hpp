#ifdef __cplusplus
/**
 *  @file O3Matrix_Square.hpp
 *  @license MIT License (see LICENSE.txt)
 *  @date 9/4/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
using namespace std;
using namespace ObjC3D::Math;

/*******************************************************************/ #pragma mark Constructors /*******************************************************************/
O3Mat_sq_TT
/*static*/ O3Mat_sq_T  O3Mat_sq_T::GetZero() {
	O3Mat_sq_T to_return;
	to_return.Zero();
	return to_return;
}

O3Mat_sq_TT
/*static*/ O3Mat_sq_T  O3Mat_sq_T::GetIdentity() {
	O3Mat_sq_T to_return;
	to_return.Identitize(); /*TOIMPLEMENT*/
	return to_return;
}

///@note If there is a difference in dimensionality between \e array and the receiver, the receiver will fill as much of itself as it can from \e array, then pad the rest with identity values.
///@param arows If \e array has a different dimensionality than the receiver, specify the number of rows in \e array here.
///@param acols If \e array has a different dimensionality than the receiver, specify the number of columns in \e array here.
///@todo O3Optimizable()
O3Mat_sq_TT2
O3Mat_sq_T& O3Mat_sq_T::Set(const TYPE2 *array, bool row_major, int arows, int acols) {
	if (!row_major || arows!=SIZE || acols!=SIZE) {
		int row, col;
		if (arows>SIZE) arows=SIZE;
		if (acols>SIZE) acols=SIZE;
		for (row=0;row<arows;row++)
			for (col=0;col<acols;col++) {
				operator()(row,col) = (row_major)? array[row + col*arows] : array[col + row*acols];
			}
		for (row=arows;row<SIZE;row++)
			for (col=acols;col<SIZE;col++)
				operator()(row,col) = (row==col)? 1 : 0;
	} else {
		int i;
		for (i=0;i<(SIZE*SIZE);i++) 
			operator()(i) = array[i];
	}
	return *this;
}

O3Mat_sq_TT
O3Mat_sq_T& O3Mat_sq_T::SetValue(NSValue* val) {
	if (!val) return Set(0);
	const char* type = [val objCType];
	const char* origtype = type;
	while (*type && *type!='[') type++;
	O3Assert(*type, @"Could not find an opening bracket indicating a vector type in %@", val);
	if (!type) return Set(0);
	type++;
	int len = atoi(type);
	if (len!=SIZE*SIZE) {
		O3Assert(len==SIZE*SIZE, @"Matrix lengths must match exactly. Cannot typecast while archiving.");
		Zero();
		return *this;
	}
	while (isdigit(*type)) type++;
	char octype = *type; type++;
	O3Assert(*type==']', @"Missing end brace in objCType of val %@. Must be a type like ...[%%i%%c]...", val);
	unsigned int bsize; NSGetSizeAndAlignment(origtype, &bsize, nil);
	void* buf = malloc(len*bsize);
	[val getValue:buf];
	#define USE_ENC_TYPE(t, enct) case enct: for (UIntP i=0; i<len; i++) operator()(i) = ((t*)buf)[i];	break;
	switch (octype) {
		USE_ENC_TYPE(float, 'f');
		USE_ENC_TYPE(double, 'd');
		USE_ENC_TYPE(char, 'c');
		USE_ENC_TYPE(unsigned char, 'C');
		USE_ENC_TYPE(short, 's');
		USE_ENC_TYPE(unsigned short, 'S');
		USE_ENC_TYPE(int, 'i');
		USE_ENC_TYPE(unsigned int, 'I');
		USE_ENC_TYPE(long, 'l');
		USE_ENC_TYPE(unsigned long, 'L');
		USE_ENC_TYPE(long long, 'q');
		USE_ENC_TYPE(unsigned long long, 'Q');
		default:
		O3Assert(false,@"Undefined type for O3Vec_T::Set(NSValue* val) (octype=%c)",octype);
		Set(0);
	}
	#undef USE_ENC_TYPE
	free(buf);
	return *this;
}

O3Mat_sq_TT2
O3Mat_sq_T& O3Mat_sq_T::Set(const O3Mat_sq_T2& other_matrix) {
	int i;
	int j = SIZE * SIZE;
	for (i=0;i<j;i++) operator()(i) = other_matrix(i);
	return *this;
}

O3Mat_sq_TT2
O3Mat_sq_T& O3Mat_sq_T::Set(const O3Mat<TYPE2, SIZE-1, SIZE-1> other_mat) {
	int i,k,j = SIZE-1;
	for (i=0;i<j;i++)
		for (i=0;i<k;i++)
			operator()(i,k) = other_mat(i,k);
	for (i=0;i<j;i++) {
		operator()(j,i) = 0;
		operator()(i,j) = 0;
	}
	operator()(j,j) = 1;
	return *this;
}

O3Mat_sq_TT2
O3Mat_sq_T& O3Mat_sq_T::Set(const O3Vec<TYPE2, 3> v1, const O3Vec<TYPE2, 3> v2, const O3Vec<TYPE2, 3> v3) {
	O3CompileAssert(SIZE==3 || SIZE==4, "O3Mat_T::Set(const vec3 v1, const vec3 v2, const vec3 v3) only valid on 3x3 and 4x4 matricies");
	if (SIZE==3) {
		operator()(0,0) = v1[0];
		operator()(1,0) = v1[1];
		operator()(2,0) = v1[2];
		operator()(0,1) = v2[0];
		operator()(1,1) = v2[1];
		operator()(2,1) = v2[2];
		operator()(0,2) = v3[0];
		operator()(1,2) = v3[1];
		operator()(2,2) = v3[2];
	}
	else if (SIZE==4) {
		operator()(0,0) = v1[0];
		operator()(1,0) = v1[1];
		operator()(2,0) = v1[2];
		operator()(3,0) = 0;
		operator()(0,1) = v2[0];
		operator()(1,1) = v2[1];
		operator()(2,1) = v2[2];
		operator()(3,1) = 0;
		operator()(0,2) = v3[0];
		operator()(1,2) = v3[1];
		operator()(2,2) = v3[2];
		operator()(3,2) = 0;
		operator()(0,3) = 0;
		operator()(1,3) = 0;
		operator()(2,3) = 1;
		operator()(3,3) = 1;
	}
	return *this;
}

/*******************************************************************/ #pragma mark Index Operators /*******************************************************************/
O3Mat_sq_TT
typename O3Mat_sq_T::RowAccessor O3Mat_sq_T::operator[](int row) {
	return RowAccessor(this, row);
}

O3Mat_sq_TT
const typename O3Mat_sq_T::RowAccessor O3Mat_sq_T::operator[](int row) const {
	return RowAccessor(const_cast<O3Mat*>(this), row);
}

///@note If you change these, you should change the accessor in DynamicMatrix as well
O3Mat_sq_TT
TYPE& O3Mat_sq_T::operator()(int row, int column) {
	return Values[SIZE * column + row];
}

///@note If you change these, you should change the accessor in DynamicMatrix as well
O3Mat_sq_TT
const TYPE& O3Mat_sq_T::operator()(int row, int column) const {
	return Values[SIZE * column + row];
}

O3Mat_sq_TT
TYPE& O3Mat_sq_T::operator()(int index) {
	return Values[index];
}

O3Mat_sq_TT
const TYPE& O3Mat_sq_T::operator()(int index) const {
	return Values[index];
}

/*******************************************************************/ #pragma mark Equality Operators /*******************************************************************/
O3Mat_sq_TT
O3Mat_sq_T& O3Mat_sq_T::operator=(const O3Mat_sq_T& m) {
	int i;
	for (i=0;i<(SIZE*SIZE);i++)
		operator()(i) = m(i);
	return *this;
}

O3Mat_sq_TT
bool O3Mat_sq_T::operator==(const O3Mat_sq_T& m) const {
	int i;
	for (i=0;i<(SIZE*SIZE);i++)
		if (operator()(i) != m(i)) return false;
	return true;
}

O3Mat_sq_TT
bool O3Mat_sq_T::operator!=(const O3Mat_sq_T& m) const {
	int i;
	for (i=0;i<(SIZE*SIZE);i++) {
		if (operator()(i) == m(i)) return false;
	}
	return true;
}

/*******************************************************************/ #pragma mark Methods and method-accessors /*******************************************************************/
O3Mat_sq_TT
O3Mat_sq_T& O3Mat_sq_T::SwapRows(int row1, int row2) {
	O3Assert(row1<SIZE, @"Cannot get row %i of %i rowed matrix for swapping.", row1,SIZE);
	O3Assert(row2<SIZE, @"Cannot get row %i of %i rowed matrix for swapping.", row2,SIZE);
	if (row1==row2) return *this;
	int i; for (i=0; i<SIZE; i++) 
		O3Swap(operator()(row1, i), operator()(row2, i));
	return *this;
}

O3Mat_sq_TT
O3Mat_sq_T O3Mat_sq_T::GetSwappedRows(int row1, int row2) const {
	return O3Mat_sq_T(*this).SwapRows(row1, row2);
}

O3Mat_sq_TT
O3Mat_sq_T& O3Mat_sq_T::SwapColumns(int column1, int column2) {
	O3Assert(column1<SIZE, @"Cannot get column %i of %i column matrix for swapping.", column1,SIZE);
	O3Assert(column2<SIZE, @"Cannot get column %i of %i column matrix for swapping.", column2,SIZE);
	if (column1==column2) return *this;
	int i; for (i=0; i<SIZE; i++)
		O3Swap(operator()(i, column1), operator()(i, column2));
	return *this;
}

O3Mat_sq_TT
O3Mat_sq_T O3Mat_sq_T::GetSwappedColumns(int column1, int column2) const {
	return O3Mat_sq_T(*this).SwapColumns(column1, column2);
}

O3Mat_sq_TT
O3Mat_sq_T& O3Mat_sq_T::Zero() {
	int i;
	int j = SIZE*SIZE;
	for (i=0;i<j;i++)
		operator()(i) = 0;
	return *this;
}

O3Mat_sq_TT
O3Mat_sq_T& O3Mat_sq_T::Identitize() {
	int i;
	int j = SIZE*SIZE;
	for (i=0;i<j;i++) 
		operator()(i) = 0;
	int size_plus_one = SIZE + 1;
	for (i=0;i<j;i+=size_plus_one) operator()(i) = 1.;
	return *this;
}

O3Mat_sq_TT
O3Mat_sq_T&  O3Mat_sq_T::Transpose() {
	int i,j;
	for (i=0;i<SIZE;i++)
		for (j=(i+1); j<SIZE; j++) {
			TYPE tmp = operator()(i,j);
			operator()(i,j) = operator()(j,i);
			operator()(j,i) = tmp;
		}
	return *this;
}

O3Mat_sq_TT
O3Mat_sq_T  O3Mat_sq_T::GetTransposed() const {
	O3Mat_sq_T to_return;
	int i,j;
	for (i=0;i<SIZE;i++)
		for (j=0;j<SIZE;j++) to_return(i,j) = operator()(j,i);
	return to_return;
}

///@todo Make O3Mat_sq_T::Determinant() work on bigger than 4x4s
O3Mat_sq_TT
double O3Mat_sq_T::Determinant() const {
	O3CompileAssert(SIZE<=4, "Cannot get determinants of <4x4 matricies (det is hardcoded). Please code a better implementation.");
	const O3Mat_sq_T& m = *this;
	if (SIZE==1) return m(0,0);
	if (SIZE==2) return m(0,0)*m(1,1) - m(1,0)*m(0,1);
	if (SIZE==3) return m(0)*m(4)*m(8) + m(1)*m(5)*m(6) + m(2)*m(3)*m(7) - m(0)*m(5)*m(7) - m(1)*m(3)*m(8) - m(2)*m(4)*m(6);
	if (SIZE==4) {
		double m11 = m(0,0); double m12 = m(0,1); double m13 = m(0,2); double m14 = m(0,3);
		double m21 = m(1,0); double m22 = m(1,1); double m23 = m(1,2); double m24 = m(1,3);
		double m31 = m(2,0); double m32 = m(2,1); double m33 = m(2,2); double m34 = m(2,3);
		double m41 = m(3,0); double m42 = m(3,1); double m43 = m(3,2); double m44 = m(3,3);
		return	  m11*(m22*(m33*m44 - m34*m43) - m32*(m23*m44 + m24*m43) + m42*(m23*m34 - m24*m33))
				- m21*(m12*(m33*m44 - m34*m43) - m32*(m13*m44 + m14*m43) + m42*(m13*m34 - m14*m33))
				+ m31*(m12*(m23*m44 - m24*m43) - m22*(m13*m44 + m14*m43) + m42*(m13*m24 - m14*m23))
				- m41*(m12*(m23*m34 - m24*m33) - m22*(m13*m34 + m14*m33) + m32*(m13*m24 - m14*m23));
	}
	return (double)0xCAFEBABE;
}

O3Mat_sq_TT
double O3Mat_sq_T::GetCofactor(int row, int col) const {
	O3Mat<double, SIZE-1, SIZE-1> tmp_cofac;
	int i=0,j=0,k=0,l=0;
	for (i=0;i<SIZE;i++) {
		if (i!=row) {
			for (j=0,l=0;j<SIZE;j++) {
				if (j!=col) {
					tmp_cofac(k,l) = (double)operator()(i,j);
					l++;
				}
			}
			k++;
		}
	}
	double det = tmp_cofac.Determinant();
	return ((row+col)%2)? -det : det;
}

O3Mat_sq_TT
O3Mat_sq_T O3Mat_sq_T::GetCofactorMatrix() const {
	O3Mat_sq_T to_return;
	int i,j;
	for (i=0;i<SIZE;i++)
		for (j=0;j<SIZE;j++)
			to_return(i,j) = GetCofactor(i,j);
	return to_return;
}

O3Mat_sq_TT
O3Mat_sq_T O3Mat_sq_T::GetAdjointMatrix() const {
	O3Mat_sq_T to_return;
	int i,j;
	for (i=0;i<SIZE;i++)
		for (j=0;j<SIZE;j++)
			to_return(i,j) = GetCofactor(j,i);
	return to_return;
}

O3Mat_sq_TT
O3Mat_sq_T& O3Mat_sq_T::Invert(bool is_ortho) {
	if (SIZE==4 && is_ortho) {	//Are we a good candidate for acceleration?
		if (O3Equals(operator()(3,0), 0., O3Epsilon(TYPE)) &&
			O3Equals(operator()(3,1), 0., O3Epsilon(TYPE)) &&
			O3Equals(operator()(3,2), 0., O3Epsilon(TYPE)) &&
			O3Equals(operator()(3,3), 1., O3Epsilon(TYPE))    ) {
			Invert3x4();
			return *this;
		}
	}
			
	return InvertLU();
}

O3Mat_sq_TT
O3Mat_sq_T O3Mat_sq_T::GetInverted(bool is_ortho) const {
	O3Mat_sq_T to_return = *this;
	return to_return.Invert(is_ortho);
}

O3Mat_sq_TT
O3Vec<TYPE, SIZE> O3Mat_sq_T::GetColumn(int col) const {
	O3Vec<TYPE, SIZE> to_return;
	int i; for (i=0;i<SIZE;i++) 
		to_return[i] = operator()(i, col);
	return to_return;
}

O3Mat_sq_TT
O3Vec<TYPE, SIZE> O3Mat_sq_T::GetRow(int row) const {
	O3Vec<TYPE, SIZE> to_return;
	int i; for (i=0;i<SIZE;i++) 
		to_return[i] = operator()(row, i);
	return to_return;	
}

O3Mat_sq_TT
O3Mat<TYPE,4,4> O3Mat_sq_T::Get4x4() const {
	O3Mat<TYPE,4,4> to_return; to_return.Identitize();
	int i,j;
	for (i=0;i<SIZE;i++)
		for (j=0;j<SIZE;j++)
			to_return(i,j) = operator()(i,j);
	return to_return;
}

O3Mat_sq_TT2
bool O3Mat_sq_T::Equals(const O3Mat_sq_T2& other, double tolerance) const {
	int i,j;
	for (i=0; i<SIZE; i++)
		for (j=0; j<SIZE; j++)
			if (!O3Equals(operator()(i,j), other(i,j), tolerance)) return false;
	return true;
}

O3Mat_sq_TT
bool O3Mat_sq_T::IsIdentity(double tolerance) const {
	int i,j;
	for (i=0;i<SIZE;i++)
		for (j=0;j<SIZE;j++) {
			TYPE testval = operator()(i,j);
			TYPE shouldbe = (i==j)? 1 : 0;
			if (!O3Equals(testval, shouldbe, tolerance)) return false;
		}
	return true;
}

O3Mat_sq_TT
bool O3Mat_sq_T::IsZero(double tolerance) const {
	int i,j;
	for (i=0;i<SIZE;i++)
		for (j=0;j<SIZE;j++)
			if (!O3Equals(operator()(i,j), 0.0, tolerance)) return false;
	return true;	
}

O3Mat_sq_TT
bool O3Mat_sq_T::IsTransposeInvertable(double tolerance) const {
	O3Mat_sq_T aCopy(*this);
	aCopy.Transpose();
	return (aCopy*(*this)).IsIdentity(tolerance);
}

///@note Broken. Just calls InvertAdjoint()
O3Mat_sq_TT
O3Mat_sq_T& O3Mat_sq_T::InvertLU() {
	return InvertAdjoint();
	
	int i,j,k;
	O3Assert(SIZE >= 2, @"Cannot LU invert a matrix less than 3x3");
    for (i=1; i<SIZE; i++) operator()(0,i) /= operator()(0,0); //Normalize row 0
    for (i=1; i<SIZE; i++)  { 
		for (j=i; j<SIZE; j++)  { //Do a column of L
			double sum = 0.0;
			for (k= 0; k<i; k++)  
				sum += operator()(j,k) * operator()(k,i);
			operator()(j,i) -= sum;
        }
		if (i==SIZE-1) continue;
		for (j=i+1; j<SIZE; j++)  {  //Do a row of U
			double sum = 0.0;
			for (k= 0; k<i; k++)
				sum += operator()(i,k)*operator()(k,j);
			operator()(i,j) = 
				(operator()(i,j)-sum) / operator()(i,i);
        }
	}
    for (i= 0; i<SIZE; i++) { //Invert L
		for (j=i; j<SIZE; j++)  {
			double x = 1.0;
			if (i!=j) {
				x = 0.0;
				for (k=i; k<j; k++) 
					x -= operator()(j,k)*operator()(k,i);
			}
			operator()(j,i) = x / operator()(j,j);
        }
	}
    for (i= 0; i<SIZE; i++) {   //Invert U
		for (j=i; j<SIZE; j++)  {
			if ( i==j ) continue;
			double sum = 0.0;
			for (k=i; k<j; k++)
				sum += operator()(k,j)*( (i==k) ? 1.0 : operator()(i,k) );
			operator()(i,j) = -sum;
        }
	}
    for (i= 0; i<SIZE; i++)  {  //Put things together
		for (j= 0; j<SIZE; j++)  {
			double sum = 0.0;
			for (k= ((i>j)?i:j); k<SIZE; k++)  
				sum += ((j==k)?1.0:operator()(j,k))*operator()(k,i);
			operator()(j,i) = sum;
        }
    }
	return *this;
}

O3Mat_sq_TT
O3Mat_sq_T& O3Mat_sq_T::Invert3x4() {
	O3Assert(SIZE==4, @"Cannot 3x4 invert a non-4x4 matrix");
	//Real props to OSG guys for this algorithm
	double	m00, m01, m02, m03;
	double  m10, m11, m12, m13;
	double  m20, m21, m22, m23;
	double  m30, m31, m32, m33;
	m00 = operator()(0,0); 	m01 = operator()(1,0); 	m02 = operator()(2,0); 	m03 = operator()(3,0);
	m10 = operator()(0,1); 	m11 = operator()(1,1); 	m12 = operator()(2,1); 	m13 = operator()(3,1);
	m20 = operator()(0,2); 	m21 = operator()(1,2); 	m22 = operator()(2,2); 	m23 = operator()(3,2); 	
	m30 = operator()(0,3); 	m31 = operator()(1,3); 	m32 = operator()(2,3); 	m33 = operator()(3,3);
	
    // Partially compute inverse of rot
    operator()(0,0) = m11*m22 - m12*m21;
    operator()(1,0) = m02*m21 - m01*m22;
    operator()(2,0) = m01*m12 - m02*m11;
	
    // Compute determinant of rot from 3 elements just computed
    double one_over_det = 1.0/(m00*operator()(0,0) + m10*operator()(1,0) + m20*operator()(2,0));
    m00 *= one_over_det; m10 *= one_over_det; m20 *= one_over_det;  // Saves on later computations
	
    // Finish computing inverse of rot
    operator()(0,0) *= one_over_det;
    operator()(1,0) *= one_over_det;
    operator()(2,0) *= one_over_det;
    operator()(3,0) = 0.0;
    operator()(0,1) = m12*m20 - m10*m22; // Have already been divided by det
    operator()(1,1) = m00*m22 - m02*m20; // same
    operator()(2,1) = m02*m10 - m00*m12; // same
    operator()(3,1) = 0.0;
    operator()(0,2) = m10*m21 - m11*m20; // Have already been divided by det
    operator()(1,2) = m01*m20 - m00*m21; // same
    operator()(2,2) = m00*m11 - m01*m10; // same
    operator()(3,2) = 0.0;
    operator()(3,3) = 1.0;
	
    if( ((m33-1.0)*(m33-1.0)) > 1.0e-6 )  // Involves perspective, so we must
    {                      				 // compute the full inverse
		
        O3Mat<double,4,4> tmp;
        operator()(0,3) = operator()(1,3) = operator()(2,3) = 0.0;
		
        double px = operator()(0,0)*m03 + operator()(1,0)*m13 + operator()(2,0)*m23;
        double py = operator()(0,1)*m03 + operator()(1,1)*m13 + operator()(2,1)*m23;
        double pz = operator()(0,2)*m03 + operator()(1,2)*m13 + operator()(2,2)*m23;
		
        double one_over_s  = 1.0/(m33 - (m30*px + m31*py + m32*pz));
		
        m30 *= one_over_s; m31 *= one_over_s; m32 *= one_over_s;  // Reduces number of calculations later on
		
        // Compute inverse of trans*corr
        tmp.operator()(0,0) = m30*px + 1.0;
        tmp.operator()(1,0) = m31*px;
        tmp.operator()(2,0) = m32*px;
        tmp.operator()(3,0) = -px * one_over_s;
        tmp.operator()(0,1) = m30*py;
        tmp.operator()(1,1) = m31*py + 1.0;
        tmp.operator()(2,1) = m32*py;
        tmp.operator()(3,1) = -py * one_over_s;
        tmp.operator()(0,2) = m30*pz;
        tmp.operator()(1,2) = m31*pz;
        tmp.operator()(2,2) = m32*pz + 1.0;
        tmp.operator()(3,2) = -pz * one_over_s;
        tmp.operator()(0,3) = -m30;
        tmp.operator()(1,3) = -m31;
        tmp.operator()(2,3) = -m32;
        tmp.operator()(3,3) = one_over_s;
		
        Set(tmp*(*this));
    } else { // Rightmost column is [0; 0; 0; 1] so it can be ignored
        operator()(0,3) = -(m30*operator()(0,0) + m31*operator()(0,1) + m32*operator()(0,2));
        operator()(1,3) = -(m30*operator()(1,0) + m31*operator()(1,1) + m32*operator()(1,2));
        operator()(2,3) = -(m30*operator()(2,0) + m31*operator()(2,1) + m32*operator()(2,2));
    }
	
    return *this;
}


O3Mat_sq_TT
O3Mat_sq_T& O3Mat_sq_T::InvertAdjoint() {
	double recip_det = O3recip(Determinant());
	Set(GetAdjointMatrix());
	int i; int j = SIZE*SIZE;
	for (i=0;i<j;i++) operator()(i) *= recip_det;
	return *this;
}

/*******************************************************************/ #pragma mark Accessors /*******************************************************************/
O3Mat_sq_TT
int O3Mat_sq_T::Rows() const {
	return SIZE;
}

O3Mat_sq_TT
int O3Mat_sq_T::Columns() const {
	return SIZE;
}

O3Mat_sq_TT
const TYPE* O3Mat_sq_T::Data(BOOL* row_major) const {
	if (row_major) *row_major=YES;
	return Values;
}

/*******************************************************************/ #pragma mark Interface /*******************************************************************/
O3Mat_sq_TT
std::ostream& operator<<(std::ostream &stream, const O3Mat_sq_T &m) {
	stream<<"O3Mat<?,"<<SIZE<<", "<<SIZE<<"> {\n";
	int i;
	int j = SIZE * SIZE;
	for (i=0;i<SIZE;i++)
		for (j=0;j<SIZE;j++) {
			stream<<m[i][j];
			stream<<((j==(SIZE-1))?";\n":",");
		}
	stream<<"}\n";
	return stream;
}

O3Mat_sq_TT
std::string O3Mat_sq_T::Description() const {
	std::ostringstream to_return;
	to_return<<"\n{";
	int i,j;
	for (i=0;i<SIZE;i++) {
		to_return<<"{";
		for (j=0;j<SIZE;j++) {
			to_return<<operator()(i,j);
			if (j!=(SIZE-1)) to_return<<", ";
		}
		if (i!=(SIZE-1))	to_return<<"}\n  ";
		else				to_return<<"}}\n";
	}
	return to_return.str();
} 

/*******************************************************************/ #pragma mark Creation /*******************************************************************/
O3Mat_sq_TT
O3Mat_sq_T& O3Mat_sq_T::SetOrtho(double left, double right, double bottom, double top, double zNear, double zFar) {
	double tx = -(right+left)/(right-left);
    double ty = -(top+bottom)/(top-bottom);
    double tz = -(zFar+zNear)/(zFar-zNear);
	double mat_data[] = {	2.0/(right-left), 0, 0, tx,
							0, 2.0/(top-bottom), 0, ty,
							0, 0, -2.0/(zFar-zNear), tz,
		0, 0, 0, 1};
	Set(mat_data);
	return *this;
}

O3Mat_sq_TT
O3Mat_sq_T& O3Mat_sq_T::SetFrustum(double left, double right, double bottom, double top, double zNear, double zFar) {
	double dnear = 2.0*zNear;
	double reciprl = 1.0 / (right-left);
	double recipfn = 1.0 / (zFar-zNear);
	double reciptb = 1.0 / (top-bottom);
    double a = (right+left)*reciprl;
    double b = (top+bottom)*reciptb;
    double c = -(zFar+zNear)*recipfn;
	double e = dnear*reciprl;
	double f = dnear*reciptb;
    double d = -dnear*zFar*recipfn;

	double mat_data[] = {	e,0,a,0,
							0,f,b,0,
							0,0,c,d,
							0,0,-1,0   };
	Set(mat_data);
	return *this;
}

O3Mat_sq_TT
O3Mat_sq_T& O3Mat_sq_T::SetPerspective(double fovy,double aspectRatio, double zNear, double zFar) {
    double right	=  tan(O3DegreesToRadians(fovy*0.5)) * zNear;
    double left		= -right;
    double top		=  right * aspectRatio;
    double bottom	=  left  * aspectRatio;
    return SetFrustum(left,right,bottom,top,zNear,zFar);
}

O3Mat_sq_TT
template <typename TYPE1, typename TYPE2>
O3Mat_sq_T& O3Mat_sq_T::SetLookAt(const O3Vec<TYPE1, 3>& eye, const O3Vec<TYPE2, 3>& center, const O3Vec<TYPE2, 3>& up, bool center_relative_to_eye) {
	O3Vec3d f;
	if (center_relative_to_eye)	f = center-eye;
	else						f = center;
	O3Vec3d s = f^up;
	O3Vec3d u = s^f;
	s.Normalize();
	u.Normalize();
	f = -f;
	
	double setdata[] = {
        s[0],	s[0],	s[0],	-(eye[0]),
        u[1],	u[1],	u[1],	-(eye[1]),
        f[2],	f[2],	f[2],	-(eye[2]),
        0.0,	0.0,	0.0,	1.0 };
	Set(setdata);
	return *this;
}


/*******************************************************************/ #pragma mark Value Extraction /*******************************************************************/
O3Mat_sq_TT
bool O3Mat_sq_T::GetOrtho(double& left, double& right, double& bottom, double& top, double& zNear, double& zFar) const {
	O3CompileAssert(SIZE==4, "Can only get orthagonal decomp on a 4x4 matrix");
	if (O3Equals(operator()(0,3), 0.0, O3Epsilon(double)) || 
		O3Equals(operator()(1,3), 0.0, O3Epsilon(double)) || 
		O3Equals(operator()(2,3), 0.0, O3Epsilon(double)) || 
		O3Equals(operator()(3,3), 1.0, O3Epsilon(double))    ) return false;
	
	double recip00 = 1.0 / operator()(0,0);
	double recip11 = 1.0 / operator()(1,1);
	double recip22 = 1.0 / operator()(2,2);
    
    left = -(1.0+operator()(0,3)) * recip00;
    right = (1.0-operator()(0,3)) * recip00;
	
    bottom = -(1.0+operator()(1,3)) * recip11;
    top    =  (1.0-operator()(1,3)) * recip11;
	
	zNear = (operator()(2,3)+1.0) * recip22;
    zFar  = (operator()(2,3)-1.0) * recip22;
    
    return true;
}

O3Mat_sq_TT
bool O3Mat_sq_T::GetFrustum(double& left, double& right, double& bottom, double& top, double& zNear, double& zFar) const {
	O3CompileAssert(SIZE==4, "Cannot get the frustum defined by a non 4x4!");
	if (O3Equals(operator()(0,3), 0.0, O3Epsilon(double)) || 
		O3Equals(operator()(1,3), 0.0, O3Epsilon(double)) || 
		O3Equals(operator()(2,3), 0.0, O3Epsilon(double)) || 
		O3Equals(operator()(3,3), 1.0, O3Epsilon(double))    ) return false;	
	
	double m22 = operator()(2,2);
	double recip00 = 1.0 / operator()(0,0);
	double recip11 = 1.0 / operator()(1,1);
	
    zNear = operator()(3,2) / (m22-1.0);
    zFar  = operator()(3,2) / (m22+1.0);
    
    left  = zNear * (m22-1.0) * recip00;
    right = zNear * (m22+1.0) * recip00;
	
    top    = zNear * (operator()(1,2)+1.0) * recip11;
    bottom = zNear * (operator()(1,2)-1.0) * recip11;
    
    return true;
}

O3Mat_sq_TT
bool O3Mat_sq_T::GetPerspective(double& fovy, double& aspectRatio, double& zNear, double& zFar) const {
	double left, right, bottom, top, near, far;
    if (!GetFrustum(left, right, bottom, top, near, far)) return false;
	fovy = O3RadiansToDegrees(atan(top/zNear)-atan(bottom/zNear));
	aspectRatio = (right-left)/(top-bottom);
	return true;
}
#endif /*defined(__cplusplus)*/
