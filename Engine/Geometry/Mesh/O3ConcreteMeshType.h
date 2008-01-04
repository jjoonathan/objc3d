//
//  O3ConcreteMesh.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3MeshType.h"
@class O3StructArray, O3StructArrayVDS;

extern NSString* O3ConcreteMeshFaceRenderMode;
extern NSString* O3ConcreteMeshIndexedRenderMode;
extern NSString* O3ConcreteMeshStrippedRenderMode;

@interface O3ConcreteMeshType : O3MeshType <O3Renderable, NSCoding> {
	//Plain faces
	O3StructArrayVDS* mFaces;
	
	//Indexed
	O3StructArrayVDS* mFaceVerticies;
	O3StructArrayVDS* mFaceIndicies;
	
	//Stripped
	UIntP* mStripLocations;
	GLsizei* mStripCounts;
	GLsizei mNumberStrips;
}
//Init
- (O3ConcreteMeshType*)initWithDataSources:(NSArray*)dataSources
				   defaultMaterialName:(NSString*)material
                                 faces:(O3StructArray*)faces;

//Accessors
- (O3StructArray*)faces;
- (void)setFaces:(O3StructArray*)newFaces;
- (void)setFaceVerticies:(O3StructArray*)verts indicies:(O3StructArray*)indicies;
- (NSString*)renderMode;
@end
