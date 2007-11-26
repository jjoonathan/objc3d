/**
 *  @file O3Texture.h
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @todo Modify -(GLsizeiptr)size to work, add -(GLsizeiptr)sizeOfMipLevel:(GLuint)mipLevel for all instances of current usage
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
const extern NSString* O3TextureFormatUnguessableException;
const extern NSString* O3TextureUnrecognizedTargetException;   

@class O3Texture;
#import "O3FramebufferObject.h"

///Represents an OpenGL texture. O3Textures are not "materials", they simply represent a resource that can be used by other materials.
///Use a simple UV map shader to get classic texturing (planned as O3TextureMap, subject to change)
@interface O3Texture : NSObject <O3FramebufferAttachable> {
	GLuint mTarget;	//The type of image (GL_TEXTURE_2D and the like)
	GLuint mTextureID;	  //OpenGL ID numer of the texture
	
	BOOL mReadyForUse; //Ready for setting
	GLuint mLoadBuffer, mLoadBufferSize, mPackHint, mUnpackHint;  //For asynchronus pack and unpack buffers
	BOOL mPacking;
	
	void* mVirtualLoadbuffer;
}

/*******************************************************************/ #pragma mark Texture Parameters /*******************************************************************/
- (GLuint)textureID;
- (GLenum)packingHint;						  - (void)setPackingHint:(GLenum)hint;
- (GLenum)unpackingHint;					  - (void)setUnackingHint:(GLenum)hint;
- (BOOL)isResident;
- (BOOL)isCompressed;
- (GLenum)internalFormat;
- (GLuint)width;
- (GLuint)height;
- (GLuint)depth;

/*******************************************************************/ #pragma mark Initialization /*******************************************************************/
- (id)init;
- (id)initWithImage:(NSImage*)image;
- (id)initWithImage:(NSImage*)image internalFormat:(GLenum)internalFormat;
- (id)initWithData:(NSData*)data format:(GLenum)internalFormat width:(GLuint)width height:(GLuint)height depth:(GLuint)depth;
- (id)initWithData:(NSData*)data type:(GLenum)type format:(GLenum)format internalFormat:(GLenum)internalFormat border:(int)border width:(GLuint)width height:(GLuint)height depth:(GLuint)depth;

/*******************************************************************/ #pragma mark Loading & Replacing Data /*******************************************************************/
- (UInt8*)loadbufferWithSize:(unsigned)size;
- (void)setData:(NSData*)data format:(GLenum)internalFormat width:(GLuint)width height:(GLuint)height depth:(GLuint)depth;
- (void)setData:(NSData*)data type:(GLenum)type format:(GLenum)format internalFormat:(GLenum)internalFormat border:(int)border mipLevel:(int)mipMapLevel  width:(GLuint)width height:(GLuint)height depth:(GLuint)depth;
- (void)setDataToContentsOfBuffer:(GLenum)buffer inRect:(NSRect)rect format:(GLenum)internalFormat border:(GLint)border;
- (void)replaceDataInRect:(NSRect)rect withData:(NSData*)data format:(GLenum)format type:(GLenum)type;
- (void)replaceDataInRect:(NSRect)rect withDataFromBuffer:(GLenum)buffer atPoint:(NSPoint)pt;

/*******************************************************************/ #pragma mark Use /*******************************************************************/
- (void)bindToTextureUnit:(int)texture_unit_number;
- (void)unbindFromTextureUnit:(int)texture_unit_number;
- (void)hintWillGetTextureData; ///<Hints that the texture data will be needed some time in the future
- (void)hintWillGetTextureDataForMipLevel:(int)mipLevel format:(GLenum)format type:(GLenum)type; ///<Hints that the texture data will be needed for mipLivel in format/type some time in the future
- (NSData*)textureData; ///<Returns the texture data in the current format
- (NSData*)textureDataForMipLevel:(int)mipLevel format:(GLenum)format type:(GLenum)type;
- (void)attachToFramebufferObject:(O3FramebufferObject*)framebuffer atPoint:(GLenum)attachmentPoint;
- (void)attachToFramebufferObject:(O3FramebufferObject*)framebuffer atPoint:(GLenum)attachmentPoint zOffset:(GLint)zOffset;

/*******************************************************************/ #pragma mark Texturing State /*******************************************************************/
+ (GLenum)textureMode;
+ (void)setTextureMode:(GLenum)newMode;
+ (NSColor*)textureEnvironmentColor;
+ (void)setTextureEnvironmentColor:(NSColor*)newColor;
+ (O3Texture*)textureForID:(GLuint)id;
+ (NSData*)dataWithContentsOfBuffer:(GLenum)buffer inRect:(NSRect)rect format:(GLenum)format type:(GLenum)type;

/************************************/ #pragma mark O3Support /************************************/
+ (O3SupportLevel)supportLevel;
+ (BOOL)supportedAtLeastToLevel:(O3SupportLevel)supportLevel;
+ (void)assertSupportedAtLeastToLevel:(O3SupportLevel)supportLevel;
@end

#ifdef __cplusplus
void O3Texture_bind(O3Texture* tex, int tex_unit=0, bool enable=true); 	///<Provides a quick way of calling -(void)bind on a texture. Instead of calling [texture bind] call O3Texture_bind(texture). This preserves most objective-C dynamicness: you can use it to call -(void)bind on any object with a method of that name, but if the object isn't a O3Texture it will be slightly slower, not faster than calling [object bind]. @note If \e enable is false you do not have to call unbind. Don't use this unless you know what you're doing. @warn This function does NOT recognize swizzled methods (after the first call to it)!
void O3Texture_unbind(O3Texture* tex, int tex_unit=0);	///<Provides a quick way of calling [texture unbind]
#endif /*defined(__cplusplus)*/