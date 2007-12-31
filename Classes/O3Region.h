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
#import "O3Locateable.h"
@class O3Scene;

@interface O3Region : O3Locateable <O3Group, O3Renderable, NSCoding> {
	O3Region* mParentRegion;
	O3Scene* mScene;
	NSMutableArray* mObjects;
}
//Init
- (O3Region*)init; ///<Creates a region without a parent node or a scene
- (O3Region*)initWithParent:(O3Region*)parent; ///<Creates a region that is a node of a larger tree of regions (parent being its parent)
- (O3Region*)initWithScene:(O3Scene*)scene; ///<Creates a region that can be the root node of %scene (does not actually set scene's root node)

//Coding
- (O3Region*)initWithCoder:(NSCoder*)coder;
- (void)encodeWithCoder:(NSCoder*)coder;

//Accessors
- (O3Scene*)scene;
- (void)setScene:(O3Scene*)scene; ///<Attaches the receiver to scene as its root node. Updates parentRegion to be nil.
- (O3Region*)parentRegion;
- (void)setParentRegion:(O3Region*)newParent; ///<Also updates scene

//Object accessors
- (void)addObject:(O3SceneObj*)aObject;
- (void)insertObject:(O3SceneObj*)aObject atIndex:(UIntP)i;
- (O3SceneObj*)objectAtIndex:(UIntP)i;
- (UIntP)indexOfObject:(O3SceneObj*)aObject;
- (void)removeObjectAtIndex:(UIntP)i;
- (NSArray*)objects;
- (void)setObjects:(NSArray*)newObjects;

//Notifications
- (void)subregionChanged:(O3Region*)region; ///<A notification that a subregion has changed (added or removed an object)

//Rendering
- (void)tickWithContext:(O3RenderContext*)context;
- (void)renderWithContext:(O3RenderContext*)context;

@end

@interface O3Locateable (O3RegionSupport)
- (void)setParentRegion:(O3Region*)newParent; ///<Default implementation sets superspace. *do* call super.
@end