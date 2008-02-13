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
	self->mRenderSteps = [[NSMutableArray alloc] initWithObjects:@"tick:", @"clear:", @"drawObjects:", @"flush", nil];
	self->mRenderLock = [[NSLock alloc] init];
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
	id slf = [self initWithRegion:rr]; if (!slf) return nil;
	[mRenderSteps setArray:[coder decodeObjectForKey:@"renderSteps"]];
	[self setBackgroundColor:[coder decodeObjectForKey:@"background"]];
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding])
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
	[coder encodeObject:mRootRegion forKey:@"rootRegion"];
	[coder encodeObject:mRenderSteps forKey:@"renderSteps"];
	[coder encodeObject:mBackgroundColor forKey:@"background"];
}

- (void)dealloc {
	[mRenderLock release];
	[mRenderSteps release];
	[mRootGroup release];
	[mRootRegion release];
	[mSceneState release];
	O3SuperDealloc();
}

/************************************/ #pragma mark Misc /************************************/
- (NSMutableDictionary*)sceneState {
	return mSceneState;
}

- (NSMutableArray*)renderSteps {
	return mRenderSteps;
}

- (NSColor*)backgroundColor {
	return mBackgroundColor;
}

- (void)setBackgroundColor:(NSColor*)color {
	O3Assign(color, mBackgroundColor);
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
	if (mNotFirstFrame) {
		context->elapsedTime = 0;
		mNotFirstFrame = YES;
		O3StartTimer(mFrameTimer);
	} else {
		context->elapsedTime = O3ElapsedTime(mFrameTimer);
		O3StartTimer(mFrameTimer);
	}
	[context->glContext makeCurrentContext];
	[context->camera setProjectionMatrix];
	NSEnumerator* mRenderStepsEnumerator = [mRenderSteps objectEnumerator];
	while (NSString* step = (NSString*)[mRenderStepsEnumerator nextObject]) {
		SEL stepsel = NSSelectorFromString(step);
		[self performSelector:stepsel withObject:(id)context];
	}
}

- (void)tickWithContext:(O3RenderContext*)ctx {O3Asrt(NO);}

- (void)tick:(O3RenderContext*)ctx {
	[ctx->camera tickWithContext:ctx];
	[[self rootGroup] tickWithContext:ctx];
}

- (void)drawObjects:(O3RenderContext*)ctx {
	[[self rootGroup] renderWithContext:ctx];
}

- (void)clear:(O3RenderContext*)ctx {
	if (!mBackgroundColor) return;
	float r=0.; float g=0.; float b=0.; float a=1.;
	[mBackgroundColor getRed:&r green:&g blue:&b alpha:&a];
	glClearColor(r,g,b,a);
	glEnable(GL_DEPTH_TEST);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_ACCUM_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
}

- (void)flush:(O3RenderContext*)ctx {
	[ctx->glContext flushBuffer];
}

/************************************/ #pragma mark Convenience /************************************/
- (void)addObject:(id<O3Renderable, NSObject>)obj {
	[[self rootRegion] addObject:obj];
}

@end
