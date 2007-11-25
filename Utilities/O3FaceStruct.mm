//
//  O3FaceStruct.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3FaceStruct.h"

@implementation O3FaceStruct

- (O3FaceStruct*)initWithV1:(O3Point3f)v1 v2:(O3Point3f)v2 v3:(O3Point3f)v3 {
	O3Triangle3x3f* tri = malloc(sizeof(O3Triangle3x3f));
	*tri = {v1,v2,v3};
	return [super initWithBytesNoCopy:tri type:O3Triangle3x3fType() freeWhenDone:YES];
}

- (O3Point3f)v1 {
	O3Point3f* pts = (O3Point3f*)mBytes;
	return pts[0];
}

- (O3Point3f)v2 {
	O3Point3f* pts = (O3Point3f*)mBytes;
	return pts[1];
}

- (O3Point3f)v3 {
	O3Point3f* pts = (O3Point3f*)mBytes;
	return pts[2];
}

/*- (O3Point3f)v4 {
	O3Assert(mType==O3Triangle3x3fType);
	O3Point3f* pts = (O3Point3f*)mBytes;
	return pts[3];
}*/

@end


/************************************/ #pragma mark Defined Types /************************************/
	O3VecStructType* gO3Triangle3x3fType = nil;
	O3VecStructType* O3Triangle3x3fType() {
		if (!gO3Triangle3x3fType) {
			gO3Triangle3x3fType = [[O3VecStructType alloc] initWithElementType:O3VecStructFloatElement
			                                                      specificType:O3VecStructIndex
																		 count:9
																		  name:@"tri3x3f"];
		}
		return gO3Triangle3x3fType;
	}

	O3VecStructType* gO3IndexedTriangle3cType = nil;
	O3VecStructType* O3IndexedTriangle3cType() {
		if (!gO3IndexedTriangle3cType) {
			gO3IndexedTriangle3cType = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt8Element
			                                                           specificType:O3VecStructIndex
														            		  count:3
														            		   name:@"tri3c"];
		}
		return gO3IndexedTriangle3cType;	
	}

	O3VecStructType* gO3IndexedTriangle3sType = nil;
	O3VecStructType* O3IndexedTriangle3sType() {
		if (!gO3IndexedTriangle3sType) {
			gO3IndexedTriangle3sType = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt16Element
			                                                           specificType:O3VecStructIndex
														            		  count:3
														            		   name:@"tri3c"];
		}
		return gO3IndexedTriangle3sType;	
	}

	O3VecStructType* gO3IndexedTriangle3iType = nil;
	O3VecStructType* O3IndexedTriangle3iType() {
		if (!gO3IndexedTriangle3iType) {
			gO3IndexedTriangle3iType = [[O3VecStructType alloc] initWithElementType:O3VecStructUInt32Element
			                                                           specificType:O3VecStructIndex
														            		  count:3
														            		   name:@"tri3i"];
		}
		return gO3IndexedTriangle3iType;	
	}