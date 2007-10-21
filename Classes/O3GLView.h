//
//  O3GLView.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 10/18/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
@class O3ResManager, O3Camera;

@interface O3GLView : NSOpenGLView {
	O3ResManager* mResManager;
	NSString* mSceneName;
	O3Camera* mCamera;
}

@end
