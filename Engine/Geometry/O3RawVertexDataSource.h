/**
 *  @file O3RawVertexDataSource.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 12/29/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3VertexFormats.h"
#import "O3VertexDataSource.h"

@class O3RawVertexData;

@interface O3RawVertexDataSource : NSObject <O3VertexDataSource> {
	BOOL				mManagesRawData;	///<YES if <i>mRawVertexData</i> was created by this object
	O3RawVertexData*	mRawVertexData;		///<The place the receiver gets its data (maybe a VBO maybe not)
	O3VertexDataType	mType;				///<The type of data refrenced by the object
	GLenum				mFormat;			///<The format of the data refrenced by the object
	GLint				mComponentCount;	///<The number of components in the object. Example: normals always have 3 components, RGB colors also have 3 components but RGBA colors have 4.
	GLsizeiptr			mOffset;			///<The offset of the data in mRawVertexData
	GLsizei				mStride;			///<The distance between the start of each element. For instance, if data was stored as <12 byte vertex><12 byte normal><12 byte vertex>... the vertex's stride would be 24.
	BOOL				mCurrentlyBound;	///<YES if the object is currently bound for rendering
	
	BOOL				mVertexAttribute;	///<YES if the object represents a vertex attribute (rather than another kind of vertex data)
	GLuint				mVertexAttributeNumber;	///<If the object represents a vertex attribute, this variable holds the number of that attribute
	BOOL				mVertexAttributeNormalized;	///<YES if the object's elements are scaled to 0..1 range (for unsigned data types) or the -1..1 range (for signed data types). \warning This only applies to vertex attributes, not other vertex data types. See the OpenGL spec for more info.
}
//Creation & Destruction
- (id)initWitBytes:(UInt8*)bytes size:(GLsizeiptr)size accessHint:(GLenum)accessHint type:(O3VertexDataType)type format:(GLenum)format componentCount:(GLint)components; ///<A convenience method to initialize the receiver and create a O3RawVertexDataSource at the same time.
- (id)initWithRawVertexData:(O3RawVertexData*)data type:(O3VertexDataType)type format:(GLenum)format componentCount:(GLint)components offset:(GLsizeiptr)offset stride:(GLsizei)stride;	///<Initialize the receiver with a preexisting O3RawVertexDataSource

//Data Access
- (void)replaceElementsInRange:(NSRange)range withBytes:(UInt8*)bytes;	///<Replace the elements in <i>range</i> with <i>bytes</i>. Offset and stride are automatically accounted for, just specify the packed values which will be changing.
- (NSData*)dataInRange:(NSRange)range;	///<Grabs the data represented by the receiver in range <i>range</i>. <i>range</i> is a byte range into the data the receiver represents, so offset/stride will be taken care of by the receiver and the return value will be packed data in mFormat. \warning If the receiver's mRawVertexData is mapped with GL_WRITE_ONLY the result of this method is undefined!
- (UInt8*)dataPointerWithAccess:(GLenum)access;	///<Gets a raw pointer to the receiver's data source with access being GL_READ_ONLY, GL_WRITE_ONLY, or GL_READ_WRITE. \warning Offset is accounted for but stride is not, this is the same as calling [[YourVertexDataSource rawVertexData] dataPointerWithAccess:<i>access</i]+[YourVertexDataSource offset] \warning you must call releaseDataPointer before rendering with (binding) the receiver
- (void)releaseDataPointer;				///<Invalidates the data pointer acquired with dataPointerWithAccess:. It is necessary to call this before binding the receiver.

//Accessors
- (GLvoid*)indicies;
- (O3VertexDataType)type;		///<Returns the type of vertex data represented by the receiver.
- (GLenum)format;				///<Returns the format of the vertex data represented by the receiver. One of GL_FLOAT, GL_HALF_FLOAT, GL_INT, etc.
- (GLint)componentCount;		///<Returns the number of components in the receiver. Example: normal data always has a component count of 3.
- (GLsizeiptr)offset;			///<Returns the offset of the receiver's data in the receiver's O3RawVertexData's raw data.
- (GLsizei)stride;				///<Returns the distance between starts of elements in the receiver's O3RawVertexData's raw data or 0 if the elements are packed. For instance, if data was stored as <12 byte vertex><12 byte normal><12 byte vertex>... the vertex's stride would be 24.
- (BOOL)vertexAttributeNormalized;	///<Returns weather or not the receiver's elements are scaled to 0..1 range (for unsigned data types) or the -1..1 range (for signed data types). \warning This only applies to vertex attributes, not other vertex data types. See the OpenGL spec for more info.
- (O3RawVertexData*)rawVertexData;	///<Returns the receiver's raw vertex data object. \warning It is very easy and possible to screw up an existing O3RawVertexDataSource by changing the raw vertex data object without recreating all the O3RawVertexDataSources that refer to it.

//Type assertion
- (O3RawVertexDataSource*)rawVertexDataSource; ///<Raises an exception if the receiver isn't a raw vertex data source, otherwise it returns the receiver.
@end
