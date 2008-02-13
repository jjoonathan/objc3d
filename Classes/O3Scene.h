//
//  O3Scene.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 10/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3Renderable.h"
#import "O3Timer.h"
@class O3Group, O3Region, O3Camera;

///A scene contains two trees of objects. One is the region tree, which is what the user/editor sees. A region is essentially a subspace, and this allows intuitive groupings of objects. The other tree it manages is the group tree, which it is free to structure as it pleases.
///Groups are more general object collections, but are not necesarily user-visible. For instance, a scene might be divided up into a binary tree, and this binary tree would be the group tree, while a more organized structure would be the region tree.
///
///O3Scene itself doesn't do much other than call through to the root group.
@interface O3Scene : NSObject <O3Renderable, NSCoding> {
	O3Group* mRootGroup; ///<User-visible internal organization of objects
	BOOL mGroupsNeedUpdate; ///<The region tree has changed and the groups need to be updated
	O3Region* mRootRegion; ///<User-visible organization of objects
	NSMutableDictionary* mSceneState; ///<A scratch dictionary that contains stuff about the scene (maybe a history of framerate or whatever). *Will* be constant over the life of the scene.
	NSMutableArray* mRenderSteps; ///<A list of methods the scene calls on itself to render
	NSColor* mBackgroundColor;
	NSLock* mRenderLock;
	O3Timer mFrameTimer; ///<Measures the actual time between frames
	BOOL mNotFirstFrame:1;
}
//Region
- (O3Region*)rootRegion; ///<@note bu sure to obey rootRegionLock
- (void)setRootRegion:(O3Region*)newRoot;

//Rendering
- (void)renderWithContext:(O3RenderContext*)context; ///<context should only be partly filled in

//Accessors
- (NSMutableArray*)renderSteps; ///<The selectors that an O3Scene calls on itself. Will be constant over the life of the scene.
- (NSMutableDictionary*)sceneState; ///<A scratch dictionary that contains stuff about the scene (maybe a history of framerate or whatever). *Will* be constant over the life of the scene.
- (NSColor*)backgroundColor;
- (void)setBackgroundColor:(NSColor*)color;

//Private
- (void)subregionChanged:(O3Region*)region; ///<A notification from the root region that it has changed
- (O3Group*)rootGroup;
@end
