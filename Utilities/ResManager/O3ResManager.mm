//
//  O3ResManager.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 9/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3ResManager.h"
#import "O3ResSource.h"
#import "O3DirectoryResSource.h"

NSString* O3ResManagerKeyWillChangeNotification = @"O3ResManagerKeyWillChangeNotification";
NSString* O3ResManagerKeyDidChangeNotification = @"O3ResManagerKeyDidChangeNotification";
O3ResManager* gO3ResManagerSharedInstance = nil;

@implementation O3ResManager

inline O3ResManager* O3ResManagerSharedInstanceP() {
	if (!gO3ResManagerSharedInstance) {
		gO3ResManagerSharedInstance=[[O3ResManager alloc] init];
		[gO3ResManagerSharedInstance setEncodedAsShared:YES];
	}
	return gO3ResManagerSharedInstance;
}

/************************************/ #pragma mark Construction /************************************/
- (O3ResManager*)init {
	O3SuperInitOrDie();
	mObjectsForNames = [[NSMutableDictionary alloc] init];
	mResourceSources = [[NSMutableArray alloc] init];
	return self;
}

- (O3ResManager*)initWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding]) {
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
		[self release];
		return nil;
	}
	O3SuperInitOrDie();
	mObjectsForNames = [[NSMutableDictionary alloc] init];
	NSArray* sources = [coder decodeObjectForKey:@"sources"];
	if ([coder decodeBoolForKey:@"shared"]) {
		if (![self isInInterfaceBuilder]) {
			[self release];
			O3ResManager* m = O3ResManagerSharedInstanceP();
			NSEnumerator* sourcesEnumerator = [sources objectEnumerator];
			while (O3ResSource* o = [sourcesEnumerator nextObject])
				[m addResourceSource:o];
			return [m retain];
		}
	}
	mResourceSources = [[NSMutableArray alloc] initWithArray:sources copyItems:NO];
	return self;	
}

- (void)dealloc {
	[mObjectsForNames release];
	[mResourceSources release];
	[mParentManager release];
	[super dealloc];
}

+ (O3ResManager*)sharedManager {
	return O3ResManagerSharedInstanceP();
}

/************************************/ #pragma mark Chaining /************************************/
///@warning the parent manager is retained
- (O3ResManager*)parentManager {
	return mParentManager;
}

- (void)setParentManager:(O3ResManager*)newParent {
	//Will be removing current parentManager's keys
	NSArray* keys = [mParentManager allKeys];
	NSEnumerator* keysEnumerator = [keys objectEnumerator];
	while (NSString* o = [keysEnumerator nextObject])
		[self willChangeValueForKey:o];
		
	//...and adding the new parent manager's keys
	NSArray* nkeys = [newParent allKeys];
	NSEnumerator* nkeysEnumerator = [nkeys objectEnumerator];
	while (NSString* o = [nkeysEnumerator nextObject])
		[self willChangeValueForKey:o];
		
	//We dropped the old parent, so we don't need notifications from it
	NSNotificationCenter* ncenter = [NSNotificationCenter defaultCenter];
	[ncenter removeObserver:self];
	
	O3Assign(newParent, mParentManager);
	
	[ncenter addObserver:self selector:@selector(keysWillChange:) name:O3ResManagerKeyWillChangeNotification object:newParent];
	[ncenter addObserver:self selector:@selector(keysDidChange:) name:O3ResManagerKeyDidChangeNotification object:newParent];
	
	//We addad the new parent manager's keys
	nkeysEnumerator = [nkeys objectEnumerator];
	while (NSString* o = [nkeysEnumerator nextObject])
		[self didChangeValueForKey:o];
		
	//We changed the old parent manager's keys
	keysEnumerator = [keys objectEnumerator];
	while (NSString* o = [keysEnumerator nextObject])
		[self didChangeValueForKey:o];
}

- (void)keysWillChange:(NSDictionary*)keys {
	[self willChangeValueForKey:[keys objectForKey:@""]];
}

- (void)keysDidChange:(NSDictionary*)keys {
	[self didChangeValueForKey:[keys objectForKey:@""]];
}

/************************************/ #pragma mark KVC /************************************/
- (BOOL)automaticallyNotifiesObserversForKey:(NSString*)k {
	return NO;
}

- (NSArray*)allKeys {
	NSArray* sk = [mParentManager allKeys];
	NSArray* k = [mObjectsForNames allKeys];
	return  sk? [k arrayByAddingObjectsFromArray:sk] : k;
}
	
- (void)setValue:(id)obj forKey:(NSString*)key {
	//O3Optimizeable();
	if ([super valueForKey:key]) {
		[super setValue:obj forKey:key];
		return;
	}
	NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
	NSDictionary* kdict = [NSDictionary dictionaryWithObject:key forKey:@""];
	[center postNotificationName:O3ResManagerKeyWillChangeNotification object:self userInfo:kdict];
	[self willChangeValueForKey:key];
	
	[mObjectsForNames setValue:obj forKey:key];
	
	[self didChangeValueForKey:key];
	[center postNotificationName:O3ResManagerKeyDidChangeNotification object:self userInfo:kdict];
}

int sortBySearchPriority(id l, id r, void* objname) {
	double lv = [(O3ResSource*)l searchPriorityForObjectNamed:(NSString*)objname];
	double rv = [(O3ResSource*)r searchPriorityForObjectNamed:(NSString*)objname];
	if (lv<rv) return NSOrderedAscending;
	if (rv<lv) return NSOrderedDescending;
	return NSOrderedSame;
}

- (id)valueForUndefinedKey:(NSString*)u {
	return nil;
}

- (id)valueForKey:(NSString*)key {
	id sval = [super valueForKey:key];
	if (sval) return sval;
	id val = [mObjectsForNames valueForKey:key];
	if (!val) val = [mParentManager valueForKey:key];
	if (!val) val = [self loadResourceNamed:key];
	return val;
}

- (id)valueForKeyWithoutLoading:(NSString*)key {
	id val = [mObjectsForNames valueForKey:key];
	if (!val) val = [mParentManager valueForKey:key];
	return val;
}

/************************************/ #pragma mark Resource Sources /************************************/
- (void)addResourceSource:(O3ResSource*)s {
	[mResSourceLock lock];
	NSIndexSet* index = [NSIndexSet indexSetWithIndex:[mResourceSources count]];
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:index forKey:@"resourceSources"];
	[mResourceSources addObject:s];
	[mResSourceLock unlock];
	[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:index forKey:@"resourceSources"];
}

- (void)insertResourceSource:(O3ResSource*)s atIndex:(UIntP)i  {
	NSIndexSet* index = [NSIndexSet indexSetWithIndex:i];
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:index forKey:@"resourceSources"];
	[mResSourceLock lock];
	[mResourceSources insertObject:s atIndex:i];
	[mResSourceLock unlock];
	[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:index forKey:@"resourceSources"];
}

- (O3ResSource*)resourceSourceAtIndex:(UIntP)i {
	return [mResourceSources objectAtIndex:i];
}

- (UIntP)indexOfResourceSource:(O3ResSource*)s {
	return [mResourceSources indexOfObject:s];
}

- (void)removeResourceSourceAtIndex:(UIntP)i {
	[mResSourceLock lock];
	NSIndexSet* index = [NSIndexSet indexSetWithIndex:i];
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:index forKey:@"resourceSources"];
	[mResourceSources removeObjectAtIndex:i];
	[mResSourceLock unlock];
	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:index forKey:@"resourceSources"];
}

- (void)removeResourceSource:(O3ResSource*)s {
	[mResSourceLock lock];
	UIntP idx = [mResourceSources indexOfObject:s];
	NSIndexSet* index = [NSIndexSet indexSetWithIndex:idx];	
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:index forKey:@"resourceSources"];
	[mResourceSources removeObjectAtIndex:idx];
	[mResSourceLock unlock];
	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:index forKey:@"resourceSources"];
}

- (UIntP)countOfResourceSources {
	return [mResourceSources count];
}

- (NSArray *)resourceSources {
	return mResourceSources;
}

- (void)setResourceSources:(NSArray *)newResourceSources {
	[self willChangeValueForKey:@"resourceSources"];
	[mResSourceLock lock];
	[mResourceSources setArray:newResourceSources];
	[mResSourceLock unlock];
	[self didChangeValueForKey:@"resourceSources"];
}

///@param pathDicts An array of dictionaries with key @"path" from which the new resource sources will be contsructed
- (void)setResourceSourcesPaths:(NSArray*)pathDicts {
	[self willChangeValueForKey:@"resourceSources"];
	[mResSourceLock lock];
	
	NSSet* curResSs = [[NSSet alloc] initWithArray:mResourceSources];
	NSArray* newPaths = [pathDicts valueForKeyPath:@"path"];
	NSMutableArray* newResSources = [[NSMutableArray alloc] init];
	NSEnumerator* newPathsEnumerator = [newPaths objectEnumerator];
	while (NSString* o = [newPathsEnumerator nextObject]) {
		O3DirectoryResSource* nResS = [[O3DirectoryResSource alloc] initWithPath:o];
		O3DirectoryResSource* oResS = [curResSs member:nResS];
		if (oResS) [newResSources addObject:oResS];
		else       [newResSources addObject:nResS];
		[nResS release];
	}
	O3Assign(newResSources, mResourceSources);
	[newResSources release];
	[curResSs release];
	
	[mResSourceLock unlock];
	[self didChangeValueForKey:@"resourceSources"];
}

/************************************/ #pragma mark Loading /************************************/
- (id)loadResourceNamed:(NSString*)resName {
	[mResSourceLock lock];
	[mResourceSources sortUsingFunction:sortBySearchPriority context:resName];
	NSEnumerator* sourceEnum = [mResourceSources objectEnumerator];
	while (O3ResSource* s = [sourceEnum nextObject]) {
		if ([s searchPriorityForObjectNamed:resName]<0) continue;
		id obj = [s loadObjectNamed:resName intoResManager:self];
		if (obj) return obj;
	}
	[mResSourceLock unlock];
	return nil;
}

- (void)encodeWithCoder:(NSCoder*)coder {
	//[super encodeWithCoder:coder];
	if (![coder allowsKeyedCoding]) [NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
	if ([self encodedAsShared]) {
		[coder encodeBool:YES forKey:@"shared"];
		[coder encodeObject:@"YES" forKey:@"shareds"];
	}
	[coder encodeObject:mResourceSources forKey:@"sources"];
}

@end

@implementation O3ResManager (IBAdditions)
- (BOOL)encodedAsShared {
	return mEncodedAsShared;
}

- (void)setEncodedAsShared:(BOOL)si {
	mEncodedAsShared = si;
}

- (BOOL)isInInterfaceBuilder {
	return NO;
}

@end