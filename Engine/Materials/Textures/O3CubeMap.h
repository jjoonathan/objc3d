/**
 *  @file O3CubeMap.h
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3Texture.h"

#define O3EXCEPTION_INCONSISTANT_FORMATS @"O3ExceptionInconsistantFormats"

@interface O3CubeMap : O3Texture {
	GLuint mLoadBuffers[6];
}

/************************************/ #pragma mark Initialization /************************************/
- (id)init;
- (id)initWithSize:(GLsizei)widthEqualsHeight
            internalFormat:(GLenum)internalFormat
                  dataType:(GLuint)type
                dataFormat:(GLuint)format
      dataForPositiveXFace:(NSData*)pxData
      dataForNegativeXFace:(NSData*)nxData
      dataForPositiveYFace:(NSData*)pyData
      dataForNegativeYFace:(NSData*)nyData
      dataForPositiveZFace:(NSData*)pzData
      dataForNegativeZFace:(NSData*)nzData;

/************************************/ #pragma mark Loading & Replacing Data /************************************/
- (void)loadbuffersWithSize:(GLuint)size 
		positiveXFace:(UInt8**)px
		negativeXFace:(UInt8**)nx
		positiveYFace:(UInt8**)py
		negativeYFace:(UInt8**)ny
		positiveZFace:(UInt8**)pz
		negativeZFace:(UInt8**)nz;
- (void)setData:(NSData*)data format:(GLenum)internalFormat size:(GLsizei)widthEqualsHeight face:(GLenum)cubeFace;
- (void)setData:(NSData*)data type:(GLenum)type format:(GLenum)format internalFormat:(GLenum)internalFormat border:(int)border mipLevel:(int)mipMapLevel size:(GLsizei)widthEqualsHeight face:(GLenum)cubeFace;
- (void)setDataToContentsOfBuffer:(GLenum)buffer inRect:(NSRect)rect face:(GLenum)cubeFace format:(GLenum)internalFormat border:(GLint)border;
- (void)replaceDataInRect:(NSRect)rect face:(GLenum)face withData:(NSData*)data format:(GLenum)format type:(GLenum)type;
- (void)replaceDataInRect:(NSRect)rect face:(GLenum)face withDataFromBuffer:(GLenum)buffer atPoint:(NSPoint)pt;
- (void)setDataWithSize:(GLsizei)widthEqualsHeight
         internalFormat:(GLenum)internalFormat
               dataType:(GLuint)type
             dataFormat:(GLuint)format
   dataForPositiveXFace:(NSData*)pxData
   dataForNegativeXFace:(NSData*)nxData
   dataForPositiveYFace:(NSData*)pyData
   dataForNegativeYFace:(NSData*)nyData
   dataForPositiveZFace:(NSData*)pzData
   dataForNegativeZFace:(NSData*)nzData;

/************************************/ #pragma mark Use /************************************/
- (void)hintWillGetTextureDataForFace:(GLenum)face; ///<Hints that the texture data will be needed some time in the future
- (void)hintWillGetTextureDataForMipLevel:(int)mipLevel format:(GLenum)format type:(GLenum)type face:(GLenum)face; ///<Hints that the texture data will be needed for mipLivel in format/type some time in the future
- (NSData*)textureDataForFace:(GLenum)face; ///<Returns the texture data in the current format
- (NSData*)textureDataForMipLevel:(int)mipLevel format:(GLenum)format type:(GLenum)type face:(GLenum)face;
- (void)attachToFramebufferObject:(O3FramebufferObject*)framebuffer atPoint:(GLenum)attachmentPoint face:(GLenum)face;

@end
