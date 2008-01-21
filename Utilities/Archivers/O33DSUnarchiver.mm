//
//  O33DSUnarchiver.m
//  ObjC3D
//
//  Created by Jonathan deWerd on 1/7/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import "O33DSUnarchiver.h"
#import "O3BufferedReader.h"
#import "O3StructArray.h"
#import "O3FaceStructType.h"
#import "O3ConcreteMeshType.h"
#import "O3MeshInstance.h"
#import "O3StructArrayVDS.h"

@implementation O33DSUnarchiver
O3DefaultO3InitializeImplementation

+ (NSArray*)quickUnarchiveFile:(NSString*)f {
	NSMutableArray* arr = [[NSMutableArray alloc] init];
	
	NSFileHandle* fd = [NSFileHandle fileHandleForReadingAtPath:f];
	O3BufferedReader r(fd);
	UIntP ct = r.ReadBytesAsUInt64(4);
	UIntP i; for (i=0; i<ct; i++) {
		NSAutoreleasePool* p = [[NSAutoreleasePool alloc] init];
		UIntP fct = 0;
		@try {
			fct = r.ReadBytesAsUInt64(4);
		} @catch (id e) {
			break;
		}
		float tok = r.ReadFloat();
		O3Asrt(O3Equals(tok,1.339,.001));
		float x = r.ReadFloat();
		float y = r.ReadFloat();
		float z = r.ReadFloat();
		float rx = r.ReadFloat();
		float ry = r.ReadFloat();
		float rz = r.ReadFloat();
		UIntP sz = fct * 3 * 3 * sizeof(float);
		NSData* d = r.ReadData(sz);
		NSData* c = r.ReadData(fct*3*3);
		O3StructArray* faces = [[O3StructArray alloc] initWithType:O3Triangle3x3fType() portableData:d];
		O3StructArray* colors = [[O3StructArray alloc] initWithType:O3RGB8Type() portableData:c];
		O3StructArrayVDS* svds = [[O3StructArrayVDS alloc] initWithStructArray:colors vertexDataType:O3ColorDataType];
		O3ConcreteMeshType* cmt = [[O3ConcreteMeshType alloc] initWithDataSources:[NSArray arrayWithObject:svds]
		                                                      defaultMaterialName:nil
		                                                                    faces:faces];
		[faces release];
		[svds release];
		O3MeshInstance* mi = [[O3MeshInstance alloc] init];
			[mi setMeshType:cmt];
			[mi setTranslation:O3Vec3d(x,y,z)];
			[mi setRotation:O3Rotation3(rx,ry,rz)];
		[arr addObject:mi];
		[cmt release];
		[mi release];
		[p release];
	}
	
	return [arr autorelease];
}

@end
