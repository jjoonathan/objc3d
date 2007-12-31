//
//  O3Scene.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 10/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3Renderable.h"
@class O3Group, O3Region, O3Camera;

///A scene contains two trees of objects. One is the region tree, which is what the user/editor sees. A region is essentially a subspace, and this allows intuitive groupings of objects. The other tree it manages is the group tree, which it is free to structure as it pleases.
///Groups are more general object collections, but are not necesarily user-visible. For instance, a scene might be divided up into a binary tree, and this binary tree would be the group tree, while a more organized structure would be the region tree.
///
///O3Scene itself doesn't do much other than call through to the root group.
@interface O3Scene : NSObject <O3Renderable, NSCoding> {
	O3Group* mRootGroup; ///<User-visible internal organization of objects
	BOOL mGroupsNeedUpdate; ///<The region tree has changed and the groups need to be updated
	O3Region* mRootRegion; ///<User-visible organization of objects
	NSLock* mRegionLock; ///<Weather or not mRootRegion can be modified
	NSMutableDictionary* mSceneState; ///<A scratch dictionary that contains stuff about the scene (maybe a history of framerate or whatever). *Will* be constant over the life of the scene.
}
//Region
- (O3Region*)rootRegion; ///<@note bu sure to obey rootRegionLock
- (NSLock*)rootRegionLock; ///<Always lock this when using rootRegion. This can be depended on to be invariant for each O3Scene (so you can cache it)
- (void)setRootRegion:(O3Region*)newRoot;

//Rendering
- (void)renderWithContext:(O3RenderContext*)context;

//Misc
///A scratch dictionary that contains stuff about the scene (maybe a history of framerate or whatever). *Will* be constant over the life of the scene.
- (NSMutableDictionary*)sceneState;

//Private
- (void)subregionChanged:(O3Region*)region; ///<A notification from the root region that it has changed
- (O3Group*)rootGroup;
@end
