//
//  O3ConcreteMesh.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3MeshType.h"
extern NSString* O3ConcreteMeshFaceRenderMode;
extern NSString* O3ConcreteMeshIndexedRenderMode;
extern NSString* O3ConcreteMeshStrippedRenderMode;

@interface O3ConcreteMeshType : O3MeshType <O3Renderable, NSCoding> {
	//Plain faces
	O3StructArray* mFaces;
	
	//Indexed
	O3StructArray* mFaceVerticies;
	O3StructArray* mFaceIndicies;
	
	//Stripped
	GLint* mStripLocations;
	GLsizei* mStripCounts;
	GLsizei mNumberStrips;
}
//Init
- (O3ConcreteMesh*)initWithDataSources:(NSArray*)dataSources
				   defaultMaterialName:(NSString*)material
                                 faces:(O3FaceArray*)faces;

//Accessors
- (O3StructArray*)faces;
- (void)setFaces:(O3StructArray*)newFaces;
- (void)setFaceVerticies:(O3StructArray*)verts indicies:(O3StructArray*)indicies;
- (NSString*)renderMode;
@end
