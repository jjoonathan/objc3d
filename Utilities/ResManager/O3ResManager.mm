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
#import "O3Num.h"

NSString* O3ResManagerKeyWillChangeNotification = @"O3ResManagerKeyWillChangeNotification";
NSString* O3ResManagerKeyDidChangeNotification = @"O3ResManagerKeyDidChangeNotification";
O3ResManager* gO3ResManagerSharedInstance = nil;

@implementation O3ResManager
O3DefaultO3InitializeImplementation

inline O3ResManager* O3ResManagerSharedInstanceP() {
	return gO3ResManagerSharedInstance;
}

O3EXTERN_C O3ResManager* O3RMGM() {
	return gO3ResManagerSharedInstance;
}

+ (void)o3init {
	gO3ResManagerSharedInstance=[[O3ResManager alloc] init];
	[gO3ResManagerSharedInstance setEncodedAsShared:YES];
	NSString* resDir = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"o3stdlib"];
	O3DirectoryResSource* stdlib = [[O3DirectoryResSource alloc] initWithPath:resDir parentResSource:nil];
	[gO3ResManagerSharedInstance addResourceSource:stdlib];
	[stdlib release];
}

inline void spawnNewLoaderThread(O3ResManager* self) {
	self->mNumThreads++;
	[NSThread detachNewThreadSelector:@selector(resourceLoaderThread:) toTarget:self withObject:nil];
}

/************************************/ #pragma mark Construction /************************************/
- (O3ResManager*)init {
	O3SuperInitOrDie();
	mObjectsForNames = [[NSMutableDictionary alloc] init];
	mResourceSources = [[NSMutableArray alloc] init];
	mObserverCount = [[NSMutableDictionary alloc] init];
	mFreeQueue = [[NSMutableArray alloc] init];
	mLoadRequests = [[NSMutableArray alloc] init];
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
	mObserverCount = [[NSMutableDictionary alloc] init];
	mFreeQueue = [[NSMutableArray alloc] init];
	mLoadRequests = [[NSMutableArray alloc] init];
	return self;	
}

- (void)dealloc {
	[mObjectsForNames release];
	[mResourceSources release];
	[mParentManager release];
	[mObserverCount release];
	[mFreeQueue release];
	[mLoadRequests release];
	[super dealloc];
}

+ (O3ResManager*)sharedManager {
	return O3ResManagerSharedInstanceP();
}

+ (O3ResManager*)gm {
	return O3ResManagerSharedInstanceP();
}

/************************************/ #pragma mark Chaining /************************************/
///@warning the parent manager is retained
- (O3ResManager*)parentManager {
	return mParentManager;
}

- (void)setParentManager:(O3ResManager*)newParent {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	//Send out notifications for all changing keys
	NSMutableSet* changingKeys = [NSMutableSet setWithArray:[mParentManager allKeys]];
	[changingKeys addObjectsFromArray:[newParent allKeys]];
	NSEnumerator* changingKeysEnum = [changingKeys objectEnumerator];
	while (NSString* o = [changingKeysEnum nextObject])
		[self willChangeValueForKey:o];
		
	//We dropped the old parent, so we don't need notifications from it
	NSNotificationCenter* ncenter = [NSNotificationCenter defaultCenter];
	[ncenter removeObserver:self];
	
	O3Assign(newParent, mParentManager);
	
	[ncenter addObserver:self selector:@selector(keysWillChange:) name:O3ResManagerKeyWillChangeNotification object:newParent];
	[ncenter addObserver:self selector:@selector(keysDidChange:) name:O3ResManagerKeyDidChangeNotification object:newParent];
	
	//Send out notifications for all keys that changed
	changingKeysEnum = [changingKeys objectEnumerator];
	while (NSString* o = [changingKeysEnum nextObject])
		[self willChangeValueForKey:o];
		
	[pool release];
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

//Flipped so that the array is sorted into descending priority
int sortBySearchPriority(id l, id r, void* objname) {
	double lv = [(O3ResSource*)l searchPriorityForObjectNamed:(NSString*)objname];
	double rv = [(O3ResSource*)r searchPriorityForObjectNamed:(NSString*)objname];
	if (lv>rv) return NSOrderedAscending;
	if (rv>lv) return NSOrderedDescending;
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
	return val;
}

- (void)addObjects:(NSDictionary*)objs {
	NSEnumerator* keyEnumerator = [objs keyEnumerator];
	NSEnumerator* objEnumerator = [objs objectEnumerator];
	while (id k = [keyEnumerator nextObject]) {
		id o = [objEnumerator nextObject];
		[self setValue:o forKey:k];
	}
}

- (void)addObserver:(NSObject *)anObserver forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
	NSString* objName = keyPath;
	O3Num* ct = [mObserverCount objectForKey:objName];
	if (!ct) [mObserverCount setObject:ct=[[O3Num alloc] initWithInt:0] forKey:objName];
	O3NumInc(ct);
	[super addObserver:anObserver forKeyPath:keyPath options:options context:context];
	if (![mObjectsForNames objectForKey:objName]) [self requestResNamed:objName];
}

- (void)removeObserver:(NSObject *)anObserver forKeyPath:(NSString *)keyPath {
	const char* str = [keyPath UTF8String];
	int dotidx = -1;
	for (int i=0; str[i]; i++) if (str[i]!='.') dotidx=i;
	NSString* objName = keyPath;
	if (dotidx!=-1) {
		char* smallstr = (char*)malloc(dotidx+1);
		memcpy(smallstr, str, dotidx);
		smallstr[dotidx+1] = 0;
		keyPath = NSStringWithUTF8StringNoCopy(smallstr, dotidx, YES);
	}
	
	O3Num* ct = [mObserverCount objectForKey:objName];
	if (!ct) {
		O3LogWarn(@"We shouldn't be removing an observer that was never added...");
	} else {
		if (!O3NumDec(ct)) [mFreeQueue addObject:objName];
	}
	[super removeObserver:anObserver forKeyPath:keyPath];
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
	//[[[mResourceSources objectAtIndex:i] retain] autorelease];
	[mResourceSources removeObjectAtIndex:i];
	[mResSourceLock unlock];
	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:index forKey:@"resourceSources"];
}

- (void)removeResourceSource:(O3ResSource*)s {
	[mResSourceLock lock];
	UIntP idx = [mResourceSources indexOfObject:s];
	if (idx==NSNotFound) {
		O3Asrt(false /*Could not locate res source for removal*/);
		return;
	}
	NSIndexSet* index = [NSIndexSet indexSetWithIndex:idx];	
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:index forKey:@"resourceSources"];
	//[[s retain] autorelease];
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
	//NSEnumerator* mResourceSourcesEnumerator = [mResourceSources objectEnumerator];
	//while (id o = [mResourceSourcesEnumerator nextObject]) [[o retain] autorelease];
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
		O3DirectoryResSource* nResS = [[O3DirectoryResSource alloc] initWithPath:o parentResSource:nil];
		O3DirectoryResSource* oResS = [curResSs member:nResS];
		if (oResS) [newResSources addObject:oResS];
		else       [newResSources addObject:nResS];
		[nResS release];
	}
	//NSEnumerator* mResourceSourcesEnumerator = [mResourceSources objectEnumerator];
	//while (id o = [mResourceSourcesEnumerator nextObject]) [[o retain] autorelease];
	O3Assign(newResSources, mResourceSources);
	[newResSources release];
	[curResSs release];
	
	[mResSourceLock unlock];
	[self didChangeValueForKey:@"resourceSources"];
}

/************************************/ #pragma mark Loading /************************************/
- (void)requestResNamed:(NSString*)resName {
	[mLoadRequests addObject:resName];
	if (!mNumThreads) [self setNumThreads:1];
}

- (BOOL)loadResourceNamed:(NSString*)resName {
	return O3ResSourcesLoadNamed_fromPreloadCache_orSources_intoManager_(resName, mPreloadedObjects, mResourceSources, self);
}

BOOL O3ResSourcesLoadNamed_fromPreloadCache_orSources_intoManager_(NSString* resName, NSMutableDictionary* preloadedObjects, NSArray* resSources, O3ResManager* targetManager) {
	BOOL ret = NO;
	id preloadedVal = [preloadedObjects valueForKey:resName];
	if (preloadedVal) {
		[targetManager setValue:preloadedVal forKey:resName];
		[preloadedObjects removeObjectForKey:resName];
		return YES;
	}
	
	NSArray* reses = [resSources sortedArrayUsingFunction:sortBySearchPriority context:resName];
	
	NSMutableSet* second_try_reses = [[NSMutableSet alloc] init];
	NSEnumerator* sourceEnum = [reses objectEnumerator];
	while (1) {
		O3ResSource* s = [sourceEnum nextObject];
		if (!s) {
			if ([second_try_reses count]) {
				s = [(sourceEnum=[second_try_reses objectEnumerator]) nextObject];
			} else goto end;			
		}
		BOOL success=NO; BOOL temporaryFailure=NO;
		if ([s searchPriorityForObjectNamed:resName]<0) goto permanent_failure;
		success = [s handleLoadRequest:resName fromManager:targetManager tryAgain:&temporaryFailure];
		if (success) O3Return(YES);
		if (temporaryFailure) {
			[second_try_reses addObject:s]; 
			continue;
		}
		
		permanent_failure:
		if ([second_try_reses containsObject:s]) [second_try_reses removeObject:s];
	}
	
	end:
	[second_try_reses release];
	return ret;
}

//Flipped, so that ascending sort places highest priority first
int O3ResManagerResPrioritySort(NSString* l, NSString* r, void* context) {
	NSDictionary* obsct = ((O3ResManager*)context)->mObserverCount;
	O3Num* lv = [obsct objectForKey:l];
	O3Num* rv = [obsct objectForKey:r];
	if (!lv || !rv) return NSOrderedSame;
	UIntP lc = O3NumInt64Value(lv);
	UIntP rc = O3NumInt64Value(rv);
	if (lc>rc) return NSOrderedAscending;
	if (rc>lc) return NSOrderedDescending;
	return NSOrderedSame;
}

- (void)resourceLoaderThread:(id)obj {
	int counter=0;
	while (1) { //Continuously try to load stuff
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		[mLoadRequests sortUsingFunction:O3ResManagerResPrioritySort context:NULL];
		NSEnumerator* mLoadRequestsEnumerator = [mLoadRequests objectEnumerator];
		UIntP failures = 0;
		while (NSString* o = [mLoadRequestsEnumerator nextObject]) { //Loop through each object
			NSAutoreleasePool* p2 = nil;
			@try {
				p2 = [[NSAutoreleasePool alloc] init];
				BOOL success = [self loadResourceNamed:o];
				if (!success) failures++;
				counter++;
				if (!(counter&7)) {
					if (mNumThreads<mTargetNumThreads) {spawnNewLoaderThread(self);}
					if (mNumThreads>mTargetNumThreads) goto end;
				}
			} @catch (NSException* e) {
				O3LogDebug(@"Loading exception ignored: %@", e);
			} @finally {
				[p2 release];
			}
		}
		if (mNumThreads<mTargetNumThreads) {spawnNewLoaderThread(self);}
		if (mNumThreads>mTargetNumThreads) goto end;
		[pool release];
		if (failures==[mLoadRequests count]) sleep(1); //So that we don't hammer away on things that aren't there
	}
	
	end:
	mNumThreads--;
}

- (void)addPreloadedObject:(id)obj forKey:(NSString*)k {
	[mPreloadedObjects setValue:obj forKey:k];
}

- (void)encodeWithCoder:(NSCoder*)coder {
	//[super encodeWithCoder:coder];
	if (![coder allowsKeyedCoding]) [NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
	if ([self encodedAsShared]) {
		[coder encodeBool:YES forKey:@"shared"];
	}
	[coder encodeObject:mResourceSources forKey:@"sources"];
}

- (int)numThreads {return mTargetNumThreads;}
- (void)setNumThreads:(int)nt {mTargetNumThreads = nt; if (!mNumThreads) spawnNewLoaderThread(self);}

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