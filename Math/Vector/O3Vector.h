#ifdef __cplusplus
#pragma once
/**
 *  @file O3Vector.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 8/27/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#include "O3Math.h"
#import "O3StructArray.h"
#import "O3ScalarStructType.h"
class O3NonlinearWriter;
class O3BufferedReader;

#define O3Vec_TT	template <typename TYPE, int NUMBER> 
#define O3Vec_T	O3Vec<TYPE, NUMBER>

/** @brief A class to represent vectors.
* The O3Vec class represents a row vector, with NUMBER components of TYPE. Several typedef vector types (see below) are provided for convenience.
* All vectors are considered row vectors, and therefore they are pre-multiplied <i>with</i> matricies (or post multiplied <i>by</i> matricies).
* For example, you would write vector * matrix, not the other way around.
* If you are constructing or setting a vector from a differently sized or typed source, values are cast using the regular C rules. Any values beyond the length of the receiver are ignored, and if the receiver is larger than the new data the rest is padded with 0s.
* @warn When __OBJC__ is defined (compiling with Objective-C++) an implicit type conversion to NSValue* becomes availible. Arithmetic should still work fine since it is
* all overloaded anyways, but just keep it in mind and check it if you get odd behavior. It is also good practice just to cast wherever you mean to convert.
*/
O3Vec_TT class O3Vec {
protected:
	TYPE v[NUMBER]; ///<Stores the array of values.
		
public: //Constructors
	static O3Vec_T GetZero();			///<Returns a vector initialized to zero.
	O3Vec() {};					///<Default constructor. v are NOT initialized to 0 for performance reasons.
	O3Vec(TYPE x)							{Set(x);}			///<Constructs a vector and sets each element equal to x
	O3Vec(TYPE x, TYPE y)					{Set(x,y);}			///<Constructs a 2 or more dimensional vector with the given values. If the vector type has more than 2 dimensions, the unprovided dimensions are filled with 1.
	O3Vec(TYPE x, TYPE y, TYPE z)			{Set(x,y,z);}		///<Constructs a 3 or more dimensional vector with the given values. If the vector type has more than 3 dimensions, the unprovided dimensions are filled with 1.
	O3Vec(TYPE x, TYPE y, TYPE z, TYPE w)	{Set(x,y,z,w);}		///<Constructs a 4 or more dimensional vector with the given values. If the vector type has more than 4 dimensions, the unprovided dimensions are filled with 1.
	O3Vec(NSArray* val)						{SetValue((NSArray*)val);}			///<Constructs a 4 or more dimensional vector with the given NSValue.
	template <typename TYPE2>			 O3Vec(const TYPE2 *array, unsigned len)	{SetArray(array, len);}		///<Constructs a vector with the information pointed at by array. If array isn't the same size as the vector you are constructing, pass its length in \e len.
	template <typename TYPE2, int SIZE2> O3Vec(const O3Vec<TYPE2, SIZE2>& v)		{Set(v);};				///<Constructs a vector from another vector.
	
public: //Setters
	O3Vec_T& Set(TYPE x);			///<Sets all elements in the receiver to x
	O3Vec_T& Set(TYPE x, TYPE y);
	O3Vec_T& Set(TYPE x, TYPE y, TYPE z);
	O3Vec_T& Set(TYPE x, TYPE y, TYPE z, TYPE w);
	O3Vec_T& SetValue(NSArray* val);
	template <typename TYPE2, int SIZE2> O3Vec_T& Set(const O3Vec<TYPE2, SIZE2>& v);
	template <typename TYPE2>			 O3Vec_T& SetArray(const TYPE2 array, unsigned arraylen=NUMBER);
	
public: //Methods and Method-accessors
	O3Vec_T& Zero();								///<Fills the vector with zeros.
	O3Vec_T& Normalize();							///<Normalizes the vector.
	O3Vec_T  GetNormalized() const;				///<Gets a normalized copy of the receiver.
	O3Vec_T& Floor();								///<Rounds all elements of the vector down to the integer between the number and zero.
	O3Vec_T  GetFloored() const;					///<Gets a floor'd copy of the receiver (see Floor()).
	O3Vec_T& Ceil();								///<Rounds all elements up to nearest integer further from zero than the original element.
	O3Vec_T  GetCeiled() const;					///<Gets a ceil'd copy of the receiver (see Ceil()).
	O3Vec_T& Round();								///<Rounds each element of the receiver to the nearest integer.
	O3Vec_T  GetRounded() const;					///<Gets a rounded copy of the receiver (see Round()).
	O3Vec_T& Clamp(TYPE min, TYPE max);			///<Clamps each element of the receiver to the range min..max.
	O3Vec_T  GetClamped(TYPE min, TYPE max) const;	///<Returns a copy of the receiver in which each element has been clamped to the range min..max.
	O3Vec_T& Abs();								///<Sets each element of the receiver to its absolute value.
	O3Vec_T  GetAbs() const;						///<Returns a copy of the receiver in which each element has been set to its absolute value.
	O3Vec_T& Negate();								///<Negates each element in the receiver.
	O3Vec_T  GetNegated() const;					///<Returns a copy of the receiver with each of the original vector's elements negated.
	O3Vec_T& SetLength(double newlen);			///<"Normalizes" the receiver so that its magnitude is newlen
	
public: //Meta-attributes
	TYPE Distance(const O3Vec_T &v);			/** \todo { Depricate DistanceSquared from O3Vec, and add to O3Point class. }*/
	TYPE DistanceSquared(const O3Vec_T &v);	/** \todo { Depricate DistanceSquared from O3Vec, and add to O3Point class. }*/
	TYPE Length() const;											///<Returns the length of the vector
	TYPE LengthSquared() const;										///<Returns the length squared of the vector
	bool IsNormalized() const;										///<Returns true if the vector is normalized (within epsilon*6).
	bool IsNormalized(TYPE tolerance) const;						///<Returns true if the vector is normalized (within tolerance).
	bool IsZero() const;											///<Returns true if the vector is zero (within epsilon).
	bool IsZero(const TYPE tolerance) const;						///<Returns true if the vector is zero (within tolerance).
	template<class T2>
		bool IsEqualTo(const T2& v, TYPE tolerance /*= O3Epsilon(TYPE)*/) const;	///<Returns true if the difference between the receiver and v is less than tolerance (which defaults to epsilon).
	double Angle(const O3Vec_T& v) const; ///<Returns the angle between the receiver and v
	TYPE SumOfComponents() const {TYPE ret=0; for (UIntP i=0; i<NUMBER; i++) ret+=v[i]; return ret;}
	
public: //Overloaded Operators
	operator TYPE* () {return v;}							///<Implicit conversion from a vector to a C array
	operator const TYPE* () const {return v;}				///<Implicit conversion from a constant vector to a constant C array
	TYPE& operator[](int index);								///<Array index operator (returns reference element at index <i>index</i>). Assignment (foo[0] = 1.;) works.
	const TYPE& operator[](int index) const;					///<Constant array operator returns a constant reference to the element at index <i>index</i>.
	bool operator==(const O3Vec_T& v) const;					///<Equality operator tests exact equality. Use IsEqualTo(O3Vec<TYPE, NUMBER> other, TYPE tolerance = epsilon(TYPE)) to test for similarity.
	bool operator!=(const O3Vec_T& v) const;					///<Inequality operator tests exact inequality. Use !IsEqualTo(TYPE tolerance) to test for asimilarity.
	TYPE operator|(const O3Vec_T &v) const;					///<Dot product operator.
	O3Vec_T  operator^(const O3Vec<TYPE, NUMBER> &v) const;	///<Cross product operator.
	O3Vec_T& operator^=(const O3Vec<TYPE, NUMBER> &v);		///<In-Place Cross product operator.
	O3Vec_T operator+() const;									///<Unary + acts like GetAbs().
	O3Vec_T operator-() const;									///<Unary - acts like GetNegative(), returning a copy of the receiver with each element negated.
	O3Vec_T operator+(const TYPE scalar) const;				///<Adds a O3Vec and a scalar, and returns the result.
	O3Vec_T operator-(const TYPE scalar) const;				///<Subtracts a O3Vec and a scalar, and returns the result.
	O3Vec_T operator*(const TYPE scalar) const;				///<Multiplies a O3Vec and a scalar, and returns the result.
	O3Vec_T operator/(const TYPE scalar) const;				///<Divides a O3Vec and a scalar, and returns the result.
	O3Vec_T& operator+=(const TYPE scalar);					///<Adds a scalar to each of the receiver's elements.		
	O3Vec_T& operator-=(const TYPE scalar);					///<Subtracts a scalar from each of the receiver's elements.	
	O3Vec_T& operator*=(const TYPE scalar);					///<Multiplies each of the receiver's elements by a scalar.	
	O3Vec_T& operator/=(const TYPE scalar);					///<Divides each of the receiver's elements by a scalar.	
	O3Vec_T operator+(const O3Vec<TYPE, NUMBER>& v) const;	///<Component-wise adds two vectors, and returns the result.
	O3Vec_T operator-(const O3Vec<TYPE, NUMBER>& v) const;	///<Component-wise subtracts two vectors, and returns the result.
	O3Vec_T operator*(const O3Vec<TYPE, NUMBER>& v) const;	///<Component-wise multiplies two vectors, and returns the result.
	O3Vec_T operator/(const O3Vec<TYPE, NUMBER>& v) const;	///<Component-wise divides two vectors, and returns the result.
	O3Vec_T& operator+=(const O3Vec<TYPE, NUMBER>& v);		///<Adds a vector component-wise to the receiver.
	O3Vec_T& operator-=(const O3Vec<TYPE, NUMBER>& v);		///<Subtracts a vector component-wise from the receiver.
	O3Vec_T& operator*=(const O3Vec<TYPE, NUMBER>& v);		///<Component-wise multiplies the receiver by a vector.
	O3Vec_T& operator/=(const O3Vec<TYPE, NUMBER>& v);		///<Component-wise divides the receiver by a vector.
	O3Vec_T& operator+=(const TYPE* carr);		///<Adds a vector component-wise to the receiver.
	template<typename TYPE2> O3Vec_T& operator=(const O3Vec<TYPE2, NUMBER>& v2);		///<Assignment operator.
	template <class T2> bool equals(const T2) const;					///<Equality operator tests exact equality. Use IsEqualTo(O3Vec<TYPE, NUMBER> other, TYPE tolerance = epsilon(TYPE)) to test for similarity.
	
public: //Accessors
	TYPE* Data() {return v;}			///<Returns a pointer to the internal values array. THIS SHOULD NOT BE USED UNLESS ABSOLUTELY NECESSARY.
	const TYPE* Data() const {return v;}			///<Returns a pointer to the internal values array. THIS SHOULD NOT BE USED UNLESS ABSOLUTELY NECESSARY.
	int Size() const {return NUMBER;}				///<Returns the number of components in a vector.
	const char* ElementType() {return @encode(TYPE);} ///<Returns the ObjC encoding of TYPE
	void Get(TYPE* x, TYPE* y) const;						///<Fetch the values of x and y into *x and *y. Can accept NULL for x or y.
	void Get(TYPE* x, TYPE* y, TYPE* z) const;				///<Fetch the values of x, y, and z into *x, *y, and *z. Can accept NULL for x, y, z, or w.
	void Get(TYPE* x, TYPE* y, TYPE* z, TYPE* w) const;		///<Fetch the values of x, y, z, and w into *x, *y, *z, and *w. Can accept NULL for x, y, z, or w.
	void GetA(TYPE* x, TYPE* y) const;						///<Fetch the values of x and y into *x and *y. DOES NOT CHECK IF X OR Y ARE NULL.
	void GetA(TYPE* x, TYPE* y, TYPE* z) const;				///<Fetch the values of x, y, and z into *x, *y, and *z. DOES NOT CHECK IF X, Y, OR Z ARE NULL.
	void GetA(TYPE* x, TYPE* y, TYPE* z, TYPE* w) const;	///<Fetch the values of x, y, z, and w into *x, *y, *z, and *w. DOES NOT CHECK IF X, Y, Z, OR W ARE NULL.
	TYPE& X() {return v[0];}  ///<Synonymous to receiver[0]. Allows assignment (as in a_vector.x() = 5.;).
	TYPE& Y() {return v[1];}  ///<Synonymous to receiver[1]. Allows assignment (as in a_vector.x() = 5.;).
	TYPE& Z() {return v[2];}  ///<Synonymous to receiver[2]. Allows assignment (as in a_vector.x() = 5.;).
	TYPE& W() {return v[3];}  ///<Synonymous to receiver[3]. Allows assignment (as in a_vector.x() = 5.;).
	TYPE& U() {return v[0];}  ///<Synonymous to receiver[0]. Allows assignment (as in a_vector.x() = 5.;).
	TYPE& V() {return v[1];}  ///<Synonymous to receiver[1]. Allows assignment (as in a_vector.x() = 5.;).
	TYPE& S() {return v[0];}  ///<Synonymous to receiver[0]. Allows assignment (as in a_vector.x() = 5.;).
	TYPE& T() {return v[1];}  ///<Synonymous to receiver[1]. Allows assignment (as in a_vector.x() = 5.;).
	TYPE& R() {return v[2];}  ///<Synonymous to receiver[2]. Allows assignment (as in a_vector.x() = 5.;).
	TYPE& G() {return v[3];}  ///<Synonymous to receiver[3]. Allows assignment (as in a_vector.x() = 5.;).
	TYPE  GetX() const {return v[0];}                	///<Acts just the same as receiver[0] but does not allow assignment.
	TYPE  GetY() const {return v[1];}                	///<Acts just the same as receiver[1] but does not allow assignment.
	TYPE  GetZ() const {return v[2];}                	///<Acts just the same as receiver[2] but does not allow assignment.
	TYPE  GetW() const {return (NUMBER>=3)?v[3]:1.0;}	///<Acts just the same as receiver[3] but does not allow assignment.
	TYPE  GetU() const {return v[0];}                	///<Acts just the same as receiver[0] but does not allow assignment
	TYPE  GetV() const {return v[1];}                	///<Acts just the same as receiver[1] but does not allow assignment.
	TYPE  GetS() const {return v[0];}                	///<Acts just the same as receiver[0] but does not allow assignment.
	TYPE  GetT() const {return v[1];}                	///<Acts just the same as receiver[1] but does not allow assignment.
	TYPE  GetR() const {return v[2];}                	///<Acts just the same as receiver[2] but does not allow assignment.
	TYPE  GetG() const {return v[3];}                	///<Acts just the same as receiver[3] but does not allow assignment.
	O3StructArray* Value() const {return [[[O3StructArray alloc] initWithCopiedBytes:this type:O3ScalarStructTypeOf(TYPE) length:NUMBER*sizeof(TYPE)] autorelease];}
	
public: //Interface
	void WriteTo(O3NonlinearWriter* w);
	O3Vec_T& SetFromReader(O3BufferedReader* br, UIntP len);
	std::string Description() const; ///<Returns a string description of the object. The caller is responsible for free()ing the returned char*.
};

/************************************/ #pragma mark Operators /************************************/
O3Vec_TT O3Vec_T operator+(const TYPE scalar, const O3Vec_T& v);
O3Vec_TT O3Vec_T operator-(const TYPE scalar, const O3Vec_T& v);
O3Vec_TT O3Vec_T operator*(const TYPE scalar, const O3Vec_T& v);
O3Vec_TT O3Vec_T operator/(const TYPE scalar, const O3Vec_T& v);

/************************************/ #pragma mark Convenience Typedefs /************************************/
typedef O3Vec<double, 2> O3Vec2d;	///<A convenience typedef defines O3Vec2d as a 2 component double precision floating point vector.
typedef O3Vec<double, 3> O3Vec3d;	///<A convenience typedef defines O3Vec3d as a 3 component double precision floating point vector.
typedef O3Vec<double, 4> O3Vec4d;	///<A convenience typedef defines O3Vec4d as a 4 component double precision floating point vector.
typedef O3Vec<real, 2> O3Vec2r;		///<A convenience typedef defines O3Vec2r as a 2 component "real" floating point vector.
typedef O3Vec<real, 3> O3Vec3r;		///<A convenience typedef defines O3Vec3r as a 3 component "real" floating point vector.
typedef O3Vec<real, 4> O3Vec4r;		///<A convenience typedef defines O3Vec4r as a 4 component "real" floating point vector.
typedef O3Vec<float, 2> O3Vec2f;		///<A convenience typedef defines O3Vec2f as a 2 component single precision floating point vector.
typedef O3Vec<float, 3> O3Vec3f;		///<A convenience typedef defines O3Vec3f as a 3 component single precision floating point vector.
typedef O3Vec<float, 4> O3Vec4f;		///<A convenience typedef defines O3Vec4f as a 4 component single precision floating point vector.
#else /*!defined(__cplusplus)*/
typedef struct {real v[2];} O3Vec2r;
typedef struct {real v[3];} O3Vec3r;
typedef struct {real v[4];} O3Vec4r;
typedef struct {float v[2];} O3Vec2f;
typedef struct {float v[3];} O3Vec3f;
typedef struct {float v[4];} O3Vec4f;
typedef struct {double v[2];} O3Vec2d;
typedef struct {double v[3];} O3Vec3d;
typedef struct {double v[4];} O3Vec4d;
#endif /*defined(__cplusplus)*/