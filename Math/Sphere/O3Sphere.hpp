/**
 *  @file O3Sphere.hpp
 *  @license MIT License (see LICENSE.txt)
 *  @date 11/5/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
using namespace ObjC3D::Math;

/*******************************************************************/ #pragma mark Constructors /*******************************************************************/
O3Sphere_TT O3Sphere_T::O3Sphere(const O3Box_T& box) {Set(box);}
O3Sphere_TT O3Sphere_T::O3Sphere(const pt& center, const real radius) {Set(center, radius);}
O3Sphere_TT O3Sphere_T::O3Sphere(const pt* points, const int count)   {Set(points, count);}

/*******************************************************************/ #pragma mark Setters /*******************************************************************/
O3Sphere_TT 
O3Sphere_T& O3Sphere_T::Set() {
	//MyCenter.Set(0); //Unnecessary
	//MyRadius = 0.;
	MyValid = false;
	return *this;
}

O3Sphere_TT 
O3Sphere_T& O3Sphere_T::Set(const O3Sphere_T& other) {
	MyCenter = other.MyCenter;
	MyRadius = other.MyRadius;
	MyValid = other.MyValid;
	return *this;
}

O3Sphere_TT 
O3Sphere_T& O3Sphere_T::Set(const O3Box_T& box) {
	MyValid = false;
	return Expand(box);
}

O3Sphere_TT 
O3Sphere_T& O3Sphere_T::Set(const pt* points, const int count) {
	MyValid = false;
	return Expand(points, count);
}

O3Sphere_TT 
O3Sphere_T& O3Sphere_T::SetCenter(const pt& center) {
	MyCenter = center;
	return *this;
}

O3Sphere_TT 
O3Sphere_T& O3Sphere_T::SetRadius(const real radius) {
	MyRadius = radius;
	return *this;
}

/*******************************************************************/ #pragma mark Radius Expanders /*******************************************************************/
O3Sphere_TT 
O3Sphere_T O3Sphere_T::GetExpandedRadius(const pt* points, const int count) {
	O3Sphere_T to_return(*this);
	return to_return.ExpandRadius(points, count);
}

O3Sphere_TT 
O3Sphere_T O3Sphere_T::GetExpandedRadius(const pt& point) {
	O3Sphere_T to_return(*this);
	return to_return.ExpandRadius(point);
}

O3Sphere_TT 
O3Sphere_T& O3Sphere_T::ExpandRadius(const pt* points, const int count) {
	O3Assert(MyValid, @"Invalid sphere");
	double radius_sq = MyRadius*MyRadius;
	bool changed = false;
	int i; for (i=0;i<count;i++) {
		double dist_sq = DistanceSquared(MyCenter, points[i]);
		if (radius_sq<dist_sq) {radius_sq = dist_sq; changed = true;}
	}
	if (changed) MyRadius = sqrt(radius_sq);
	return *this;
}

O3Sphere_TT 
O3Sphere_T& O3Sphere_T::ExpandRadius(const pt& point) {
	O3AssertIvar(MyValid);
	double dist_sq = DistanceSquared(MyCenter, point);
	if ((MyRadius*MyRadius)<dist_sq) MyRadius = sqrt(dist_sq);
}

//Invalid below here, TODO
/*******************************************************************/ #pragma mark Expanders /*******************************************************************/
O3Sphere_TT 
O3Sphere_T& O3Sphere_T::Expand(const pt& point) {
	if (MyValid) {
		O3Vec3r direction_vec = point - MyCenter;
		double distance_sq = direction_vec.LengthSquared();
		if (distance_sq>(MyRadius*MyRadius)) {
			double distance = sqrt(distance_sq);
			double dr = (distance-MyRadius)*.5;
			MyCenter += direction_vec*(dr/distance);
			MyRadius += dr;
		}
	} else {
		MyCenter = point;
		MyRadius = 0.0;
	}
}

O3Sphere_TT 
O3Sphere_T  O3Sphere_T::GetExpanded(const pt& point) {
	O3Sphere_T to_return(*this);
	return to_return.Expand(point);
}

O3Sphere_TT 
O3Sphere_T& O3Sphere_T::Expand(const pt* points, const int count) {
	int i;
	for (i=0;i<count;i++) Expand(points[i]);
}

O3Sphere_TT 
O3Sphere_T  O3Sphere_T::GetExpanded(const pt* points, const int count) {
	O3Sphere_T to_return(*this);
	return to_return.Expand(points, count);
}

O3Sphere_TT 
O3Sphere_T& O3Sphere_T::Expand(const std::vector<pt> points) {
	int i;
	for (i=0;i<points.size();i++) Expand(points[i]);
}

O3Sphere_TT 
O3Sphere_T  O3Sphere_T::GetExpanded(const std::vector<pt> points) {
	O3Sphere_T to_return(*this);
	return to_return.Expand(points);
}

O3Sphere_TT 
O3Sphere_T& O3Sphere_T::Expand(const O3Sphere_T& other) {
	if (other.MyValid) {
		if (MyValid) {
			O3Vec3r direction_vec = other.MyCenter - MyCenter;
			double dv_len_sq = direction_vec.LengthSquared();
			if (O3Equals(dv_len_sq, 0., O3Epsilon(real))) {
				if (other.MyRadius>MyRadius) MyRadius = other.MyRadius;
				return *this;
			}
			double dv_len = sqrt(dv_len_sq);
			if ((dv_len+other.MyRadius)>MyRadius) {
				O3Vec3r e1 = MyCenter-(direction_vec*(MyRadius/dv_len));
				O3Vec3r e2 = other.MyCenter+(direction_vec*(other.MyRadius/dv_len));
				MyCenter = (e1+e2)*.5;
				MyRadius = (e2-MyCenter).Length();
			}
		} else {
			MyCenter = other.MyCenter;
			MyRadius = other.MyRadius;
		}
	}
	return *this;
}

O3Sphere_TT 
O3Sphere_T  O3Sphere_T::GetExpanded(const O3Sphere_T& other) {
	return O3Sphere_T(*this).Expand(other);
}

O3Sphere_TT 
O3Sphere_T& O3Sphere_T::Expand(const O3Box_T& O3Box) {
	Expand(O3Box.GetCorners());
}

O3Sphere_TT 
O3Sphere_T  O3Sphere_T::GetExpanded(const O3Box_T& O3Box) {
	return GetExpanded(O3Box.GetCorners());
}
