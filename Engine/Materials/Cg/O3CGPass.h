/**
 *  @file O3CGPass.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 3/15/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import <Cg/cg.h>
#import <Cg/cgGL.h>
#import "O3Material.h"
#import "O3CGAutoSetParameters.h"
#ifdef __cplusplus
#import <vector>
#include <map>
#include <set>
#include <string>
using namespace std;
#endif
@class O3CGTechnique;
@class O3KVCHelper;
@class O3CGAnnotation;

/** 
 * This class only currently exists to allow access to the annotations.
 * It is not actually used in the other code.
 */
@interface O3CGPass : NSObject {
	CGpass mPass;
	O3KVCHelper* mAnnotationKVCHelper; ///<Allows KVC to be used properly on annotations
#ifdef __cplusplus
	map<string, O3CGAnnotation*>* mAnnotations; ///<All the receiver's annotations
#else
	void* mAnnotations;
#endif
}

//Init
- (O3CGPass*)initWithPass:(CGpass)pass;

//Inspectors
- (NSString*)name;

//Annotations
- (id)annotations;
- (NSArray*)annotationKeys;
- (O3CGAnnotation*)annotationNamed:(NSString*)key;

- (void)purgeCaches;
@end
