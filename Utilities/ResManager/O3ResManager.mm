//
//  O3ResManager.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 9/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3ResManager.h"
#import "O3ResSource.h"

O3ResManager* gO3ResManagerSharedInstance = nil;

@implementation O3ResManager
/************************************/ #pragma mark Construction /************************************/
- (O3ResManager*)init {
	O3SuperInitOrDie();
	mObjectsForNames = [[NSMutableDictionary alloc] init];
	mResourceSources = [[NSMutableArray alloc] init];
	return self;
}

- (void)dealloc {
	[mObjectsForNames release];
	[mResourceSources release];
	[super dealloc];
}

+ (O3ResManager*)sharedManager {
	return gO3ResManagerSharedInstance ?: gO3ResManagerSharedInstance=[[self alloc] init];
}



/************************************/ #pragma mark KVC /************************************/
- (BOOL)automaticallyNotifiesObserversForKey:(NSString*)k {
	return NO;
}
	
- (void)setValue:(id)obj forKey:(NSString*)key {
	[self willChangeValueForKey:key];
	[mObjectsForNames setValue:obj forKey:key];
	[self didChangeValueForKey:key];
}

int sortBySearchPriority(id l, id r, void* objname) {
	double lv = [(O3ResSource*)l searchPriorityForObjectNamed:(NSString*)objname];
	double rv = [(O3ResSource*)r searchPriorityForObjectNamed:(NSString*)objname];
	if (lv<rv) return NSOrderedAscending;
	if (rv<lv) return NSOrderedDescending;
	return NSOrderedSame;
}

- (id)valueForKey:(NSString*)key {
	id val = [mObjectsForNames valueForKey:key];
	if (!val) val = [self loadResourceNamed:key];
	return val;
}

- (id)valueForKeyWithoutLoading:(NSString*)key {
	return [mObjectsForNames valueForKey:key];
}

/************************************/ #pragma mark Resource Sources /************************************/
- (void)addResourceSource:(O3ResSource*)s {
	NSIndexSet* index = [NSIndexSet indexSetWithIndex:[mResourceSources count]];
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:index forKey:@"resourceSources"];
	[mResourceSources addObject:s];
	[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:index forKey:@"resourceSources"];
}

- (void)insertResourceSource:(O3ResSource*)s atIndex:(unsigned int)i  {
	NSIndexSet* index = [NSIndexSet indexSetWithIndex:i];
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:index forKey:@"resourceSources"];
	[mResourceSources insertObject:s atIndex:i];
	[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:index forKey:@"resourceSources"];
}

- (O3ResSource*)resourceSourceAtIndex:(unsigned int)i {
	return [mResourceSources objectAtIndex:i];
}

- (unsigned int)indexOfResourceSource:(O3ResSource*)s {
	return [mResourceSources indexOfObject:s];
}

- (void)removeResourceSourceAtIndex:(unsigned int)i {
	NSIndexSet* index = [NSIndexSet indexSetWithIndex:i];
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:index forKey:@"resourceSources"];
	[mResourceSources removeObjectAtIndex:i];
	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:index forKey:@"resourceSources"];
}

- (void)removeResourceSource:(O3ResSource*)s {
	UIntP idx = [mResourceSources indexOfObject:s];
	NSIndexSet* index = [NSIndexSet indexSetWithIndex:idx];	
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:index forKey:@"resourceSources"];
	[mResourceSources removeObjectAtIndex:idx];
	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:index forKey:@"resourceSources"];
}

- (unsigned int)countOfResourceSources {
	return [mResourceSources count];
}

- (NSArray *)resourceSources {
	return mResourceSources;
}

- (void)setResourceSources:(NSArray *)newResourceSources {
	[self willChangeValueForKey:@"resourceSources"];
	[mResourceSources setArray:newResourceSources];
	[self didChangeValueForKey:@"resourceSources"];
}

/************************************/ #pragma mark Loading /************************************/
- (id)loadResourceNamed:(NSString*)resName {
	[mResSourceLock lock];
	[mResourceSources sortUsingFunction:sortBySearchPriority context:resName];
	NSEnumerator* sourceEnum = [mResourceSources objectEnumerator];
	while (O3ResSource* s = [sourceEnum nextObject]) {
		if ([s searchPriorityForObjectNamed:resName]<0) continue;
		id obj = [s tryToLoadObjectNamed:resName intoResManager:self sideEffects:YES];
		if (obj) return obj;
	}
	[mResSourceLock unlock];
	return nil;
}

@end
