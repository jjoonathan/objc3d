/**
 *  @file O3TextureConstantInterperetation.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 2006
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 *  @brief Interperets OpenGL texture constants (isolates dirty work)
 */
#ifdef __cplusplus
extern GLenum* gCompressedInternalFormats;		//In O3Texture.mm
extern GLint gNumberCompressedInternalFormats;	//In O3Texture.mm

inline BOOL isFormatCompressedP(GLenum format) {
	if (format==GL_COMPRESSED_RGBA_S3TC_DXT1_EXT) return YES;
	int i; for (i=0;i<gNumberCompressedInternalFormats;i++)
		if (gCompressedInternalFormats[i]==format) return YES;
	return NO;
}

inline unsigned sizeForFormatAndNumberPixelsP(GLenum format, GLenum type, unsigned pixels) {
	unsigned btyes_per_sample = 1;
	switch (type) {
		case GL_BYTE: 
		case GL_BITMAP: 
		case GL_UNSIGNED_BYTE: 
		case GL_UNSIGNED_BYTE_3_3_2:
		case GL_UNSIGNED_BYTE_2_3_3_REV:
			btyes_per_sample = 1; break;
			
		case GL_SHORT: 
		case GL_UNSIGNED_SHORT:
		case GL_UNSIGNED_SHORT_5_6_5:
		case GL_UNSIGNED_SHORT_5_6_5_REV:
		case GL_UNSIGNED_SHORT_4_4_4_4:
		case GL_UNSIGNED_SHORT_4_4_4_4_REV:
		case GL_UNSIGNED_SHORT_5_5_5_1:
		case GL_UNSIGNED_SHORT_1_5_5_5_REV:
		case GL_HALF_FLOAT_ARB:
			btyes_per_sample = 2; break;
			
		case GL_INT: 
		case GL_UNSIGNED_INT:
		case GL_FLOAT:
		case GL_UNSIGNED_INT_8_8_8_8:
		case GL_UNSIGNED_INT_8_8_8_8_REV:
		case GL_UNSIGNED_INT_10_10_10_2:
		case GL_UNSIGNED_INT_2_10_10_10_REV:
			btyes_per_sample = 4; break;
			
		default:
			O3CLogWarn(@"Could not figure out bytes per sample for pixel type %i = 0x%X. Assuming 1.", type, type);
	}
	unsigned samples_per_pixel = 4;
	switch (format) {
		case GL_RGB:
		case GL_BGR:
			samples_per_pixel = 3; break;
			
		case GL_RGBA:
		case GL_BGRA:
			samples_per_pixel = 4; break;
			
		case GL_RED:
		case GL_GREEN:
		case GL_BLUE:
		case GL_ALPHA:
		case GL_LUMINANCE:
		case GL_COLOR_INDEX:
		case GL_STENCIL_INDEX:
		case GL_DEPTH_COMPONENT:
			samples_per_pixel = 1; break;
			
		case GL_LUMINANCE_ALPHA:
			samples_per_pixel = 2; break;
			
		default:
  			O3CLogWarn(@"Could not figure out samples per pixel for pixel format %i = 0x%X. Assuming 4.", format, format);
	}
	return samples_per_pixel * btyes_per_sample * pixels;
}

static void formatAndTypeForInternalFormatAP(GLenum internalFormat, GLenum* format, GLenum* type) {
	switch (internalFormat) {
		case GL_RGBA8:
		    *type = GL_UNSIGNED_BYTE;
			*format = GL_RGBA;
			break;
		case GL_RGBA16:
			*type = GL_UNSIGNED_SHORT;
    		*format = GL_RGBA;
    		break;
		case GL_RGB8 :
		    *type = GL_UNSIGNED_BYTE;
			*format = GL_RGB;
			break;                                     
		case GL_RGB16:
		    *type = GL_UNSIGNED_SHORT;
			*format = GL_RGB;
			break;
		case GL_RGBA16F_ARB:
			*type = GL_HALF_FLOAT_ARB;
			*format = GL_RGBA;
			break;
		case GL_RGB16F_ARB:
			*type = GL_HALF_FLOAT_ARB;
			*format = GL_RGB;
			break;
		case GL_ALPHA16F_ARB:
			*type = GL_HALF_FLOAT_ARB;
			*format = GL_ALPHA;
			break;			
		case GL_ALPHA8:
			*type = GL_UNSIGNED_BYTE;
			*format = GL_ALPHA;
			break;
		case GL_ALPHA16:
			*type = GL_UNSIGNED_SHORT;
			*format = GL_ALPHA;
			break;        
		case GL_LUMINANCE8:
			*type = GL_UNSIGNED_BYTE;
			*format = GL_LUMINANCE;
			break;         
		case GL_LUMINANCE16:
			*type = GL_UNSIGNED_SHORT;
			*format = GL_LUMINANCE;
			break;
		case GL_LUMINANCE8_ALPHA8:
			*type = GL_UNSIGNED_BYTE;
			*format = GL_LUMINANCE_ALPHA;
			break;
		case GL_LUMINANCE16_ALPHA16:
			*type = GL_UNSIGNED_SHORT;
			*format = GL_LUMINANCE_ALPHA;
			break;
		case GL_INTENSITY8:
			*type = GL_UNSIGNED_BYTE;
			*format = GL_INTENSITY;
			break;
		case GL_INTENSITY16:
		    *type = GL_UNSIGNED_SHORT;
			*format = GL_INTENSITY;
			break;
		case GL_R3_G3_B2:
		    *type = GL_UNSIGNED_BYTE_3_3_2;
			*format = GL_RGB;
			break;
		case GL_RGBA2:
		case GL_RGB10_A2:
		    *type = GL_UNSIGNED_INT_10_10_10_2;
			*format = GL_RGBA;
			break;
		case GL_RGBA4:
		    *type = GL_UNSIGNED_SHORT_4_4_4_4;
			*format = GL_RGBA;
			break;
		case GL_RGB5_A1:
		    *type = GL_UNSIGNED_SHORT_5_5_5_1;
			*format = GL_RGBA;
			break;
		case GL_RGBA32F_ARB:
			*type = GL_FLOAT;
			*format = GL_RGBA;
			break;
		case GL_RGB32F_ARB:
			*type = GL_FLOAT;
			*format = GL_RGB;
			break;
		case GL_ALPHA32F_ARB:
			*type = GL_FLOAT;
			*format = GL_ALPHA;
			break;
		case GL_INTENSITY32F_ARB:
			*type = GL_FLOAT;
			*format = GL_INTENSITY;
			break;
		case GL_LUMINANCE32F_ARB:
			*type = GL_FLOAT;
			*format = GL_LUMINANCE;
			break;
		case GL_LUMINANCE_ALPHA32F_ARB:
			*type = GL_FLOAT;
			*format = GL_LUMINANCE_ALPHA;
			break;
		case GL_INTENSITY16F_ARB:
			*type = GL_HALF_FLOAT_ARB;
			*format = GL_INTENSITY;
			break;
		case GL_LUMINANCE16F_ARB:
			*type = GL_HALF_FLOAT_ARB;
			*format = GL_LUMINANCE;
			break;
		case GL_LUMINANCE_ALPHA16F_ARB:
			*type = GL_HALF_FLOAT_ARB;
			*format = GL_LUMINANCE_ALPHA;
			break;
		case GL_DEPTH_COMPONENT16:
		//case GL_DEPTH_COMPONENT16_ARB:
			*type = GL_HALF_FLOAT_ARB;
			*format = GL_DEPTH_COMPONENT;
			break;
		case GL_DEPTH_COMPONENT24:
		//case GL_DEPTH_COMPONENT24_ARB:
			*type = GL_FLOAT;
			*format = GL_DEPTH_COMPONENT;
			break;
		case GL_DEPTH_COMPONENT32:
		//case GL_DEPTH_COMPONENT32_ARB:
			*type = GL_FLOAT;
			*format = GL_DEPTH_COMPONENT;
			break;
		default:
			if (isFormatCompressedP(internalFormat)) {
				*type = (GLenum)0;
				*format =(GLenum)0;
				return;
			} else {
				O3CLogWarn(@"Texture format & type were not guessable for internalFormat 0x%X. Assuming NULL and NULL.", internalFormat);
			}
	}
}

inline unsigned sizeForIneternalFormatAndPixelsP(GLenum internalFormat, unsigned pixels) {
	GLenum type, format;
	formatAndTypeForInternalFormatAP(internalFormat, &format, &type);
	return sizeForFormatAndNumberPixelsP(format, type, pixels);
}
#endif /*defined(__cplusplus)*/
