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
@class O3CGEffect;
@class O3KVCHelper;
@class O3CGAnnotation;
@class O3CGPass;

@interface O3CGTechnique : NSObject <O3MultipassDirector> {
	/*O3WEAK*/ O3CGEffect* mEffect; ///<The effect that contains the technique
	CGtechnique mTechnique; ///<The actual technique wrapped by the O3CGTechnique
	O3KVCHelper* mAnnotationKVCHelper;
	O3KVCHelper* mPassesKVCHelper;
#ifdef __cplusplus
	vector<CGpass>* mPasses; ///<A cache of the passes in the O3CGTechnique (not the ObjC objects)
	map<string, O3CGPass*>* mPassMap; ///<All the receiver's pass objects organized into a map by name
	map<string, O3CGAnnotation*>* mAnnotations; ///<All the receiver's annotations
#else
	void* mPasses;
	void* mPassMap;
	void* mAnnotations;
#endif
}
//Init
- (id)initWithTechnique:(CGtechnique)technique fromEffect:(O3CGEffect*)effect;

//Inspectors
- (BOOL)isValid; ///<YES iff the receiver can be used for rendering (is valid)
- (NSString*)name;

//Annotations
- (id)annotations;
- (NSArray*)annotationKeys;
- (O3CGAnnotation*)annotationNamed:(NSString*)key;

//Passes
- (id)passes;
- (NSArray*)passKeys;
- (O3CGPass*)passNamed:(NSString*)key;

- (void)purgeCaches;

//Use
- (int)renderPasses;	///<How many passes are required for the receiver
- (void)beginRendering;
- (void)setRenderPass:(int)passnum;	///<Sets the OpenGL state tot hat required for pass number \e passnum of the receiver @warn Stomps on OpenGL state, reset anything important afterwards
- (void)endRendering;
@end
