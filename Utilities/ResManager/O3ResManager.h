//
//  O3ResManager.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 9/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
@class O3ResSource;
@class O3ResManager;

extern NSString* O3ResManagerKeyWillChangeNotification;
extern NSString* O3ResManagerKeyDidChangeNotification;
extern O3ResManager* gO3ResManagerSharedInstance;
O3EXTERN_C O3ResManager* O3RMGM(); //Shortcut for the global res manager

@interface O3ResManager : NSObject {
	NSMutableArray* mResourceSources;
		NSLock* mResSourceLock;
	NSMutableDictionary* mObjectsForNames;
	O3ResManager* mParentManager;
	BOOL mEncodedAsShared; ///<YES if this should be encoded/decoded as the shared instance (used for archiving)

	NSMutableDictionary* mPreloadedObjects; ///<Objects that were loaded but not requested (yet)
	NSMutableArray* mLoadRequests;
	
	NSMutableDictionary* mObserverCount; ///<A dictionary of NSNumbers with the number of observers for each key
	NSMutableArray* mFreeQueue; ///<A queue of object names whose bind counts have dropped to zero and need to be freed
	int mNumThreads, mTargetNumThreads;
}
+ (void)o3init;

//Construction
- (O3ResManager*)init;
+ (O3ResManager*)sharedManager;
+ (O3ResManager*)gm; //GlobalManager: shortcut for sharedManager

//KVC
- (NSArray*)allKeys;
- (void)setValue:(id)obj forKey:(NSString*)key; ///<Adds a value to the receiver, but doesn't add it to the garbage collector unless someone binds to it. It is then removed if the binding reference count becomes 0.
- (id)valueForKey:(NSString*)key; ///<Returns the value for the presently loaded %key, possibly nil, even if the value is in a resource source. 
- (void)addObjects:(NSDictionary*)objs;

//Loading (don't call, use values by binding to them)
- (void)requestResNamed:(NSString*)resName; ///<Adds resName to the queue of resources to load
- (BOOL)loadResourceNamed:(NSString*)resName; ///<Searches for, loads, and returns resName (nil if not found) after adding it to the receiver.
- (void)addPreloadedObject:(id)obj forKey:(NSString*)k; ///<Called by res sources who un-lazily load objects. If an object is found in the preload cache when it comes time to load it, it is simply promoted into the regular list of stuff.

//Misc
- (O3ResManager*)parentManager;
- (void)setParentManager:(O3ResManager*)newParent;
- (int)numThreads;
- (void)setNumThreads:(int)nt;

//Resource Source Management
- (void)addResourceSource:(O3ResSource*)s;
- (void)insertResourceSource:(O3ResSource*)s atIndex:(UIntP)i;
- (O3ResSource*)resourceSourceAtIndex:(UIntP)i;
- (UIntP)indexOfResourceSource:(O3ResSource*)s;
- (void)removeResourceSourceAtIndex:(UIntP)i;
- (NSArray*)resourceSources;
- (void)setResourceSources:(NSArray*)newResourceSources;

- (void)setResourceSourcesPaths:(NSArray*)pathDicts; ///<Creates new directory res saurces for all paths in pathDicts.path, and then replaces all sources in mResourceSources with them (excluding duplicates)
@end

@interface O3ResManager (IBAdditions)
- (BOOL)encodedAsShared;
- (void)setEncodedAsShared:(BOOL)si;
- (BOOL)isInInterfaceBuilder;
@end

BOOL O3ResSourcesLoadNamed_fromPreloadCache_orSources_intoManager_(NSString* resName, NSMutableDictionary* preloadedObjects, NSArray* resSources, O3ResManager* targetManager);