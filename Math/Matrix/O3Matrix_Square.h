#ifdef __cplusplus
/**
 *  @file O3Matrix_Square.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 9/26/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#define O3Mat_sq_TT	template<typename TYPE, int SIZE>
#define O3Mat_sq_T		O3Mat<TYPE, SIZE, SIZE>
#define O3Mat_sq_TTT2	template<typename TYPE2>
#define O3Mat_sq_TT2	O3Mat_sq_TT O3Mat_sq_TTT2
#define O3Mat_sq_T2	O3Mat<TYPE2, SIZE, SIZE>

O3Mat_sq_TT class O3Mat_sq_T {
public:
	TYPE Values[SIZE*SIZE]; //DynamicMatrix depends on this. Do not change the name or the type without first modifying DynamicMatrix.
	
public: //Constructors
	static O3Mat_sq_T  GetZero();
	static O3Mat_sq_T  GetIdentity();
	O3Mat() {}; ///<Construct a matrix (not zeroed for performance reasons).
	O3Mat(const O3DynamicMatrix& dynm) {Set(dynm);}; ///<Construct a matrix from a dynamic matrix representation
	O3Mat_sq_TTT2 O3Mat(const TYPE2 *array, bool row_major = false) {Set(array, row_major);}; ///<Construct a matrix filled with the elements in array, specifying weather it is row or column major format (but defaulting to column major).
	O3Mat_sq_TTT2 O3Mat(const O3Mat_sq_T2& other_matrix) {Set(other_matrix);}; ///<Construct a matrix with the contents of other_matrix
	O3Mat_sq_TTT2 O3Mat(const O3Mat<TYPE2, SIZE-1, SIZE-1> other_mat) {Set(other_mat);} ///<Construct a matrix from a smaller matrix (other_mat is put in the upper left corner of the receiver, and everything else is padded with identity values)
	O3Mat_sq_TTT2 O3Mat(const O3Vec<TYPE2,SIZE> v1, const O3Vec<TYPE2,SIZE> v2, const O3Vec<TYPE2,SIZE> v3) {Set(v1,v2,v3);};	   ///<Constructs a matrix with the given vectors as an orthonormal base. Valid on 3x3 and 4x4 matricies.
	
public: //Setters
	O3Mat_sq_TTT2 O3Mat_sq_T& Set(const TYPE2* array, bool row_major = false, int arows = SIZE, int acols = SIZE);	///<Fills the receiver with the elements in array, specifying weather array is row or column major.
	O3Mat_sq_TTT2 O3Mat_sq_T& Set(const O3Mat_sq_T2& other_matrix);		///<Fills the receiver with the contents of other_matrix.
	O3Mat_sq_TTT2 O3Mat_sq_T& Set(const O3Mat<TYPE2, SIZE-1, SIZE-1> other_mat); ///<Set a matrix to a smaller matrix (other_mat is put in the upper left corner of the receiver, and everything else is padded with identity values)
	O3Mat_sq_TTT2 O3Mat_sq_T& Set(const O3Vec<TYPE2, 3> v1, const O3Vec<TYPE2, 3> v2, const O3Vec<TYPE2, 3> v3);		///<Fills the orthonormal base of the receiver. Valid on 3x3 and 4x4 matricies.
	O3Mat_sq_T& Set(const O3DynamicMatrix& dynm);	///<Set a matrix to the values represented by a DynamicMatrix (mostly for the ObjC interface)
	
	
	
public: //RowAccessor helper class
		class RowAccessor { ///<RowAccessor is a helper class which allows matricies to be accessed like mat[i][j]
private:
		int Row;
		O3Mat *Mat;
		
public:
			RowAccessor(O3Mat_sq_T* matrix, int row) : Row(row), Mat(matrix) { ///<Initialize a row accessor with a matrix and a row
				O3Assert(row<SIZE, @"Attempt to access row %i of %i row matrix", row, SIZE);	//These prevent vectorization
				O3AssertIvar(matrix);
			}
			TYPE& operator[](int column) { ///<Access an element in column column
				O3Assert(column<SIZE, @"Attempt to access column %i of %i column matrix", column, SIZE); //This prevents vectorization
				return (*Mat)(Row, column);
			}
			const TYPE& operator[](int column) const { ///<Access a constant element in column column
				O3Assert(column<SIZE, @"Attempt to access column %i of %i column matrix", column, SIZE); //This prevents vectorization
				return (*Mat)(Row, column);
			}
		};
	
public: //Operators
	RowAccessor operator[](int row);					///<Get a row accessor for row row. NOTE: a O3Mat can be accessed and assigned like a_matrix[i][j].
	const RowAccessor operator[](int row) const;		///<Get a  constant row accessor for row row. NOTE: a O3Mat can be accessed like a_matrix[i][j]. It cannot be assigned, however.
	TYPE& operator()(int row, int column);  			///<Access an element at row, column. Can be used for assignment (a_matrix(1,2) = 5).
	const TYPE& operator()(int row, int column) const;	///<Access an element at row, column. Cannot be used for assignment (a_matrix(1,2) = 5 will NOT work).
	TYPE& operator()(int index);						///<Access an element in the internal value array (which is column major) by index. Should not be used, as gcc can catch and optimize accesses in the mat[i][j] format. Assignment works.
	const TYPE& operator()(int index) const;			///<Access an element in the internal value array (which is column major) by index. Should not be used, as gcc can catch and optimize accesses in the mat[i][j] format. Assignment does NOT work.
	O3Mat_sq_T& operator=(const O3Mat_sq_T& m); ///<Turns the receiver into a copy of m.
	bool operator==(const O3Mat_sq_T& mat) const;	///<Tests for exact equality between two matricies.
	bool operator!=(const O3Mat_sq_T& mat) const;	///<Tests for exact inquality between two matricies.
	
public: //Advanced Set functions
	O3Mat_sq_T& SetOrtho(double left, double right, double bottom, double top, double zNear, double zFar);
	O3Mat_sq_T& SetFrustum(double left, double right, double bottom, double top, double zNear, double zFar);
	O3Mat_sq_T& SetPerspective(double fovy,double aspectRatio, double zNear, double zFar);
	template <typename TYPE1, typename TYPE2>
	O3Mat_sq_T& SetLookAt(const O3Vec<TYPE1, 3>& eye, const O3Vec<TYPE2, 3>& center, const O3Vec<TYPE2, 3>& up, bool center_relative_to_eye = false);
		
public: //Methods and method-accessors
	O3Mat_sq_T& Zero();							///<Sets every element in the receiver to 0.
	O3Mat_sq_T& Identitize();							///<Sets every element in the receiver to 0, except for those on the diagonal which it sets to 1 (turns the receiver into an identity matrix).
	O3Mat_sq_T& SwapRows(int row1, int row2);				///<Swaps the rows row1 and row2.
	O3Mat_sq_T  GetSwappedRows(int row1, int row2) const;		///<Gets a copy of the receiver with row1 and row2 swapped
	O3Mat_sq_T& SwapColumns(int column1, int column2);			///<Swaps the columns column1 column2.
	O3Mat_sq_T  GetSwappedColumns(int column1, int column2) const;	///<Gets a copy of the receiver with column1 and column2 swapped.
	O3Mat_sq_T& Transpose();
	O3Mat_sq_T  GetTransposed() const;
	O3Mat_sq_T& Invert(bool is_ortho = false);
	O3Mat_sq_T  GetInverted(bool is_ortho = false) const;
	double		 Determinant() const;
	double GetCofactor(int row, int col) const;
	O3Mat_sq_T GetCofactorMatrix() const;
	O3Mat_sq_T GetAdjointMatrix() const;
	
public: //Value extraction
	O3Mat<TYPE,4,4>   Get4x4() const; ///<Creates a 4x4 matrix from the receiver, filling in any missing values from the identity (use to convert a rotation's 3x3 to a 4x4 matrix, for instance)
	O3Vec<TYPE, SIZE> GetColumn(int col) const;  	///<Gets the column at index \e col
	O3Vec<TYPE, SIZE> GetRow(int row) const;     	///<Gets the row at index \e row
	bool GetOrtho(double& left, double& right, double& bottom, double& top, double& zNear, double& zFar) const; ///<Returns true on success and false on failure.
	bool GetFrustum(double& left, double& right, double& bottom, double& top, double& zNear, double& zFar) const; ///<Returns true on success and false on failure.
	bool GetPerspective(double& fovy, double& aspectRatio, double& zNear, double& zFar) const; ///<Returns true on success and false on failure.
	
public: //Accessors
	int Rows() const;		///<Returns the number of rows in the receiver.
	int Columns() const;	///<Returns the number of columns in the receiver.
	const TYPE *Data(BOOL* row_major=NULL) const;	///<Returns a pointer to the internal values array. THIS SHOULD NOT BE USED.
	const char* ElementType() const {return @encode(TYPE);} ///<Returns the ObjC encoding of TYPE
	
public: //Type detection
	bool IsIdentity(double tolerance = O3Epsilon(TYPE)) const; ///<Returns true if every element in the receiver equals the identity value plus or minus tolerance (which defaults to a small value appropriate for the receiver's type)
	bool IsZero(double tolerance = O3Epsilon(TYPE)) const; ///<Returns true if every element in the receiver equals zero plus or minus tolerance (which defaults to a small value appropriate for the receiver's type)
	bool IsNull(double tolerance = O3Epsilon(TYPE)) const {return IsZero(tolerance);} ///<See IsZero
	bool IsTransposeInvertable(double tolerance = O3Epsilon(TYPE)) const; ///<Returns weather or not the transpose of the receiver is its inverse (this usually only happens with rotation matricies)
	O3Mat_sq_TTT2 bool Equals(const O3Mat_sq_T2& other, double tolerance = O3Epsilon(TYPE)) const;
	O3Mat_sq_TTT2 bool IsEqual(const O3Mat_sq_T2& other, double tolerance = O3Epsilon(TYPE)) const {return Equals(other, tolerance);}
	
public: //Type conversion
	//Defined in O3DynamicMatrix.hpp
	operator const O3DynamicMatrix () const; ///<Automatically convert the receiver to an O3DynamicMatrix if appropriate.
	operator const TYPE* () const {return Values;} ///<Allows implicit conversion to a pointer to members (for easy integration with OpenGL & such)
	operator TYPE* () {return Values;} ///<Allows implicit conversion to a pointer to members (for easy integration with OpenGL & such)
	
public: //Interface
	std::string Description() const; ///<Returns a string describing the receiver
	
public: //Specific inversion methods
	O3Mat_sq_T& Invert3x4(); ///<Uses quick inversion technique (shamelessly stolen from OSG)
	O3Mat_sq_T& InvertLU(); ///<Uses lower-upper inversion technique
	O3Mat_sq_T& InvertAdjoint(); ///<Uses adjoint inversion technique
};
#endif /*defined(__cplusplus)*/
