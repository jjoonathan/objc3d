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

@interface O3ResManager : NSObject {
	NSMutableArray* mResourceSources;
		NSLock* mResSourceLock;
	NSMutableDictionary* mObjectsForNames;
	O3ResManager* mParentManager;
	BOOL mEncodedAsShared; ///<YES if this should be encoded/decoded as the shared instance (used for archiving)
}
//Construction
- (O3ResManager*)init;
+ (O3ResManager*)sharedManager;

//KVC
- (NSArray*)allKeys;
- (void)setValue:(id)obj forKey:(NSString*)key;
- (id)valueForKey:(NSString*)key;
- (id)valueForKeyWithoutLoading:(NSString*)key;

//Loading
- (id)loadResourceNamed:(NSString*)resName; ///Searches for, loads, and returns resName (nil if not found). This *does* add the resource to the receiver.

//Chaining
- (O3ResManager*)parentManager;
- (void)setParentManager:(O3ResManager*)newParent;

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