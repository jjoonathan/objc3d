#pragma once
/**
 *  @file O3Functions.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 8/24/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
/************************************/ #pragma mark Square Root /************************************/
#ifdef __cplusplus
inline float	O3rsqrt(float value);		//Returns the reciprocol of a square root
inline float	O3rsqrte(float value);	//Returns the estimate reciprocol of a square root
inline float	O3recip(float value);		//Returns the reciprocol of the passed value
inline double	O3rsqrt(double value);
inline double	O3rsqrte(double value);
inline double	O3recip(double value);
#else
#define O3rsqrt(value) (1.0 / sqrt(value))
#define O3rsqrte(value) (1.0 / sqrt(value))
#define O3recip(value) (1.0 / (value))
#endif


/************************************/ #pragma mark Swap /************************************/
#ifdef __cplusplus
template <typename T> 
inline void O3swap(T& thing1, T& thing2);
#endif

/************************************/ #pragma mark Conversion /************************************/
#define O3DegreesToRadians(x) ((x)*(3.14159265358979323846/180.0))
#define O3RadiansToDegrees(x) ((x)*(180/3.14159265358979323846))

/************************************/ #pragma mark Maximum/Minimum /************************************/
//Use the Cocoa.h macros if possible
#if defined(MAX) && defined(MIN)
#define O3Max(a, b) MAX(a,b)
#define O3Min(a, b) MIN(a,b)
#else
#define O3Max(a, b) (((a)<(b))?(b):(a))
#define O3Min(a, b) (((a)<(b))?(a):(b))
#endif
#define O3Abs(a)    (((a)<0)?-(a):(a))

/************************************/ #pragma mark Rounding /************************************/
#ifdef __cplusplus
template <typename T, typename T2>
T O3RoundUpToNearest(T num, T2 amount) {
	T dev = num % amount;
	if (dev) dev = amount - dev;
	return num+dev;
}
#endif

/*******************************************************************/ #pragma mark Byteswapping /*******************************************************************/
typedef enum {
	O3LittleEndian,
	O3BigEndian
} O3ENDIANESS;	///<Defines supported endianess. Also typedefed to O3Endianess.
typedef O3ENDIANESS O3Endianess;	///<Since it is unclear which naming convention should be used, both are allowed.

#ifdef __cplusplus
template <typename TYPE> TYPE O3Byteswap(const TYPE& to_swap); ///<Swaps the bytes for any TYPE

#ifndef __BIG_ENDIAN__
#define O3HOST_ENDIANESS O3LittleEndian
#define O3ByteswapLittleToHost(x) (x)
#define O3ByteswapBigToHost(x)    O3Byteswap(x)
#define O3ByteswapHostToLittle(x) (x)
#define O3ByteswapHostToBig(x)    O3Byteswap(x)
#define O3ByteswapToHost(endianess, x) ((endianess==O3BigEndian)?O3Byteswap(x):(x))
#define O3ByteswapHostTo(endianess, x) ((endianess==O3BigEndian)?O3Byteswap(x):(x))
#define O3NeedByteswapToLittle 1
#define O3NeedByteswapToBig 0
#else
#define O3HOST_ENDIANESS O3BigEndian
#define O3ByteswapLittleToHost(x) O3Byteswap(x)
#define O3ByteswapBigToHost(x)    (x)
#define O3ByteswapHostToLittle(x) O3Byteswap(x)
#define O3ByteswapHostToBig(x)    (x)
#define O3ByteswapToHost(endianess, x) ((endianess==O3LittleEndian)?O3Byteswap(x):(x))
#define O3ByteswapHostTo(endianess, x) ((endianess==O3LittleEndian)?O3Byteswap(x):(x))
#define O3NeedByteswapToLittle 0
#define O3NeedByteswapToBig 1
#endif /*defined(__BIG_ENDIAN__)*/
#endif /*defined(__cplusplus)*/

/************************************/ #pragma mark Foundation Additions /************************************/
inline NSRect O3CenterSizeInRect(NSSize s, NSRect rect) {
	double xpadding = (rect.size.width-s.width)*.5;
	double ypadding = (rect.size.height-s.height)*.5;
	return NSMakeRect(rect.origin.x+xpadding, rect.origin.y+ypadding, s.width, s.height);
}

#define O3CenterOfNSRect(rect) NSMakePoint(rect.origin.x+.5*rect.size.width,  rect.origin.y+.5*rect.size.height)
#define O3CenterOfCGRect(rect) CGPointMake(rect.origin.x+.5*rect.size.width,  rect.origin.y+.5*rect.size.height)

#include "O3Functions.hpp"
