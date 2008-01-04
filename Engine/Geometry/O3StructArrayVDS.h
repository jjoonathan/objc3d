//
//  O3StructArrayVDS.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3VertexDataSource.h"
#import "O3VertexFormats.h"
@class O3StructArray;
@class O3StructType;

@interface O3StructArrayVDS : O3VertexDataSource <NSCoding> {
	O3StructArray*	    mStructArray;		///<The struct array where the receiver gets its data (maybe a VBO maybe not)
	NSData*			    mData;				///<A cache of the data object backing mStructArray
	O3StructType*		mStructType;		///<The struct type of the struct array
	O3VertexDataType	mType;				///<The type of data the struct array is providing
	GLenum				mFormat;			///<The format of the data refrenced by the object
	GLint				mComponentCount;	///<The number of components in the object. Example: normals always have 3 components, RGB colors also have 3 components but RGBA colors have 4.
	GLsizeiptr			mOffset;			///<The offset of the data in mRawVertexData
	GLsizei				mStride;			///<The distance between the start of each element. For instance, if data was stored as <12 byte vertex><12 byte normal><12 byte vertex>... the vertex's stride would be 24.
	BOOL				mCurrentlyBound;	///<YES if the object is currently bound for rendering
	
	BOOL				mVertexAttribute;	///<YES if the object represents a vertex attribute (rather than another kind of vertex data)
	GLuint				mVertexAttributeNumber;	///<If the object represents a vertex attribute, this variable holds the number of that attribute
	BOOL				mVertexAttributeNormalized;	///<YES if the object's elements are scaled to 0..1 range (for unsigned data types) or the -1..1 range (for signed data types). \warning This only applies to vertex attributes, not other vertex data types. See the OpenGL spec for more info.
}
- initWithStructArray:(O3StructArray*)arr vertexDataType:(O3VertexDataType)t;

//Accessors
- (GLvoid*)indicies;
- (GLenum)format;
- (O3VertexDataType)type;
- (O3StructArray*)structArray;
- (GLuint)componentCount;
- (UIntP)count; //The number of elements (not necesarily the number of elements to render. For instance, in an array of faces this would return the number of faces not the number of verts)
@end
