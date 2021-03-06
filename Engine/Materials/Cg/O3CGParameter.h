/**
 *  @file O3CGParameter.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 2/20/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import <Cg/cg.h>
#import <Cg/cgGL.h>
#import "O3Parameter.h"
#ifdef __cplusplus
#include <map>
#include <string>
#endif
@class vre;
@class O3KVCHelper;
@class O3CGAnnotation;

/**
 * This class wraps a CG parameter. At any given point, more than one O3CGParameter may exist for a CGparameter.
 * Use isEqualTo for comparisons. This is a "thin" wrapper: the only thing it keeps track of if the parameter it is wrapping.
 * It doesn't do anything else special.
 * It is safe and acceptable to use -rawParameter to get the wrapped parameter and modify it.
 */
@interface O3CGParameter : O3Parameter {
	NSMutableDictionary* mSubParams; ///<Holds fields of a struct param
	NSMutableDictionary* mAnnotations;
	CGparameter mParam;
	BOOL mFreeParamWhenDone;
}
//Initialization
- (id)initWithType:(CGtype)type;
- (id)initWithType:(CGtype)type count:(int)array_size;
- (id)initWithType:(CGtype)type dimensions:(int*)array_size dimensionCount:(unsigned)dim_count;
- (id)initWithParam:(CGparameter)param; ///<Wraps a CGparameter in an O3CGParameter
- (id)initWithTypeFromParam:(CGparameter)param; ///<Duplicates the parameter
- (id)initByCopying:(O3CGParameter*)other;

//Inspectors
- (CGparameter)rawParameter;
- (int)intValue;
- (float)floatValue;
- (double)doubleValue;
- (NSString*)stringValue;
- (CGtype)type;
- (O3CGParameter*)structField:(NSString*)name;

//Thin wrapper management
- (BOOL)freeWhenDone; ///<Weather or not the receiver is responsible for destroying mParam when it is done with it
- (void)setFreeWhenDone:(BOOL)newOwns; ///<Sets weather or not the receiver frees its parameter when it is done with it

//Mutators
- (void)setIntValue:(int)val;
- (void)setIntArrayValue:(int*)val count:(unsigned)count;
- (void)setIntMatrixValue:(int*)val rows:(unsigned)rows columns:(unsigned)cols;
- (void)setIntMatrixValue:(int*)val rows:(unsigned)rows columns:(unsigned)cols rowMajor:(BOOL)rowMajor;

- (void)setFloatValue:(float)val;
- (void)setFloatArrayValue:(const float*)val count:(unsigned)count;
- (void)setFloatMatrixValue:(const float*)val rows:(unsigned)rows columns:(unsigned)cols;
- (void)setFloatMatrixValue:(const float*)val rows:(unsigned)rows columns:(unsigned)cols rowMajor:(BOOL)rowMajor;

- (void)setDoubleValue:(double)val;
- (void)setDoubleArrayValue:(const double*)val count:(unsigned)count;
- (void)setDoubleMatrixValue:(const double*)val rows:(unsigned)rows columns:(unsigned)cols;
- (void)setDoubleMatrixValue:(const double*)val rows:(unsigned)rows columns:(unsigned)cols rowMajor:(BOOL)rowMajor;

//Annotations
- (NSArray*)annotationNames;
- (O3CGAnnotation*)annotationNamed:(NSString*)key;
@end

///Essentially binds \e from to \e to on the key @"value". Does not work for other key-value bindings, and disconnecting is handeled autoamatically if you don't do it manually. A parameter can only be bound to one source parameter at a time (multiple destination parameters are possible).
O3EXTERN_C void O3CGParameterBindValueFrom_to_(O3CGParameter* from, O3CGParameter* to);
O3EXTERN_C BOOL O3CGParameterUnbindValue(O3CGParameter* self);
