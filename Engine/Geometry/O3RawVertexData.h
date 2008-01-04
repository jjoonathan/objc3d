/**
 *  @file O3RawVertexData.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 12/27/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3VertexFormats.h"
#ifdef __cplusplus
#include <set>
#endif

const extern NSString* O3RawVertexDataDoublyMappedException;

///@todo Replace with O3VertexData (bytes: mutableBytes: will work nicely, have hintDoneWithBytes function)
@interface O3RawVertexData : NSObject {
	GLuint mVertexBufferID;
	void*  mVertexArray;	///<If we are in fallback (plain vertex array) mode, this is either 0x1 or a valid pointer to the data buffer after initialization
	GLenum mAccessHint;
	void* mMappedBuffer;
#ifdef __cplusplus
	std::set<O3VertexDataType>* mBoundTypes;
#else
	void* mBoundTypes;
#endif
	GLsizeiptr mSize;		///<The size in bytes of the buffer. \note Always holds onto its size incase the buffer is >2GB (forward compatibility) and so virtual and real VBOs act the same. Also makes "size" KVO compliant :)
	int mTimesMapped;
}

- (id)initWithBytes:(UInt8*)bytes size:(GLsizeiptr)size accessHint:(GLenum)accessHint;
- (void)setBytes:(UInt8*)bytes size:(GLsizeiptr)size accessHint:(GLenum)accessHint;

- (NSData*)data;
- (NSData*)dataInRange:(NSRange)range;
- (void)replaceDataInRange:(NSRange)range withBytes:(UInt8*)bytes;
- (UInt8*)dataPointerWithAccess:(GLenum)access; ///<Get a pointer to the represented data with access level <i>access</i>. \warning If dataPointerWithAccess is called twice without calling releaseDataPointer, the <i>access</i> between them will be the same, which may not be what you want.
- (void)releaseDataPointer;

/************************************/ #pragma mark Binding and unbinding /************************************/
- (GLvoid*)indicies; ///@warn See the warning attached to bindAsSourceForVertexDataType:...
- (void)bindAsSourceForVertexDataType:(O3VertexDataType)type format:(GLenum)format componentCount:(GLint)components;
- (void)bindAsSourceForVertexDataType:(O3VertexDataType)type format:(GLenum)format componentCount:(GLint)components offset:(GLsizeiptr)offset stride:(GLsizei)stride;
- (void)bindAsSourceForVertexAttributeNumber:(GLuint)attrib format:(GLenum)format componentCount:(GLint)components;
- (void)bindAsSourceForVertexAttributeNumber:(GLuint)attrib format:(GLenum)format componentCount:(GLint)components normalized:(BOOL)normalized offset:(GLsizeiptr)offset stride:(GLsizei)stride;

- (void)unbind;
- (void)unbindAsSourceForVertexDataTypeOrAttribute:(O3VertexDataType)type;

/************************************/ #pragma mark Accessors /************************************/
- (BOOL)isMapped;
- (GLenum)accessHint;
- (GLsizeiptr)size;
@end

//void O3RawVertexData_Bind(O3RawVertexData* self); //Valid but made private since it doesn't do what the bind... methods do in the class
GLvoid* O3RawVertexData_indicies(O3RawVertexData* self); ///Safe (but not fast) to call this on anything that responds to -(GLvoid*)indicies.
