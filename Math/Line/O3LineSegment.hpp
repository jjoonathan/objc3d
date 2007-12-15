#ifdef __cplusplus
/**
 *  @file O3LineSegment.hpp
 *  @license MIT License (see LICENSE.txt)
 *  @date 10/4/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
/*******************************************************************/ #pragma mark Setters /*******************************************************************/
LineSeg_TT
LineSeg_T& LineSeg_T::Set(const LineSeg_T& line) {
	*this = line;
	return *this;
}

LineSeg_TT
LineSeg_T& LineSeg_T::Set(LineSeg_pt_T start, LineSeg_pt_T end) {
	MyStart = start;
	MyEnd = end;
	return *this;
}

LineSeg_TT
LineSeg_T& LineSeg_T::Set(LineSeg_pt_T point, O3Vec3r vector) {
	MyStart = point;
	MyEnd = point+vector;
	return *this;
}

/*******************************************************************/ #pragma mark Operators /*******************************************************************/
LineSeg_TT
LineSeg_T& LineSeg_T::operator=(const LineSeg_T& other_segment) {
	MyStart = other_segment.GetStart();
	MyEnd = other_segment.GetEnd();
	return *this;
}

LineSeg_TT
bool LineSeg_T::operator==(const LineSeg_T& other_segment) const {
	if (other_segment.GetStart() != GetStart()) return false;
	if (other_segment.GetEnd() != GetEnd()) return false;
	return true;
}

LineSeg_TT
bool LineSeg_T::operator!=(const LineSeg_T& other_segment) const {
	return !operator==(other_segment);
}

/*******************************************************************/ #pragma mark Methods /*******************************************************************/
LineSeg_TT
bool  LineSeg_T::Parallel(const LineSeg_T& other_segment, real tollerance = O3Epsilon(TYPE)) {
	LineSeg_pt_T other_start = other_segment.GetStart(); //For more efficency: a/b=c/d a=bc/d ad=bc (but screws up tollerance)
	LineSeg_pt_T other_end   = other_segment.GetEnd();
	double my_xyslope = (MyStart.GetY()-MyEnd.GetY()) / (MyStart.GetX()-MyEnd.GetX());
	double other_xyslope = (other_start.GetY()-other_end.GetY()) / (other_start.GetX()-other_end.GetX());
	if (!O3Equals(my_xyslope, other_xyslope, O3Epsilon(real)*2.)) return false;
	double my_xzslope = (MyStart.GetZ()-MyEnd.GetZ()) / (MyStart.GetX()-MyEnd.GetX());
	double other_xzslope = (other_start.GetZ()-other_end.GetZ()) / (other_start.GetX()-other_end.GetX());
	if (!O3Equals(my_xzslope, other_xzslope, O3Epsilon(real)*2.)) return false;
	return true;
}
#endif /*defined(__cplusplus)*/
