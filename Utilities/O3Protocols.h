#pragma once
/**
 *  @file O3Protocols.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 9/9/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 *  @brief This file contains various global protocols for use in ObjC3D
 */
/**
 * O3MultipassDirector is a protocol for all objects that control a multipass rendering (by changing the state in-between each pass)
 * For example, a shader and a CG effect both represent a multipass director.
 */
@protocol O3MultipassDirector
- (int)renderPasses;
- (void)beginRendering;
- (void)setRenderPass:(int)passnum;
- (void)endRendering;
@end

/**
 * O3HasParameters is a protocol for all objects (shaders, effects, and such) that have KVC-enabled parameters 
 */
@protocol O3HasParameters
- (id)parameters;
- (NSArray*)parameterKeys;
- (NSObject*)parameterNamed:(NSString*)key;
- (void)setParameterValue:(NSValue*)value forKey:(NSString*)key;
@end

/**
 * O3HasCGParameters is a protocol for all objects (shaders, effects, and such) that have KVC-enabled CG parameters 
 */
@class O3CGParameter;
@protocol O3HasCGParameters
- (id)parameters;
- (NSArray*)parameterKeys;
- (O3CGParameter*)parameterNamed:(NSString*)key;
- (void)setParameterValue:(NSValue*)value forKey:(NSString*)key;
@end

/**
 * NSObject (O3MutableValues) is an informal protocol that assures that all objects have certain *value and set*Value methods.
 */
@interface NSObject (O3MutableValues)
- (NSValue*)value;
- (int)intValue;
- (float)floatValue;
- (double)doubleValue;
- (NSString*)stringValue;

- (void)setIntValue:(int)val;
- (void)setFloatValue:(float)val;
- (void)setDoubleValue:(double)val;
- (void)setValue:(NSObject*)newValue; ///<Sets the value of the receiver to newValue without changing the receiver's type
@end
