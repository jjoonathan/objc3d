//
//  O3TestTet.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 12/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3TestTet.h"
#import "O3Camera.h"
#import "O3StructArrayVDS.h"
#import "O3StructArray.h"

float O3TestTetVerts[3*4] = {0,0,0,
                            1,0,0,
                            0,1,0,
                            0,0,1};
UInt8 O3TestTetColors[4*4] = {0xFF,0,0xFF,0xFF,
                              0xFF,0,0,0xFF,
                              0,0xFF,0,0xFF,
                              0,0,0xFF,0xFF};
UInt8 O3TestTetIndicies[3*4] = {1,2,3,
                                0,1,2,
                                1,0,3,
                                2,0,3};
UInt8 O3TestLineIndicies[2*6] = {0,1,0,2,0,3,1,2,1,3,2,3};
							
                            

@implementation O3TestTet
O3DefaultO3InitializeImplementation

- (void)renderWithContext:(O3RenderContext*)ctx {
	[mObjectSpace push:ctx];
	static O3StructArray* colDat = nil;
	if (!colDat) colDat = [[O3StructArray alloc] initWithTypeNamed:@"RGBA8" rawData:[NSData dataWithBytesNoCopy:O3TestTetColors length:sizeof(O3TestTetColors) freeWhenDone:NO]];
	static O3StructArray* vrtDat = nil;
	if (!vrtDat) vrtDat = [[O3StructArray alloc] initWithTypeNamed:@"vec3r" rawData:[NSData dataWithBytesNoCopy:O3TestTetVerts length:sizeof(O3TestTetVerts) freeWhenDone:NO]];
	static O3StructArray* idxDat = nil;
	if (!idxDat) idxDat = [[O3StructArray alloc] initWithTypeNamed:@"ui8" rawData:[NSData dataWithBytesNoCopy:O3TestTetIndicies length:sizeof(O3TestTetIndicies) freeWhenDone:NO]];
	static O3StructArrayVDS* col = nil;
	if (!col) col =                [[O3StructArrayVDS alloc] initWithStructArray:colDat
	                                                              vertexDataType:O3ColorDataType];
	static O3StructArrayVDS* vrt = nil;
	if (!vrt) vrt =                [[O3StructArrayVDS alloc] initWithStructArray:vrtDat
	                                                              vertexDataType:O3VertexLocationDataType];
	static O3StructArrayVDS* idx = nil;
	if (!idx) idx =                [[O3StructArrayVDS alloc] initWithStructArray:idxDat
	                                                              vertexDataType:O3VertexLocationIndexDataType];
	[colDat uploadToGPU];
	[vrtDat uploadToGPU];
	[idxDat uploadToGPU];
	
	[col bind];
	[vrt bind];
	[idx bind];
	
	glDrawElements(GL_TRIANGLES, 12, GL_UNSIGNED_BYTE, (GLvoid*)[idx indicies]);
	
	[col unbind];
	[vrt unbind];
	[idx unbind];
	[mObjectSpace pop:ctx];
}

- (void)tickWithContext:(O3RenderContext*)context {
}

@end
