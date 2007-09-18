/**
 *  @file O3FramebufferObject.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 12/21/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
static NSMutableDictionary* gAllFramebufferObjects;
	static void O3DummyUser_FramebufferGlobals() {gAllFramebufferObjects;}

@class O3FramebufferObject;

@protocol O3FramebufferAttachable
- (void)attachToFramebufferObject:(O3FramebufferObject*)framebuffer atPoint:(GLenum)attachmentPoint;
@end

@interface O3FramebufferObject : NSObject <O3Support> {
	GLuint mFrameBufferID;
	NSMutableDictionary* mAttachedObjects;
}
- (NSDictionary*)attachedObjects;
- (void)detachObjectAtPoint:(GLenum)point;
- (void)detachObject:(id<O3FramebufferAttachable>)object;
- (void)attachObject:(id<O3FramebufferAttachable>)object toPoint:(GLenum)point;
- (void)createBufferWithFormat:(GLenum)format width:(GLuint)width height:(GLuint)height andAttachToPoint:(GLenum)point;
- (void)bind;
- (void)unbind;
+ (void)unbind;

//O3Support
+ (O3SupportLevel)supportLevel;
+ (BOOL)supportedAtLeastToLevel:(O3SupportLevel)supportLevel;
+ (void)assertSupportedAtLeastToLevel:(O3SupportLevel)supportLevel;
@end

///The O3Accelerate interface to O3FramebufferObject.
///@param forRendering YES if \e self is being bound for rendering and NO if it is just being bound for modifying (IOW if "NO" error checking will be skipped)
void O3FramebufferObject_bind(O3FramebufferObject* self, BOOL forRendering);
