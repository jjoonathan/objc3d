/**
 *  @file O3Mesh.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 12/27/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3Mesh.h"
#import "O3VertexDataSource.h"
#import "O3RawVertexDataSource.h"

///@todo Make KVC compliant
@implementation O3Mesh

inline O3VertexDataSource* O3Mesh_vertexLocations(O3Mesh* self) {
	return self->mVertexLocations;
}

inline void setVertexLocationsP(O3Mesh* self, O3VertexDataSource* new_vertexLocations) {
	if (new_vertexLocations == self->mVertexLocations) return;
	[self willChangeValueForKey:@"vertexLocations"];
	[self->mVertexLocations release];
	self->mVertexLocations = [[new_vertexLocations rawVertexDataSource] retain];
	[self didChangeValueForKey:@"vertexLocations"];
}

inline void setVertexIndiciesP(O3Mesh* self, O3VertexDataSource* new_mVertexIndicies) {
	if (new_mVertexIndicies == self->mVertexIndicies) return;
	[self willChangeValueForKey:@"vertexIndicies"];
	[self->mVertexIndicies release];
	self->mVertexIndicies = [[new_mVertexIndicies rawVertexDataSource] retain];
	[self didChangeValueForKey:@"vertexIndicies"];
}

inline O3VertexDataSource* O3Mesh_vertexIndicies(O3Mesh* self) {
	return self->mVertexIndicies;
}

inline NSObject<O3MultipassDirector>* O3Mesh_material(O3Mesh* self) {
	return self->mDefaultDirector;
}

inline void O3Mesh_setMaterial(O3Mesh* self, NSObject<O3MultipassDirector>* new_material) {
	if (new_material == self->mDefaultDirector) return;
	[self willChangeValueForKey:@"material"];
	[self->mDefaultDirector release];
	self->mDefaultDirector = [new_material retain];
	[self didChangeValueForKey:@"material"];
}

inline void initP(O3Mesh* self) {
	self->mVertexDataSources = [[NSMutableDictionary alloc] init];
}

/**********************************************/ #pragma mark Initialization /**********************************************/
- (id)init {
	O3SuperInitOrDie();
	initP(self);
	return self;
}

- (id)initWithVerticies:(O3VertexDataSource*)vertexLocations indicies:(O3VertexDataSource*)indicies primitiveType:(GLenum)primitiveType primitiveCount:(GLsizeiptr)primCount verticiesPerPrimitive:(const GLsizei*)vertsPerPrimitive primitivesHaveSameNumberVerticies:(BOOL)primitivesConstant material:(NSObject<O3MultipassDirector>*)mat {
	O3SuperInitOrDie();
	initP(self);
	setVertexLocationsP(self, vertexLocations);
	setVertexIndiciesP(self, indicies);
	mPrimitiveType = primitiveType;
	mPrimitiveCount = primCount;
	if (primitivesConstant) {
		mElementCount = *vertsPerPrimitive;
	} else {
		unsigned vertCountArraySize = sizeof(GLsizei)*primCount;
		mElementCounts = (GLsizei*)malloc(vertCountArraySize);
		memcpy(mElementCounts, vertsPerPrimitive, primCount);
	}
	O3Mesh_setMaterial(self, mat);
	return self;
}

- (void)dealloc {
	[mVertexDataSources release];
	if (mElementCounts) free(mElementCounts);
	[super dealloc];
}

/**********************************************/ #pragma mark Modifiers /**********************************************/
- (void)stripify {
	O3ToImplement();
}

/**********************************************/ #pragma mark Accessors /**********************************************/
//Many of these are pseudo-accessors that just call their inline C counterparts
- (NSObject<O3MultipassDirector>*)material {return O3Mesh_material(self);}
- (void)setMaterial:(NSObject<O3MultipassDirector>*)newMaterial {O3Mesh_setMaterial(self, newMaterial);}
- (O3VertexDataSource*)vertexLocations {return O3Mesh_vertexLocations(self);}
- (void)setVertexLocations:(O3VertexDataSource*)newVertexLocations; {setVertexLocationsP(self, newVertexLocations);}
- (GLenum)primitiveType {return mPrimitiveType;}
- (void)setPrimitiveType:(GLenum)primitiveType {mPrimitiveType=primitiveType;}
- (BOOL)primitivesHaveEqualVertexCount {return mElementCount?YES:NO;}
- (const GLsizei*)primitiveVertexCounts {return mElementCounts;}
- (NSMutableDictionary*)vertexDataSources {return mVertexDataSources;}
- (void)addVertexDataSource:(O3VertexDataSource*)source {[mVertexDataSources setObject:source forKey:[NSNumber numberWithUnsignedInt:[source type]]];}
- (O3VertexDataSource*)vertexDataSourceForType:(O3VertexDataType)type {return [mVertexDataSources objectForKey:[NSNumber numberWithUnsignedInt:type]];}

/************************************/ #pragma mark Use /************************************/
- (void)renderWithContext:(O3RenderContext*)context {
	//O3Optimizable()
	//Bind vertex data sources
	NSEnumerator* vdsEnum = [mVertexDataSources objectEnumerator];
	O3VertexDataSource* obj;
	while (obj=[vdsEnum nextObject]) [obj bind];
	[mVertexLocations bind];
	[mVertexIndicies bind];
	
	[mDefaultDirector beginRendering];
	int passes = [mDefaultDirector renderPasses];
	if (passes==0) passes=1;
	if (mElementCounts) {
		GLsizeiptr* indicies = new GLsizeiptr[mPrimitiveCount];
		GLsizeiptr accumulator = 0;
		indicies[0] = 0;
		int i; for (i=1;i<mPrimitiveCount;i++) indicies[i] = (accumulator+=mElementCounts[i-1]);
		for (i=0;i<passes;i++) {
			[mDefaultDirector setRenderPass:i];
			glMultiDrawElements(mPrimitiveType, mElementCounts, [mVertexIndicies type], (const void**)indicies, mPrimitiveCount);
		}
		delete[] indicies;
	} else {
		int i; for (i=0;i<passes;i++) {
			[mDefaultDirector setRenderPass:i];
			glDrawElements(mPrimitiveType, mElementCount*mPrimitiveCount, [mVertexIndicies format], [mVertexIndicies indicies]);
		}
	}
	[mDefaultDirector endRendering];
	
	//Unbind vertex data sources
	vdsEnum = [mVertexDataSources objectEnumerator];
	while (obj=[vdsEnum nextObject]) [obj unbind];
	[mVertexLocations unbind];
	[mVertexIndicies unbind];
}

/************************************/ #pragma mark KVC/KVO /************************************/
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
	if ([key isEqualToString:@"vertexLocations"]) return NO;
	if ([key isEqualToString:@"vertexIndicies"]) return NO;
	if ([key isEqualToString:@"vertexMaterial"]) return NO;
	return [super automaticallyNotifiesObserversForKey:key];
}
@end
