/**
 *  @file O3BGRA16.h
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

#pragma pack(push, 0)
		class BGRA16 {
		private:
			const static long RBits = 16; 
			const static long GBits = 16;
			const static long BBits = 16;
			const static long ABits = 16;
			unsigned MyB : BBits;
			unsigned MyG : GBits;
			unsigned MyR : RBits;
			unsigned MyA : ABits;

			public: //Initializers
			BGRA16(): MyR(((1<<RBits)-1)), MyG(0.), MyB(0.), MyA((1<<ABits-1)) {};
			BGRA16(float r, float g, float b) {Set(r,g,b);}
			BGRA16(float r, float g, float b, float a) {Set(r,g,b,a);}
			BGRA16(const Color& other) {Set(other);}

			public: //Operators
			operator Color () const {return Color(GetR(), GetG(), GetB(), GetA());}
			BGRA16& operator=(const Color& other) {
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
			float BGRA16::GetR() const {return (float)MyR/((1<<RBits)-1);}
			float BGRA16::GetG() const {return (float)MyG/((1<<GBits)-1);}
			float BGRA16::GetB() const {return (float)MyB/((1<<BBits)-1);}
			float BGRA16::GetA() const {return (float)MyA/((1<<ABits)-1);}
			void  BGRA16::Get(float* r, float* g, float* b, float *a = NULL) const {
				if (r) *r = (float)MyR/((1<<RBits)-1);
				if (g) *g = (float)MyG/((1<<GBits)-1);
				if (b) *b = (float)MyB/((1<<BBits)-1);
				if (a) *a = (float)MyA/(1<<ABits);
			}
			void BGRA16::GetA(float* r, float* g, float* b) const {
				*r = (float)MyR/((1<<RBits)-1);
				*g = (float)MyG/((1<<GBits)-1);
				*b = (float)MyB/((1<<BBits)-1);
			}
			void BGRA16::GetA(float* r, float* g, float* b, float* a) const {
				*r = (float)MyR/((1<<RBits)-1);
				*g = (float)MyG/((1<<GBits)-1);
				*b = (float)MyB/((1<<BBits)-1);
				*a = (float)MyA/((1<<ABits)-1);
			}

			public: //Setters
			void  BGRA16::SetR(float r) {MyR = round(r*((1<<RBits)-1));}
			void  BGRA16::SetG(float g) {MyG = round(g*((1<<GBits)-1));}
			void  BGRA16::SetB(float b) {MyB = round(b*((1<<BBits)-1));} 
			void  BGRA16::SetA(float a) {MyA = round(a*((1<<ABits)-1));}
			void  BGRA16::Set(float r, float g, float b) {SetR(r); SetG(g); SetB(b);};
			void  BGRA16::Set(float r, float g, float b, float a) {SetR(r); SetG(g); SetB(b); SetA(a);};
			void  BGRA16::Set(const Color& other) {
				SetR(other.GetR());
				SetG(other.GetG());
				SetB(other.GetB());
				SetA(other.GetA());
			}
		};
#pragma pack(pop)

	} //end namespace Engine
} //end namespace ObjC3D
