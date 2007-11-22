#pragma once
#ifdef __cplusplus
/**
 *  @file O3LineSegment.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 10/4/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#include "Math.h"
#include "O3Point.h"
#include "O3Vector.h"

#define LineSeg_T LineSegment<TYPE, DIMENSIONS>
#define LineSeg_pt_T  O3Point<TYPE, DIMENSIONS>
#define LineSeg_TT template<typename TYPE, int DIMENSIONS>

LineSeg_TT class LineSegment {
	LineSeg_pt_T MyStart, MyEnd; //Uses start and end rather than origin + vector to increase precision
	
  public: //Constructors
  	LineSegment() {};	///<Returns a new (not necessarily zero) line segment.
  	LineSegment(const LineSeg_T& line) {Set(line);}; ///<Copy constructor
  	LineSegment(LineSeg_pt_T start, LineSeg_pt_T end) : MyStart(start), MyEnd(end) {}; ///<Constructs a line segment from a starting point and an ending point.
  	LineSegment(LineSeg_pt_T point, O3Vec3r vector) : MyStart(point), MyEnd(point+vector) {}; ///<Constructs a line segment from a starting point and a vector (ending point is starting point + vector).
  	
  public: //Setters
	LineSeg_T& Set(const LineSeg_T& line); ///<Copy constructor
  	LineSeg_T& Set(LineSeg_pt_T start, LineSeg_pt_T end); ///<Sets a line segment to a starting point and an ending point.
  	LineSeg_T& Set(LineSeg_pt_T point, O3Vec3r vector); ///<Sets a line segment to a starting point and a vector (ending point is starting point + vector).
	LineSeg_T& SetStart(LineSeg_pt_T point);	///<Sets the start point
	LineSeg_T& SetEnd(LineSeg_pt_T point);		///<Sets the end point
	LineSeg_T& SetVector(O3Vec3r vector);	///<Sets the vector that goes from the start point to the end point
	
  public: //Accessors
	LineSeg_pt_T& Start()		{return MyStart;};
  	LineSeg_pt_T& End()		{return MyEnd;};
  	LineSeg_pt_T  GetStart()	const	{return MyStart;};
  	LineSeg_pt_T  GetEnd()	const	{return MyEnd;};
	LineSeg_pt_T  GetVector() const   {return MyEnd-MyStart;}

public: //Methods
	bool Parallel(const LineSeg_T& other_segment, real tollerance); ///<Tests weather two line segments are parallel with difference in xy slope + difference in xz slope < tollerance (which defaults to epsilon)
				  
  public: //Operators
	LineSeg_T& operator=(const LineSeg_T& other_segment);
	bool operator==(const LineSeg_T& other_segment) const; ///<Tests equality (NOTE: LineSeg_T(a,b) != LineSeg_T(b,a))
	bool operator!=(const LineSeg_T& other_segment) const; ///<Tests inequality (returns !operator==)
};
#endif /*defined(__cplusplus)*/
