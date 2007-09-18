/**
 *  @file O3CubeMap.mm
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#include "O3Texture.h"
#include "O3CubeMap.h"

@implementation O3CubeMap
#include "O3TextureConstantInterperetation.h"

/************************************/ #pragma mark Information /************************************/
- (unsigned)size {
	unsigned to_return = 0;
	if (isFormatCompressedP([self internalFormat])) {
		glGetTexLevelParameteriv(GL_TEXTURE_CUBE_MAP_POSITIVE_X_ARB, 0, GL_TEXTURE_COMPRESSED_IMAGE_SIZE_ARB, (GLint*)&to_return);
	} else {
		unsigned number_pixels = [self width] * [self height];
		to_return = sizeForIneternalFormatAndPixelsP([self internalFormat], number_pixels);
	}
	return to_return;
}

/************************************/ #pragma mark Initialization /************************************/
- (void)dealloc {
	if (mLoadBuffers[0]) glDeleteBuffers(6, mLoadBuffers);
	[super dealloc];
}

- (id)init {
	O3SuperInitOrDie();
	mTarget = GL_TEXTURE_CUBE_MAP;
	return self;
}

- (id)initWithSize:(GLsizei)widthEqualsHeight
            internalFormat:(GLenum)internalFormat
                  dataType:(GLuint)type
                dataFormat:(GLuint)format
      dataForPositiveXFace:(NSData*)pxData
      dataForNegativeXFace:(NSData*)nxData
      dataForPositiveYFace:(NSData*)pyData
      dataForNegativeYFace:(NSData*)nyData
      dataForPositiveZFace:(NSData*)pzData
      dataForNegativeZFace:(NSData*)nzData {
	O3SuperInitOrDie();
	mTarget = GL_TEXTURE_CUBE_MAP;
	O3Texture_bind(self, -1, false);
	glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X_ARB, 0, internalFormat, widthEqualsHeight, widthEqualsHeight, 0, format, type, (GLvoid*)[pxData bytes]);
	glTexImage2D(GL_TEXTURE_CUBE_MAP_NEGATIVE_X_ARB, 0, internalFormat, widthEqualsHeight, widthEqualsHeight, 0, format, type, (GLvoid*)[nxData bytes]);
	glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_Y_ARB, 0, internalFormat, widthEqualsHeight, widthEqualsHeight, 0, format, type, (GLvoid*)[pyData bytes]);
	glTexImage2D(GL_TEXTURE_CUBE_MAP_NEGATIVE_Y_ARB, 0, internalFormat, widthEqualsHeight, widthEqualsHeight, 0, format, type, (GLvoid*)[nyData bytes]);
	glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_Z_ARB, 0, internalFormat, widthEqualsHeight, widthEqualsHeight, 0, format, type, (GLvoid*)[pzData bytes]);
	glTexImage2D(GL_TEXTURE_CUBE_MAP_NEGATIVE_Z_ARB, 0, internalFormat, widthEqualsHeight, widthEqualsHeight, 0, format, type, (GLvoid*)[nzData bytes]);
	return self;
}

/************************************/ #pragma mark Loading & Replacing Data /************************************/
- (void)loadbuffersWithSize:(GLuint)size 
		positiveXFace:(UInt8**)px
		negativeXFace:(UInt8**)nx
		positiveYFace:(UInt8**)py
		negativeYFace:(UInt8**)ny
		positiveZFace:(UInt8**)pz
		negativeZFace:(UInt8**)nz	{
	if (mLoadBuffer) {
		O3LogWarn(@"Attempt to create loadbuffers when one was already in use (or when a data hint had already been given).");
		return;
	}
	mLoadBufferSize = size;
	UInt8** loadBufferBuffers[] = {px, nx, py, ny, pz, nz};
	glGenBuffers(6,mLoadBuffers);
	int i; for (i=0;i<6;i++) {
		UInt8** buffer = loadBufferBuffers[i];
		if (!buffer) {
			glDeleteBuffers(1, mLoadBuffers+i);
			mLoadBuffers[i] = 0;
			continue;
		}
		glBindBuffer(GL_PIXEL_UNPACK_BUFFER_ARB, mLoadBuffers[i]);
		glBufferData(GL_PIXEL_UNPACK_BUFFER_ARB, size, NULL, mUnpackHint);
		*buffer = (UInt8*)glMapBuffer(GL_PIXEL_UNPACK_BUFFER_ARB, GL_WRITE_ONLY);		
	}
}

- (void)setData:(NSData*)data format:(GLenum)internalFormat size:(GLsizei)widthEqualsHeight face:(GLenum)cubeFace {
	GLenum type, format;
	formatAndTypeForInternalFormatAP(internalFormat, &format, &type);
	if (!data && mLoadBuffer) {
		glBindBuffer(GL_PIXEL_UNPACK_BUFFER_ARB, mLoadBuffer);
		glUnmapBuffer(GL_PIXEL_UNPACK_BUFFER_ARB);
		glTexImage2D(cubeFace, 0, internalFormat, widthEqualsHeight, widthEqualsHeight, 0, format, type, (GLvoid*)0);
		glDeleteBuffers(1, &mLoadBuffer);
		mLoadBuffer = 0;
		return;
	}
	glTexImage2D(cubeFace, 0, internalFormat, widthEqualsHeight, widthEqualsHeight, 0, format, type, [data bytes]);
}

- (void)setData:(NSData*)data type:(GLenum)type format:(GLenum)format internalFormat:(GLenum)internalFormat border:(int)border mipLevel:(int)mipMapLevel size:(GLsizei)widthEqualsHeight face:(GLenum)cubeFace {
	O3Texture_bind(self, -1, false);
	if (!data && mLoadBuffer) {
		glBindBuffer(GL_PIXEL_UNPACK_BUFFER_ARB, mLoadBuffer);
		glUnmapBuffer(GL_PIXEL_UNPACK_BUFFER_ARB);
		glTexImage2D(cubeFace, mipMapLevel, internalFormat, widthEqualsHeight, widthEqualsHeight, border, format, type, (GLvoid*)0);
		glDeleteBuffers(1, &mLoadBuffer);
		mLoadBuffer = 0;
		return;
	}
	glTexImage2D(cubeFace, mipMapLevel, internalFormat, widthEqualsHeight, widthEqualsHeight, border, format, type, [data bytes]);
}

- (void)setDataToContentsOfBuffer:(GLenum)buffer inRect:(NSRect)rect face:(GLenum)cubeFace format:(GLenum)internalFormat border:(GLint)border {
	O3Texture_bind(self, -1, false);
	GLenum old_buffer; glGetIntegerv(GL_READ_BUFFER, (GLint*)&old_buffer);
	BOOL swapped_buffers = old_buffer!=buffer; 
	if (swapped_buffers) glReadBuffer(buffer);
	
	GLint width = rect.size.width;
	GLint height = rect.size.height;
	if (width!=height) {
		[NSException raise:O3EXCEPTION_INCONSISTANT_FORMATS format:@"Cube maps must have square faces but one was made from buffer contents with dimensions %ix%i.", width, height];
		return;
	}
	
	glCopyTexImage2D(cubeFace, 0, internalFormat, (GLint)rect.origin.x, (GLint)rect.origin.y, width, height, border);

	if (swapped_buffers) glReadBuffer(old_buffer);
}

- (void)replaceDataInRect:(NSRect)rect face:(GLenum)face withData:(NSData*)data format:(GLenum)format type:(GLenum)type {
	if (!data && mLoadBuffer) {
		glBindBuffer(GL_PIXEL_UNPACK_BUFFER_ARB, mLoadBuffer);
		glUnmapBuffer(GL_PIXEL_UNPACK_BUFFER_ARB);
		glTexSubImage2D(face, 0, (GLint)rect.origin.x, (GLint)rect.origin.y, (GLint)rect.size.width, (GLint)rect.size.height, format, type, (GLvoid*)0);
		glDeleteBuffers(1, &mLoadBuffer);
		mLoadBuffer = 0;
		return;
	}
	glTexSubImage2D(face, 0, (GLint)rect.origin.x, (GLint)rect.origin.y, (GLint)rect.size.width, (GLint)rect.size.height, format, type, [data bytes]);
}

- (void)replaceDataInRect:(NSRect)rect face:(GLenum)face withDataFromBuffer:(GLenum)buffer atPoint:(NSPoint)pt {
	O3Texture_bind(self, -1, false);
	GLenum old_buffer; glGetIntegerv(GL_READ_BUFFER, (GLint*)&old_buffer);
	BOOL swapped_buffers = old_buffer!=buffer; 
	if (swapped_buffers) glReadBuffer(buffer);
	
	glCopyTexSubImage2D(face, 0, (GLint)rect.origin.x, (GLint)rect.origin.y, (GLint)pt.x, (GLint)pt.y, (GLint)rect.size.width, (GLint)rect.size.height);
	
	if (swapped_buffers) glReadBuffer(old_buffer);
}

- (void)setDataWithSize:(GLsizei)widthEqualsHeight
         internalFormat:(GLenum)internalFormat
               dataType:(GLuint)type
             dataFormat:(GLuint)format
   dataForPositiveXFace:(NSData*)pxData
   dataForNegativeXFace:(NSData*)nxData
   dataForPositiveYFace:(NSData*)pyData
   dataForNegativeYFace:(NSData*)nyData
   dataForPositiveZFace:(NSData*)pzData
   dataForNegativeZFace:(NSData*)nzData {
	O3Texture_bind(self, -1, false);
	NSData* faceData[] = {pxData, nxData, pyData, nyData, pzData, nzData};
	GLenum faces[] = {	GL_TEXTURE_CUBE_MAP_POSITIVE_X_ARB,
						GL_TEXTURE_CUBE_MAP_NEGATIVE_X_ARB,
						GL_TEXTURE_CUBE_MAP_POSITIVE_Y_ARB,
						GL_TEXTURE_CUBE_MAP_NEGATIVE_Y_ARB,
						GL_TEXTURE_CUBE_MAP_POSITIVE_Z_ARB,
						GL_TEXTURE_CUBE_MAP_NEGATIVE_Z_ARB};
	int i; for (i=0;i<6;i++) {
		if (mLoadBuffers[i] && !faceData[i]) {
			glBindBuffer(GL_PIXEL_UNPACK_BUFFER_ARB, mLoadBuffers[i]);
			glUnmapBuffer(GL_PIXEL_UNPACK_BUFFER_ARB);
			glTexImage2D(faces[i], 0, internalFormat, widthEqualsHeight, widthEqualsHeight, 0, format, type, (GLvoid*)0);
			glDeleteBuffers(1, mLoadBuffers+i);
			mLoadBuffers[i] = 0;
			continue;
		}
		glTexImage2D(faces[i], 0, internalFormat, widthEqualsHeight, widthEqualsHeight, 0, format, type, [faceData[i] bytes]);
	}
}

/************************************/ #pragma mark Use /************************************/
- (void)hintWillGetTextureDataForFace:(GLenum)face {
	if (mPacking) return;
	GLenum format, type;
	formatAndTypeForInternalFormatAP([self internalFormat], &format, &type);
	[self hintWillGetTextureDataForMipLevel:0 format:format type:type face:face];}
- (void)hintWillGetTextureDataForMipLevel:(int)mipLevel format:(GLenum)format type:(GLenum)type face:(GLenum)face {
	O3Texture_bind(self, -1, false);
	if (mPacking) return;
	O3Assert(!mLoadBuffer , @"Attempt to start unpacking while packing");
	mPacking = YES;
	unsigned size = [self size];
	glGenBuffers(1,&mLoadBuffer);
	glBindBuffer(GL_PIXEL_PACK_BUFFER_ARB, mLoadBuffer);
	glBufferData(GL_PIXEL_PACK_BUFFER_ARB, size, NULL, mPackHint);
	if (!format && !type) {
		O3Assert([self isCompressed], @"Cannot get data for uncompressed texture without format and type");
		glGetCompressedTexImage(face, mipLevel, (GLvoid*)0);
	}
	else glGetTexImage(face, mipLevel, format, type, (GLvoid*)0);
}

- (NSData*)textureDataForFace:(GLenum)face {
	O3BadPractice();
	GLenum oldTarget = mTarget;
	mTarget = face;
	NSData* to_return = [super textureData];
	mTarget = oldTarget;
	return to_return;
}

- (NSData*)textureDataForMipLevel:(int)mipLevel format:(GLenum)format type:(GLenum)type face:(GLenum)face {
	O3BadPractice();
	GLenum oldTarget = mTarget;
	mTarget = face;
	NSData* to_return = [super textureDataForMipLevel:mipLevel format:format type:type];
	mTarget = oldTarget;
	return to_return;
}

- (void)attachToFramebufferObject:(O3FramebufferObject*)framebuffer atPoint:(GLenum)attachmentPoint face:(GLenum)face {
	O3FramebufferObject_bind(framebuffer, NO);
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, attachmentPoint, face, mTextureID, 0);
	O3FramebufferObject_bind(nil, NO);
}

@end
