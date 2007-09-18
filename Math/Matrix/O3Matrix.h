#pragma once
/**
 *  @file O3Matrix.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 9/4/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#include <iostream>
class O3DynamicMatrix;

#define O3Mat_TT	template <typename TYPE, int ROWS, int COLUMNS>
#define O3Mat_T	O3Mat<TYPE, ROWS, COLUMNS>
#define O3Mat_TTT2 template<typename TYPE2>
#define O3Mat_TT2	O3Mat_TT O3Mat_TTT2
#define O3Mat_T2	O3Mat<TYPE2, ROWS, COLUMNS>

/*
 The O3Mat class represents a column-major (translation elements are indexes 12, 13, and 14 = [0][3], [1][3], and [2][3]) matrix. 
*/
O3Mat_TT class O3Mat {	
  public:
	TYPE Values[COLUMNS*ROWS]; //DynamicMatrix depends on this. Do not change the name or the type without first modifying DynamicMatrix.

  public: //Constructors
	static O3Mat_T  GetZero();
	O3Mat() {}; ///<Construct a matrix (not zeroed for performance reasons).
	O3Mat_TTT2 O3Mat(const TYPE2 *array, bool row_major = false) {Set(array, row_major);};		///<Construct a matrix filled with the elements in array, specifying weather it is row or column major format (but defaulting to column major).
	O3Mat_TTT2 O3Mat(const O3Mat_T2& other_matrix) {Set(other_matrix);};				///<Construct a matrix with the contents of other_matrix
	O3Mat_TTT2 O3Mat(const O3DynamicMatrix& dynm) {Set(dynm);};
	
  public: //Setters
	O3Mat_T& Set(const O3DynamicMatrix& dynm);	///<Set a matrix to the values represented by a DynamicMatrix (mostly for the ObjC interface)
	O3Mat_TTT2 O3Mat_T& Set(const TYPE2* array, bool row_major=false, unsigned arows=ROWS, unsigned acols=COLUMNS);	///<Fills the receiver with the elements in array, specifying weather array is row or column major (or not).
	O3Mat_TTT2 O3Mat_T& Set(const O3Mat_T2& other_matrix);		///<Fills the receiver with the contents of other_matrix.
	
  public: //RowAccessor helper class
	class RowAccessor { ///<RowAccessor is a helper class which allows matricies to be accessed like mat[i][j]
	  private:
		int Row;
		O3Mat *Mat;
	  public:
		RowAccessor(O3Mat_T* matrix, int row) : Row(row), Mat(matrix) { ///<Initialize a row accessor with a matrix and a row
			O3Assert(row<ROWS, @"Attempt to access row %i of %i rowed matrix", row, ROWS);	//These prevent vectorization
			O3AssertIvar(matrix);
		}
		TYPE& operator[](int column) { ///<Access an element in column column
			O3Assert(column<COLUMNS, @"Attempt to access column %i of %i column matrix", column, COLUMNS); //This prevents vectorization
			return (*Mat)(Row, column);
		}
		const TYPE& operator[](int column) const { ///<Access a constant element in column column
			O3Assert(column<COLUMNS, @"Attempt to access column %i of %i column matrix", column, COLUMNS); //This prevents vectorization
			return (*Mat)(Row, column);
		}
		operator TYPE() {return Mat(Row);}
		operator TYPE() const {return Mat(Row);}
	};
	
  public: //Operators
	RowAccessor operator[](int row);				///<Get a row accessor for row row. NOTE: a O3Mat can be accessed and assigned like a_matrix[i][j].
	const RowAccessor operator[](int row) const;		///<Get a  constant row accessor for row row. NOTE: a O3Mat can be accessed like a_matrix[i][j]. It cannot be assigned, however.
	TYPE& operator()(int row, int column);  			///<Access an element at row, column. Can be used for assignment (a_matrix(1,2) = 5).
	const TYPE& operator()(int row, int column) const;	///<Access an element at row, column. Cannot be used for assignment (a_matrix(1,2) = 5 will NOT work).
	TYPE& operator()(int index);				///<Access an element in the internal value array (which is column major) by index. Should not be used, as gcc can catch and optimize accesses in the mat[i][j] format. Assignment works.
	const TYPE& operator()(int index) const;			///<Access an element in the internal value array (which is column major) by index. Should not be used, as gcc can catch and optimize accesses in the mat[i][j] format. Assignment does NOT work.
	O3Mat_T& operator=(const O3Mat_T& m); ///<Turns the receiver into a copy of m.
	bool operator==(const O3Mat_T& mat) const;	///<Tests for exact equality between two matricies.
	bool operator!=(const O3Mat_T& mat) const;	///<Tests for exact inquality between two matricies.

  public: //Methods and method-accessors
	O3Mat_T& Zero();							///<Sets every element in the receiver to 0.
	O3Mat_T& SwapRows(int row1, int row2);				///<Swaps the rows row1 and row2.
	O3Mat_T  GetSwappedRows(int row1, int row2) const;		///<Gets a copy of the receiver with row1 and row2 swapped
	O3Mat_T& SwapColumns(int column1, int column2);			///<Swaps the columns column1 column2.
	O3Mat_T  GetSwappedColumns(int column1, int column2) const;	///<Gets a copy of the receiver with column1 and column2 swapped.
	O3Vec<TYPE, ROWS> GetColumn(int col) const;	///<Gets the column at index \e col
	O3Vec<TYPE, COLUMNS> GetRow(int row) const;	///<Gets the row at index \e row
	O3Mat_TTT2 bool Equals(const O3Mat_T2& other, double tolerance = O3Epsilon(TYPE));
	
  public: //Accessors
	int Rows() const;		///<Returns the number of rows in the receiver.
	int Columns() const;	///<Returns the number of columns in the receiver.
	const char* ElementType() const {return @encode(TYPE);} ///<Returns the ObjC encoding of TYPE
	const TYPE* Data(BOOL* row_major=NULL) const;		///<Returns a pointer to the internal values array. THIS SHOULD NOT BE USED.
	
  public: //Type conversion
	//Defined in O3DynamicMatrix.hpp
	operator const O3DynamicMatrix () const; ///<Automatically convert the receiver to an O3DynamicMatrix if appropriate.
	operator const TYPE* () const {return Values;} ///<Allows implicit conversion to a pointer to members (for easy integration with OpenGL & such)
	operator TYPE* () {return Values;} ///<Allows implicit conversion to a pointer to members (for easy integration with OpenGL & such)
	
  public: //Interface
	std::string Description() const; ///<Returns a string describing the receiver
};

/************************************/ #pragma mark Operators /************************************/
template <typename TYPE, int ROWS, int COLUMNS>	O3Mat_T operator+(const O3Mat_T& m1, TYPE scalar);
template <typename TYPE, int ROWS, int COLUMNS>	O3Mat_T operator-(const O3Mat_T& m1, TYPE scalar);
template <typename TYPE, int ROWS, int COLUMNS>	O3Mat_T operator*(const O3Mat_T& m1, TYPE scalar);
template <typename TYPE, int ROWS, int COLUMNS>	O3Mat_T operator/(const O3Mat_T& m1, TYPE scalar);
template <typename TYPE, int ROWS, int COLUMNS>	O3Mat_T operator+(TYPE scalar, const O3Mat_T& m1);
template <typename TYPE, int ROWS, int COLUMNS>	O3Mat_T operator-(TYPE scalar, const O3Mat_T& m1);
template <typename TYPE, int ROWS, int COLUMNS>	O3Mat_T operator*(TYPE scalar, const O3Mat_T& m1);
template <typename TYPE, int ROWS, int COLUMNS>	O3Mat_T operator/(TYPE scalar, const O3Mat_T& m1);
template <typename TYPE, typename TYPE2, int ROWS, int COLUMNS>	O3Mat_T operator+(O3Mat_T& m1, const O3Mat_T2& m2);
template <typename TYPE, typename TYPE2, int ROWS, int COLUMNS>	O3Mat_T operator-(O3Mat_T& m1, const O3Mat_T2& m2);
template <typename TYPE, typename TYPE2, int ROWS, int INTERNAL, int COLUMNS>	O3Mat_T operator*(const O3Mat<TYPE, ROWS, INTERNAL>& m1, const O3Mat<TYPE2, INTERNAL, COLUMNS>& m2);
template <typename TYPE, typename TYPE2, int SIZE> O3Mat<TYPE, SIZE, SIZE> operator*(const O3Mat<TYPE, SIZE-1, SIZE-1> m1, const O3Mat<TYPE2, SIZE, SIZE> m2);
template <typename TYPE, typename TYPE2, int SIZE> O3Mat<TYPE, SIZE, SIZE> operator*(const O3Mat<TYPE, SIZE, SIZE> m1, const O3Mat<TYPE2, SIZE-1, SIZE-1> m2);
template <typename TYPE, int ROWS, int COLUMNS>	O3Mat_T& operator+=(O3Mat_T& m, TYPE scalar);
template <typename TYPE, int ROWS, int COLUMNS>	O3Mat_T& operator-=(O3Mat_T& m, TYPE scalar);
template <typename TYPE, int ROWS, int COLUMNS>	O3Mat_T& operator*=(O3Mat_T& m, TYPE scalar);
template <typename TYPE, int ROWS, int COLUMNS>	O3Mat_T& operator/=(O3Mat_T& m, TYPE scalar);
template <typename TYPE, typename TYPE2, int ROWS, int COLUMNS>	O3Mat_T& operator+=(O3Mat_T& m1, const O3Mat_T2& m2);
template <typename TYPE, typename TYPE2, int ROWS, int COLUMNS>	O3Mat_T& operator-=(O3Mat_T& m1, const O3Mat_T2& m2);
template <typename TYPE, typename TYPE2, int ROWS, int INTERNAL, int COLUMNS>	O3Mat_T& operator*=(O3Mat<TYPE, ROWS, INTERNAL>& m1, const O3Mat<TYPE2, INTERNAL, COLUMNS>& m2);
template <typename TYPE, typename TYPE2, int SIZE> O3Mat<TYPE, SIZE, SIZE>& operator*=(O3Mat<TYPE, SIZE, SIZE> m2, const O3Mat<TYPE2, SIZE-1, SIZE-1> m1);
O3Mat_TT std::ostream& operator<<(std::ostream &stream, const O3Mat_T &m);

/************************************/ #pragma mark Convenience Typedefs /************************************/
typedef O3Mat<real, 3, 3> O3Mat3x3r;
typedef O3Mat<double, 3, 3> O3Mat3x3d;
typedef O3Mat<float, 3, 3> O3Mat3x3f;
typedef O3Mat<real, 4, 4> O3Mat4x4r;
typedef O3Mat<double, 4, 4> O3Mat4x4d;
typedef O3Mat<float, 4, 4> O3Mat4x4f;
