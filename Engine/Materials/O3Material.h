/**
 *  @file O3Material.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 1/4/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#ifdef __cplusplus
#import "O3CGParameter.h"
#include <map>
#include <string>
using namespace std;
#endif
@class O3KVCHelper, O3Material, O3Parameter;

struct O3MaterialParameterPair {
#ifdef __cplusplus
	O3MaterialParameterPair(): value(nil), cg_value(nil), cg_to(nil), paramName(nil) {} ///<Default constructor for use in the map
	~O3MaterialParameterPair() {
		O3Destroy(value);
		O3Destroy(cg_value);
		O3Destroy(cg_to);
		O3Destroy(paramName);
	}
	id Value() {return value ?: [cg_value value];}
	O3Parameter* Param(O3Material* pt);
	void SetValue(id nval) {
		if (cg_to) {
			if (!cg_value) cg_value = [[O3CGParameter alloc] initByCopying:cg_to];
			[cg_value setValue:nval];
		} else
			O3Assign(nval, value);
	}
	NSString* Name() {return paramName;}
	void SetName(NSString* nn) {O3Assign(nn, paramName);}
	void Set(O3Material* parentMaterial);
	void SetTarget(NSObject<O3MultipassDirector, O3HasParameters>* matType) {
		if (cg_value) {
			O3Assign([cg_value value], value);
			O3Destroy(cg_value);
		}
		if ([matType paramsAreCGParams]) {
			O3CGParameter* pTo = (O3CGParameter*)[matType param:paramName];
			O3CGParameter* newP = [[O3CGParameter alloc] initByCopying:pTo];
			if (value) [newP setValue:value];
			O3Destroy(value);
			O3Assign(pTo, cg_to);
			O3Assign(newP, cg_value);
			[newP release];
		} else {
			O3Destroy(cg_to);
		}
	}
	private:
#endif
	O3CGParameter* cg_value;
	id value;	//The value to send to -setValue, but only if cg_value doesn't provide a value for cg_to.
	O3CGParameter* cg_to;
	NSString* paramName;
};

/**
 * The O3Material class encapsulates a material type and its settings. For example, if you
 * had a procedural wood shader that had several inputs that changed per mesh, you could maintain one O3Material per mesh
 * which contained the parameters to the shader 
 * @warn O3Material doesn't clean up after itself for efficiency reasons. -endRendering is just for compatibility.
 * @bug Possible bug: doesn't retain target parameters
 */
@interface O3Material : NSObject <O3MultipassDirector, O3HasParameters> {
	NSString* mMaterialTypeName; ///<The name of the material type if a name should be used
	NSObject<O3MultipassDirector, O3HasParameters>* mMaterialType;	///<The type of material (the shader that implements this type of material). @warning This does not get archived.
#ifdef __cplusplus
	map<string, O3MaterialParameterPair>* mParameters;
#else
	void* mParameters;
#endif
}
//Creation
- (id)initWithMaterialType:(NSObject<O3MultipassDirector, O3HasParameters>*)materialType;
- (id)initWithMaterialTypeNamed:(NSString*)typeName;

//Material type
- (NSString*)materialTypeName;
- (void)setMaterialTypeName:(NSString*)newName;
- (NSObject<O3MultipassDirector, O3HasParameters>*)materialType;
- (void)setMaterialType:(NSObject<O3MultipassDirector, O3HasParameters>*)materialType;

//O3HasParameters
- (NSDictionary*)paramValues;
- (id)valueForParam:(NSString*)pname;
- (void)setValue:(id)val forParam:(NSString*)pname;
- (O3Parameter*)param:(NSString*)pname;
- (NSArray*)paramNames;

//O3MultipassDirector
- (int)renderPasses; ///<How many passes the receiver takes to be rendered properly
- (void)beginRendering;
- (void)setRenderPass:(int)passnum; ///<Set the OpenGL state to that required for pass \e passnum. @note This stomps on OpenGL state so you have to backup anything you want to keep yourself
- (void)endRendering;
@end
