#ifdef __cplusplus
/**
 *  @file O3Box.hpp
 *  @license MIT License (see LICENSE.txt)
 *  @date 11/5/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
/*******************************************************************/ #pragma mark Constructors /*******************************************************************/
O3Box_TT
O3Box_T::O3Box(const pt& min, const pt& max) {
	Set(min, max);
}

O3Box_TT
O3Box_T::O3Box(const pt* points, const int count) {
	Set(points, count);
}

O3Box_TT
O3Box_T::O3Box(const O3Box_sphere_T& sphere) {
	Set(sphere);
}

/*******************************************************************/ #pragma mark Setters /*******************************************************************/
O3Box_TT
O3Box_T& O3Box_T::Set() {
	MyMin = O3TypeMax(real);
	MyMax = -O3TypeMax(real);
	return *this;
}

O3Box_TT
O3Box_T& O3Box_T::Set(const O3Box& other) {
	MyMin = other.MyMin;
	MyMax = other.MyMax;
	return *this;
}

O3Box_TT
O3Box_T& O3Box_T::Set(const pt& min, const pt& max) {
	MyMin = min;
	MyMax = max;
	FixCorners();
	return *this;
}

O3Box_TT
O3Box_T& O3Box_T::Set(const pt* points, const int count) {
	Set();
	Expand(points, count);
	return *this;
}

O3Box_TT
O3Box_T& O3Box_T::SetMin(pt min) {
	MyMin=min;
	return *this;
}

O3Box_TT
O3Box_T& O3Box_T::SetMax(pt max) {
	MyMax=max;
	return *this;
}

/*******************************************************************/ #pragma mark Setters /*******************************************************************/
O3Box_TT
O3Box_T& O3Box_T::Expand(const pt& point) {
	int i; for (i=0;i<DIMENSIONS;i++) {
		real val = point[i];
		if (MyMin[i]<val) MyMin[i]=val;
		if (MyMax[i]>val) MyMax[i]=val;
	}
	return *this;
}

O3Box_TT
O3Box_T  O3Box_T::GetExpanded(const pt& point) {
	O3Box_T to_return(*this);
	int i; for (i=0;i<DIMENSIONS;i++) {
		real val = point[i];
		if (to_return.MyMin[i]<val) to_return.MyMin[i]=val;
		if (to_return.MyMax[i]>val) to_return.MyMax[i]=val;
	}
	return to_return;
}

O3Box_TT
O3Box_T& O3Box_T::Expand(const pt* points, int count) {
	int i,j;
	for (j=0;j<count;j++)
		for (i=0;i<DIMENSIONS;i++) {
			real val = points[j][i];
			if (MyMin[i]<val) MyMin[i]=val;
			if (MyMax[i]>val) MyMax[i]=val;
		}
	return *this;	
}

O3Box_TT
O3Box_T  O3Box_T::GetExpanded(const pt* points, int count){
	O3Box_T to_return(*this);
	int i,j;
	for (j=0;j<count;j++)
		for (i=0;i<DIMENSIONS;i++) {
			real val = points[j][i];
			if (to_return.MyMin[i]<val) to_return.MyMin[i]=val;
			if (to_return.MyMax[i]>val) to_return.MyMax[i]=val;
		}
	return to_return;
}

O3Box_TT
O3Box_T& O3Box_T::Expand(const O3Box_T& other) {
	Expand(other.MyMin);
	return Expand(other.MyMax);
}

O3Box_TT
O3Box_T  O3Box_T::GetExpanded(const O3Box_T& other) {
	O3Box_T to_return(*this);
	to_return.Expand(other.MyMin);
	return to_return.Expand(other.MyMax);
}

O3Box_TT
O3Box_T& O3Box_T::Expand(const O3Box_sphere_T& sphere) {
	pt center = sphere.GetCenter();
	real radius = sphere.GetRadius();
	Expand(center+radius);
	Expand(center-radius);
	return *this;
}
	
O3Box_TT
O3Box_T O3Box_T::GetExpanded(const O3Box_sphere_T& sphere) {
	O3Box_T to_return(*this);
	pt center = sphere.GetCenter();
	real radius = sphere.GetRadius();
	to_return.Expand(center+radius);
	to_return.Expand(center-radius);
	return to_return;	
}


O3Box_TT
void O3Box_T::FixCorners() {
	int i; for (i=0;i<DIMENSIONS;i++) {
		if(MyMin[i]>MyMax[i]) O3swap(MyMin[i], MyMax[i]);
	}
}
#endif /*defined(__cplusplus)*/
