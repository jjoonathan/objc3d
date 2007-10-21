//
//  O3Group.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 10/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
@class O3Camera;

@interface O3Group : NSObject {
	NSMutableArray* objects;
}

//Drawing
- (void)drawWithCamera:(O3Camera*)camera;

@end
