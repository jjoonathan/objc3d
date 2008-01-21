//
//  O3StructArrayVDS.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3StructArrayVDS.h"
#import "O3StructArray.h"
#import "O3VertexFormats.h"
#import "O3GPUData.h"
#import "O3StructType.h"

@implementation O3StructArrayVDS
O3DefaultO3InitializeImplementation

- initWithStructArray:(O3StructArray*)arr vertexDataType:(O3VertexDataType)t {
	O3SuperInitOrDie();
	O3Assign(arr, mStructArray);
	mType = t;
	if (O3VertexDataTypeIsVertexAttribute(t)) {
		mVertexAttributeNumber = O3VertexAttributeNumberForForDataType(t);
	}
	return self;
}

- (id)initWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding]) {
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
		[self release];
		return nil;
	}	
	return [self initWithStructArray:[coder decodeObjectForKey:@"vertValues"]
	                  vertexDataType:(O3VertexDataType)[coder decodeInt32ForKey:@"type"]];
}

- (void)encodeWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding])
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
	[coder encodeObject:mStructArray forKey:@"vertValues"];
	[coder encodeInt32:(Int32)mType forKey:@"type"];
}

- (void)dealloc {
	[mStructArray release];
	O3SuperDealloc();
}

/************************************/ #pragma mark Accessors /************************************/
- (GLvoid*)indicies {
	return [[mStructArray rawData] glPtrForBindingElements];
}

- (GLenum)format {
	GLenum f;
	[mStructArray getRawData:nil
	                    type:nil
	                  format:&f
	              components:nil
	                  offset:nil
	                  stride:nil
	                  normed:nil
	          vertsPerStruct:nil
			         forType:O3InvalidVertexDataType];
	return f;
}

- (O3VertexDataType)type {
	return mType;
}

- (O3StructArray*)structArray {
	return mStructArray;
}

- (GLuint)componentCount {
	GLsizeiptr c;
	[mStructArray getRawData:nil
	                    type:nil
	                  format:nil
	              components:&c
	                  offset:nil
	                  stride:nil
	                  normed:nil
	          vertsPerStruct:nil
			         forType:O3InvalidVertexDataType];
	return c;
}

- (UIntP)count {
	return [mStructArray count];
}

/************************************/ #pragma mark GL /************************************/
///Binds and returns count
- (UIntP)bind {
	NSData* dat;
	O3StructType* type;
	GLsizeiptr comp_count;
	GLenum format;
	GLint stride;
	GLint offset;
	GLboolean normed;
	int vps;
	[mStructArray getRawData:&dat
	                    type:&type
	                  format:&format
	              components:&comp_count
	                  offset:&offset
	                  stride:&stride
	                  normed:&normed
	          vertsPerStruct:&vps
	                 forType:mType];
	
	switch (mType) {
			case O3VertexLocationDataType:
				glEnableClientState(GL_VERTEX_ARRAY);
				glVertexPointer(comp_count, format, stride, [dat glPtrForBindingArray]);
				break;
			case O3NormalDataType:
				glEnableClientState(GL_NORMAL_ARRAY);
				O3AssertArg(comp_count==3, @"comp_count must be 3 for a normal array.");
				glNormalPointer(format, stride, [dat glPtrForBindingArray]);	
				break;	
			case O3ColorDataType:
				glEnableClientState(GL_COLOR_ARRAY);
				GLvoid* ptr = [dat glPtrForBindingArray];
				glColorPointer(comp_count, format, stride, ptr);
				break;
			case O3ColorIndexDataType:
				glEnableClientState(GL_INDEX_ARRAY);
				O3AssertArg(comp_count<2, @"Index arrays can only have one component.");
				if (format==GL_UNSIGNED_SHORT) format = GL_SHORT; //An idiosyncrasy of the OSX implementation. Luckily, short actually means unsigned short in this case :)
				glIndexPointer(format, stride, [dat glPtrForBindingArray]);
				break;
			case O3VertexLocationIndexDataType:
				[dat glPtrForBindingElements];
				break;
			case O3TexCoordDataType:
				glClientActiveTexture(GL_TEXTURE0);
				glEnableClientState(GL_TEXTURE_COORD_ARRAY);
				glTexCoordPointer(comp_count, format, stride, [dat glPtrForBindingArray]);
				break;
			case O3EdgeFlagDataType:
				O3AssertArg(comp_count<2, @"Edge flag arrays can only have one component.");
				O3AssertArg(format==GL_BOOL, @"Edge flag format must be GL_BOOL.");
				glEnableClientState(GL_EDGE_FLAG_ARRAY);
				glEdgeFlagPointer(stride, [dat glPtrForBindingArray]);
				break;
			case O3SecondaryColorDataType:
				glEnableClientState(GL_SECONDARY_COLOR_ARRAY);
				glSecondaryColorPointer(comp_count, format, stride, [dat glPtrForBindingArray]);
				break;
			case O3FogCoordDataType:
				glEnableClientState(GL_FOG_COORD_ARRAY);
				O3AssertArg(comp_count<2, @"Fog coord arrays can only have one element in them.");
				glFogCoordPointer(format, stride, [dat glPtrForBindingArray]);
				break;
			default:
				if (O3VertexDataTypeIsTexCoord(mType)) {
					glClientActiveTexture(GL_TEXTURE0+O3TexCoordNumberForForDataType(mType));
					glEnableClientState(GL_TEXTURE_COORD_ARRAY);
					glTexCoordPointer(comp_count, format, stride, [dat glPtrForBindingArray]);
					break;
				}
				if (O3VertexDataTypeIsVertexAttribute(mType)) {
					GLuint attrib = O3VertexAttributeNumberForForDataType(mType);
					glEnableVertexAttribArray(attrib);
					glVertexAttribPointer(attrib, comp_count, format, normed, stride, [dat glPtrForBindingArray]);
					break;
				}
				[NSException raise:O3VertexDataTypeUnrecognizedException
	                        format:@"[O3StructArrayVDS bindAsSourceForVertexDataType...] does not recognize %i as a valid vertex [dat glPtrForBindingArray] type. Note that for vertex attributes, you should use the bindAsSourceForVertexAttribute methods."];
		}
		return [mStructArray count]*vps;
}

- (void)unbind {
	switch (mType) {
		case O3VertexLocationDataType:	
			glDisableClientState(GL_VERTEX_ARRAY);
			break;
		case O3VertexLocationIndexDataType:
			glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_BINDING_ARB, GL_ZERO);
			break;
		case O3NormalDataType:			
			glDisableClientState(GL_NORMAL_ARRAY);
			break;
		case O3ColorDataType:			
			glDisableClientState(GL_COLOR_ARRAY);
			break;
		case O3ColorIndexDataType:			
			glDisableClientState(GL_INDEX_ARRAY);
			break;
		case O3TexCoordDataType:		
			glClientActiveTexture(GL_TEXTURE0);
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
			break;
		case O3EdgeFlagDataType:		
			glDisableClientState(GL_EDGE_FLAG_ARRAY);
			break;
		case O3SecondaryColorDataType:	
			glDisableClientState(GL_SECONDARY_COLOR_ARRAY);
			break;
		case O3FogCoordDataType:		
			glDisableClientState(GL_FOG_COORD_ARRAY);
			break;
		default:
			if (O3VertexDataTypeIsVertexAttribute(mType)) {
				int index = O3VertexAttributeNumberForForDataType(mType);
				glDisableVertexAttribArray(index);
				break;
			}
			if (O3VertexDataTypeIsTexCoord(mType)) {
				glClientActiveTexture(mType);
				glDisableClientState(GL_TEXTURE_COORD_ARRAY);
				break;
			}
			[NSException raise:O3VertexDataTypeUnrecognizedException
                        format:@"[O3StructArrayVDS unbindAsSourceForVertexDataTypeOrAttribute...] does not recognize %i as a valid vertex data type. Note that for vertex attributes, you should use the bindAsSourceForVertexAttribute methods."];
	}
}

- (void)uploadToGPU {
	[mStructArray uploadToGPU];
}

@end
