//
//  O3ConcreteMesh.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3ConcreteMeshType.h"
#import "O3FaceStruct.h"
#import "O3StructType.h"

NSString* O3ConcreteMeshFaceRenderMode = @"Individual Triangles";
NSString* O3ConcreteMeshIndexedRenderMode = @"Indexed Triangles";
NSString* O3ConcreteMeshStrippedRenderMode = @"Triangle Strips";

@implementation O3ConcreteMeshType

/************************************/ #pragma mark Init /************************************/
- (O3ConcreteMesh*)initWithDataSources:(NSArray*)dataSources
				   defaultMaterialName:(NSString*)material
                                 faces:(O3FaceArray*)faces {
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
		[self setVerticies:[coder decodeObjectForKey:@"verts"] indicies:[coder decodeObjectForKey:@"indicies"]];
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
	if (!faces) O3ToImplement();
	return mFaces;
}

- (void)setFaces:(O3FaceArray*)newFaces {
	if ([newFaces structType]!=O3Triangle3x3fType()) {
		if (![newFaces setStructType:O3Triangle3x3fType()]) {
			[NSException raise:NSInvalidArgumentException format:@"%@ was not a O3Triangle3x3f struct array"];
		}
	}
	O3Assign(newFaces, mFaces);
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
	O3AssertArg(vtype==ptType && (itype==idxType1 || itype==idxType2 || itype==idxType3), @"verts must be of O3Point3fType, indicies must be of O3IndexedTriangle3?Type");
	[mFaces release];
	O3Assign(verts, mFaceVerticies);
	O3Assign(indicies, mFaceIndicies);
}

- (NSString*)renderMode {
	if (mFaces) return O3ConcreteMeshFaceRenderMode;
	if (!mStripLocations) return O3ConcreteMeshIndexedRenderMode;
	return O3ConcreteMeshStrippedRenderMode;
}

@end
