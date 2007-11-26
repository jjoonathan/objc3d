#pragma once
#ifdef __cplusplus
/**
 *  @file O3Sphere.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 11/5/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
template <int DIMENSIONS> class O3Box;

#define O3Sphere_T O3Sphere<DIMENSIONS>
#define O3Sphere_TT template<int DIMENSIONS>
#define O3Sphere_box_T O3Box<DIMENSIONS>

O3Sphere_TT
class O3Sphere {
	typedef O3Point<real, DIMENSIONS> pt;
	typedef O3Vec<real, DIMENSIONS> vec;
	
	pt MyCenter;
	real MyRadius;
	bool MyValid;
	
public: //Constructors
		O3Sphere(): MyValid(false) {}; ///<Default constructor, returns an "invalid" sphere (does not include origin
	O3Sphere(const O3Sphere_T& other):	MyCenter(other.MyCenter), 
									MyRadius(other.MyRadius),
									MyValid(other.MyValid) {}; ///<Copy constructor
	O3Sphere(const O3Sphere_box_T& box); ///<Create a bounding O3Sphere from a bounding O3Box
	O3Sphere(const pt& center, const real radius); ///<Generate a O3Sphere with a center and a radius
	O3Sphere(const pt* points, const int count); ///<Generate a O3Sphere as the smallest O3Sphere that can contain all points in points
	
public: //Setters
	O3Sphere_T& Set(); ///<Sets the receiver to a 0 radius sphere on the origin. NOTE: if you subsequently expand it to include some points, the origin will not be included.
	O3Sphere_T& Set(const O3Sphere_T& other); ///<Copy setter
	O3Sphere_T& Set(const O3Sphere_box_T& box); ///<Create a bounding sphere containing box
	O3Sphere_T& Set(const pt* points, const int count); ///<Sets the receiver to the smallest O3Sphere that can contain the points in points
	O3Sphere_T& SetCenter(const pt& center); ///<Sets the center point of the receiver
	O3Sphere_T& SetRadius(const real radius); ///Sets the radius of the receiver
	
public: //Expanders
	O3Sphere_T& Expand(const std::vector<pt> points); ///<Expands the receiver (if necessary) to include points
	O3Sphere_T  GetExpanded(const std::vector<pt> points); ///<Returns a copy of the receiver, expanded (if necessary) to include points
	O3Sphere_T& Expand(const pt& point); ///<Expands the receiver (if necessary) to include point
	O3Sphere_T  GetExpanded(const pt& point); ///<Returns a copy of the receiver, expanded (if necessary) to include point
	O3Sphere_T& Expand(const pt* points, int count); ///<Expands the receiver to include count points pointed at by points
	O3Sphere_T  GetExpanded(const pt* points, int count); ///<Returns a copy of the receiver, expanded to include count points pointed at by points
	O3Sphere_T& Expand(const O3Sphere_T& other); ///<Expands the receiver (if  necessary) to include other
	O3Sphere_T  GetExpanded(const O3Sphere_T& other); ///<Returns a copy of the receiver, expanded (if  necessary) to include other
	O3Sphere_T& Expand(const O3Sphere_box_T& O3Box); ///<Expands the receiver (if necesssary) to include O3Box
	O3Sphere_T  GetExpanded(const O3Sphere_box_T& O3Box); ///<Returns a copy of the receiver, expanded (if necesssary) to include O3Box

	O3Sphere_T& ExpandRadius(const pt& point); ///<Expands the receiver (if necessary) to include point without moving the center
	O3Sphere_T  GetExpandedRadius(const pt& point); ///<Returns a copy of the receiver, expanded (if necessary) to include point but with the same center
	O3Sphere_T& ExpandRadius(const pt* points, const int count); ///<Expands the receiver to include count points pointed at by points, but does not move the center
	O3Sphere_T  GetExpandedRadius(const pt* points, const int count); ///<Returns a copy of the receiver, expanded to include count points pointed at by points, but does not move the center
	O3Sphere_T& ExpandRadius(const O3Sphere_T& other); ///<Expands the receiver (if  necessary) to include other, but does not move the center
	O3Sphere_T  GetExpandedRadius(const O3Sphere_T& other); ///<Returns a copy of the receiver, expanded (if  necessary) to include other, but does not move the center
	O3Sphere_T& ExpandRadius(const O3Sphere_box_T& O3Box); ///<Expands the receiver (if necesssary) to include O3Box, but does not move the center
	O3Sphere_T  GetExpandedRadius(const O3Sphere_box_T& O3Box); ///<Returns a copy of the receiver, expanded (if necesssary) to include O3Box, but does not move the center
};
#endif /*defined(__cplusplus)*/
