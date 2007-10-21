//
//  O3Region.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 10/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3Group.h"
#import "O3Scene.h"
#import "O3Space.h"
@class O3Scene;
using namespace ObjC3D::Math;

@interface O3Region : O3Group {
	O3Region* mParentRegion;
	O3Scene* mScene;
	Space3 mSpace;
}

@end
