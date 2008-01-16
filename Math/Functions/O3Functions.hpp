#pragma once
/**
 *  @file O3Functions.hpp
 *  @license MIT License (see LICENSE.txt)
 *  @date 8/24/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#ifdef __cplusplus
using namespace ObjC3D;
#endif

/*******************************************************************/ #pragma mark Reciprocal and Square Root Functions /*******************************************************************/
#ifdef __cplusplus
inline float O3rsqrt(float value) {
	return 1.0 / sqrt(value);
}

inline float O3rsqrte(float value) {
	float halfVal = .5*value;
	UInt32 ival = *(int*)&value;
	ival = 0x5f3759df - (ival>>1);
	value = *(float*)&ival;
	value *= (1.5f - halfVal*value*value);
	return value;
	//return sqrt(value);
}

inline float	O3recip(float value) {
	return 1.0 / value;
}

inline double O3rsqrt(double value) {
	return 1.0 / sqrt(value);
}

inline double O3rsqrte(double value) {
	return 1.0 / sqrt(value);
}

inline double	O3recip(double value) {
	return 1.0 / value;
}

#endif /*defined(__cplusplus)*/




/************************************/ #pragma mark Regular swap /************************************/
#ifdef __cplusplus
template <typename T> struct O3swap_implementation;
template <typename T> void O3swap(T& thing1, T& thing2) {O3swap_implementation<T>::swap(thing1, thing2);}
template <typename T> struct O3swap_implementation {
	void swap(T& thing1, T& thing2) {
		T tmp = thing1;
		thing1 = thing2;
		thing2 = tmp;
	}
};
#endif

/************************************/ #pragma mark Byteswapping /************************************/
#ifdef __cplusplus
template <typename TYPE> struct O3ByteswapImplementation {
	static inline TYPE byteswap(const TYPE& to_swap) {
		TYPE to_return;
		int typesize = sizeof(TYPE);
		const UInt8* srcbytes = reinterpret_cast<const UInt8*>(&to_swap);
		UInt8* destbytes = reinterpret_cast<UInt8*>(&to_return);
		int i; for (i=0;i<typesize;i++) destbytes[i] = srcbytes[typesize-i-1];
		return to_return;
	}
};
template <typename TYPE> inline TYPE O3Byteswap(const TYPE& to_swap) {O3ByteswapImplementation<TYPE> t; return t.byteswap(to_swap);}

#ifdef O3UseCoreFoundation
template <> struct O3ByteswapImplementation<Int32>	{static inline Int32  byteswap(Int32 to_swap) {return CFSwapInt32(to_swap);}};
template <> struct O3ByteswapImplementation<UInt32>	{static inline UInt32 byteswap(UInt32 to_swap) {return CFSwapInt32(to_swap);}};
template <> struct O3ByteswapImplementation<Int16>	{static inline Int16  byteswap(Int16 to_swap) {return CFSwapInt16(to_swap);}};
template <> struct O3ByteswapImplementation<UInt16>	{static inline UInt16 byteswap(UInt16 to_swap) {return CFSwapInt16(to_swap);}};
template <> struct O3ByteswapImplementation<Int8>	{static inline Int8   byteswap(Int8 to_swap) {return to_swap;}};
template <> struct O3ByteswapImplementation<UInt8>	{static inline UInt8  byteswap(Int8 to_swap) {return to_swap;}};
template <> struct O3ByteswapImplementation<Int64>	{static inline Int64  byteswap(Int64 to_swap) {return CFSwapInt64(to_swap);}};
template <> struct O3ByteswapImplementation<UInt64>	{static inline UInt64 byteswap(UInt64 to_swap) {return CFSwapInt64(to_swap);}};
template <> struct O3ByteswapImplementation<float>	{
	inline float byteswap(float to_swap) {
		UInt32 v = *(float*)&to_swap;
		UInt32 v2 = CFSwapInt32(v);
		return *(float*)&v2;
	}
};
template <> struct O3ByteswapImplementation<double>	{
	inline double byteswap(double to_swap) {
		UInt64 v = *(double*)&to_swap;
		UInt64 v2 = CFSwapInt64(v);
		return *(double*)&v2;
	}
};
#endif /*defined(O3UseCoreFoundation)*/

#endif /*defined(__cplusplus)*/
