//
//  O3Region.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 10/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3Region.h"

@implementation O3Locateable (O3RegionSupport)
- (void)setParentRegion:(O3Region*)newParent {
	[self setSuperspaceToThatOfLocateable:newParent];	
}
@end

@implementation NSObject (O3RegionSupport)
- (void)setParentRegion:(O3Region*)newParent {
}
@end

@implementation O3Region
O3DefaultO3InitializeImplementation
inline void changed(O3Region* self) {
	if (self->mParentRegion) [self->mParentRegion subregionChanged:self];
	else [self->mScene subregionChanged:self];
}

/************************************/ #pragma mark Init /************************************/
- (O3Region*)init {
	O3SuperInitOrDie();
	mObjects = [[NSMutableArray alloc] init];
	return self;
}

- (O3Region*)initWithParent:(O3Region*)parent {
	O3SuperInitOrDie();
	[self setParentRegion:parent];
	mObjects = [[NSMutableArray alloc] init];
	return self;
}

- (O3Region*)initWithScene:(O3Scene*)scene {
	O3SuperInitOrDie();
	[self setScene:scene];
	mObjects = [[NSMutableArray alloc] init];
	return self;
}

- (O3Region*)initWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding]) {
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
		[self release];
		return nil;
	}
	[super initWithCoder:coder];
	mObjects = [[coder decodeObjectForKey:@"objects"] mutableCopy];
	[mObjects makeObjectsPerformSelector:@selector(setParentRegion:) withObject:self];
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding])
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
	[super encodeWithCoder:coder];
	[coder encodeObject:mObjects forKey:@"objects"];
}

- (void)dealloc {
	[mObjects release];
	O3SuperDealloc();
}

/************************************/ #pragma mark Accessors /************************************/
- (O3Scene*)scene {
	return mScene;
}

- (O3Region*)parentRegion {
	return mParentRegion;
}

///Sets the new parent region, removes self from the old parent region if necessary, and updates superspace and scene. Does not add self to newParent though (this method is called in response to addition)
- (void)setParentRegion:(O3Region*)newParent {
	[mParentRegion removeObjectAtIndex:[mParentRegion indexOfObject:self]];
	mParentRegion=newParent;
	mScene=[newParent scene];
	[super setParentRegion:newParent];
}

- (void)setScene:(O3Scene*)scene {
	[self setParentRegion:nil]; //Clears mScene, so we do this first
	mScene=scene;
}


/************************************/ #pragma mark Objects Accessors /************************************/
#ifdef O3DEBUG
#define O3CheckRenderable(obj) if (![(NSObject*)obj conformsToProtocol:@protocol(O3Renderable)]) {O3Assert(NO, @"Object %@ does not conform to O3Renderable protocol.", obj);	 return;}
#else
#define O3CheckRenderable(obj)
#endif
///Adds aObject and sets its superspace to self
///@warning DO NOT add an O3Region. Use its setParentRegion method instead
- (void)addObject:(O3SceneObj*)aObject {
	O3CheckRenderable(aObject);
	[mObjects addObject:aObject];
	[aObject setParentRegion:self];
	changed(self);
}

- (void)addObjects:(NSArray*)objs {
	#ifdef O3DEBUG
	NSEnumerator* mObjectsEnumerator = [mObjects objectEnumerator];
	while (id o = [mObjectsEnumerator nextObject]) O3CheckRenderable(o);
	#endif
	[mObjects addObjectsFromArray:objs];
}

- (void)insertObject:(O3SceneObj*)aObject atIndex:(UIntP)i  {
	[mObjects insertObject:aObject atIndex:i];
	[aObject setParentRegion:self];
	changed(self);
}

- (O3SceneObj*)objectAtIndex:(UIntP)i {
	return [mObjects objectAtIndex:i];
}

- (UIntP)indexOfObject:(O3SceneObj*)aObject {
	return [mObjects indexOfObject:aObject];
}

///Removes the object at index i but does not call setParentRegion:
- (void)removeObjectAtIndex:(UIntP)i {
	[mObjects removeObjectAtIndex:i];
	changed(self);
}

///Removes aObject but does not call setParentRegion:
- (void)removeObject:(O3SceneObj*)aObject {
	[mObjects removeObject:aObject];
	changed(self);
}

- (UIntP)countOfObjects {
	return [mObjects count];
}

- (NSArray*)objects {
	return mObjects;
}

- (void)setObjects:(NSArray*)newObjects {
	[mObjects setArray:newObjects];
	[newObjects makeObjectsPerformSelector:@selector(setParentRegion:) withObject:self];
	changed(self);
}

- (void)renderWithContext:(O3RenderContext*)context {
	O3AssertIvar(mObjects);
	[mObjects makeObjectsPerformSelector:@selector(renderWithContext:) withObject:(id)context]; //Bad, but it should work. context isn't a real object.
}

- (void)tickWithContext:(O3RenderContext*)context {
	[mObjects makeObjectsPerformSelector:@selector(tickWithContext:) withObject:(id)context]; //Bad, but it should work. context isn't a real object.
}


/************************************/ #pragma mark Notifications /************************************/
- (void)subregionChanged:(O3Region*)region {
	changed(self);
}

@end
