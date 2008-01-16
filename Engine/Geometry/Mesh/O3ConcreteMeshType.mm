//
//  O3ConcreteMesh.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3ConcreteMeshType.h"
#import "O3FaceStructType.h"
#import "O3StructType.h"
#import "O3StructArrayVDS.h"
#import "O3StructArray.h"

NSString* O3ConcreteMeshFaceRenderMode = @"Individual Triangles";
NSString* O3ConcreteMeshIndexedRenderMode = @"Indexed Triangles";
NSString* O3ConcreteMeshStrippedRenderMode = @"Triangle Strips";

@implementation O3ConcreteMeshType

/************************************/ #pragma mark Init /************************************/
- (O3ConcreteMeshType*)initWithDataSources:(NSArray*)dataSources
				   defaultMaterialName:(NSString*)material
                                 faces:(O3StructArray*)faces {
	if (![super initWithDataSources:dataSources  defaultMaterialName:material]) return nil;
	[self setFaces:faces];
	return self;
}

- (id)initWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding]) {
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
		[self release];
		return nil;
	}
	if (![super initWithCoder:coder]) return nil;
	O3StructArray* faces = [coder decodeObjectForKey:@"faces"];
	if (faces) {
		[self setFaces:faces];
	} else {
		[self setFaceVerticies:[coder decodeObjectForKey:@"verts"] indicies:[coder decodeObjectForKey:@"indicies"]];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding])
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
	if (mFaces) {
		[coder encodeObject:mFaces forKey:@"faces"];
	} else {
		[coder encodeObject:mFaceVerticies forKey:@"verts"];
		[coder encodeObject:mFaceIndicies forKey:@"indicies"];
	}
	[super encodeWithCoder:coder];
}

- (void)dealloc {
	[mFaces release];
	[mFaceVerticies release];
	[mFaceIndicies release];
	O3SuperDealloc();
}

/************************************/ #pragma mark Accessors /************************************/
- (O3StructArray*)faces {
	if (!mFaces) O3ToImplement();
	return [mFaces structArray];
}

- (void)setFaces:(O3StructArray*)newFaces {
	if ([newFaces structType]!=O3Triangle3x3fType()) {
		if (![newFaces setStructType:O3Triangle3x3fType()]) {
			[NSException raise:NSInvalidArgumentException format:@"%@ was not a O3Triangle3x3f struct array"];
		}
	}
	O3StructArrayVDS* vds = [[O3StructArrayVDS alloc] initWithStructArray:newFaces vertexDataType:O3VertexLocationDataType];
	O3Assign(vds, mFaces);
	[vds release];
	[mFaceVerticies release];
	[mFaceIndicies release];
}

- (void)setFaceVerticies:(O3StructArray*)verts indicies:(O3StructArray*)indicies {
	O3StructType* ptType = O3Point3fType();
	O3StructType* idxType1 = O3IndexedTriangle3cType();
	O3StructType* idxType2 = O3IndexedTriangle3sType();
	O3StructType* idxType3 = O3IndexedTriangle3iType();	
	O3StructType* vtype = [verts structType];
	O3StructType* itype = [indicies structType];
	O3VerifyArg(vtype==ptType && (itype==idxType1 || itype==idxType2 || itype==idxType3), @"verts must be of O3Point3fType, indicies must be of O3IndexedTriangle3?Type");
	[mFaces release];
	O3StructArrayVDS* vds1 = [[O3StructArrayVDS alloc] initWithStructArray:verts vertexDataType:O3VertexLocationDataType];
	O3StructArrayVDS* vds2 = [[O3StructArrayVDS alloc] initWithStructArray:indicies vertexDataType:O3VertexLocationIndexDataType];
	O3Assign(vds1, mFaceVerticies);
	O3Assign(vds2, mFaceIndicies);
}

- (NSString*)renderMode {
	if (mFaces) return O3ConcreteMeshFaceRenderMode;
	if (!mStripLocations) return O3ConcreteMeshIndexedRenderMode;
	return O3ConcreteMeshStrippedRenderMode;
}

- (void)renderWithContext:(O3RenderContext*)ctx {
	UIntP vds_count = O3CFArrayGetCount(mVertexDataSources);
	UIntP i; for(i=0; i<vds_count; i++) {
		O3VertexDataSource* vds = O3CFArrayGetValueAtIndex(mVertexDataSources, i);
		[vds bind];
	}
	UIntP passes = [mDefaultMaterial renderPasses];
	if (passes==0) passes=1;
	glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER, GL_ZERO);
	if (mFaces) { //Face by face
		UIntP count =[mFaces bind];
		for (i=0;i<passes;i++) {
			[mDefaultMaterial setRenderPass:i];
			glDrawArrays(GL_TRIANGLES, 0, count);
		}
	} else if (!mStripLocations) { //Indexed
		[mFaceVerticies bind];
		[mFaceIndicies bind];
		UIntP count = [mFaceIndicies count];
		for (i=0;i<passes;i++) {
			[mDefaultMaterial setRenderPass:i];
			glDrawElements(GL_TRIANGLES, count, [mFaceIndicies format], [mFaceVerticies indicies]);
		}
	} else { //Stripped
		[mFaceVerticies bind];
		[mFaceIndicies bind];
		for (i=0;i<passes;i++) {
			[mDefaultMaterial setRenderPass:i];
			glMultiDrawElements(GL_TRIANGLE_STRIP, mStripCounts, [mFaceIndicies format], (const GLvoid**)mStripLocations, mNumberStrips);
		}
	}
}

- (void)tickWithContext:(O3RenderContext*)context {
}

/************************************/ #pragma mark Convenience /************************************/
- (void)uploadToGPU {
	[super uploadToGPU];
	[mFaces uploadToGPU];
	[mFaceVerticies uploadToGPU];
	[mFaceIndicies uploadToGPU];
}

@end
