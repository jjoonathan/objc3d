/**
 *  @file O3CGEffect.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 1/5/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import <Cg/cg.h>
#import <Cg/cgGL.h>
#import "O3Material.h"
#import "O3CGAutoSetParameters.h"
#ifdef __cplusplus
#include <vector>
#include <map>
#include <set>
#include <string>
using namespace std;
#endif
@class O3CGTechnique;
@class O3KVCHelper;
@class O3CGParameter;
@class O3CGAnnotation;
@class O3CGMaterial;

@interface O3CGEffect : NSObject <O3HasParameters, O3HasCGParameters, O3MultipassDirector> {
	CGeffect mEffect;	///<The effect wrapped by the receiver
	int mTechniqueLevel; ///<The number of techniques that failed validation before one was found that passed (for stats only, not actually used)
	int mPasses; ///<The number of renderPasses required by the receiver (or 0 if the number has yet to be discovered; it's lazy loaded)
	O3CGTechnique* mPrincipalTechnique; ///<The first supported technique
	O3KVCHelper* mTechniqueKVCHelper; ///<Allows KVC to be used properly on techniques
	O3KVCHelper* mParameterKVCHelper; ///<Allows KVC to be used properly on parameters
	O3KVCHelper* mAnnotationKVCHelper; ///<Allows KVC to be used properly on annotations
	NSString* mSource; ///<Saved for archiving purposes
#ifdef __cplusplus
	map<string, O3CGTechnique*>* mTechniques; ///<All the techniques in the receiver
	map<string, O3CGParameter*>* mParameters; ///<All the receiver's parameters
	map<string, O3CGAnnotation*>* mAnnotations; ///<All the receiver's annotations
	vector<O3CGAutoSetParameter>* mAutoSetParameters; ///<Parameters that need to be automatically set
	set<CGparameter>* mTextureParams; ///<Parameters that have a sampler and therefore need to be manually enabled and disabled
#else
	void* mTechniques;
	void* mParameters;
	void* mAnnotations;
	void* mAutoSetParameters;
	void* mTextureParams;
#endif
	BOOL mRenderingBegun; ///<Used for debug purposes (YES if we are in the middle of a beginRendering / endRendering block)
}
//Convenience
- (O3CGMaterial*)newMaterial; ///<Returns a new material with the default technique

//Initialization
+ (void)o3init;
- (id)initWithSource:(NSString*)source;

//Source editing (not efficient, but handy for KVC)
- (NSString*)source;
- (void)setSource:(NSString*)source; //Clears out params, techniques, etc.

//Annotations
- (id)annotations;
- (NSArray*)annotationKeys;
- (O3CGAnnotation*)annotationNamed:(NSString*)key;

//Techniques
- (id)techniques;
- (NSArray*)techniqueKeys;
- (O3CGTechnique*)techniqueNamed:(NSString*)key;

//Parameters
- (id)parameters;
- (NSArray*)parameterKeys;
- (O3CGParameter*)parameterNamed:(NSString*)key;
- (void)setParameterValue:(id)value forKey:(NSString*)key;
- (CGtype)typeNamed:(NSString*)tname;

//Use
- (int)renderPasses;	///<How many passes are required for the receiver's foremost technique
- (void)beginRendering;	///<Start rendering the receiver's foremost technique
- (void)setRenderPass:(int)passnum;	///<Sets the OpenGL state to that required for pass number \e passnum of the receiver's foremost technique @warn Stomps on OpenGL state, reset anything important afterwards
- (void)endRendering;	///<Stops rendering the receiver's foremost technique

//Memory management
- (void)purgeCaches; ///<Purges all of the receiver's caches. mTechniques, mParameters, and mAnnotations in this case.

//Class
+ (BOOL)effectsEnabled; ///<Returns weather or not effects are enabled. If effects are disabled, calling setRenderPass: returns without actually setting the pass (but every other method works as expected)
+ (NSError*)setEffectsEnabled:(BOOL)enabled; ///<Sets weather or not effects are enabled. If effects are disabled, calling setRenderPass: returns without actually setting the pass (but every other method works as expected)

//Globals
+ (O3CGParameter*)globalNamed:(NSString*)gpname;
+ (void)setGlobalValue:(id)val forKey:(NSString*)k;
+ (O3CGParameter*)createGlobalOfType:(CGtype)t forKey:(NSString*)k;
@end

@interface O3CGEffect (TechniquePrivateCallbacks)
- (void)beginTechniqueRendering;
- (void)endTechniqueRendering;
@end
