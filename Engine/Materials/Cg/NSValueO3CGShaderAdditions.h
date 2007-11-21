/**
 *  @file NSValueO3CGShaderAdditions.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 1/11/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import <Cocoa/Cocoa.h>
#import <Cg/Cg.h>

@interface NSValue (O3CGShader)
+ (NSValue*)valueWithBytes:(const void*)bytes cgType:(CGtype)type;
@end
