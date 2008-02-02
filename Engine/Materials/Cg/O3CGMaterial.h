/**
 *  @file O3CGMaterial.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 4/4/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#ifdef __cplusplus
#include <map>
#include <string>
using namespace std;
#endif
@class O3KVCHelper;
@class O3CGParameter;

struct O3CGMaterialParameterPair {
	O3CGParameter* target;
	O3CGParameter* value;
#ifdef __cplusplus
	O3CGMaterialParameterPair() {
		target = nil;
		value = nil;
	}
#endif
};

/**
 * The O3CGMaterial class is a special case of O3Material specifically for Cg render directors (shaders, effects).
 * It bypasses the Objective C layer when setting parameters for additional speed. You shouldn't use this on any
 * non-Cg render directors (it won't work).
 * @warn O3CGMaterial doesn't clean up after itself for efficiency reasons. -endRendering is just for compatibility.
 * @bug Possible bug: doesn't retain target parameters
 */
@interface O3CGMaterial : NSObject {
	NSString* mMaterialTypeName;
	NSObject<O3MultipassDirector, O3HasCGParameters>* mMaterialType;	///<The type of material (the shader that implements this type of material)
	O3KVCHelper* mParameterKVCHelper;
#ifdef __cplusplus
	map<string, O3CGMaterialParameterPair>* mParameters;
	vector<O3CGParameter*>* mParamsToUnbind; ///<All open bindings that the receiver is responsible for closing
#else
	void* mParameters;
	void* mParamsToUnbind;
#endif
}
//Creation
- (id)initWithMaterialType:(NSObject<O3MultipassDirector, O3HasCGParameters>*)materialType;
- (id)initWithMaterialTypeNamed:(NSString*)typeName;

//Material type
- (NSString*)materialTypeName;
- (void)setMaterialTypeName:(NSString*)newName;
- (NSObject<O3MultipassDirector, O3HasCGParameters>*)materialType;
- (void)setMaterialType:(NSObject<O3MultipassDirector, O3HasCGParameters>*)materialType;

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
