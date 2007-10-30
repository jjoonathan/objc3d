//
//  O3Scene.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 10/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3Scene.h"
#import "O3Region.h"
#import "O3Camera.h"

@implementation O3Scene
/************************************/ #pragma mark Init & Dealloc /************************************/
- (O3Scene*)init {
	O3SuperInitOrDie();
	mRegionLock = [NSLock new];
	return self;
}

- (O3Scene*)initWithRegion:(O3Region*)root {
	O3SuperInitOrDie();
	mRegionLock = [NSLock new];
	[self setRootRegion:root];
	return self;
}

- (void)dealloc {
	[mRegionLock release];
	[mRootGroup release];
	[mRootRegion release];
	O3SuperDealloc();
}

/************************************/ #pragma mark Region Tree /************************************/
- (O3Region*)rootRegion {
	return mRootRegion;
}

- (void)setRootRegion:(O3Region*)newRoot {
	[mRegionLock lock];
	O3Assign(newRoot, mRootRegion);
	[mRegionLock unlock];
}

- (NSLock*)rootRegionLock {
	return mRegionLock;
}

/************************************/ #pragma mark Private /************************************/
- (void)subregionChanged:(O3Region*)region {
	if ([mRegionLock tryLock]) {
		O3LogWarn(@"Subregion changed while the region tree was locked!");
		[mRegionLock unlock];
	}
	mGroupsNeedUpdate = YES;
}

///A lame placeholder implementation
- (O3Group*)rootGroup {
	if (!mGroupsNeedUpdate) return mRootGroup;
	O3Assign(mRootRegion, mRootGroup);
	return mRootGroup;
}


/************************************/ #pragma mark Rendering /************************************/
- (void)renderWithContext:(O3RenderContext*)context {
	[mRegionLock lock];
	[[self rootGroup] renderWithContext:context];
	[mRegionLock unlock];
}

@end
