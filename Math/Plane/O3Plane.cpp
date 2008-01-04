/*
 *  O3Plane.cpp
 *  ObjC3D
 *
 *  Created by Jonathan deWerd on 10/4/06.
 *  Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 *
 */
#include "O3Plane.h"

using namespace ObjC3D::Math;

/*******************************************************************/ #pragma mark Setters /*******************************************************************/
Plane& Plane::Set()   {MyA=0; MyB=0; MyC=1; MyD=0; return *this;}
Plane& Plane::SetXY() {MyA=0; MyB=0; MyC=1; MyD=0; return *this;}
Plane& Plane::SetXZ() {MyA=0; MyB=1; MyC=0; MyD=0; return *this;}
Plane& Plane::SetYZ() {MyA=1; MyB=0; MyC=0; MyD=0; return *this;}
Plane& Plane::SetA(real val) {MyA=val; return *this;}
Plane& Plane::SetB(real val) {MyB=val; return *this;}
Plane& Plane::SetC(real val) {MyC=val; return *this;}
Plane& Plane::SetD(real val) {MyD=val; return *this;}

Plane& Plane::Set(const Plane& other_plane) {
	MyA = other_plane.GetA();
	MyB = other_plane.GetB();
	MyC = other_plane.GetC();
	MyD = other_plane.GetD();
	return *this;
}

Plane& Plane::Set(real a, real b, real c, real d) {
	MyA = a;
	MyB = b;
	MyC = c;
	MyD = d;
	return *this;
}

Plane& Plane::Set(const O3Point3& pt, O3Vec3r vec) {
	vec.Normalize();
	MyA = vec.X();
	MyB = vec.Y();
	MyC = vec.Z();
	MyD = -(pt.GetX()*MyA + pt.GetY()*MyB + pt.GetZ()*MyC);
	return *this;
}

Plane& Plane::Set(const O3Point3& p0, const O3Point3& p1, const O3Point3& p2) {
	O3Vec3r v0(p0-p1);
	O3Vec3r v1(p2-p1);
	O3Vec3r n = v1^v0; //Cross product
	n.Normalize();
	MyA = n.X();
	MyB = n.Y();
	MyC = n.Z();
	MyD = -(n.X()*MyA + n.Y()*MyB + n.Z()*MyC);
	return *this;
}

/*******************************************************************/ #pragma mark Operators /*******************************************************************/
Plane& Plane::operator=(const Plane& other_plane) {
	MyA = other_plane.GetA();
	MyB = other_plane.GetB();
	MyC = other_plane.GetC();
	MyD = other_plane.GetD();
	return *this;
}
/*******************************************************************/ #pragma mark Methods /*******************************************************************/
real Plane::Dot(const O3Vec3r& v) const {
	return	GetA()*v.GetX() + 
	GetB()*v.GetY() + 
	GetC()*v.GetZ();
}

real Plane::Distance(const O3Point3 pt) const {
	return GetA()*pt.GetX() + GetB()*pt.GetY() + GetC()*pt.GetZ() + GetD();
}

O3Point3& Plane::Reflect(O3Point3& pt) const {
	real d = Distance(pt);
	pt += (-Normal().Normalize()*d) * 2;
	return pt;
}

O3Point3 Plane::GetReflected(O3Point3 pt) const {
	real d = Distance(pt);
	return O3Point3(pt + -Normal().Normalize()*d*2	);
}

O3Point3& Plane::Project(O3Point3& pt) const {
	real d = Distance(pt);
	pt.X() -= GetA()*d;
	pt.Y() -= GetB()*d;
	pt.Z() -= GetC()*d;
	return pt;
}

O3Point3 Plane::GetProjected(O3Point3 pt) const {
	real d = Distance(pt);
	return O3Point3( pt.GetX() - GetA()*d,
				   pt.GetY() - GetB()*d,
				   pt.GetZ() - GetC()*d );
}

/*******************************************************************/ #pragma mark Accessors and meta-attributes /*******************************************************************/
O3Vec3r Plane::Normal() const {
	return O3Vec3r(MyA, MyB, MyC);
}