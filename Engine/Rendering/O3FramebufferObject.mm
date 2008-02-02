/**
 *  @file O3FramebufferObject.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 12/21/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3FramebufferObject.h"
#import "O3Renderbuffer.h"

O3SupportLevel  gFramebufferObjectSupport = O3NotSupported;

@implementation O3FramebufferObject
O3DefaultO3InitializeImplementation

inline BOOL framebufferCompleteP(O3FramebufferObject* self) {
#ifdef O3DEBUG
	GLenum status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
	if (status!=GL_FRAMEBUFFER_COMPLETE_EXT) {
		switch (status) {
			case GL_FRAMEBUFFER_UNSUPPORTED_EXT:
				O3LogError(@"Framebuffer \"%s\" is not supported for an implementation dependant reason.", NSStringUTF8String([self description]));
				return NO;
			case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_EXT:
				O3LogError(@"Framebuffer \"%s\" returned an obsolete error (GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_EXT).", NSStringUTF8String([self description]));
				return NO;
			case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_EXT:
				O3LogError(@"Framebuffer \"%s\" is invalid because it is missing a required attachment.", NSStringUTF8String([self description]));
				return NO;
			case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_EXT:
				O3LogError(@"Framebuffer \"%s\" is invalid because it is of unacceptable dimensions.", NSStringUTF8String([self description]));
				return NO;
			case GL_FRAMEBUFFER_INCOMPLETE_FORMATS_EXT:
				O3LogError(@"Framebuffer \"%s\" is invalid because it uses an unsupported format.", NSStringUTF8String([self description]));
				return NO;
			case GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER_EXT:
				O3LogError(@"Framebuffer \"%s\" has an incomplete draw buffer.", NSStringUTF8String([self description]));
				return NO;
			case GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER_EXT:
				O3LogError(@"Framebuffer \"%s\" has an incomplete read buffer.", NSStringUTF8String([self description]));
				return NO;
			default:
				O3LogError(@"Framebuffer \"%s\" has an unrecognized error (%d=0x%X).", NSStringUTF8String([self description]), status, status);
				return NO;
		}
		return NO;
	}
#endif
	return YES;
}

inline void bindP(O3FramebufferObject* self, BOOL forRendering) {
	GLuint bufferID = 0;
	if (self) bufferID = self->mFrameBufferID;
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, bufferID);
	if (forRendering && bufferID && !framebufferCompleteP(self)) {
		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
		O3LogError(@"FBO \"%s\" is incomplete, so it cannot be bound.", NSStringUTF8String([self description]));
	}
}
void O3FramebufferObject_bind(O3FramebufferObject* self, BOOL forRendering) {bindP(self, forRendering);}

inline void lazyInitializeP() {
	static BOOL initialized = NO;
	if (initialized) return;
	initialized = YES;
	gFramebufferObjectSupport = (GLEW_EXT_framebuffer_object)? O3FullySupported : O3NotSupported;
}

- (id)init {
	lazyInitializeP();
	if (gFramebufferObjectSupport==O3NotSupported) {
		O3LogWarn(@"init was called on a framebuffer object but framebuffer objects are not supported on this computer");
		return nil;
	}
	O3SuperInitOrDie();
	glGenFramebuffersEXT(1, &mFrameBufferID);
	return self;
}

- (void)dealloc {
	bindP(nil, NO);
	glDeleteFramebuffersEXT(1, &mFrameBufferID);
	[super dealloc];
}

- (NSDictionary*)attachedObjects {
	return mAttachedObjects;
}

- (void)detachObject:(id<O3FramebufferAttachable>)object {
	NSEnumerator* keys = [mAttachedObjects keyEnumerator];
	NSNumber* key;
	while (key = [keys nextObject])
		if ([[mAttachedObjects objectForKey:key] isEqual:object]) {
			[self detachObjectAtPoint:(GLenum)[key unsignedIntValue]];
			break;
		}
}

- (void)detachObjectAtPoint:(GLenum)point {
	NSNumber* key = [NSNumber numberWithUnsignedInt:(unsigned int)point];
	[mAttachedObjects removeObjectForKey:key];
	
	bindP(self, NO);
	glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, point, GL_RENDERBUFFER_EXT, GL_ZERO);
	bindP(nil, NO);
}

- (void)attachObject:(id<O3FramebufferAttachable>)object toPoint:(GLenum)point {
	[object attachToFramebufferObject:self atPoint:point];
}

- (void)createBufferWithFormat:(GLenum)format width:(GLuint)width height:(GLuint)height andAttachToPoint:(GLenum)point {
	bindP(self, NO);
	O3Renderbuffer* buff = [[O3Renderbuffer alloc] initWithFormat:format width:width height:height];
	O3Assert(buff, @"Renderbuffer creation failed.");
	[self attachObject:buff toPoint:point];
	bindP(nil, NO);
}

- (void)bind {bindP(self, YES);}
- (void)unbind {bindP(nil, NO);}
+ (void)unbind {bindP(nil, NO);}

+ (O3SupportLevel)supportLevel {
	lazyInitializeP();
	return gFramebufferObjectSupport;
}

+ (BOOL)supportedAtLeastToLevel:(O3SupportLevel)supportLevel {
	lazyInitializeP();
	return gFramebufferObjectSupport;
}
	
+ (void)assertSupportedAtLeastToLevel:(O3SupportLevel)supportLevel {
	lazyInitializeP();
	if (supportLevel>gFramebufferObjectSupport)
		[NSException raise:O3NotSupportedException format:@"[O3Framebuffer assertSupportedAtLeastToLevel:%i] failed, support level was %i", supportLevel, gFramebufferObjectSupport];
}

@end
