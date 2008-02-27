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
	O3Assign([coder decodeObjectForKey:@"faces"], mFaces);
	O3Assign([coder decodeObjectForKey:@"verts"], mFaceVerticies);
	O3Assign([coder decodeObjectForKey:@"indicies"], mStripIndicies);
	if (mNumberStrips = [coder decodeInt64ForKey:@"numberStrips"]) {
		mStripLocations = (UIntP*)O3NSDataDup([O3SACCast([coder decodeObjectForKey:@"stripLocations"],UIntP) rawData]);
		mStripCounts = (GLsizei*)O3NSDataDup([O3SACCast([coder decodeObjectForKey:@"stripCounts"],GLsizei) rawData]);
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding])
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver %@", self, coder];
	[coder encodeObject:mFaces forKey:@"faces"];
	[coder encodeObject:mFaceVerticies forKey:@"verts"];
	[coder encodeObject:mFaceIndicies forKey:@"indicies"];
	[coder encodeObject:mStripIndicies forKey:@"stripIndicies"];
	if (mNumberStrips) {
		O3Asrt(mStripLocations && mStripIndicies);
		[coder encodeInt64:mNumberStrips forKey:@"numberStrips"];
		id locs = [[O3StructArray alloc] initWithBytes:mStripLocations typeName:@"uiP" length:sizeof(UIntP)*mNumberStrips];
		id cts = [[O3StructArray alloc] initWithBytes:mStripCounts type:O3ScalarStructTypeOf(GLsizei) length:sizeof(GLsizei)*mNumberStrips];
		[coder encodeObject:locs forKey:@"stripLocations"];
		[coder encodeObject:cts forKey:@"stripCounts"];
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

///@warning May convert %newFaces to O3Triangle3x3f type
- (void)setFaces:(O3StructArray*)newFaces {
	if ([newFaces structType]!=O3Triangle3x3fType()) {
		O3StructArray* nfmc = [newFaces mutableCopy];
		if (![nfmc setStructType:O3Triangle3x3fType()])
			[NSException raise:NSInvalidArgumentException format:@"%@ was not a O3Triangle3x3f struct array"];
		[nfmc autorelease];
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

- (O3StructArray*)verticies {
	return [mFaceVerticies structArray];
}

- (O3StructArray*)indicies {
	return [mFaceIndicies structArray];
}

- (O3StructArray*)stripIndicies {
	return [mStripIndicies structArray];
}

- (BOOL)indicesAreValid {
	UIntP max_idx = O3Max([[[mStripIndicies structArray] highestValue] doubleValue], [[[mFaceIndicies structArray] highestValue] doubleValue]);
	return max_idx<[mFaceVerticies count];
}

- (NSString*)renderMode {
	if (mFaces) return O3ConcreteMeshFaceRenderMode;
	if (!mStripLocations) return O3ConcreteMeshIndexedRenderMode;
	return O3ConcreteMeshStrippedRenderMode;
}

- (void)renderWithContext:(O3RenderContext*)ctx {
	//glPushClientAttrib(GL_CLIENT_VERTEX_ARRAY_BIT);
	NSObject<O3MultipassDirector,NSCoding>* the_material = (NSObject<O3MultipassDirector,NSCoding>*)ctx->scratch[0] ?: mDefaultMaterial;
	[mVertexDataSources makeObjectsPerformSelector:@selector(bind)];
	O3GLBreak();
	UIntP passes = [the_material renderPasses];
	[the_material beginRendering];
	if (passes==0) passes=1;
	if (mFaces) { //Face by face
		glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER, GL_ZERO);
		UIntP count = [mFaces bind];
		for (UIntP i=0;i<passes;i++) {
			[the_material setRenderPass:i];
			glDrawArrays(GL_TRIANGLES, 0, count);
		}
		[mFaces unbind];
	}
	if (mFaceVerticies && mFaceIndicies) { //Indexed
		[mFaceVerticies bind];
		UIntP count = [mFaceIndicies bind];
		GLenum index_for = [mFaceIndicies format];
		const GLvoid* index_ptr = [mFaceIndicies indicies];
		for (UIntP i=0;i<passes;i++) {
			if (the_material) {
				[the_material setRenderPass:i];
			}
			glDrawElements(GL_TRIANGLES, count, index_for, index_ptr);
		}
		[mFaceVerticies unbind];
		[mFaceIndicies unbind];
	}
	if (mFaceVerticies && mStripIndicies && mNumberStrips) { //Stripped
		O3Asrt(mStripCounts && mStripLocations);
		[mFaceVerticies bind];
		[mStripIndicies bind]; O3Asrt([[[mStripIndicies structArray] rawData] isGPUData]);
		GLenum idx_format = [mStripIndicies format];
		for (UIntP i=0;i<passes;i++) {
			[the_material setRenderPass:i];
			glMultiDrawElements(GL_TRIANGLE_STRIP, mStripCounts, idx_format, (const GLvoid**)mStripLocations, mNumberStrips);
		}
		[mFaceVerticies unbind];
		[mStripIndicies unbind];
	}
	[the_material endRendering];
	[mVertexDataSources makeObjectsPerformSelector:@selector(unbind)];
	//glPopClientAttrib();
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
	if (mFaceVerticies && mFaceIndicies) {
		O3Fixme();
		return;
	}
	O3StructArray* tri_verts = [[mFaces structArray] mutableCopy];
	if (!tri_verts) return;
	O3Destroy(mFaces);
	[tri_verts setStructType:O3Vec3fType()];
	O3StructArray* new_idxs = [tri_verts uniqueify];
	if (!new_idxs) {
		O3Asrt(false /*Uniqueification failed*/);
		mFaces = nil;
	}
	[new_idxs compressIntegerType];
	O3StructArrayVDS* verts = [[O3StructArrayVDS alloc] initWithStructArray:tri_verts vertexDataType:O3VertexLocationDataType];
	O3StructArrayVDS* idxs = [[O3StructArrayVDS alloc] initWithStructArray:new_idxs vertexDataType:O3VertexLocationIndexDataType];
	O3Assign(verts, mFaceVerticies);
	O3Assign(idxs, mFaceIndicies);
	if (uploadNewFacesToGPU) [self uploadToGPU];
}

///Very un-thread-safe
- (void)stripFacesAndUpload:(BOOL)uploadStripsToGPU {
	if (mNumberStrips) O3LogWarn(@"Stripping an already stripped mesh is bad (the previous strip data will be leaked and/or ignored)");
	[self indexFacesAndUpload:NO];
	O3Asrt(mFaceIndicies&&mFaceVerticies);
	O3StructArray* faces_i = [mFaceIndicies structArray];
	O3Assert([[mFaceVerticies structArray] count] < ~(UInt32)0, @"Stripification does not support 64 bit indicies");
	[faces_i setStructTypeName:@"ui32"];
	UInt32* idxs = (UInt32*)[[faces_i rawData] bytes];
	using namespace triangle_stripper;
	size_t faces_i_ct = [faces_i count];
	O3Asrt(!(faces_i_ct%3));
	tri_stripper* stripper = new tri_stripper((const triangle_stripper::index*)idxs, faces_i_ct);
	stripper->SetCacheSize();
	stripper->SetMinStripSize(12);
	primitive_vector outvec;
	stripper->Strip(&outvec);
	
	UIntP tri_idx_count=0;
	UIntP strip_idx_count=0;
	UIntP strip_count=0;
	UIntP outvec_size = outvec.size();
	for (UIntP i=0; i<outvec_size; i++) {
		primitive_group& p = outvec[i];
		UIntP num_idxs = p.Indices.size();
		if (p.Type==TRIANGLES) {
			tri_idx_count += num_idxs;
		} else if (p.Type==TRIANGLE_STRIP) {
			strip_count++;
			strip_idx_count += num_idxs;
		} else O3Asrt(NO);
	}
	static BOOL has_logged_header = NO;
	if (!has_logged_header) {O3LogInfo(@"Strip Count, Strip Indicies, New Tri Idx Count, Old Tri Idx Count"); has_logged_header=YES;}
	O3LogInfo(@"%i, %i, %i, %i", strip_count, strip_idx_count, tri_idx_count, faces_i_ct);

	UIntP running_tri_idx=0;
	UIntP running_strip_idx=0;
	UIntP running_strip=0;
	UInt32* tri_idxs = tri_idx_count? (UInt32*)malloc(sizeof(UInt32)*tri_idx_count): nil;
	UInt32* strip_idxs = strip_idx_count? (UInt32*)malloc(sizeof(UInt32)*strip_idx_count) : nil;
	if (mStripLocations) free(mStripLocations);
	if (mStripCounts) free(mStripCounts);
	mStripLocations = (UIntP*)malloc(sizeof(UIntP)*strip_count);
	mStripCounts = (GLsizei*)malloc(sizeof(GLsizei)*strip_count);
	for (UIntP i=0; i<outvec_size; i++) {
		primitive_group& p = outvec[i];
		if (p.Type==TRIANGLES) {
			UIntP idcs = p.Indices.size();
			for (UIntP k=0; k<idcs; k++)
				tri_idxs[running_tri_idx++] = p.Indices[k];
		} else if (p.Type==TRIANGLE_STRIP) {
			UIntP idcs = p.Indices.size();
			mStripLocations[running_strip] = running_strip_idx;
			mStripCounts[running_strip] = idcs;
			running_strip++;
			for (UIntP k=0; k<idcs; k++)
				strip_idxs[running_strip_idx++] = p.Indices[k];			
		} else O3Asrt(NO);
	}
	O3Asrt(running_strip_idx==strip_idx_count && running_tri_idx==tri_idx_count);
	
	O3StructArray* new_face_indicies = [[O3StructArray alloc] initWithBytes:tri_idxs typeName:@"ui32" length:sizeof(UInt32)*tri_idx_count];
	O3StructArray* new_strip_indicies = [[O3StructArray alloc] initWithBytes:strip_idxs typeName:@"ui32" length:sizeof(UInt32)*strip_idx_count];
	[new_face_indicies compressIntegerType];
	[new_strip_indicies compressIntegerType];
	[new_strip_indicies uploadToGPU];
	O3StructArrayVDS* new_face_vds = [[O3StructArrayVDS alloc] initWithStructArray:new_face_indicies vertexDataType:O3VertexLocationIndexDataType];
	O3StructArrayVDS* new_strip_vds = [[O3StructArrayVDS alloc] initWithStructArray:new_strip_indicies vertexDataType:O3VertexLocationIndexDataType];
	O3Assign(new_face_vds, mFaceIndicies);
	O3Assign(new_strip_vds, mStripIndicies);

	mNumberStrips = strip_count;
	delete stripper;
	[[faces_i rawData] relinquishBytes];
	if (uploadStripsToGPU) [self uploadToGPU];
}


@end
