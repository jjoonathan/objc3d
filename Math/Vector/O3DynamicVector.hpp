#pragma once
/**
 *  @file O3DynamicVector.hpp
 *  @license MIT License (see LICENSE.txt)
 *  @date 9/4/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "ObjCEncoding.h"
#import "O3EncodingInterpretation.h"	

///Access elements of the vector as so: <code>O3DynamicVector vec(stuff); vec.ElementOfTypeAt<double>(index);</code>. Replace "double" with the actual type of data you want to get out of it.
template <typename T>
const T O3DynamicVector::ElementOfTypeAt(int x) const {
	O3Assert(x<mElements, @"Cannot access item %i of dynamic vector with length %i.", x, mElements);
	switch (mElementType[0]) {
		case 'f':
			return ((float*)mVectorData)[x];
		case 'd':
			return ((double*)mVectorData)[x];
		case 'i':
			return ((int*)mVectorData)[x];
		case 'c':
			return ((char*)mVectorData)[x];
		case 's':
			return ((short*)mVectorData)[x];
		case 'l':
			return ((long*)mVectorData)[x];
		case 'q':
			return ((long long*)mVectorData)[x];
		case 'C':
			return ((unsigned char*)mVectorData)[x];
		case 'I':
			return ((unsigned int*)mVectorData)[x];
		case 'S':
			return ((unsigned short*)mVectorData)[x];
		case 'L':
			return ((unsigned long*)mVectorData)[x];
		case 'Q':
			return ((unsigned long long*)mVectorData)[x];
		default:
			O3Assert(false , @"Unknown objective C type encoding \"%s\" for DynamicVector element fetcher", mElements);
	}
	return 0;
}

template <typename T, int N>
O3Vec<T,N>::operator const O3DynamicVector () const  { ///<Allows vectors to be implicitly cast as dynamic vectors (so they can be passed dynamically)
	return O3DynamicVector(*this);
}

template <typename TYPE, int N>
O3Vec<TYPE,N>& O3Vec<TYPE,N>::Set(const O3DynamicVector& dvec) {
	int i; for (i=0;i<N;i++) Values[i] = dvec.ElementOfTypeAt<TYPE>(i);
	return *this;
}

template <typename T> void O3DynamicVector::SetElementAtTo(int x, T val) {
	O3Assert(x<mElements, @"Cannot access item %i of dynamic vector with size %i.", x, mElements);
	switch(*ElementType()) {
		case 'c':
			((const char*)VectorData())[x] = val;
			break;
		case 'C':
			((const unsigned char*)VectorData())[x] = val;
			break;				
		case 'i':
			((const int*)VectorData())[x] = val;
			break;
		case 'I':
			((const unsigned int*)VectorData())[x] = val;
			break;	
		case 's':
			((const short*)VectorData())[x] = val;
			break;
		case 'S':
			((const unsigned short*)VectorData())[x] = val;
			break;				
		case 'l':
			((const long*)VectorData())[x] = val;
			break;
		case 'L':
			((const unsigned long*)VectorData())[x] = val;
			break;	
		case 'q':
			((const long long*)VectorData())[x] = val;
			break;
		case 'Q':
			((const unsigned long long*)VectorData())[x] = val;
			break;	
		case 'f':
			((const float*)VectorData())[x] = val;
			break;
		case 'd':
			((const double*)VectorData())[x] = val;
			break;
		default:
			O3Assert(false , @"Unknown element type \"%s\" in O3DynamicVector::SetElementAtTo(...)", ElementType());
	}
}

template <typename T, int COLS>
O3DynamicVector::O3DynamicVector(const O3Vec<T, COLS>& vec) {
	SetISA();
	mVectorData = (void*)vec.Data();
	mType = @encode(O3Vec<T, COLS>);
	mElementType = @encode(T);
	mElements = vec.Size();
	mSize = sizeof(vec.Values);			
	mShouldFreePtrs = NO;
}
