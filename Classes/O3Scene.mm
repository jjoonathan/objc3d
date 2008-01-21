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
O3DefaultO3InitializeImplementation
/************************************/ #pragma mark Init & Dealloc /************************************/
inline void initP(O3Scene* self) {
	self->mSceneState = [[NSMutableDictionary alloc] init];
}

- (O3Scene*)init {
	O3SuperInitOrDie(); initP(self);
	O3Region* rr = [[O3Region alloc] init];
	[self setRootRegion:rr];
	[rr release];
	return self;
}

- (O3Scene*)initWithRegion:(O3Region*)root {
	O3SuperInitOrDie(); initP(self);
	[self setRootRegion:root];
	return self;
}

- (id)initWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding]) {
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
		[self release];
		return nil;
	}
	O3Region* rr = [coder decodeObjectForKey:@"rootRegion"];
	return [self initWithRegion:rr];
}

- (void)encodeWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding])
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
	[coder encodeObject:mRootRegion forKey:@"rootRegion"];
}

- (void)dealloc {
	[mRootGroup release];
	[mRootRegion release];
	[mSceneState release];
	O3SuperDealloc();
}

/************************************/ #pragma mark Misc /************************************/
- (NSMutableDictionary*)sceneState {
	return mSceneState;
}

/************************************/ #pragma mark Region Tree /************************************/
- (O3Region*)rootRegion {
	return mRootRegion;
}

- (void)setRootRegion:(O3Region*)newRoot {
	O3Assign(newRoot, mRootRegion);
	[newRoot setScene:self];
}

/************************************/ #pragma mark Private /************************************/
- (void)subregionChanged:(O3Region*)region {
	mGroupsNeedUpdate = YES;
}

///A lame placeholder implementation
- (O3Group*)rootGroup {
	if (!mGroupsNeedUpdate &&mRootGroup) return mRootGroup;
	O3Assign(mRootRegion, mRootGroup);
	return mRootGroup;
}


/************************************/ #pragma mark Rendering /************************************/
- (void)renderWithContext:(O3RenderContext*)context {
	[[self rootGroup] renderWithContext:context];
}

- (void)tickWithContext:(O3RenderContext*)context {
	[[self rootGroup] tickWithContext:context];
}

/************************************/ #pragma mark Convenience /************************************/
- (void)addObject:(id<O3Renderable, NSObject>)obj {
	[[self rootRegion] addObject:obj];
}

@end
