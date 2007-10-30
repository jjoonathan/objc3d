/**
 *  @file O3Mesh.h
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3Renderable.h"
#import "O3VertexFormats.h"
@class O3VertexDataSource;
@class O3RawVertexDataSource;

///@todo Assert that the proper data sources are attached for the material (else garbage ensues)
///@todo Refactor setMaterial to setDefaultMaterial

@interface O3Mesh : NSObject <O3Renderable> {
	O3RawVertexDataSource* 			mVertexLocations; 		///<Holds the locations of all the verticies. A mesh *must* have them for rendering, but they can be overriden in a mesh instance. For instance, a skeletally animated character might store the "blind position" in the O3Mesh and the post bone transformed vertex positions in the O3MeshInstance.  Internally raw until implicit vertex generation is allowed :)
	O3RawVertexDataSource* 			mVertexIndicies;  		///<Holds the indicies of the verticies to be rendered. Internally raw until implicit index generation is allowed :)
	NSMutableDictionary* 			mVertexDataSources;	///<Holds the vertx data sources associated with the mesh keyed by the type of data they represent as an unsigned integer. @note Index and "vertex location" arrays are opaquely stored in different variables.
	NSObject<O3MultipassDirector>* 	mDefaultDirector;	///<The object which directs the rendering of the receiver (usually the material, hence the name)
	
	GLsizeiptr 	mPrimitiveCount; ///<The number of primitives in the receiver
	GLenum 		mPrimitiveType; ///<The type of primitives that compose the mesh (GL_TRIANGLES, GL_TRIANGLE_STRIP, etc)
	GLsizeiptr 	mElementCount; 	///<The number of verticies to render per primitive iff mElementType is a single statically sized type (GL_QUADS, GL_LINES, or GL_TRIANGLES), else mElementCount is 0.
	GLsizei* 	mElementCounts;	///<An array with the number of verticies in each primitive iff mElementType is a dynamically sized type (GL_QUAD_STRIP, GL_TRIANGLE_STRIP, GL_LINE_LOOP, etc)
}
/**********************************************/ #pragma mark Initialization /**********************************************/
- (id)initWithVerticies:(O3VertexDataSource*)vertexLocations indicies:(O3VertexDataSource*)indicies primitiveType:(GLenum)primitiveType primitiveCount:(GLsizeiptr)primCount verticiesPerPrimitive:(const GLsizei*)vertsPerPrimitive primitivesHaveSameNumberVerticies:(BOOL)primitivesConstant material:(NSObject<O3MultipassDirector>*)mat;

/**********************************************/ #pragma mark Modifiers /**********************************************/
- (void)stripify;	///<Turn a triangle mesh into a mesh of triangle strips

/**********************************************/ #pragma mark Accessors /**********************************************/
- (NSObject<O3MultipassDirector>*)material;	///<The material of the receiver
- (void)setMaterial:(NSObject<O3MultipassDirector>*)newMaterial;	///<Sets the material of the receiver
- (O3VertexDataSource*)vertexLocations; ///<The verticies themselves (their coordinates)
- (void)setVertexLocations:(O3VertexDataSource*)newVertexLocations; ///<Replaces the vertex locations. @note You must also update the primitive type, primitive count, and element counts otherwise you could end up with an invalid mesh!
- (GLenum)primitiveType; ///<The type of primitive that composes the receiver
- (void)setPrimitiveType:(GLenum)primitiveType; ///<Sets the type of primitive that composes the receiver. @note Does not update the verticies themselves so this could easily have undesired consequences.
- (BOOL)primitivesHaveEqualVertexCount; ///<YES if all the receiver's primitives have the same element count
- (const GLsizei*)primitiveVertexCounts; ///<The sizes (in verticies) of the receiver's primitives
- (NSMutableDictionary*)vertexDataSources; ///<Gets a mutable dictionary of O3VertexDataSources that provide the receiver with vertex data, keyed by [NSNumber numberWithUnsignedInt:O3VertexDataType]
- (void)addVertexDataSource:(O3VertexDataSource*)source;	///<Like calling [[O3Mesh vertexDataSources] setObject:source forKey:[NSNumber numberWithUnsignedInt:[source type]]]
- (O3VertexDataSource*)vertexDataSourceForType:(O3VertexDataType)type;	///<Like calling [[O3Mesh vertexDataSources] objectForKey:[NSNumber numberWithUnsignedInt:type]]

/************************************/ #pragma mark Use /************************************/
- (void)renderWithContext:(O3RenderContext*)context; ///<Render with info about the context (hints, etc) \e context
@end
