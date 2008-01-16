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
	O3VertexDataType	mType;				///<The type of data the struct array is providing
		
	BOOL				mVertexAttribute;	///<YES if the object represents a vertex attribute (rather than another kind of vertex data)
	GLuint				mVertexAttributeNumber;	///<If the object represents a vertex attribute, this variable holds the number of that attribute
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
