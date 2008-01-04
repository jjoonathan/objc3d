/**
 *  @file O3CGProgram.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 1/5/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#include <Cg/cg.h>
#include <Cg/cgGL.h>
#import "O3Utilities.h"
#import "O3CGAutoSetParameters.h"
#ifdef __cplusplus
#include <map>
#include <string>
#include <vector>
using namespace std;
#endif
@class O3KVCHelper;
@class O3CGParameter;
@class O3CGAnnotation;

extern const unsigned O3CGActionUndoableWhenPrecompiledError;
extern CGcontext gCGContext; ///<Access with O3GlobalCGContext();
	CGcontext O3GlobalCGContext();

@interface O3CGProgram : NSObject <O3HasParameters, O3HasCGParameters, O3MultipassDirector> {
	CGprogram mProgram;		///<The CGprogram that is wrapped by the receiver
	NSString* mEntryPoint;	///<The entry point into the program (this doesn't seem to be fetchable via the Cg runtime?)
	O3KVCHelper* mParameterKVCHelper; ///<Allows KVC to be used properly on parameters
	O3KVCHelper* mAnnotationKVCHelper; ///<Allows KVC to be used properly on annotations
#ifdef __cplusplus
	map<string, O3CGParameter*>* mParameters; ///<All the receiver's parameters
	map<string, O3CGAnnotation*>* mAnnotations; ///<All the receiver's annotations
	vector<O3CGAutoSetParameter>* mAutoSetParameters;
#else
	void* mParameters;
	void* mAnnotations;
	void* mAutoSetParameters;
#endif
	#ifdef O3DEBUG
	bool mRenderingBegun; ///<Catches attempts to set pases without first enabling rendering
	#endif
}
//Initialization
- (id)initWithSource:(NSString*)source entryFunction:(NSString*)entryPoint type:(CGprofile)profile;
- (id)initWithPrecompiledData:(NSData*)data entryFunction:(NSString*)entryPoint type:(CGprofile)profile;

//Annotations
- (id)annotations;
- (NSArray*)annotationKeys;
- (O3CGAnnotation*)annotationNamed:(NSString*)key;

//Parameters
- (id)parameters;
- (NSArray*)parameterKeys;
- (O3CGParameter*)parameterNamed:(NSString*)key;
- (void)setParameterValue:(NSValue*)value forKey:(NSString*)key;

//Use
- (int)renderPasses;	///<How many passes are required for the receiver's foremost technique
- (void)beginRendering;	///<Start rendering the receiver's foremost technique
- (void)setRenderPass:(int)passnum;	///<Sets the OpenGL state tot hat required for pass number \e passnum of the receiver's foremost technique @warn Stomps on OpenGL state, reset anything important afterwards
- (void)endRendering;	///<Stops rendering the receiver's foremost technique

//Memory management
- (void)purgeCaches; ///<Purges all of the receiver's caches. mTechniques, mParameters, and mAnnotations in this case.

//Class Methods
+ (BOOL)compiledLazily;		///<YES if programs are only compiled when needed
+ (BOOL)compiledAutomatically;	///<YES if programs are compiled automatically
+ (void)setCompiledLazily:(BOOL)lazy;	///<Sets weather programs are only compiled when needed (YES) or if they are compiled the moment they change (NO). YES by default. Implicitly sets compiledAutomatically to YES. @note This setting has no meaning when \e compiledAutomatically is false.
+ (void)setCompiledAutomatically:(BOOL)compiledAutomatically;	///<Sets weather or not the receiver is compiled automatically.
+ (BOOL)shadersEnabled; ///<Weather or not shaders are enabled
+ (NSError*)setShadersEnabled:(BOOL)enable; ///<Sets weather or not shaders are enabled. @return Nil on success or an error if shaders could not be enabled.

@end
