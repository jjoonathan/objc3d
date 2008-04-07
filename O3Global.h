#pragma once
/**
 *  @file O3Global.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 9/17/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
//#import "O3Utilities.h" //Imported at the end to catch the defs in this file
#include <Cg/cg.h>
#include <Cg/cgGL.h>

/******************************/ #pragma mark Exceptions /********************************/
#ifdef __OBJC__
#include "O3Protocols.h"
#define O3BadContextException @"ObjC3D Unsuitable or Missing Context"
#define O3BadMethodException @"ObjC3D Method Not Applicable (probably depricated by subclass)"
#endif

/************************************/ #pragma mark Errors /************************************/
#define O3CGErrorDomain @"O3CGErrorDomain"
#define O3GLErrorDomain @"O3GLErrorDomain"
#define O3DefaultErrorDomain @"O3DefaultErrorDomain"

/******************************/ #pragma mark Levels of Support /********************************/
#ifdef __OBJC__
#define O3NotSupportedException @"ObjC3D Feature Not Supported Exception"

///Defines enumeration constants for how well something is supported. Test ((support level)&O3FullySupported) to see if all functionality is supported (though it may be through some emulation mechanism).
///Also note that the support levels are in order, so (O3NotSupported==false)<O3PartiallySupported<O3EmulationSupported<O3FallbackSupported<O3FullySupported.
typedef enum O3SupportLevel {
	O3NotSupported=0,		/*000*/ ///<A feature is not supported at all
	O3PartiallySupported=1,	/*001*/ ///<Some parts of a feature are supported, some are not
	O3EmulationSupported=2,	/*010*/ ///<A feature is fully supported, though through emulation mechanism rather than natively. This implies lots of slowness, extra memory copies, etc
	O3FallbackSupported=4,	/*100*/ ///<A feature is fully supported, though through a fallback mechanism (perhaps not as fast as could be)
	O3FullySupported=6		/*110*/ ///<A feature is fully supported ( (x&O3FullySupported) is nonzero if all functionality is supported in some way, perhaps through emulation)
} O3SupportLevel;

@protocol O3Support
+ (O3SupportLevel)supportLevel;
+ (BOOL)supportedAtLeastToLevel:(O3SupportLevel)supportLevel;
+ (void)assertSupportedAtLeastToLevel:(O3SupportLevel)supportLevel;
@end
#endif

/******************************/ #pragma mark Runtime Speed Hacks /********************************/

//Comment this out if things start getting fishy.
#define O3AllowHacks

//This block is a more detailed version of the option above. To debug, comment out individual items.
#ifdef O3AllowHacks
	//Allows the use of CF* functions on toll-free-bridged classes for extra speed.
	#ifdef __COREFOUNDATION__
		#define O3UseCoreFoundation 1
	#else
		#define O3UseCoreFoundation 0
	#endif
	
	#define O3UseCoreGraphics 1

	//O3AllowObjcInitAndDeallocSpeedHack allows O3Retain and O3Release to use special fast methods of allocation and release that skip the ObjC runtime and eek out extra speed.
	//NOTE: As of now, this option is somewhat tied to the one above. If CoreFoundation can't be used, this option automatically is ignored and the fallback ObjC -retain and -release are used normally.
	#define O3AllowObjcInitAndDeallocSpeedHack 1
	
	//Allows thi assumption that [NSDict objectEnumerator] and [NSDict keyEnumerator] enumerate simultaneously
	#define O3AssumeSimultaneousDictEnumeration 1
	
	//This allows O3Retain(), O3Release() macros which were originally intended to speed up the retain/release cycle. However, there are problems with the CoreFoudation bridge, so the macros only work some of the time
	//#define O3AllowObjcMemoryManagementHack 1
	
	//This allows std::vectors to be converted straight to C arrays by assuming that everything is stored sequentially (using &first_element).
	#define O3AllowVectorConversionHack 1
	
	//Allows gcc-specific code to be used
	#define O3AssumeGCCHack 1
	
	//Allows the skiping of initialization where it would be pointless (assumes NSObject's -init does nothing, which is true in Cocoa)
	#define O3AllowInitHack 1
	
	//Allows the use of mach calls to increase speed
	#define O3AllowMachCalls 1
	
	//Use BSD-specific APIs (some may have sneaked past, this was added later)
	#define O3AllowBSDCalls 1
#else
	//#define O3UseCoreFoundation 0
	//#define O3UseCoreGraphics 0
	//#define O3AllowObjcInitAndDeallocSpeedHack 0
	//#define O3AssumeSimultaneousDictEnumeration 0
	//#define O3AllowVectorConversionHack 0
	//#define O3AssumeGCCHack 0
	//#define O3AllowInitHack 0
	//#define O3AllowMachCalls 0
	//#define O3AllowBSDCalls 0
#endif

/************************************/ #pragma mark Deferred Global Imports /************************************/
#import "O3Utilities.h"

/************************************/ #pragma mark Context Management /************************************/
static UInt64 gO3GL2xContextSwitches = 0; ///<O3BeginGLRes increments this by 3, O3EndGLRes decrements it by 1. While in a resource context it should be odd, and when outside it should be even. You can watch it to improve performance by eliminating switches.
static void O3GL2xContextSwitchesDummyUser() {gO3GL2xContextSwitches;}
O3EXTERN_C CGcontext O3GlobalCGContext(); ///<All CG stuff goes here
O3EXTERN_C NSOpenGLContext* O3GLResourceContext(); ///<This is where all O3D textures, etc are stored. IT SHOULD NOT BE USED FOR RENDERING. Share the resources with your render context to use them :)
O3EXTERN_C void O3BeginGLRes(); ///<Enters the global resource context (which should be separate from the rendering context).
O3EXTERN_C void O3EndGLRes(); ///<Exits the global resource context (and restores the previous context).

