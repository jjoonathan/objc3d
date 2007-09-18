#pragma once
/**
 *  @file O3Space.h
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @todo Template-ize this class to work with other dimensions
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#include "Math.h"
#include "O3Matrix.h"
#include "O3Vector.h"
#include "O3Scale.h"
#include "O3Translation.h"
#include "O3Rotation.h"
#include "O3Quaternion.h"

namespace ObjC3D {
	namespace Math {

		class Space3 {
		protected:
			Space3* mSuperspace;
			mutable O3Transformation3 mFromSuperspace;
			mutable O3Transformation3 mFromRootspace;
			mutable unsigned mPseudohash;
			mutable unsigned mSuperPseudohash;

		private: //Common Init
			void Init() {
				mPseudohash = mSuperPseudohash = 0;
			}

		public: //Init
			Space3(Space3* supers = NULL) 								{Init(); SetSuperspace(supers);}
			Space3(const O3Mat4x4d& mat, Space3* supers = NULL) 			{Init(); Set(mat); SetSuperspace(supers);}
			Space3(const O3Transformation3& trans, Space3* supers = NULL) {Init(); Set(trans); SetSuperspace(supers);}
			Space3(const Space3& other, Space3* supers = NULL) 			{Init(); Set(other); SetSuperspace(supers);}
			Space3(const O3Translation3& trans, const O3Rotation3& rot, const O3Scale3& scale, Space3* supers = NULL) {Init(); Set(trans, rot, scale); SetSuperspace(supers);}

		public: //Mutators
			Space3& SetSuperspace(Space3* supers);
			Space3& Set(); ///<Clears the receiver to the identity space (does not change super)
			Space3&	Set(const O3Mat4x4d& mat); ///<Sets the receiver's transformation from its superspace
			Space3& Set(const O3Transformation3& trans); ///<Sets the receiver's transformation from its superspace
			Space3& Set(const Space3& other); ///<Sets the receiver to be a copy of other (does not change the receiver's superspace)
			Space3& Set(const O3Translation3& trans, const O3Rotation3& rot, const O3Scale3& scale); ///<Sets the transformation, rotation, and scale represented by the receiver. They are applied in that order (translation, then rotation, then scale). *-+333333333333333333333333333333333333333333333333 @note If you use this a lot, consider using TRSSpace3

		public: //Inspectors
			Space3* Superspace() const {return mSuperspace;};
			const O3Mat4x4d& MatrixFromSuper() const; ///<Gets the matrix that transforms from the receiver's superspace to the receiver's space
			const O3Mat4x4d& MatrixFromRoot() const;  ///<Gets the matrix that transforms from the root space to the receiver's space
			O3Mat4x4d MatrixToSpace(const Space3& other) const; ///<Gets the matrix that transforms from the receiver's space to other's space
			const O3Mat4x4d& MatrixToRoot() const; ///<Gets the matrix that transforms from the receiver's space to the root space
			const O3Mat4x4d& MatrixToSuper() const; ///<Gets the matrix that transforms from the receiver's space to its superspace
			bool IsSame(const Space3* other) const {return this==other;}
			O3Vec3d VectorToSpace(const Space3& other, O3Vec3d oldvec) const;
			O3Vec4d VectorToSpace(const Space3& other, O3Vec4d oldvec) const;
			O3Vec3d VectorToRoot(O3Vec3d oldvec) const;
			O3Vec4d VectorToRoot(O3Vec4d oldvec) const;
			O3Vec3d VectorFromRoot(O3Vec3d oldvec) const;
			O3Vec4d VectorFromRoot(O3Vec4d oldvec) const;

		protected: //Private
			virtual void UpdateRootspaceTransform() const;
			virtual void Modified() const {mPseudohash++; if (mSuperPseudohash) mSuperPseudohash--;}

		public: //Operators
			Space3& operator=(const Space3& other);
			Space3& operator+=(const O3Scale3& scale);
			Space3  operator+(const O3Scale3& scale) const 
				{Space3 to_return(*this); return to_return+=scale;} 
			Space3& operator-=(const O3Scale3& scale);	
			Space3  operator-(const O3Scale3& scale) const 
				{Space3 to_return(*this); return to_return-=scale;}

			Space3& operator+=(const O3Rotation3& rot);
			Space3  operator+(const O3Rotation3& rot) const 
				{Space3 to_return(*this); return to_return+=rot;}
			Space3& operator-=(const O3Rotation3& rot);	
			Space3  operator-(const O3Rotation3& rot) const 
				{Space3 to_return(*this); return to_return-=rot;}

			Space3& operator+=(const O3Translation3& trans);
			Space3  operator+(const O3Translation3& trans) const
				{Space3 to_return(*this); return to_return+=trans;}
			Space3& operator-=(const O3Translation3& trans);	
			Space3  operator-(const O3Translation3& trans) const
				{Space3 to_return(*this); return to_return-=trans;}

			Space3& operator+=(const O3Transformation3& trans);
			Space3  operator+(const O3Transformation3& trans) const
				{Space3 to_return(*this); return to_return+=trans;}
			Space3& operator-=(const O3Transformation3& trans);
			Space3  operator-(const O3Transformation3& trans) const
				{Space3 to_return(*this); return to_return-=trans;}

			Space3& operator+=(const O3Mat4x4d& mat);
			Space3  operator+ (const O3Mat4x4d& mat) const
				{Space3 to_return(*this); return to_return+=mat;}
			Space3& operator-=(const O3Mat4x4d& mat);
			Space3  operator- (const O3Mat4x4d& mat) const
				{Space3 to_return(*this); return to_return-=mat;}

			bool operator==(const Space3& other) const {
				return mFromRootspace==other.mFromRootspace;
			}

		public: //Other methods
			bool Equals(const Space3& other, double tolerance = O3Epsilon(real)) const {
				return mFromRootspace.Equals(other.mFromRootspace, tolerance);
			}

			bool IsEqual(const Space3& other, double tolerance = O3Epsilon(real)) const {
				return mFromRootspace.IsEqual(other.mFromRootspace, tolerance);
			}

			bool IsValid(double tolerance = 1.0e-6) const {  ///<Checks to see weather MyTransform*MyInverseTransform is the identity within tolerance for the root>receiver transformation
				return mFromSuperspace.IsValid(tolerance);
			}
			
		protected:
			void DidChange();
	};

} // /Math
} // /ObjC3D

template <typename T> inline
T O3ConvertRootToSpace(const T& root_vector, const ObjC3D::Math::Space3* space) {
	if (!space) return root_vector;
	return space->VectorFromRoot(root_vector);
}

template <typename T> inline
T O3ConvertSpaceToRoot(const T& space_vector, const ObjC3D::Math::Space3* space) {
	if (!space) return space_vector;
	return space->VectorToRoot(space_vector);
}

template <typename T> inline
T O3ConvertSpaceToSpace(const T& space_vector, const ObjC3D::Math::Space3* from, const ObjC3D::Math::Space3* to) {
	if (from==to) return space_vector;
	if (!from) return O3ConvertRootToSpace(space_vector, to);
	return from->VectorToSpace(to, space_vector);
}
