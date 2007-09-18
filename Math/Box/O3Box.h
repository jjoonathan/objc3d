#pragma once
/**
 *  @file O3Box.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 11/5/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
template<int DIMENSIONS> class O3Sphere;

#define O3Box_T O3Box<DIMENSIONS>
#define O3Box_TT template<int DIMENSIONS>
#define O3Box_sphere_T O3Sphere<DIMENSIONS>

O3Box_TT
class O3Box {
	typedef O3Point<real, DIMENSIONS> pt;
	typedef O3Vec<real, DIMENSIONS> vec;
	typedef std::vector<pt> Array_pt;
	
	pt MyMin, MyMax;
	
public: //Constructors
	O3Box(): MyMin(O3TypeMax(real)), MyMax(-O3TypeMax(real)) {}; ///<Default constructor, returns a box whose max point is -O3TypeMax(TYPE) and whose min point is -O3TypeMin(TYPE) (and is therefore "empty")
	O3Box(const O3Box_T& other): MyMin(other.MyMin), MyMax(other.MyMax) {}; ///<Copy constructor
	O3Box(const O3Box_sphere_T& sphere); ///<Create a bounding box from a bounding sphere
	O3Box(const pt& min, const pt& max); ///<Generate a box between two points (do NOT need to be ordered necesarily)
	O3Box(const pt* points, const int count); ///<Generate a box as the smallest box that can contain all points in points
	
public: //Setters
	O3Box_T& Set(); ///<Sets the receiver to the "empty" box (NOTE: this does not mean the box at the origin. For example, if you calles a.Set() then a.Expand(&{b,c},2), a would then be the box between b and c.
	O3Box_T& Set(const O3Box_T& other); ///<Copy setter
	O3Box_T& Set(const O3Box_sphere_T& sphere); ///<Copy setter
	O3Box_T& Set(const pt& min, const pt& max); ///<Sets the receiver to be the box between min and max (note: min and max don't have to be axially correct)
	O3Box_T& Set(const pt* points, const int count); ///<Sets the receiver to the smallest axially aligned box that can contain the points in points
	O3Box_T& SetMin(pt min); ///<Sets the min point of the receiver to min
	O3Box_T& SetMax(pt max); ///Sets the mac point of the receiver to include max
	
public: //Inspectors
	pt& Min() {return MyMin;}
	pt& Max() {return MyMax;}
	pt  GetMin() {return MyMin;}
	pt  GetMax() {return MyMax;}
	int GetDimensions();
	
public: //Expanders
	O3Box_T& Expand(const pt& point); ///<Expands the receiver (if necessary) to include point
	O3Box_T  GetExpanded(const pt& point); ///<Returns a copy of the receiver, expanded (if necessary) to include point
	O3Box_T& Expand(const pt* points, int count); ///<Expands the receiver to include count points pointed at by points
	O3Box_T  GetExpanded(const pt* points, int count); ///<Returns a copy of the receiver, expanded to include count points pointed at by points
	O3Box_T& Expand(const O3Box_T& other); ///<Expands the receiver (if  necessary) to include other
	O3Box_T  GetExpanded(const O3Box_T& other); ///<Returns a copy of the receiver, expanded (if  necessary) to include other
	O3Box_T& Expand(const O3Box_sphere_T& sphere); ///<Expands the receiver (if necesssary) to include sphere
	O3Box_T  GetExpanded(const O3Box_sphere_T& sphere); ///<Returns a copy of the receiver, expanded (if necesssary) to include sphere
	
private:
	void FixCorners();
	
public:
	Array_pt GetCorners() const { //GCC has issues when this is taken out of the header?
		int corners = 1;
		int i,j; for (i=0;i<DIMENSIONS;i++) corners *= 2;
		Array_pt to_return(corners);
		for (i=0;i<corners;i++) {
			pt point;
			for (j=0;j<DIMENSIONS;j++)
				point[j] = ((i>>j)&1)? MyMax[j] : MyMin[j];
			to_return.push_back(point);
		}
		return to_return;
	}
};

