/**
 *  @file O3Plane.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 10/4/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#ifndef O3FILE_PLANE_H
#define O3FILE_PLANE_H

namespace ObjC3D {
namespace Math {

class Plane {
	real MyA, MyB, MyC, MyD;

public: //Constructors
	static Plane XY() {return Plane(0.0, 0.0, 1.0, 0.0);}	///<Returns the XY plane.
	static Plane XZ() {return Plane(0.0, 1.0, 0.0, 0.0);}	///<Returns the XZ plane.
	static Plane YZ() {return Plane(1.0, 0.0, 0.0, 0.0);}	///<Returns the YZ plane.
	Plane() : 
		MyA(0.0), 
		MyB(0.0),
		MyC(1.0),
		MyD(0.0) {};				///<Constructs the XY plane.
	Plane(const Plane& other_plane) : 
		MyA(other_plane.GetA()), 
		MyB(other_plane.GetB()),
		MyC(other_plane.GetC()),
		MyD(other_plane.GetD()) {}; 	///<Constructs a plane from another plane.
	Plane(real a, real b, real c, real d) : 
		MyA(a), 
		MyB(b),
		MyC(c),
		MyD(d) {}; 	///<Constructs a plane with a, b, c, and d values for the plane equation.
	Plane(const O3Point3& pt, O3Vec3r vector) {Set(pt, vector);};						///<Constructs a plane from a point and a vector
	Plane(const O3Point3& p1, const O3Point3& p2, const O3Point3& p3) {Set(p1,p2,p3);}; 	///<Constructs a plane from three points.
	
public: //Setters
	Plane& Set();   ///<Sets to the XY plane
	Plane& SetXY(); ///<Sets to the XY plane
	Plane& SetXZ(); ///<Sets to the XZ plane
	Plane& SetYZ(); ///<Sets to the YZ plane
	Plane& SetA(real val); ///<Sets the A component of the plane equation
	Plane& SetB(real val); ///<Sets the B component of the plane equation
	Plane& SetC(real val); ///<Sets the C component of the plane equation
	Plane& SetD(real val); ///<Sets the D component of the plane equation
	Plane& Set(const Plane& other_plane);			///<Set a plane to another plane (like =)
	Plane& Set(real a, real b, real c, real d);		///<Set a plane to the four coefficents of the plane equation (ax+by+cz+d=0)
	Plane& Set(const O3Point3& pt, O3Vec3r vector); 	///<Set a plane to the plane defined by point pt and normal vector
	Plane& Set(const O3Point3& p1, const O3Point3& p2, const O3Point3& p3); ///<Set a plane to the plane defined by points p1, p2, and p3

public: //Methods
	real Dot(const O3Vec3r& v) const;
	real Distance(const O3Point3 pt) const;			///<Returns the distance between pt and the receiver.
	O3Point3& Reflect(O3Point3& pt) const;			///<Reflects pt over the receiver
	O3Point3   GetReflected(O3Point3 pt) const;	///<Gets a copy of pt reflected over the receiver
	O3Point3& Project(O3Point3& pt) const;			///<Projects pt onto the receiver
	O3Point3   GetProjected(O3Point3 pt) const;	///<Gets a copy of pt projected onto the receiver
	
public: //Accessors and meta-attributes
	real& A() {return MyA;}
	real& B() {return MyB;}
	real& C() {return MyC;}
	real& D() {return MyD;}
	real  GetA() const {return MyA;}
	real  GetB() const {return MyB;}
	real  GetC() const {return MyC;}
	real  GetD() const {return MyD;}
	O3Vec3r Normal() const; ///<Returns the NOT-NECESARILY-NORMALIZED normal vector.
	real* Data() {return (real*)&MyA;} ///<@todo clean this up

public: //Operators
	Plane& operator=(const Plane& other_plane);
	template<typename TYPE> Plane& operator=(const O3Vec<TYPE, 4>& v) {
			return Set(v[0], v[1], v[2], v[3]);
	}
};

} //end namespace Math
} //end namespace ObjC3D

#endif
