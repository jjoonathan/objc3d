/**
 *  @file O3RGB565.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 11/13/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#ifndef O3Engine_Color_Include
#error Do not include this file as a header, instead include Color.h and it will automatically be included.
#endif

namespace ObjC3D {
	namespace Engine {

#pragma pack(push, 1)
		class RGB565 {
		private:
			const static long RBits = 5; 
			const static long GBits = 6;
			const static long BBits = 5;
			unsigned MyR : RBits;
			unsigned MyG : GBits;
			unsigned MyB : BBits;

			public: //Initializers
			RGB565(): MyR(((1<<RBits)-1)), MyG(0.), MyB(0.) {};
			RGB565(float r, float g, float b) {Set(r,g,b);}
			RGB565(float r, float g, float b, float a) {Set(r,g,b,a);}
			RGB565(const Color& other) {Set(other);}


			public: //Operators
			operator Color () const {return Color(GetR(), GetG(), GetB(), GetA());}
			RGB565& operator=(const Color& other) {
				SetR(other.GetR());
				SetG(other.GetG());
				SetB(other.GetB());
				SetA(other.GetA());
				return *this;
			}
			bool operator==(const Color& other) const {
				if (!O3Equals(GetR(), other.GetR())) return false;
				if (!O3Equals(GetG(), other.GetG())) return false;
				if (!O3Equals(GetB(), other.GetB())) return false;
				if (!O3Equals(GetA(), other.GetA())) return false;
				return true;
			}
			bool operator!=(const Color& other) const {return !operator==(other);}

			public: //Inspectors
			float RGB565::GetR() const {return (float)MyR/((1<<RBits)-1);}
			float RGB565::GetG() const {return (float)MyG/((1<<GBits)-1);}
			float RGB565::GetB() const {return (float)MyB/((1<<BBits)-1);}
			float RGB565::GetA() const {return 1.;}
			void  RGB565::Get(float* r, float* g, float* b, float *a = NULL) const {
				if (r) *r = (float)MyR/((1<<RBits)-1);
				if (g) *g = (float)MyG/((1<<GBits)-1);
				if (b) *b = (float)MyB/((1<<BBits)-1);
				if (a) *a = 1.;
			}
			void RGB565::GetA(float* r, float* g, float* b) const {
				*r = (float)MyR/((1<<RBits)-1);
				*g = (float)MyG/((1<<GBits)-1);
				*b = (float)MyB/((1<<BBits)-1);
			}
			void RGB565::GetA(float* r, float* g, float* b, float* a) const {
				*r = (float)MyR/((1<<RBits)-1);
				*g = (float)MyG/((1<<GBits)-1);
				*b = (float)MyB/((1<<BBits)-1);
				*a = 1.;
			}

			public: //Setters
			void  RGB565::SetR(float r) {MyR = (UInt16)round(r*((1<<RBits)-1));}
			void  RGB565::SetG(float g) {MyG = (UInt16)round(g*((1<<GBits)-1));}
			void  RGB565::SetB(float b) {MyB = (UInt16)round(b*((1<<BBits)-1));} 
			void  RGB565::SetA(float a) {O3AssertFalse();}
			void  RGB565::Set(float r, float g, float b) {SetR(r); SetG(g); SetB(b);};
			void  RGB565::Set(float r, float g, float b, float a) {SetR(r); SetG(g); SetB(b);};
			void  RGB565::Set(const Color& other) {
				SetR(other.GetR());
				SetG(other.GetG());
				SetB(other.GetB());
			}
		};
#pragma pack(pop)

	} //end namespace Engine
} //end namespace ObjC3D
