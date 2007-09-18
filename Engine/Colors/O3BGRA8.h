/**
 *  @file O3BGRA8.h
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
		class BGRA8 {
		private:
			const static long RBits = 8; 
			const static long GBits = 8;
			const static long BBits = 8;
			const static long ABits = 8;
			unsigned MyB : BBits;
			unsigned MyG : GBits;
			unsigned MyR : RBits;
			unsigned MyA : ABits;

			public: //Initializers
			BGRA8(): MyR((1<<RBits)), MyG(0.), MyB(0.), MyA(((1<<ABits)-1)) {};
			BGRA8(float r, float g, float b) {Set(r,g,b);}
			BGRA8(float r, float g, float b, float a) {Set(r,g,b,a);}
			BGRA8(const Color& other) {Set(other);}

			public: //Operators
			operator Color () const {return Color(GetR(), GetG(), GetB(), GetA());}
			BGRA8& operator=(const Color& other) {
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
			float BGRA8::GetR() const {return (float)MyR/(1<<RBits);}
			float BGRA8::GetG() const {return (float)MyG/(1<<GBits);}
			float BGRA8::GetB() const {return (float)MyB/(1<<BBits);}
			float BGRA8::GetA() const {return (float)MyA/(1<<ABits);}
			void  BGRA8::Get(float* r, float* g, float* b, float *a = NULL) const {
				if (r) *r = (float)MyR/(1<<RBits);
				if (g) *g = (float)MyG/(1<<GBits);
				if (b) *b = (float)MyB/(1<<BBits);
				if (a) *a = (float)MyA/(1<<ABits);
			}
			void BGRA8::GetA(float* r, float* g, float* b) const {
				*r = (float)MyR/(1<<RBits);
				*g = (float)MyG/(1<<GBits);
				*b = (float)MyB/(1<<BBits);
			}
			void BGRA8::GetA(float* r, float* g, float* b, float* a) const {
				*r = (float)MyR/(1<<RBits);
				*g = (float)MyG/(1<<GBits);
				*b = (float)MyB/(1<<BBits);
				*a = (float)MyA/(1<<ABits);
			}

			public: //Setters
			void  BGRA8::SetR(float r) {MyR = round(r*(1<<RBits));}
			void  BGRA8::SetG(float g) {MyG = round(g*(1<<GBits));}
			void  BGRA8::SetB(float b) {MyB = round(b*(1<<BBits));} 
			void  BGRA8::SetA(float a) {MyA = round(a*(1<<ABits));}
			void  BGRA8::Set(float r, float g, float b) {SetR(r); SetG(g); SetB(b);};
			void  BGRA8::Set(float r, float g, float b, float a) {SetR(r); SetG(g); SetB(b); SetA(a);};
			void  BGRA8::Set(const Color& other) {
				SetR(other.GetR());
				SetG(other.GetG());
				SetB(other.GetB());
				SetA(other.GetA());
			}
		};
#pragma pack(pop)

	} //end namespace Engine
} //end namespace ObjC3D
