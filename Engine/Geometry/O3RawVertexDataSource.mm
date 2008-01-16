/**
 *  @file O3RawVertexDataSource.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 12/29/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3RawVertexDataSource.h"
#import "O3RawVertexData.h"
#import "O3VertexFormats.h"
#import "O3VertexDataSource.h"

@implementation O3RawVertexDataSource

inline unsigned O3RawVertexDataSource_ElementSize(O3RawVertexDataSource* self) {
	unsigned component_size = O3SizeofGLType(self->mType);
	return component_size*(self->mComponentCount);
}

/************************************/ #pragma mark Creation & Destruction /************************************/
- (void)dealloc {
	if (mRawVertexData) [mRawVertexData release];
	[super dealloc];
}

- (id)init {
	O3SuperInitOrDie();
	return self;
}

///@param bytes A pointer to the data to initialize with. The data is assumed to be packed (no space between elements).
///@param size The length in bytes of the data pointed at by <i>bytes</i>
///@param accessHint A hint specifying how the receiver is likely to be accessed in the future. Pass GL_STATIC_DRAW (the default if nil is passed) if the receiver's data will be specified and left alone, GL_DYNAMIC_DRAW if the receiver's data will change frequently and GL_STREAM_DRAW if the receiver's data will be updated regularly (every frame)
///@param type The type of vertex data that will be represented by the receiver
///@param components The number of components in the receiver. Example: normals always have 3 components, RGB colors also have 3 components but RGBA colors have 4.
- (id)initWitBytes:(UInt8*)bytes size:(GLsizeiptr)size accessHint:(GLenum)accessHint type:(O3VertexDataType)type format:(GLenum)format componentCount:(GLint)components {
	O3SuperInitOrDie();
	mRawVertexData = [[O3RawVertexData alloc] initWithBytes:bytes size:size accessHint:accessHint];
	mType = type;
	mFormat = format;
	mComponentCount = components;
	//mOffset = 0;
	//mStride = 0;
	
	return self;	
}

///@param data The raw vertex data object containing the receiver's data
///@param accessHint A hint specifying how the receiver is likely to be accessed in the future. Pass GL_STATIC_DRAW (the default if nil is passed) if the receiver's data will be specified and left alone, GL_DYNAMIC_DRAW if the receiver's data will change frequently and GL_STREAM_DRAW if the receiver's data will be updated regularly (every frame)
///@param type The type of vertex data that will be represented by the receiver
///@param components The number of components in the receiver. Example: normals always have 3 components, RGB colors also have 3 components but RGBA colors have 4.
///@param offset The offset into <i>data</i> (in bytes) at which the receiver will find its data
///@param stride The differencce between starts of elements in bytes. For instance, if data was stored as <12 byte vertex><12 byte normal><12 byte vertex>... the vertex's stride would be 24. Pass 0 to indicate that data is packed together (nothing between elements)
- (id)initWithRawVertexData:(O3RawVertexData*)data type:(O3VertexDataType)type format:(GLenum)format componentCount:(GLint)components offset:(GLsizeiptr)offset stride:(GLsizei)stride {
	O3SuperInitOrDie();

	mRawVertexData = [data retain];
	mType = type;
	mFormat = format;
	mComponentCount = components;
	mOffset = offset;
	mStride = stride;
	
	return self;
}


/************************************/ #pragma mark Data Access /************************************/
- (NSData*)dataInRange:(NSRange)range {
	O3AssertIvar(mRawVertexData);
	if (!mManagesRawData) O3LogWarn(@"[O3RawVertexDataSource dataInRange:] was called on an O3RawVertexDataSource object which was made from an O3RawVertexData object. You should use setBytes... directly on the O3RawVertexData object.");
	unsigned element_size = O3RawVertexDataSource_ElementSize(self);
	if (!mStride) {
		range.location *= element_size;
		range.location += mOffset;
		range.length   *= element_size;
		return [mRawVertexData dataInRange:range];
	}
	UInt8* rawData = (UInt8*)[mRawVertexData dataPointerWithAccess:GL_READ_ONLY]+mOffset+(element_size*range.location);
	UInt8* returnData = (UInt8*)malloc(element_size*range.length);
	UInt8* returnDataIncrementor = returnData;
	for (unsigned i=0; i<range.length; i++) {
		memcpy(returnDataIncrementor, rawData, element_size);
		rawData+=element_size;
		returnDataIncrementor+=element_size;
	}
	[mRawVertexData releaseDataPointer];
	return [NSData dataWithBytesNoCopy:returnData length:range.length*element_size freeWhenDone:YES];
}

- (UInt8*)dataPointerWithAccess:(GLenum)access {
	O3AssertIvar(mRawVertexData);
	if (!mManagesRawData) O3LogWarn(@"[O3RawVertexDataSource dataPointerWithAccess:] was called on an O3RawVertexDataSource object which was made from an O3RawVertexData object. You should use setBytes... directly on the O3RawVertexData object.");
	
	return [mRawVertexData dataPointerWithAccess:access]+mOffset;	
}

- (void)releaseDataPointer {
	O3AssertIvar(mRawVertexData);
	if (!mManagesRawData) O3LogWarn(@"[O3RawVertexDataSource releaseDataPointer] was called on an O3RawVertexDataSource object which was made from an O3RawVertexData object. You should use setBytes... directly on the O3RawVertexData object.");
	
	[mRawVertexData releaseDataPointer];	
}

- (void)replaceElementsInRange:(NSRange)range withBytes:(UInt8*)bytes {
	unsigned element_size = O3RawVertexDataSource_ElementSize(self);
	if (!mStride) {
		range.location *= element_size;
		range.location += mOffset;
		range.length   *= element_size;
		[mRawVertexData replaceDataInRange:range withBytes:bytes];
		return;
	}
	UInt8* rawData = (UInt8*)[mRawVertexData dataPointerWithAccess:GL_WRITE_ONLY]+mOffset+(element_size*range.location);
	UInt8* end = rawData + range.length;
	while (rawData<end) {
		memcpy(rawData, bytes, element_size);
		rawData += element_size;
		bytes   += element_size;
	}
	[mRawVertexData releaseDataPointer];
}

/************************************/ #pragma mark Accessors /************************************/
- (GLvoid*)indicies			{return [mRawVertexData indicies];}
- (O3VertexDataType)type 	{return mType;}
- (GLenum)format 			{return mFormat;}
- (GLint)componentCount		{return mComponentCount;}
- (GLsizeiptr)offset		{return mOffset;}
- (GLsizei)stride			{return mStride;}
- (BOOL)vertexAttributeNormalized	{return mVertexAttributeNormalized;}
- (O3RawVertexData*)rawVertexData	{return mRawVertexData;}

/************************************/ #pragma mark Use /************************************/
- (UIntP)bind {
	UIntP s = [mRawVertexData size] / mStride;
	if (mCurrentlyBound) return s;
	mCurrentlyBound = YES;
	if (mVertexAttribute) {
		[mRawVertexData bindAsSourceForVertexAttributeNumber:mVertexAttributeNumber
                                                      format:mFormat
                                              componentCount:mComponentCount
                                                  normalized:mVertexAttributeNormalized
                                                      offset:mOffset
                                                      stride:mStride];
	} else {
		[mRawVertexData bindAsSourceForVertexDataType:mType
                                               format:mFormat
                                       componentCount:mComponentCount
                                               offset:mOffset
                                               stride:mStride];
	}
	return s;
}

- (void)unbind {
	mCurrentlyBound = NO;
	[mRawVertexData unbindAsSourceForVertexDataTypeOrAttribute:mType];
}

/************************************/ #pragma mark Type Assertion /************************************/
- (O3RawVertexDataSource*)rawVertexDataSource {
	return self;
}

@end
