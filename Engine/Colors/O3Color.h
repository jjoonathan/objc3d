/**
 *  @file O3Color.h
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#ifndef O3FILE_COLOR_H
#define O3FILE_COLOR_H

#include "O3Global.h"
#include "O3Vector.h"

using namespace ObjC3D::Math;

namespace ObjC3D {
namespace Engine {
		
#pragma pack(push, 0)
		class Color : private O3Vec4r {
			
public: //Initializers
			Color(): O3Vec4r(1,.3,.3,.7) {}; ///<Default initializer initializes to a red-ish color that is easy to see
			Color(float r, float g, float b): O3Vec4r(r,g,b,1) {}; ///<Initializes red, green, and blue and sets alpha to 1.
			Color(float r, float g, float b, float a): O3Vec4r(r,g,b,a) {}; ///<Initializes to red, green, blue, and alpha
			Color(const Color& other) {Set(other);} ///<Initializes to the contents of another color
			
public: //Operators
			using O3Vec4r::operator=;
			using O3Vec4r::operator+;
			using O3Vec4r::operator-;
			using O3Vec4r::operator*;
			using O3Vec4r::operator/;
			using O3Vec4r::operator==;
			using O3Vec4r::operator!=;
			using O3Vec4r::operator+=;
			using O3Vec4r::operator-=;
			using O3Vec4r::operator*=;
			using O3Vec4r::operator/=;
			using O3Vec4r::operator float*;
			using O3Vec4r::operator const float*;
			
			//operator const GLfloat* () {return (float*)O3Vec4r::operator float*();}

public: //Inspectors
			float Color::GetR() const {return operator[](0);}
			float Color::GetG() const {return operator[](1);}
			float Color::GetB() const {return operator[](2);}
			float Color::GetA() const {return operator[](3);}
			void  Color::Get(float* r, float* g, float* b, float *a = NULL) const {
				if (r) *r = operator[](0);
				if (g) *g = operator[](1);
				if (b) *b = operator[](2);
				if (a) *a = operator[](3);
			}
			void Color::GetA(float* r, float* g, float* b) const {
				*r = operator[](0);
				*g = operator[](1);
				*b = operator[](2);
			}
			void Color::GetA(float* r, float* g, float* b, float* a) const {
				*r = operator[](0);
				*g = operator[](1);
				*b = operator[](2);
				*a = operator[](3);
			}
			
public: //Setters
			void  Color::SetR(float r) {operator[](0) = r;}
			void  Color::SetG(float g) {operator[](1) = g;}
			void  Color::SetB(float b) {operator[](1) = b;} 
			void  Color::SetA(float a) {operator[](1) = a;}
			void  Color::Set(float r, float g, float b) {SetR(r); SetG(g); SetB(b);};
			void  Color::Set(float r, float g, float b, float a) {SetR(r); SetG(g); SetB(b); SetA(a);};
			void  Color::Set(const Color& other) {
				SetR(other.GetR());
				SetG(other.GetG());
				SetB(other.GetB());
				SetA(other.GetA());
			}
			
			#ifdef __OBJC__
			Color(NSColor* other) {Set(other);}		///<Initializes to the contents of an NSColor
			void  Color::Set(NSColor* aColor) {float r,g,b,a; [aColor getRed:&r green:&g blue:&b alpha:&a]; Set(r,g,b,a);}
			operator NSColor* () const {return [NSColor colorWithCalibratedRed:GetR() green:GetG() blue:GetB() alpha:GetA()];}
			#endif
		};
#pragma pack(pop)
		
	} //end namespace Engine
} //end namespace ObjC3D

#define O3Engine_Color_Include
#include "O3BGRA8.h"
#include "O3BGRA16.h"
#include "O3RGB565.h"
#undef O3Engine_Color_Include

#endif
