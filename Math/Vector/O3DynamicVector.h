#pragma once
/**
 *  @file O3DynamicVector.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 9/4/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "ObjCEncoding.h"
#import "O3EncodingInterpretation.h"
class O3DynamicMatrix;


/**
 * This struct gives Vectors the ability to be semi-dynamic. See O3Value +valueWithVector: for a sample implementation (you can pass Vectors as DynamicVectors and it will Just Work).
 * If you can, you should use O3Value, since DynamicMatrix is not memory managed.
 * @note This depends indirectly on Objective-C's @encode. You can use a DynamicVector without ObjC but it will be worthless because you won't be able to actually make one (O3Vec's automatic cast to DynamicVector isn't present in plain c++).
 * @warn Never keep one of these around. As a rule of thumb, you should never type DynamicVector except as the type expected in an argument. You should never explicitly create one, in other words.
 * @note A DynamicVector is an alias back to the original, so if the original changes any DynamicVector referencing it changes as well. 
 */
class O3DynamicVector {
private:
	void* mVectorData; 	///<The vector data the receiver represents
	const char* mType; 			///<The @encode type of the overall mVectorData
	const char* mElementType; 	///<The @encode type of the elements in mVectorData
	UInt16 mElements;			///<The number of elements in mVectorData
	UInt16 mSize;	 			///<The number of bytes in mVectorData
	BOOL mShouldFreePtrs;		///<YES if the receiver made duplicates of mMatrixData, mType, and mElementType and needs to free them
	
public:
	template <typename T, int COLS> O3DynamicVector(const O3Vec<T, COLS>& vec);
	O3DynamicVector(const char* encoding, const void* data);
	O3DynamicVector(const O3DynamicMatrix& mat); ///<Creates a vector from a dynamic row or column matrix
	~O3DynamicVector();
	
	void CopyData(); ///<Transfers ownership of the matrix to the receiver by copying it.

	//Accessors
	const void* VectorData() const {return mVectorData;}
	const char* Type() const {return mType;}
	const char* ElementType() const {return mElementType;}
	UInt16 Rows() const {return 1;}
	UInt16 Columns() const {return mElements;}
	UInt16 Elements() const {return mElements;}
	UInt16 Size() const {return mSize;}

	template <typename T> const T ElementOfTypeAt(int x) const;
	template <typename T> void O3DynamicVector::SetElementAtTo(int x, T val);
	void SetTo(const O3DynamicVector& other); ///<Replaces the vector represented by the receiver with the vector represented by other. Regular casting rules apply.

private:
	void SetISA() const {}; ///<Doesn't actually do anything now
};

//These are declared elsewhere, but are here for clarity:
//template <typename T, int N> O3Vec<T,N>::operator const O3DynamicVector () const;
//template <typename T, int N> O3Vec<T,N>& O3Vec<T,N>::Set(const O3DynamicVector& dvec);
