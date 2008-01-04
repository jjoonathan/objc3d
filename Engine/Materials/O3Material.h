/**
 *  @file O3Material.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 1/4/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#ifdef __cplusplus
#include <map>
#include <string>
using namespace std;
#endif
@class O3KVCHelper;

struct O3MaterialParameterPair {
	NSObject* target;	//Has -setValue:
	NSObject* value;	//Has -value
#ifdef __cplusplus
	O3MaterialParameterPair() { ///<Default constructor for use in the map
		target = nil;
		value = nil;
	}
#endif
};

/**
 * The O3Material class encapsulates a material type and its settings. For example, if you
 * had a procedural wood shader that had several inputs that changed per mesh, you could maintain one O3Material per mesh
 * which contained the parameters to the shader 
 * @warn O3Material doesn't clean up after itself for efficiency reasons. -endRendering is just for compatibility.
 * @bug Possible bug: doesn't retain target parameters
 */
@interface O3Material : NSObject <O3MultipassDirector> {
	NSObject<O3MultipassDirector, O3HasParameters>* mMaterialType;	///<The type of material (the shader that implements this type of material)
	O3KVCHelper* mParameterKVCHelper;
#ifdef __cplusplus
	map<string, O3MaterialParameterPair>* mParameters;
#else
	void* mParameters;
#endif
}
//Creation
- (id)initWithMaterialType:(NSObject<O3MultipassDirector, O3HasParameters>*)materialType;

//Material type
- (NSObject<O3MultipassDirector, O3HasParameters>*)materialType;
- (void)setMaterialType:(NSObject<O3MultipassDirector, O3HasParameters>*)materialType;

//mParameters
- (id)parameters;
- (NSArray*)parameterNames;
- (void)setValue:(NSObject*)value forParameter:(NSString*)param;
- (NSObject*)valueForParameter:(NSString*)param;

//O3MultipassDirector
- (int)renderPasses; ///<How many passes the receiver takes to be rendered properly
- (void)beginRendering;
- (void)setRenderPass:(int)passnum; ///<Set the OpenGL state to that required for pass \e passnum. @note This stomps on OpenGL state so you have to backup anything you want to keep yourself
- (void)endRendering;
@end
