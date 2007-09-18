#pragma once
/**
 *  @file O3DynamicMatrix.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 9/4/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
/**
* This struct gives Matricies the ability to be semi-dynamic. See O3Value +valueWithMatrix: for a sample implementation (you can pass Matricies as DynamicMatrix-es and it will Just Work).
 * If you can, you should use O3Value, since DynamicMatrix is not memory managed. 
 * @note This depends indirectly on Objective-C's @encode. You can use a DynamicMatrix without ObjC (update: nope) but it will be worthless because you won't be able to actually make one (O3Mat's automatic cast to DynamicMatrix isn't present in plain c++).
 * @warn Never keep one of these around. As a rule of thumb, you should never type DynamicMatrix except as the type expected in an argument. You should never explicitly declare one, in other words.
 * @note A DynamicMatrix is an alias back to the original, so if the original changes any DynamicMatrix referencing it changes as well.
 */
class O3DynamicMatrix {
private:
	const void* mMatrixData; 	///<The matrix data the receiver represents
	mutable const char* mType; 			///<The @encode type of the overall mMatrixData
	const char* mElementType; 	///<The @encode type of the elements in mMatrixData
	UInt16 mRows, mColumns; 	///<The number of rows and columns in mMatrixData
	UInt16 mSize;	 			///<The number of bytes in mMatrixData
	mutable BOOL mShouldFreeMatrixDat:1;		///<YES if the receiver made a duplicate of mMatrixData and needs to free it
	mutable BOOL mShouldFreeType:1;		///<YES if the receiver made a duplicate of mType and needs to free it
	mutable BOOL mShouldFreeEleType:1;		///<YES if the receiver made a duplicate of mElementType and needs to free it
	
public:
	template <typename T, int R, int C>	O3DynamicMatrix(const O3Mat<T,R,C>& mat);
	template <typename T, int COLS>		O3DynamicMatrix(const O3Vec<T, COLS>& vec);	
	O3DynamicMatrix(const O3DynamicMatrix& other);
	O3DynamicMatrix(const O3DynamicVector& vec);
	O3DynamicMatrix(const char* encoding, const void* data, BOOL freeWhenDone = NO);
	O3DynamicMatrix(O3BufferedReader* r);
	~O3DynamicMatrix();
	
	void CopyData(); ///<Transfers ownership of the matrix to the receiver by copying it.	
	
	//Accessors
	NSData* PortableData() const;
	const void* MatrixData() const {return mMatrixData;}
	const char* ElementType() const {return mElementType;}
	const BOOL IsEqual(const O3DynamicMatrix* other);
	UInt16 Rows() const {return mRows;}
	UInt16 Columns() const {return mColumns;}
	UInt32 Elements() const {return mRows*mColumns;}
	UInt16 Size() const {return mSize;}
	const char* Type() const { ///<Lazy loads Typo (lawls. I meant Type.) if it hasn't already been made
		if (mType) return mType;
		char* type = (char*)malloc(32);
		snprintf(type, 32, "[%i[%i%s]]",Rows(), Columns(), ElementType());
		O3Assert(!mShouldFreeType,@"???"); mShouldFreeType = YES;
		return mType = type;
	}
	
	template <typename T> const T ElementOfTypeAt(int row, int col) const; ///<Access elements of the matrix as so: <code>O3DynamicMatrix mat(stuff); mat.ElementOfTypeAt<double>(row,col);</code>. Replace "double" with the actual type of data you want to get out of it.
	template <typename T> void SetElementAtTo(int row, int col, T val); ///<Sets the element at (row, col) to val.
	void SetTo(const O3DynamicMatrix& other); ///<Replaces the matrix represented by the receiver with the matrix represented by other. Regular casting rules apply.

private:
	void initWithEncoding_data_(const char* encoding, const void* data, BOOL freeWhenDone = NO);
	void initWithRows_Cols_ElementType_data_(int rows, int cols, const char* ele_type, const void* data, BOOL freeMatWhenDone = NO, BOOL freeEleTypeWhenDone = NO);
	void SetISA() const {};
	template <typename T> void O3DynamicMatrix::SetToType(const O3DynamicMatrix& other);
};

//These are declared elsewhere, but are here for clarity:
//template <typename T, int R, int C> O3Mat<T,R,C>::operator const O3DynamicMatrix () const;	///<Automatically creates a DynamicMatrix if warranted
//O3Mat_sq_TT O3Mat_sq_T& O3Mat_sq_T::Set(const O3DynamicMatrix& dynm);	///<Set a matrix to the values represented by a DynamicMatrix (mostly for the ObjC interface)
//O3Mat_TT2 O3Mat_T& O3Mat_T::Set(const O3DynamicMatrix& dynm);	///<Set a matrix to the values represented by a DynamicMatrix (mostly for the ObjC interface)
