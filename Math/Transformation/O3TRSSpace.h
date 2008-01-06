#pragma once
/**
 *  @file O3TRSSpace.h
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @todo Fixme
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#include "O3Space.h"
#error "This class probably doesn't work"

namespace ObjC3D {
	namespace Math {

		class TRSSpace3 : public O3Space3 {
		protected:
			O3Translation3 mTranslation;
			O3Rotation3 mRotation;
			O3Scale3 mScale;
			mutable unsigned mTRSPseudohash;
			mutable unsigned mLastTRSPseudohash;

		public: //Init
			void Init();
			TRSSpace3(O3Space3* supers = NULL) 								{Init(); O3Space3::SetSuperspace(supers); O3Space3::SetSuperspace(supers);}
			TRSSpace3(const TRSSpace3& other, O3Space3* supers = NULL) 			{Init(); Set(other); O3Space3::SetSuperspace(supers);}
			TRSSpace3(const O3Translation3& trans, const O3Rotation3& rot, const O3Scale3& scale, O3Space3* supers = NULL) {Init(); Set(trans, rot, scale); O3Space3::SetSuperspace(supers);}
			TRSSpace3(const O3Translation3& trans, O3Space3* supers = NULL) : mTranslation(trans) {Init(); O3Space3::SetSuperspace(supers);}
			TRSSpace3(const O3Rotation3& rot, O3Space3* supers = NULL) : mRotation(rot) {Init(); O3Space3::SetSuperspace(supers);}
			TRSSpace3(const O3Scale3& scale, O3Space3* supers = NULL) : mScale(scale) {Init(); O3Space3::SetSuperspace(supers);}

		public: //Inspectors
			const O3Mat4x4d& MatrixFromSuper() const; ///<Gets the matrix that transforms from the receiver's superspace to the receiver's space
			const O3Mat4x4d& MatrixFromRoot() const;  ///<Gets the matrix that transforms from the root space to the receiver's space
			O3Mat4x4d MatrixToSpace(const O3Space3& other) const; ///<Gets the matrix that transforms from the receiver's space to other's space
			const O3Mat4x4d& MatrixToRoot() const; ///<Gets the matrix that transforms from the receiver's space to the root space
			const O3Mat4x4d& MatrixToSuper() const; ///<Gets the matrix that transforms from the receiver's space to its superspace
				
		public: //Setters
			TRSSpace3& Set(); ///<Clears the receiver to the identity space (does not change super)
			TRSSpace3& Set(const TRSSpace3& other); ///<Sets the receiver to be a copy of other (does not change the receiver's superspace)
			TRSSpace3& Set(const O3Translation3& trans, const O3Rotation3& rot, const O3Scale3& scale); ///<Sets the transformation, rotation, and scale represented by the receiver. They are applied in that order (translation, then rotation, then scale). @note If you use this a lot, consider using TRSSpace3

		public: //Elemental inspectors and mutators
			TRSSpace3& SetTranslation(const O3Translation3& trans); ///<Sets the receiver's translation component without affecting other components
			TRSSpace3& SetRotation(const O3Rotation3& rot); ///<Sets the receiver's rotation component without affecting other components
			TRSSpace3& SetScale(const O3Scale3& scale); ///<Sets the receiver's scale component without affecting other components
			const O3Scale3& O3Scale() const {return mScale;}
			const O3Translation3& O3Translation() const {return mTranslation;}
			const O3Rotation3& Rotation() const {return mRotation;}
			O3Scale3 GetScale() const {return mScale;}
			O3Translation3 GetTranslation() const {return mTranslation;}
			O3Rotation3 GetRotation() const {return mRotation;}

		protected: //Private (just call super)
			void UpdateSuperspaceTransform() const;
			inline void UpdateRootspaceTransform() const {UpdateSuperspaceTransform(); O3Space3::UpdateRootspaceTransform();};
			inline void Modified() const {mTRSPseudohash++; O3Space3::Modified();};
			inline bool IsSame(const O3Space3* other) const {return this==other;}

		public: //Operators
			TRSSpace3& operator+=(const O3Scale3& scale);
			TRSSpace3  operator+(const O3Scale3& scale) const 
				{TRSSpace3 to_return(*this); return to_return+=scale;} 
			TRSSpace3& operator-=(const O3Scale3& scale);	
			TRSSpace3  operator-(const O3Scale3& scale) const 
				{TRSSpace3 to_return(*this); return to_return-=scale;}

			TRSSpace3& operator+=(const O3Rotation3& rot);
			TRSSpace3  operator+(const O3Rotation3& rot) const 
				{TRSSpace3 to_return(*this); return to_return+=rot;}
			TRSSpace3& operator-=(const O3Rotation3& rot);	
			TRSSpace3  operator-(const O3Rotation3& rot) const 
				{TRSSpace3 to_return(*this); return to_return-=rot;}

			TRSSpace3& operator+=(const O3Translation3& trans);
			TRSSpace3  operator+(const O3Translation3& trans) const
				{TRSSpace3 to_return(*this); return to_return+=trans;}
			TRSSpace3& operator-=(const O3Translation3& trans);	
			TRSSpace3  operator-(const O3Translation3& trans) const
				{TRSSpace3 to_return(*this); return to_return-=trans;}

			bool operator==(const O3Space3& other) const {return O3Space3::operator==(other);}

		public: //Other methods
			bool Equals(const O3Space3& other, double tolerance = O3Epsilon(real)) const {return O3Space3::Equals(other, tolerance);}
			bool IsEqual(const O3Space3& other, double tolerance = O3Epsilon(real)) const {return O3Space3::IsEqual(other, tolerance);}
			bool IsValid(double tolerance = 1.0e-6) const {return O3Space3::IsValid(tolerance);}
	};

} // /Math
} // /ObjC3D
