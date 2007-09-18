/**
 *  @file O3RenderBuffer.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 12/21/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import <Cocoa/Cocoa.h>
#import "O3FrameBufferobject.h"

@interface O3Renderbuffer : NSObject <O3FramebufferAttachable, O3Support> {
	GLuint mRenderBufferID;
}
- (GLuint)width;
- (GLuint)height;
- (GLenum)internalFormat;
- (NSSize)redResolution;
- (NSSize)greenResolution;
- (NSSize)blueResolution;
- (NSSize)alphaResolution;
- (NSSize)stencilResolution;
- (NSSize)depthResolution;
- (id)initWithFormat:(GLenum)type width:(GLuint)width height:(GLuint)height;
- (void)attachToFramebufferObject:(O3FramebufferObject*)framebuffer atPoint:(GLenum)attachmentPoint;

//O3Support
+ (O3SupportLevel)supportLevel;
+ (BOOL)supportedAtLeastToLevel:(O3SupportLevel)supportLevel;
+ (void)assertSupportedAtLeastToLevel:(O3SupportLevel)supportLevel;
@end
