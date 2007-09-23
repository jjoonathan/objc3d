//
//  O3ResManager.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 9/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
@class O3ResSource;

@interface O3ResManager : NSObject {
	NSMutableArray* mResourceSources;
		NSLock* mResSourceLock;
	NSMutableDictionary* mObjectsForNames;
}
//Construction
- (O3ResManager*)init;
+ (O3ResManager*)sharedManager;

//KVC
- (void)setValue:(id)obj forKey:(NSString*)key;
- (id)valueForKey:(NSString*)key;
- (id)valueForKeyWithoutLoading:(NSString*)key;

//Loading
- (id)loadResourceNamed:(NSString*)resName;

//Resource Source Management
- (void)addResourceSource:(O3ResSource*)s;
- (void)insertResourceSource:(O3ResSource*)s atIndex:(unsigned int)i;
- (O3ResSource*)resourceSourceAtIndex:(unsigned int)i;
- (unsigned int)indexOfResourceSource:(O3ResSource*)s;
- (void)removeResourceSourceAtIndex:(unsigned int)i;
- (NSArray *)resourceSources;
- (void)setResourceSources:(NSArray *)newResourceSources;
@end
