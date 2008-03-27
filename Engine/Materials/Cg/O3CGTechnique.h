/**
 *  @file O3CGTechnique.h
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import <Cg/cg.h>
#import <Cg/cgGL.h>
#ifdef __cplusplus
#include <vector>
#include <map>
#include <string>
using namespace std;
#endif
@class O3CGEffect, O3KVCHelper, O3CGAnnotation, O3CGPass, O3Material;

@interface O3CGTechnique : NSObject <O3MultipassDirector, O3HasParameters> {
	/*O3WEAK*/ O3CGEffect* mEffect; ///<The effect that contains the technique
	CGtechnique mTechnique; ///<The actual technique wrapped by the O3CGTechnique
	NSMutableDictionary* mAnnotations;
	NSMutableDictionary* mPassMap;
#ifdef __cplusplus
	vector<CGpass>* mPasses; ///<A cache of the passes in the O3CGTechnique (not the ObjC objects)
#else
	void* mPasses;
#endif
}
//Init
- (id)initWithTechnique:(CGtechnique)technique fromEffect:(O3CGEffect*)effect;

//Inspectors
- (BOOL)isValid; ///<YES iff the receiver can be used for rendering (is valid)
- (NSString*)name;
- (O3CGEffect*)effect;

//Annotations
- (NSArray*)annotationNames;
- (O3CGAnnotation*)annotation:(NSString*)key;

//Passes
- (NSArray*)passNames;
- (O3CGPass*)passNamed:(NSString*)key;
- (void)purgeCaches;

//Parameters
- (BOOL)paramsAreCGParams;
- (NSDictionary*)paramValues;
- (id)valueForParam:(NSString*)pname;
- (void)setValue:(id)val forParam:(NSString*)pname;
- (O3Parameter*)param:(NSString*)pname;

//Use
- (O3Material*)newMaterial;
- (int)renderPasses;	///<How many passes are required for the receiver
- (void)beginRendering;
- (void)setRenderPass:(int)passnum;	///<Sets the OpenGL state tot hat required for pass number \e passnum of the receiver @warn Stomps on OpenGL state, reset anything important afterwards
- (void)endRendering;
@end
