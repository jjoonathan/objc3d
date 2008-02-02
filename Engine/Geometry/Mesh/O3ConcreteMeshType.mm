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
#import "O3ScalarStructType.h"
#import "O3StructArrayVDS.h"
#import "O3StructArray.h"
#import "O3GPUData.h"
#import "tri_stripper.h"

NSString* O3ConcreteMeshFaceRenderMode = @"Individual Triangles";
NSString* O3ConcreteMeshIndexedRenderMode = @"Indexed Triangles";
NSString* O3ConcreteMeshStrippedRenderMode = @"Triangle Strips";

@implementation O3ConcreteMeshType
O3DefaultO3InitializeImplementation

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
	O3StructArray* face_verts = [coder decodeObjectForKey:@"verts"];
	O3StructArray* face_inds = [coder decodeObjectForKey:@"indicies"];
	if (faces) [self setFaces:faces];
	if (face_verts&&face_inds) [self setFaceVerticies:[coder decodeObjectForKey:@"verts"] indicies:[coder decodeObjectForKey:@"indicies"]];
	if (mNumberStrips = [coder decodeInt64ForKey:@"numberStrips"]) {
		mStripLocations = (UIntP*)O3NSDataDup([O3SACCast([coder decodeObjectForKey:@"stripLocations"],UIntP) rawData]);
		mStripCounts = (GLsizei*)O3NSDataDup([O3SACCast([coder decodeObjectForKey:@"stripCounts"],GLsizei) rawData]);
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding]) {
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
		[coder encodeObject:mFaces forKey:@"faces"];
		[coder encodeObject:[mFaceVerticies structArray] forKey:@"verts"];
		[coder encodeObject:[mFaceIndicies structArray] forKey:@"indicies"];
		[coder encodeObject:[mStripIndicies structArray] forKey:@"stripIndicies"];
		if (mNumberStrips) {
			O3Asrt(mStripLocations && mStripIndicies);
			[coder encodeInt64:mNumberStrips forKey:@"numberStrips"];
			id locs = [[O3StructArray alloc] initWithBytes:mStripLocations typeName:@"uiP" length:sizeof(UIntP)*mNumberStrips];
			id cts = [[O3StructArray alloc] initWithBytes:mStripCounts type:O3ScalarStructTypeOf(GLsizei) length:sizeof(GLsizei)*mNumberStrips];
			[coder encodeObject:locs forKey:@"stripLocations"];
			[coder encodeObject:cts forKey:@"stripCounts"];
		}
	}
	[super encodeWithCoder:coder];
}

- (void)dealloc {
	[mFaces release];
	[mFaceVerticies release];
	[mFaceIndicies release];
	[mStripIndicies release];
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
}

- (void)setFaceVerticies:(O3StructArray*)verts indicies:(O3StructArray*)indicies {
	O3StructType* ptType = O3Point3fType();
	O3StructType* idxType1 = O3IndexedTriangle3cType();
	O3StructType* idxType2 = O3IndexedTriangle3sType();
	O3StructType* idxType3 = O3IndexedTriangle3iType();	
	O3StructType* vtype = [verts structType];
	O3StructType* itype = [indicies structType];
	O3VerifyArg(vtype==ptType && (itype==idxType1 || itype==idxType2 || itype==idxType3), @"verts must be of O3Point3fType, indicies must be of O3IndexedTriangle3?Type");
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
	if (mFaces && !mFaceIndicies) { //Face by face
		UIntP count = [mFaces bind];
		for (i=0;i<passes;i++) {
			[mDefaultMaterial setRenderPass:i];
			glDrawArrays(GL_TRIANGLES, 0, count);
		}
	}
	if (mFaces && mFaceIndicies) { //Indexed
		[mFaceVerticies bind];
		UIntP count = [mFaceIndicies bind];
		for (i=0;i<passes;i++) {
			[mDefaultMaterial setRenderPass:i];
			glDrawElements(GL_TRIANGLES, count, [mFaceIndicies format], [mFaceVerticies indicies]);
		}
	}
	if (mFaces && mFaceIndicies && mNumberStrips) { //Stripped
		O3Asrt(mStripCounts && mStripLocations);
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
	[mStripIndicies uploadToGPU];
}

/************************************/ #pragma mark Operations /************************************/
- (void)indexFacesAndUpload:(BOOL)uploadNewFacesToGPU {
	O3StructArray* faces = [[mFaces structArray] retain];
	O3Destroy(mFaces);
	O3StructArray* new_idxs = [faces uniqueify];
	if (!new_idxs) {
		O3Asrt(false /*Uniqueification failed*/);
		mFaces = nil;
	}
	O3StructArrayVDS* verts = [[O3StructArrayVDS alloc] initWithStructArray:faces vertexDataType:O3VertexLocationDataType];
	O3StructArrayVDS* idxs = [[O3StructArrayVDS alloc] initWithStructArray:new_idxs vertexDataType:O3VertexLocationIndexDataType];
	O3Assign(verts, mFaceVerticies);
	O3Assign(idxs, mFaceIndicies);
	if (uploadNewFacesToGPU) [self uploadToGPU];
}

///Very un-thread-safe
- (void)stripFacesAndUpload:(BOOL)uploadStripsToGPU {
	if (mNumberStrips) O3LogWarn(@"Stripping an already stripped mesh is bad");
	[self indexFacesAndUpload:NO];
	O3StructArray* faces_v = [mFaceVerticies structArray];
	O3StructArray* faces_i = [mFaceIndicies structArray];
	O3Assert([faces_v count] < ~(UInt32)0, @"Stripification does not support 64 bit indicies");
	[faces_i setStructTypeName:@"ui32"];
	UInt32* idxs = (UInt32*)[[faces_i rawData] bytes];
	using namespace triangle_stripper;
	tri_stripper* stripper = new tri_stripper((const triangle_stripper::index*)idxs, (size_t)[faces_i count]);
	stripper->SetCacheSize();
	stripper->SetMinStripSize();
	primitive_vector strips;
	primitive_vector tris;
	stripper->Strip(&strips, &tris);
	
	UIntP new_idx_count=0;
	for (UIntP i=0; i<tris.size(); i++) new_idx_count += tris[i].Indices.size();
	UInt32* face_idxs = (UInt32*)malloc(sizeof(UInt32)*new_idx_count);
	UIntP j=0;
	for (UIntP i=0; i<tris.size(); i++) {
		primitive_group& p = tris[i];
		O3Asrt(p.Type==TRIANGLES);
		for (UIntP k=0; k<p.Indices.size(); k++)
			face_idxs[j++] = p.Indices[k];
	}
	
	mNumberStrips = 0;
	if (mStripLocations) free(mStripLocations);
	if (mStripCounts) free(mStripCounts);
	mStripLocations = (UIntP*)malloc(sizeof(UIntP)*mNumberStrips);
	mStripCounts = (GLsizei*)malloc(sizeof(GLsizei)*mNumberStrips);
	UIntP new_strip_idx_count=0;
	for (UIntP i=0; i<strips.size(); i++) new_strip_idx_count += strips[i].Indices.size();
	UInt32* strip_idxs = (UInt32*)malloc(sizeof(UInt32)*new_strip_idx_count);
	j=0;
	for (UIntP i=0; i<strips.size(); i++) {
		primitive_group& p = strips[i];
		O3Asrt(p.Type==TRIANGLE_STRIP);
		mStripLocations[i] = j;
		UIntP l = mStripCounts[i] = p.Indices.size();
		for (UIntP k=0; k<l; k++)
			strip_idxs[j++] = p.Indices[k];
	}
	
	O3StructArray* new_face_indicies = [[O3StructArray alloc] initWithBytes:face_idxs typeName:@"ui32" length:sizeof(UInt32)*new_idx_count];
	O3StructArray* new_strip_indicies = [[O3StructArray alloc] initWithBytes:strip_idxs typeName:@"ui32" length:sizeof(UInt32)*new_strip_idx_count];
	[new_face_indicies compressIntegerType];
	[new_strip_indicies compressIntegerType];
	O3StructArrayVDS* new_face_vds = [[O3StructArrayVDS alloc] initWithStructArray:new_face_indicies vertexDataType:O3VertexLocationIndexDataType];
	O3StructArrayVDS* new_strip_vds = [[O3StructArrayVDS alloc] initWithStructArray:new_strip_indicies vertexDataType:O3VertexLocationIndexDataType];
	O3Assign(new_face_vds, mFaceIndicies);
	O3Assign(new_strip_vds, mStripIndicies);

	mNumberStrips = strips.size();
	delete stripper;
	[[faces_i rawData] relinquishBytes];
	if (uploadStripsToGPU) [self uploadToGPU];
}


@end
