/**
 *  @file O3RenderBuffer.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 12/21/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3RenderBuffer.h"

extern O3SupportLevel  gFramebufferObjectSupport; //O3FramebufferObject.mm

@implementation O3Renderbuffer

inline id initP(O3Renderbuffer* self) {
	if (gFramebufferObjectSupport==O3NotSupported) {
		if ([O3Renderbuffer supportLevel]==O3NotSupported) {
			O3LogWarn(@"init was called on a renderbuffer but framebuffer objects (and therefore renderbuffers) are not supported on this computer");
			[self release];
			return nil;
		}
	}
	return self;
}

- (id)init {
	O3SuperInitOrDie();

	glGenRenderbuffersEXT(1, &mRenderBufferID);
	return self;
}

- (id)initWithFormat:(GLenum)type width:(GLuint)width height:(GLuint)height {
	O3SuperInitOrDie();
	glGenRenderbuffersEXT(1, &mRenderBufferID);
	glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, mRenderBufferID);
	glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT, type, width, height);
	return self;
}

- (GLuint)width {
	GLuint to_return;
	glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, mRenderBufferID);
	glGetRenderbufferParameterivEXT(GL_RENDERBUFFER_EXT, GL_RENDERBUFFER_WIDTH_EXT, (GLint*)&to_return);
	return to_return;
}

- (GLuint)height {
	GLuint to_return;
	glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, mRenderBufferID);
	glGetRenderbufferParameterivEXT(GL_RENDERBUFFER_EXT, GL_RENDERBUFFER_HEIGHT_EXT, (GLint*)&to_return);
	return to_return;
}

- (GLenum)internalFormat {
	GLenum to_return;
	glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, mRenderBufferID);
	glGetRenderbufferParameterivEXT(GL_RENDERBUFFER_EXT, GL_RENDERBUFFER_INTERNAL_FORMAT_EXT, (GLint*)&to_return);
	return to_return;
}

- (NSSize)redResolution {
	GLuint resolution[2];
	glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, mRenderBufferID);
	glGetRenderbufferParameterivEXT(GL_RENDERBUFFER_EXT, GL_RENDERBUFFER_RED_SIZE_EXT, (GLint*)&resolution);
	return NSMakeSize((float)(resolution[0]), (float)(resolution[1]));
}

- (NSSize)greenResolution {
	GLuint resolution[2];
	glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, mRenderBufferID);
	glGetRenderbufferParameterivEXT(GL_RENDERBUFFER_EXT, GL_RENDERBUFFER_GREEN_SIZE_EXT, (GLint*)&resolution);
	return NSMakeSize((float)(resolution[0]), (float)(resolution[1]));
}

- (NSSize)blueResolution {
	GLuint resolution[2];
	glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, mRenderBufferID);
	glGetRenderbufferParameterivEXT(GL_RENDERBUFFER_EXT, GL_RENDERBUFFER_BLUE_SIZE_EXT, (GLint*)&resolution);
	return NSMakeSize((float)(resolution[0]), (float)(resolution[1]));
}

- (NSSize)alphaResolution {
	GLuint resolution[2];
	glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, mRenderBufferID);
	glGetRenderbufferParameterivEXT(GL_RENDERBUFFER_EXT, GL_RENDERBUFFER_ALPHA_SIZE_EXT, (GLint*)&resolution);
	return NSMakeSize((float)(resolution[0]), (float)(resolution[1]));
}

- (NSSize)stencilResolution {
	GLuint resolution[2];
	glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, mRenderBufferID);
	glGetRenderbufferParameterivEXT(GL_RENDERBUFFER_EXT, GL_RENDERBUFFER_STENCIL_SIZE_EXT, (GLint*)&resolution);
	return NSMakeSize((float)(resolution[0]), (float)(resolution[1]));
}

- (NSSize)depthResolution {
	GLuint resolution[2];
	glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, mRenderBufferID);
	glGetRenderbufferParameterivEXT(GL_RENDERBUFFER_EXT, GL_RENDERBUFFER_DEPTH_SIZE_EXT, (GLint*)&resolution);
	return NSMakeSize((float)(resolution[0]), (float)(resolution[1]));
}

- (void)dealloc {
	glDeleteRenderbuffersEXT(1, &mRenderBufferID);
	[super dealloc];
}

- (void)attachToFramebufferObject:(O3FramebufferObject*)framebuffer atPoint:(GLenum)attachmentPoint {
	O3FramebufferObject_bind(framebuffer, NO);
	glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, attachmentPoint, GL_RENDERBUFFER_EXT, mRenderBufferID);
	O3FramebufferObject_bind(nil, NO);
}

+ (O3SupportLevel)supportLevel {return [O3FramebufferObject supportLevel];}
+ (BOOL)supportedAtLeastToLevel:(O3SupportLevel)supportLevel {return [O3FramebufferObject supportedAtLeastToLevel:supportLevel];}
+ (void)assertSupportedAtLeastToLevel:(O3SupportLevel)supportLevel {
	if (![O3FramebufferObject supportedAtLeastToLevel:supportLevel])
		[NSException raise:O3NotSupportedException format:@"[O3RenderBuffer assertSupportedAtLeastToLevel:%i] failed, support level was %i", supportLevel, gFramebufferObjectSupport];
}
						  
@end
