#pragma once
/**
 *  @file O3Utilities.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 9/9/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#ifdef __cplusplus
#include <cassert>
#include <cfloat>
#include <limits>
#include <vector>
#include <iostream>
#include <stdint.h>
#include <limits>
#endif

#import "O3BigObject.h"

/*******************************************************************/ #pragma mark Int Types /*******************************************************************/
#ifndef __MACTYPES__
typedef   uint8_t UInt8;
typedef  uint16_t UInt16;
typedef  uint32_t UInt32;
typedef  uint64_t UInt64;
typedef    int8_t SInt8;
typedef   int16_t SInt16;
typedef   int32_t SInt32;
typedef   int64_t SInt64;
#endif
typedef  SInt8 	  Int8; //Same as above but implicitly signed
typedef  SInt16	  Int16;
typedef  SInt32	  Int32;
typedef  SInt64	  Int64;
typedef uintptr_t UIntP; //Unsigned Integer that can hold a pointer
typedef uintmax_t UIntM; //Mega-unsigned-integer (biggest that can be used w/o a bignum library)
typedef  intptr_t SIntP; //Integer that can hold a pointer
typedef  intmax_t SIntM; //Mega-integer (biggest that can be used w/o a bignum library)
typedef  SIntP 	  IntP; 
typedef  SIntM 	  IntM; 

/*******************************************************************/ #pragma mark String Utilities /*******************************************************************/
#if (defined(_M_IX86) || defined(__i386__) || defined(__i386) || defined(i386)) && !defined(__ia32__)
#define __ia32__
#endif

/*******************************************************************/ #pragma mark String Utilities /*******************************************************************/
#define O3STRINGIFY(x) #x
#define O3TO_STRING(x) O3STRINGIFY(x)
#define O3At() "<" __FILE__ ":" O3TO_STRING(__LINE__) ">"
#define O3OCAt() @"<" @__FILE__ @":" @O3TO_STRING(__LINE__) @">"

#ifdef __cplusplus
template <typename TYPE>
void O3PRINTHEX(const TYPE& to_print) { //inefficent as hell, but hey, it's debug :)
	const UInt8* printbytes = (const UInt8*)(&to_print);
	int i; for(i=0;i<sizeof(TYPE);i++) printf("%X", printbytes[i]);
}
#endif

/*******************************************************************/ #pragma mark Markers /*******************************************************************/
#define O3ToImplement() O3LogError(@"O3ToImplement() tag hit");
#define O3Optimizable() O3LogInfo(@"O3Optimizable() tag hit")
#define O3BadPractice() O3LogWarn(@"O3BadPractice() tag hit")
#define O3Fixme() O3LogWarn(@"O3Fixme() tag hit")
#define O3CheckGLError() if(1) { int O3glError = glGetError(); if (O3glError) O3LogError(@"glError was %i = 0x%X, not 0.\n", O3glError, O3glError); }
#define O3CToImplement() O3CLogError(@"O3ToImplement() tag hit");
#define O3COptimizable() O3CLogInfo(@"O3Optimizable() tag hit")
#define O3CBadPractice() O3CLogWarn(@"O3BadPractice() tag hit")
#define O3CFixme() O3CLogWarn(@"O3Fixme() tag hit")
#define O3CCheckGLError() if(1) { int O3glError = glGetError(); if (O3glError) O3CLogError(@"glError was %i = 0x%X, not 0.\n", O3glError, O3glError); }

/*******************************************************************/ #pragma mark Assertions /*******************************************************************/
void O3FailAssert();
#ifdef O3DEBUG
	#define O3Assert(condition, str, args...)  {if (!(condition)) {O3FailAssert(); [NSException raise:NSInternalInconsistencyException format:@"Assertion (" @#condition @") at " @__FILE__ @":" @O3TO_STRING(__LINE__) @" failed: " str, ## args];}}	
	#define O3Verify(condition, str, args...)  ({O3Assert(condition, str, ##args); condition;})	
	#define O3AssertArg(condition, str, args...)  {if (!(condition)) {O3FailAssert(); [NSException raise:NSInvalidArgumentException format:@"Argument assertion (" @#condition @") at " @__FILE__ @":" @O3TO_STRING(__LINE__) @" failed: " str, ## args];}}	
	#define O3AssertIvar(condition)  {if (!(condition)) {O3FailAssert(); [NSException raise:NSInternalInconsistencyException format:@"Ivar or global \"" @#condition @"\" at " @__FILE__ @":" @O3TO_STRING(__LINE__) @" is missing"];}}	
	#define O3AssertFalse(str, args...) O3Assert(false, @"Supposedly unreachable code has been reached: " str, ##args)
	#define O3AssertInContext(ctx) O3Assert((ctx) == [NSOpenGLContext currentContext], @"Code called in incorrect OpenGL context.");
	#define O3Asrt(condition) O3Assert(condition, @"No description of assertion provided. Please report or fix this (better yet do both), as it was probably really not expected to happen.");
	#define O3VerifyArg(condition, str, args...) {if (!(condition)) {O3FailAssert(); [NSException raise:NSInvalidArgumentException format:@"Argument assertion (" @#condition @") at " @__FILE__ @":" @O3TO_STRING(__LINE__) @" failed: " str, ## args];}}	
#else
	#define O3Assert(condition, str, args...)
	#define O3Verify(condition, str, args...) ({condition;})
	#define O3AssertArg(condition, str, args...)
	#define O3VerifyArg(condition, str, args...) {if (!(condition)) {O3FailAssert(); [NSException raise:NSInvalidArgumentException format:@"Argument assertion (" @#condition @") at " @__FILE__ @":" @O3TO_STRING(__LINE__) @" failed: " str, ## args];}}	
	#define O3AssertIvar(condition)
	#define O3AssertFalse(str, args...)
	#define O3AssertInContext(ctx)
	#define O3Asrt(condition)
#endif
#define O3CompileAssert(x, str) typedef bool O3CompileAssert_HELPER[(x) ? 1 : -1 + 0*(int)str]

/*******************************************************************/ #pragma mark Epsilon, Infinity & Equality /*******************************************************************/
#ifdef __cplusplus
#define O3Epsilon(x) std::numeric_limits<x>::epsilon()
#define O3Inf(x) std::numeric_limits<x>::infinity()
template <typename Ta, typename Tb>
inline bool O3Equals(Ta a, Tb b) {return ((a-b)<O3Epsilon(Ta)) || ((b-a)<O3Epsilon(Ta));}
template <typename Ta, typename Tb, typename Tc>
inline bool O3Equals(Ta a, Tb b, Tc tolerance) {return ((a-b)<tolerance) || ((b-a)<tolerance);}
#endif

/*******************************************************************/ #pragma mark Numeric Limits /*******************************************************************/
#ifdef __cplusplus
#define O3TypeMax(x) std::numeric_limits<x>::max()
#define O3TypeMin(x) std::numeric_limits<x>::min()
#endif

/*******************************************************************/ #pragma mark Debug Logging /*******************************************************************/
///Just a random NSObject singleton. Feel free to use it. By default it inherits all log4cocoa requests in C
inline NSObject* NSObjectPlainObjectSingleton() {
	static NSObject* obj = nil; 
	if (!obj) obj = [NSObject alloc];
	return obj;
}

#ifdef O3DEBUG
void O3Break(); ///<Useful for non-trivial fast breakpoints
//Debug these (O3Log*) by putting a break on @sel(callAppenders:).
#include <Log4Cocoa/Log4Cocoa.h>
#define O3LogDebug(format, args...) log4Debug(([NSString stringWithFormat:format, ##args]))
#define O3LogInfo(format, args...) log4Info(([NSString stringWithFormat:format, ##args]))
///Debug these (O3Log*) by putting a break on @sel(callAppenders:).
#define O3LogWarn(format, args...) log4Warn(([NSString stringWithFormat:format, ##args]))
#define O3LogError(format, args...) log4Error(([NSString stringWithFormat:format, ##args]))
#define O3LogFatal(format, args...) log4Fatal(([NSString stringWithFormat:format, ##args]))
#define O3CLogDebug(format, args...) ({id self = NSObjectPlainObjectSingleton(); O3LogDebug(format,##args);})
#define O3CLogInfo(format, args...)  ({id self = NSObjectPlainObjectSingleton(); O3LogInfo(format,##args);} )
#define O3CLogWarn(format, args...)  ({id self = NSObjectPlainObjectSingleton(); O3LogWarn(format,##args);} )
#define O3CLogError(format, args...) ({id self = NSObjectPlainObjectSingleton(); O3LogError(format,##args);})
#define O3CLogFatal(format, args...) ({id self = NSObjectPlainObjectSingleton(); O3LogFatal(format,##args);})
#else
#define O3Break()
#define O3LogDebug(format, args...)
#define O3LogInfo(format, args...) 
#define O3LogWarn(format, args...) 
#define O3LogError(format, args...) 
#define O3LogFatal(format, args...) 
#define O3CLogDebug(format, args...)  
#define O3CLogInfo(format, args...)   
#define O3CLogWarn(format, args...)   
#define O3CLogError(format, args...)  
#define O3CLogFatal(format, args...)  
#endif



/*******************************************************************/ #pragma mark O3Accelerate /*******************************************************************/
#include "O3Accelerate.h"

/*******************************************************************/ #pragma mark Fast Memory Utils /*******************************************************************/
#ifdef __cplusplus
#ifdef O3AllowObjcMemoryManagementHack
inline id<NSObject> O3Alloc(Class someclass, NSZone* zone) {return NSAllocateObject(someclass, 0, zone);}
inline id<NSObject> O3Copy(id<NSObject> obj, NSZone* zone)	{return NSCopyObject(obj, 0, zone);}
inline id<NSObject> O3Release(id<NSObject> obj) 				{if (NSDecrementExtraRefCountWasZero((obj))) {NSDeallocateObject((obj)); return nil;} return obj;}
inline id<NSObject> O3Retain(id<NSObject> obj) 					{NSIncrementExtraRefCount((obj)); return obj;}
inline id<NSObject> O3Autorelease(id<NSObject> obj) 			{[(obj) autorelease]; return obj;}
inline id<NSObject> O3RetainAutorelease(id<NSObject> obj) 		{O3Autorelease(O3Retain(obj)); return obj;}
#else
inline id<NSObject> O3Alloc(Class someclass, NSZone* zone) {return [someclass allocWithZone:zone];}
inline id<NSCopying> O3Copy(id<NSCopying> obj, NSZone* zone)	{return [obj copyWithZone:zone];}
inline id<NSObject> O3Release(id<NSObject> obj) 				{[obj release]; return obj;}
inline id<NSObject> O3Retain(id<NSObject> obj) 					{return [obj retain];}
inline id<NSObject> O3Autorelease(id<NSObject> obj) 			{return [obj autorelease];}
inline id<NSObject> O3RetainAutorelease(id<NSObject> obj) 		{return O3Autorelease(O3Retain(obj));}
#endif
inline id<NSObject> O3Alloc(Class someclass) {return O3Alloc(someclass, NULL);}
inline id<NSCopying> O3Copy(id<NSCopying> obj)	{return O3Copy(obj,NULL);}
#endif /*defined(__cplusplus)*/

#ifdef O3AllowObjcInitAndDeallocSpeedHack
#include <objc-runtime.h>
#define O3SuperInitOrDie() {													\
	static IMP super_init = NULL;												\
	if (!super_init)															\
		super_init = [super.super_class instanceMethodForSelector:@selector(init)];	\
	if (!super_init(self, @selector(init))) {									\
		O3Release(self);														\
		return nil;																\
	}																			\
}
#define O3SuperDealloc() {														\
	static IMP super_dealloc = NULL;											\
	if (!super_dealloc) 														\
		super_dealloc = [super.super_class instanceMethodForSelector:@selector(dealloc)];	\
	super_dealloc(self, @selector(dealloc));									\
	if (0) [super dealloc];														\
}
#else
#define O3SuperInitOrDie() if (![super init]) return nil;
#define O3SuperDealloc() [super dealloc]
#endif

/*******************************************************************/ #pragma mark Random Useful Macros /*******************************************************************/
#define O3Assign(source, dest) ({\
	id O3AssignSource = (id)(source);											\
	id O3AssignDest = (id)(dest);												\
	if (O3AssignSource != O3AssignDest) {										\
		if (O3AssignSource) O3Retain(O3AssignSource);							\
		(dest) = O3AssignSource;												\
		if (O3AssignDest) O3Release(O3AssignDest);								\
	}																			\
	O3AssignSource;                                                             \
})

#define O3AssignCopy(source, dest) O3Assign(O3Copy(source), (dest))
#define O3AssignMutableCopy(source, dest) O3Assign([(source) mutableCopy], (dest))
#define O3Destroy(victim) ({ O3Release(victim); (victim) = nil; nil;})

#define O3DestroyCppContainer(type, name, prePath, postPath) {		\
	if (name) {												\
		type::iterator it = name->begin();					\
		type::iterator end = name->end();					\
		for (; it!=end; it++)								\
			O3Release(prePath it postPath);					\
		delete name; name = NULL;							\
	}														\
}
#define O3DestroyCppMap(type, name) O3DestroyCppContainer(type, name, , ->second)
#define O3DestroyCppVector(type, name) O3DestroyCppContainer(type, name, *, )
#ifdef __cplusplus
#define O3EXTERN_C_BLOCK extern "C" {
#define O3END_EXTERN_C }
#define O3END_EXTERN_C_BLOCK }
#define O3EXTERN_C extern "C" 
#else
#define O3EXTERN_C_BLOCK
#define O3END_EXTERN_C
#define O3EXTERN_C
#define O3END_EXTERN_C_BLOCK
#endif

O3EXTERN_C void O3GLBreak();

