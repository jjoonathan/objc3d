/**
 *  @file O3Texture.mm
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#include "O3Texture.h"
#include "NSImageAdditions.h"

const NSString* O3TextureFormatUnguessableException      = @"ObjC3D Texture Format Unguessable";
const NSString* O3TextureUnrecognizedTargetException     = @"ObjC3D Unrecognized Target Exception";

GLenum*	gCompressedInternalFormats;
GLint	gNumberCompressedInternalFormats;
BOOL		gAutomaticallyUseMipmaps;
NSMutableDictionary* gAllTextures; //Stores all textures index by their IDs
O3SupportLevel gPixelBufferSupportLevel;
GLuint			gMaximumTextureUnits;


@implementation O3Texture (O3Accelerate)

void O3Texture_bind(O3Texture* tex, int tex_unit, bool enable) {
	static Class O3Texture_Class = NULL; if (!O3Texture_Class) O3Texture_Class = NSClassFromString(@"O3Texture");
	static Class O3CubeMap_Class = NULL; if (!O3CubeMap_Class) O3CubeMap_Class = NSClassFromString(@"O3CubeMap");
	O3AssertArg((tex->isa)==O3Texture_Class || (tex->isa)==O3CubeMap_Class, @"This O3Accelerate function cannot handle non O3Texture or O3CubeMap classes");
	GLenum tex_unit_name = GL_TEXTURE0 + tex_unit;
	if (tex_unit>=0) glActiveTexture(tex_unit_name);
	if (enable) glEnable(tex->mTarget);
	glBindTexture(tex->mTarget, tex->mTextureID);
}

void O3Texture_unbind(O3Texture* tex, int tex_unit) {
	static Class O3Texture_Class = NULL; if (!O3Texture_Class) O3Texture_Class = NSClassFromString(@"O3Texture");
	static Class O3CubeMap_Class = NULL; if (!O3CubeMap_Class) O3CubeMap_Class = NSClassFromString(@"O3CubeMap");
	O3AssertArg((tex->isa)==O3Texture_Class || (tex->isa)==O3CubeMap_Class, @"This O3Accelerate function cannot handle non O3Texture or O3CubeMap classes");
	GLenum tex_unit_name = GL_TEXTURE0 + tex_unit;
	if (tex_unit>=0) glActiveTexture(tex_unit_name);
	glDisable(tex->mTarget);
}

@end


@implementation O3Texture    
/*******************************************************************/ #pragma mark Initialization /*******************************************************************/
/// This function basically performs class initialization (initializes statics, gl state and so on)
inline void initializeTexturingP() {
	//Only run once
	static bool texturingInitialized = NO;
	if (texturingInitialized) return;
	texturingInitialized = YES;
	
	glGetIntegerv(GL_NUM_COMPRESSED_TEXTURE_FORMATS, &gNumberCompressedInternalFormats);
	gCompressedInternalFormats = (GLenum*)malloc(gNumberCompressedInternalFormats*sizeof(GLenum));
	glGetIntegerv(GL_COMPRESSED_TEXTURE_FORMATS, (GLint*)gCompressedInternalFormats);
	
	gPixelBufferSupportLevel = (GLEW_ARB_pixel_buffer_object)? O3FullySupported : O3EmulationSupported;
}

- (void)dealloc {
	glDeleteTextures(1, &mTextureID);
	if (mLoadBuffer) {
		O3LogWarn(@"Texture object %@ was deallocated with a loadbuffer open. It was deleted, though GL may defer the actual deletion to the next command that uses another buffer");
		glDeleteBuffers(1, &mLoadBuffer);
	}
	[gAllTextures removeObjectForKey:[NSNumber numberWithUnsignedInt:mTextureID]];
	[super dealloc];
}

///This is the designated initializer
inline void initP(O3Texture* self) {
	initializeTexturingP();
	self->mPackHint = GL_STATIC_READ;
	self->mUnpackHint = GL_STATIC_DRAW;
	glGenTextures(1,&(self->mTextureID));
	[gAllTextures setObject:self forKey:[NSNumber numberWithUnsignedInt:self->mTextureID]];
}

///This method is called every time the data in \e self changes (via the ObjC interface). It isn't used presently.
inline void dataInitP(O3Texture* self) {
}

// This section is continued after the "Shortcut Functions" section //
/*******************************************************************/ #pragma mark Shortcut Functions /*******************************************************************/
///@bug Not thread safe!
inline void miniPushP(O3Texture* self, bool push) {
	static GLint oldid;
	GLenum binding_type;
	switch (self->mTarget) {
		case GL_TEXTURE_2D:
			binding_type = GL_TEXTURE_BINDING_2D;
			break;
		case GL_TEXTURE_1D:
			binding_type = GL_TEXTURE_BINDING_1D;
			break;
		case GL_TEXTURE_3D:
			binding_type = GL_TEXTURE_BINDING_3D;
			break;
		case GL_TEXTURE_CUBE_MAP:
			binding_type = GL_TEXTURE_BINDING_CUBE_MAP;
			break;			
		default:
			O3AssertFalse();
	}
	if (push) glGetIntegerv(binding_type, &oldid);
	else glBindTexture(self->mTarget, (GLenum)oldid);
}

inline void getDimensionsP(O3Texture* self, GLuint* width, GLuint* height, GLuint* depth, GLuint mipLevel = 0) {
	*width = *height = *depth = 0;
	miniPushP(self, true);
	O3Texture_bind(self, -1, false);
	switch (self->mTarget) {
		case GL_TEXTURE_3D:
			glGetTexLevelParameteriv(self->mTarget, mipLevel, GL_TEXTURE_DEPTH, (GLint*)depth);
		case GL_TEXTURE_2D:
		case GL_TEXTURE_CUBE_MAP:
			glGetTexLevelParameteriv(self->mTarget, mipLevel, GL_TEXTURE_HEIGHT, (GLint*)height);
		case GL_TEXTURE_1D:
			glGetTexLevelParameteriv(self->mTarget, mipLevel, GL_TEXTURE_WIDTH, (GLint*)width);
		break;
		default:
			miniPushP(self, false);
			[NSException raise:O3TextureUnrecognizedTargetException format:@"Could not get the dimensions of texture %@ because its target type was not recognized.", self];
	}
	miniPushP(self, false);
}

#include "O3TextureConstantInterperetation.h"

inline GLenum dimensionalityP(GLuint width, GLuint height, GLuint depth) {
	if (depth>1) return GL_TEXTURE_3D;
	if (height>1) return GL_TEXTURE_2D;
	return GL_TEXTURE_1D;
}

///@note Stomps on current texture state
inline BOOL loadP(O3Texture* self, GLubyte* data, GLsizei length, GLenum type, GLenum format, GLenum internalFormat, int mipMapLevel, int border, GLuint width, GLuint height, GLuint depth) {
	O3Texture_bind(self, -1, false);
	self->mTarget = dimensionalityP(width, height, depth);
	if (!type && !format && isFormatCompressedP(internalFormat)) { //If texture is a compressed format
		switch (self->mTarget) {
			case GL_TEXTURE_2D:
				glCompressedTexImage2D(self->mTarget, mipMapLevel, internalFormat, width, height, border, length, data);
				dataInitP(self);
				return glGetError()?NO:YES;
			case GL_TEXTURE_1D:
				glCompressedTexImage1D(self->mTarget, mipMapLevel, internalFormat, width, border, length, data);		
				dataInitP(self);
				return glGetError()?NO:YES;
			case GL_TEXTURE_3D:
				glCompressedTexImage3D(self->mTarget, mipMapLevel, internalFormat, width, height, depth, border, length, data);
				dataInitP(self);
				return glGetError()?NO:YES;
			default:
				O3Assert(false , @"mTarget not one of GL_TEXTURE_1D, GL_TEXTURE_2D, or GL_TEXTURE_3D");
				return NO;
		}
	} else {
		switch (self->mTarget) {
			case GL_TEXTURE_2D:
				glTexImage2D(self->mTarget, mipMapLevel, internalFormat, width, height, border, format, type, data);
				dataInitP(self);
				return glGetError()?NO:YES;
			case GL_TEXTURE_1D:
				glTexImage1D(self->mTarget, mipMapLevel, internalFormat, width, border, format, type, data);		
				dataInitP(self);
				return glGetError()?NO:YES;
			case GL_TEXTURE_3D:
				glTexImage3D(self->mTarget, mipMapLevel, internalFormat, width, height, depth, border, format, type, data);
				dataInitP(self);
				return glGetError()?NO:YES;
			default:
				O3Assert(false , @"mTarget not one of GL_TEXTURE_1D, GL_TEXTURE_2D, or GL_TEXTURE_3D");
				return NO;
		}
	}
}

/************************************/ #pragma mark Initialization Continued /************************************/
- (id)initWithImage:(NSImage*)image {return [self initWithImage:image internalFormat:GL_RGBA8];}
- (id)initWithImage:(NSImage*)image internalFormat:(GLenum)internalFormat {
	O3BadPractice(); //This method depends a whole lot on what NSBitmapImageRep decides to initialize itself to
	if (!image) {O3LogError(@"image is nil!");return nil;}
	BOOL flipped = [image isFlipped];
	[image setFlipped:!flipped];
	NSBitmapImageRep* bitmap = [image bitmap];
	if (!bitmap) {O3LogError(@"[NSImage bitmap] returned nil!"); return nil;}
	[image setFlipped:flipped];
	
	int bits = [bitmap bitsPerSample];
	if (bits==NSImageRepMatchesDevice) {
		O3LogWarn(@"[NSImage bitsPerSample] returned NSImageRepMatchesDevice, assuming 8 bits per sample.");
		bits = 8;} 
	O3Verify(bits==8, @"Bits per sample must be 8 for BitmapImageReps to be used as O3Textures");
	int channels          = [bitmap samplesPerPixel]; 									O3Verify(channels==3 || channels==4, @"Channels must be 3 or 4 for BitmapImageReps to be used as O3Textures");
	int bytes_per_row     = [bitmap bytesPerRow];										O3Assert(![bitmap isPlanar], @"Cannot handle planar bitmaps.");
	unsigned width        = [bitmap pixelsWide];
	unsigned height       = [bitmap pixelsHigh];
	NSBitmapFormat format = [bitmap bitmapFormat];
	// BOOL floating_point   = (format & NSFloatingPointSamplesBitmapFormat)?YES:NO;
	BOOL alpha_first      = (format & NSAlphaFirstBitmapFormat)?YES:NO;  				O3Verify(!alpha_first, @"Alpha cannot come first for BitmapImageReps to be used as O3Textures");
	unsigned size = bytes_per_row*height;
	
   	if (!(self = [self init])) return nil; 	//Calls a esignated initializer
	void* loadbuffer = [self loadbufferWithSize:size];
	memcpy(loadbuffer, [bitmap bitmapData], size);
		[self setData:nil
                 type:GL_UNSIGNED_BYTE
               format:GL_RGBA
       internalFormat:internalFormat
               border:0
             mipLevel:0
                width:width
               height:height
                depth:0];
	
//		[self setData:[NSData dataWithBytesNoCopy:[bitmap bitmapData] length:size freeWhenDone:NO]
//                 type:GL_UNSIGNED_BYTE
//               format:GL_RGBA
//       internalFormat:internalFormat
//               border:0
//             mipLevel:0
//                width:width
//               height:height
//                depth:0];
		return self;
}

- (id)init {
	O3SuperInitOrDie();
	initP(self); //Initialize the state to comply with GL spec
	return self;
}

- (id)initWithData:(NSData*)data
                    format:(GLenum)internalFormat
                     width:(GLuint)width
                    height:(GLuint)height
                     depth:(GLuint)depth	{
	O3SuperInitOrDie();
	initP(self);
	mTarget = dimensionalityP(width, height, depth);
	GLenum type, format;
	formatAndTypeForInternalFormatAP(internalFormat, &format, &type);
	loadP(self, (GLubyte*)[data bytes], [data length], type, format, internalFormat, 0, 0, width, height, depth);
	return self;
}

- (id)initWithData:(NSData*)data
                      type:(GLenum)type
                    format:(GLenum)format
            internalFormat:(GLenum)internalFormat
                    border:(int)border
                     width:(GLuint)width
                    height:(GLuint)height
                     depth:(GLuint)depth	{
	O3SuperInitOrDie();
	initP(self);
	mTarget = dimensionalityP(width, height, depth);
	loadP(self, (GLubyte*)[data bytes], [data length], type, format, internalFormat, border, 0, width, height, depth);
	return self;
}


/*******************************************************************/ #pragma mark Texture Parameters /*******************************************************************/
- (GLuint)textureID {return mTextureID;}
- (GLenum)packingHint {return mPackHint;}
- (GLenum)unpackingHint {return mUnpackHint;}

- (BOOL)isResident {
	miniPushP(self, true); //Push
	GLint to_return;
	glGetTexParameteriv(self->mTarget, GL_TEXTURE_RESIDENT, &to_return);
	miniPushP(self, false); //Pop
	return to_return ? YES : NO; //Just for safety (BOOL can cast to smaller data types)
}

- (GLuint)width {
	miniPushP(self, true);
	O3Texture_bind(self, -1, false);
	GLuint to_return;
	glGetTexLevelParameteriv(mTarget, 0, GL_TEXTURE_WIDTH, (GLint*)&to_return);
	miniPushP(self, false);
	return to_return;	
}

- (GLuint)height {
	miniPushP(self, true);
	O3Texture_bind(self, -1, false);
	GLuint to_return;
	glGetTexLevelParameteriv(mTarget, 0, GL_TEXTURE_HEIGHT, (GLint*)&to_return);
	miniPushP(self, false);
	return to_return;	
}

- (GLuint)depth {
	miniPushP(self, true);
	O3Texture_bind(self, -1, false);
	GLuint to_return;
	glGetTexLevelParameteriv(mTarget, 0, GL_TEXTURE_DEPTH, (GLint*)&to_return);
	miniPushP(self, false);
	return to_return;	
}

- (GLenum)internalFormat {
	miniPushP(self, true);
	O3Texture_bind(self, -1, false);
	GLenum to_return;
	glGetTexLevelParameteriv(mTarget, 0, GL_TEXTURE_INTERNAL_FORMAT, (GLint*)&to_return);
	miniPushP(self, false);
	return to_return;	
}

- (BOOL)isCompressed {
	miniPushP(self, true);
	O3Texture_bind(self, -1, false);
	GLenum to_return;
	glGetTexLevelParameteriv(mTarget, 0, GL_TEXTURE_INTERNAL_FORMAT, (GLint*)&to_return);
	miniPushP(self, false);
	return isFormatCompressedP(to_return);	
}

- (void)setPackingHint:(GLenum)hint				{mPackHint = hint;}
- (void)setUnackingHint:(GLenum)hint			{mUnpackHint = hint;}

- (unsigned)size {
	unsigned to_return = 0;
	if (isFormatCompressedP([self internalFormat])) {
		glGetTexLevelParameteriv(mTarget, 0, GL_TEXTURE_COMPRESSED_IMAGE_SIZE_ARB, (GLint*)&to_return);
	} else {
		GLuint width, height, depth; getDimensionsP(self, &width, &height, &depth);
		unsigned number_pixels = width;
		if (mTarget==GL_TEXTURE_2D) number_pixels *= height;
		if (mTarget==GL_TEXTURE_3D) number_pixels *= height * depth;
		to_return = sizeForIneternalFormatAndPixelsP([self internalFormat], number_pixels);
	}
	return to_return;
}

/*******************************************************************/ #pragma mark Data Loading /*******************************************************************/
- (void)setData:(NSData*)data
         format:(GLenum)internalFormat
          width:(GLuint)width
         height:(GLuint)height
          depth:(GLuint)depth	{
	mTarget = dimensionalityP(width, height, depth);
	GLenum type, format; 
	formatAndTypeForInternalFormatAP(internalFormat, &format, &type);
	
	if (!data && mLoadBuffer) {
		glBindBuffer(GL_PIXEL_UNPACK_BUFFER_ARB, mLoadBuffer);
		glUnmapBuffer(GL_PIXEL_UNPACK_BUFFER_ARB);
		loadP(self, (GLubyte*)0, mLoadBufferSize, type, format, internalFormat, 0, 0, width, height, depth);
		glBindBuffer(GL_PIXEL_UNPACK_BUFFER_ARB, GL_ZERO);
		glDeleteBuffers(1, &mLoadBuffer);
		mLoadBuffer = NULL;
	} else {
		GLubyte* bytes;
		GLsizeiptr size;
		if (mVirtualLoadbuffer) {
			bytes = (GLubyte*)mVirtualLoadbuffer;
			size = mLoadBufferSize;
		} else {
			bytes = (GLubyte*)[data bytes];
			size = [data length];
		}
		O3Assert(bytes, @"Cannot get bytes for texture seting");
		O3LogInfo(@"It is better to use a loadbuffer to load your textures. Calling setData: or initWithData: causes an unnecessary coppy or worse.");
		loadP(self, bytes, size, type, format, internalFormat, 0, 0, width, height, depth);
		if (mVirtualLoadbuffer) {
			free(mVirtualLoadbuffer);
			mVirtualLoadbuffer = NULL;
		}
	}
}

- (void)setData:(NSData*)data
           type:(GLenum)type
         format:(GLenum)format
 internalFormat:(GLenum)internalFormat
         border:(int)border
       mipLevel:(int)mipMapLevel
          width:(GLuint)width
         height:(GLuint)height
          depth:(GLuint)depth	{
	mTarget = dimensionalityP(width, height, depth);

	if (!data && mLoadBuffer) {
		glBindBuffer(GL_PIXEL_UNPACK_BUFFER_ARB, mLoadBuffer);
		glUnmapBuffer(GL_PIXEL_UNPACK_BUFFER_ARB);
		loadP(self, (GLubyte*)0, mLoadBufferSize, type, format, internalFormat, mipMapLevel, border, width, height, depth);
		glBindBuffer(GL_PIXEL_UNPACK_BUFFER_ARB, GL_ZERO);
		glDeleteBuffers(1, &mLoadBuffer);
		mLoadBuffer = NULL;
	} else {
		O3LogInfo(@"It is better to use a loadbuffer to load your textures. Calling setData: or initWithData: causes an unnecessary coppy or worse.");
		GLubyte* bytes;
		GLsizeiptr size;
		if (mVirtualLoadbuffer) {
			bytes = (GLubyte*)mVirtualLoadbuffer;
			size = mLoadBufferSize;
		} else {
			bytes = (GLubyte*)[data bytes];
			size = [data length];
		}
		loadP(self, bytes, size, type, format, internalFormat, mipMapLevel, border, width, height, depth);
		if (mVirtualLoadbuffer) {
			free(mVirtualLoadbuffer);
			mVirtualLoadbuffer = NULL;
		}
	}
}

- (UInt8*)loadbufferWithSize:(unsigned)size {
	if (mLoadBuffer) {
		O3LogWarn(@"Attempt to create loadbuffer when one was already in use (or when a data hint had already been given).");
		return nil;
	}
	mLoadBufferSize = size;
	if (gPixelBufferSupportLevel==O3EmulationSupported) return (UInt8*)(mVirtualLoadbuffer = malloc(size));
	glGenBuffers(1,&mLoadBuffer);
	glBindBuffer(GL_PIXEL_UNPACK_BUFFER_ARB, mLoadBuffer);
	glBufferData(GL_PIXEL_UNPACK_BUFFER_ARB, size, NULL, mUnpackHint);
	UInt8* buffer = (UInt8*)glMapBuffer(GL_PIXEL_UNPACK_BUFFER_ARB, GL_WRITE_ONLY);
	O3Assert(buffer, @"Failed to map buffer");
	return buffer;
}

///@warn Stomps on current texture unit
- (void)setDataToContentsOfBuffer:(GLenum)buffer inRect:(NSRect)rect format:(GLenum)internalFormat border:(GLint)border {
	O3Texture_bind(self, -1, false);
	GLenum old_buffer; glGetIntegerv(GL_READ_BUFFER, (GLint*)&old_buffer);
	BOOL swapped_buffers = old_buffer!=buffer; 
	if (swapped_buffers) glReadBuffer(buffer);
	
	mTarget = (abs(rect.size.height)<O3Epsilon(float)) ? GL_TEXTURE_1D : GL_TEXTURE_2D;
	if (mTarget==GL_TEXTURE_1D) glCopyTexImage1D(GL_TEXTURE_1D, 0, internalFormat, (GLint)rect.origin.x, (GLint)rect.origin.y, (GLint)rect.size.width, border);
	if (mTarget==GL_TEXTURE_2D) glCopyTexImage2D(GL_TEXTURE_2D, 0, internalFormat, (GLint)rect.origin.x, (GLint)rect.origin.y, (GLint)rect.size.width, (GLint)rect.size.height, border);

	if (swapped_buffers) glReadBuffer(old_buffer);
}
		
///@warn Stomps on current texture unit
- (void)replaceDataInRect:(NSRect)rect withDataFromBuffer:(GLenum)buffer atPoint:(NSPoint)pt {
	O3Texture_bind(self, -1, false);
	GLenum old_buffer; glGetIntegerv(GL_READ_BUFFER, (GLint*)&old_buffer);
	BOOL swapped_buffers = old_buffer!=buffer; 
	if (swapped_buffers) glReadBuffer(buffer);
	
	if (mTarget==GL_TEXTURE_1D) glCopyTexSubImage1D(GL_TEXTURE_2D, 0, (GLint)rect.origin.x, (GLint)pt.x, (GLint)pt.y, (GLint)rect.size.width);
	if (mTarget==GL_TEXTURE_2D) glCopyTexSubImage2D(GL_TEXTURE_2D, 0, (GLint)rect.origin.x, (GLint)rect.origin.y, (GLint)pt.x, (GLint)pt.y, (GLint)rect.size.width, (GLint)rect.size.height);
	
	if (swapped_buffers) glReadBuffer(old_buffer);
}

- (void)replaceDataInRect:(NSRect)rect withData:(NSData*)data format:(GLenum)format type:(GLenum)type {
	if (mVirtualLoadbuffer) {
		if (mTarget==GL_TEXTURE_1D) glTexSubImage1D(mTarget, 0, (GLint)rect.origin.x, (GLint)rect.size.width, format, type, mVirtualLoadbuffer);
		if (mTarget==GL_TEXTURE_2D) glTexSubImage2D(mTarget, 0, (GLint)rect.origin.x, (GLint)rect.origin.y, (GLint)rect.size.width, (GLint)rect.size.height, format, type, mVirtualLoadbuffer);
		free(mVirtualLoadbuffer);
		mVirtualLoadbuffer = NULL;
		return;
	}
	if (!data && mLoadBuffer) {
		glBindBuffer(GL_PIXEL_UNPACK_BUFFER_ARB, mLoadBuffer);
		glUnmapBuffer(GL_PIXEL_UNPACK_BUFFER_ARB);
		if (mTarget==GL_TEXTURE_1D) glTexSubImage1D(mTarget, 0, (GLint)rect.origin.x, (GLint)rect.size.width, format, type, (GLvoid*)0);
		if (mTarget==GL_TEXTURE_2D) glTexSubImage2D(mTarget, 0, (GLint)rect.origin.x, (GLint)rect.origin.y, (GLint)rect.size.width, (GLint)rect.size.height, format, type, (GLvoid*)0);
		glBindBuffer(GL_PIXEL_UNPACK_BUFFER_ARB, GL_ZERO);
		glDeleteBuffers(1, &mLoadBuffer);
		mLoadBuffer = NULL;
		mPacking = NO;
		return;
	}
	if (mTarget==GL_TEXTURE_1D) glTexSubImage1D(mTarget, 0, (GLint)rect.origin.x, (GLint)rect.size.width, format, type, [data bytes]);
	if (mTarget==GL_TEXTURE_2D) glTexSubImage2D(mTarget, 0, (GLint)rect.origin.x, (GLint)rect.origin.y, (GLint)rect.size.width, (GLint)rect.size.height, format, type, [data bytes]);
}

/*******************************************************************/ #pragma mark Use /*******************************************************************/
- (void)bindToTextureUnit:(int)texture_unit_number {
	O3Texture_bind(self, texture_unit_number);
}

- (void)unbindFromTextureUnit:(int)texture_unit_number {
	O3Texture_unbind(self, texture_unit_number);
}

///@note Stomps on current texture unit
- (void)hintWillGetTextureData {
	if (gPixelBufferSupportLevel==O3EmulationSupported) return; //Hints are ignored if they cannot be used :)
	if (mPacking) return;
	GLenum format, type;
	formatAndTypeForInternalFormatAP([self internalFormat], &format, &type);
	[self hintWillGetTextureDataForMipLevel:0 format:format type:type];
}

///@note Stomps on current texture unit
- (void)hintWillGetTextureDataForMipLevel:(int)mipLevel format:(GLenum)format type:(GLenum)type {
	if (gPixelBufferSupportLevel==O3EmulationSupported) return; //Hints are ignored if they cannot be used :)
	O3Texture_bind(self, -1, false);
	if (mPacking) return;
	O3Assert(!mLoadBuffer , @"Attempt to start unpacking while packing");
	mPacking = YES;
	unsigned size = [self size];
	glGenBuffers(1,&mLoadBuffer);
	glBindBuffer(GL_PIXEL_PACK_BUFFER_ARB, mLoadBuffer);
	glBufferData(GL_PIXEL_PACK_BUFFER_ARB, size, NULL, mPackHint);
	if (!format && !type) {
		O3Assert([self isCompressed], @"Cannot get uncompressed texture data without format and type");
		glGetCompressedTexImage(mTarget, mipLevel, (GLvoid*)0);
	}
	else glGetTexImage(mTarget, mipLevel, format, type, (GLvoid*)0);
}

///@note Stomps on current texture unit
- (NSData*)textureData {
	if (mPacking) {
		glBindBuffer(GL_PIXEL_PACK_BUFFER_ARB, mLoadBuffer);
		GLint size; glGetBufferParameteriv(GL_PIXEL_PACK_BUFFER_ARB, GL_BUFFER_SIZE, &size);
		NSData* to_return = [NSData dataWithBytes:glMapBuffer(GL_PIXEL_PACK_BUFFER_ARB,GL_READ_ONLY) length:size];
		glUnmapBuffer(GL_PIXEL_PACK_BUFFER_ARB);
		glBindBuffer(GL_PIXEL_PACK_BUFFER_ARB, GL_ZERO);
		glDeleteBuffers(1,&mLoadBuffer);
		mPacking = NO;
		return to_return;
	}
	O3Texture_bind(self, -1, false);
	unsigned size = [self size];
	void* bytes = malloc(size);
	if ([self isCompressed]) {
		bytes = malloc(size);
		glGetCompressedTexImage(mTarget, 0, bytes);
		O3CheckGLError();
	} else {
		GLenum format, type;
		formatAndTypeForInternalFormatAP([self internalFormat], &format, &type);
		glGetTexImage(mTarget,0,format,type,bytes);
		O3CheckGLError();
	}
	return [NSData dataWithBytesNoCopy:bytes length:size freeWhenDone:YES];
}

///@note Stomps on current texture unit
- (NSData*)textureDataForMipLevel:(int)mipLevel format:(GLenum)format type:(GLenum)type {
	if (mPacking) {
		glBindBuffer(GL_PIXEL_PACK_BUFFER_ARB, mLoadBuffer);
		GLint size; glGetBufferParameteriv(GL_PIXEL_PACK_BUFFER_ARB, GL_BUFFER_SIZE, &size);
		NSData* to_return = [NSData dataWithBytes:glMapBuffer(GL_PIXEL_PACK_BUFFER_ARB,GL_READ_ONLY) length:size];
		glUnmapBuffer(GL_PIXEL_PACK_BUFFER_ARB);
		glBindBuffer(GL_PIXEL_PACK_BUFFER_ARB, GL_ZERO);
		glDeleteBuffers(1,&mLoadBuffer);
		mPacking = NO;
		return to_return;
	}
	O3Texture_bind(self, -1, false);
	unsigned size;
	void* bytes;
	if (!format && !type) {
		O3Assert([self isCompressed], @"Cannot get uncompressed texture data without format and type");
		size = [self size];
		bytes = malloc(size);
		glGetCompressedTexImage(mTarget, mipLevel, bytes);
	} else {
		GLuint width, height, depth; getDimensionsP(self, &width, &height, &depth, mipLevel);
		unsigned number_pixels = width;
		if (mTarget==GL_TEXTURE_2D) number_pixels *= height;
		if (mTarget==GL_TEXTURE_3D) number_pixels *= height * depth;
		size = sizeForFormatAndNumberPixelsP(format, type, number_pixels);
		bytes = malloc(size);
		glGetTexImage(mTarget, mipLevel, format, type, bytes);
	}
	return [NSData dataWithBytesNoCopy:bytes length:size freeWhenDone:YES];
}

- (void)attachToFramebufferObject:(O3FramebufferObject*)framebuffer atPoint:(GLenum)attachmentPoint {
	O3FramebufferObject_bind(framebuffer, NO);
	switch (mTarget) {
		case GL_TEXTURE_1D:
			glFramebufferTexture1DEXT(GL_FRAMEBUFFER_EXT, attachmentPoint, mTarget, mTextureID, 0);
			break;
		case GL_TEXTURE_2D:
			glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, attachmentPoint, mTarget, mTextureID, 0);
			break;
		default:
			[NSException raise:O3TextureUnrecognizedTargetException format:@"Couldn't attach texture object %@ to framebuffer %@ because its format (dimensionality) was unrecognized. Note that if the texture is 3D, you need to attach it by calling [texture attachToFramebufferObject:atPoint:zOffset:] and if it is a cubemap you need to call [texture attachToFramebufferObject:atPoint:face:].", self, framebuffer];
	}
	O3FramebufferObject_bind(nil, NO);
}

- (void)attachToFramebufferObject:(O3FramebufferObject*)framebuffer atPoint:(GLenum)attachmentPoint zOffset:(GLint)zOffset {
	O3Assert(mTarget==GL_TEXTURE_3D, @"Cannot attach a given Z offset to a framebuffer of a non-3D texture");
	O3FramebufferObject_bind(framebuffer, NO);
	glFramebufferTexture3DEXT(GL_FRAMEBUFFER_EXT, attachmentPoint, mTarget, mTextureID, 0, zOffset);
	O3FramebufferObject_bind(nil, NO);
}

/*******************************************************************/ #pragma mark Texturing State /*******************************************************************/
+ (GLenum)textureMode {
	GLenum to_return;
	glGetIntegerv(GL_TEXTURE_ENV_MODE, (GLint*)&to_return);
	return to_return;
}

+ (void)setTextureMode:(GLenum)newMode {
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, newMode);
}

+ (NSColor*)textureEnvironmentColor {
	GLfloat colors[4];
	glGetFloatv(GL_TEXTURE_ENV_COLOR, colors);
	return [NSColor colorWithCalibratedRed:colors[0] green:colors[1] blue:colors[2] alpha:colors[3]];
}

+ (void)setTextureEnvironmentColor:(NSColor*)newColor {
	GLfloat colors[4];
	[newColor getRed:colors green:colors+1 blue:colors+2 alpha:colors+3];
	glTexEnvfv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_COLOR, colors);
}

+ (O3Texture*)textureForID:(GLuint)id {
	return [gAllTextures objectForKey:[NSNumber numberWithUnsignedInt:id]];
}

///@param the x, y, width, and height of the rectangle to dump. If the values are not integers they will be round()ed.
+ (NSData*)dataWithContentsOfBuffer:(GLenum)buffer inRect:(NSRect)rect format:(GLenum)format type:(GLenum)type {
	unsigned width = round(rect.size.width);
	unsigned height = round(rect.size.height);
	unsigned x = round(rect.origin.x);
	unsigned y = round(rect.origin.y);
	unsigned size = sizeForFormatAndNumberPixelsP(format, type, x*y);
	void* dbuffer = malloc(size);
	GLenum old_read_buffer; glGetIntegerv(GL_READ_BUFFER, (GLint*)&old_read_buffer);
	glReadBuffer(buffer);
	O3CheckGLError();
	glReadPixels(x, y, width, height, format, type, dbuffer);
	return [NSData dataWithBytesNoCopy:dbuffer length:size freeWhenDone:YES];
}



/*******************************************************************/ #pragma mark Support /*******************************************************************/
+ (O3SupportLevel)supportLevel {
	initializeTexturingP();
	return gPixelBufferSupportLevel;
}

+ (BOOL)supportedAtLeastToLevel:(O3SupportLevel)supportLevel {
	initializeTexturingP();
	return gPixelBufferSupportLevel;
}

+ (void)assertSupportedAtLeastToLevel:(O3SupportLevel)supportLevel {
	initializeTexturingP();
	if (gPixelBufferSupportLevel<supportLevel)
		[NSException raise:O3NotSupportedException format:@"[O3Texture assertSupportedAtLeastToLevel:%i] failed, support level was %i", supportLevel, gPixelBufferSupportLevel];
}

@end


