//
//  O3FileResSource.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 9/27/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3ResSource.h"
@class O3DirectoryResSource, O3KeyedUnarchiver;

extern int gO3KeyedUnarchiverLazyThreshhold; ///1MB default for lazy loading

@interface O3FileResSource : O3ResSource {
	NSString* mPath;
	NSDate* mLastUpdatedDate;
	O3KeyedUnarchiver* mUnarchiver;
	NSDictionary* mKeys;
	O3DirectoryResSource* mContainerResSource;
	
	NSString* mCachedName;
	float     mCachedPriority;
	
	BOOL mFullyLoaded:1;
	BOOL mIsBig:1; BOOL mIsBigDetermined:1;
}
- (O3FileResSource*)initWithPath:(NSString*)path parentResSource:(O3DirectoryResSource*)drs;
- (NSDictionary*)keyLocationDict; ///<A perfectly acceptable substitute for -keys, and it can be searched quicker too.
- (NSString*)domain;

//O3ResSource abstract methods
- (double)searchPriorityForObjectNamed:(NSString*)key;
- (void)loadAllObjectsInto:(O3ResManager*)manager;
- (id)loadObjectNamed:(NSString*)name;
- (BOOL)isBig;

//Semi-Private
- (BOOL)needsUpdate;
- (void)close;
@end

double O3FileResSourceSearchPriority(O3FileResSource* self, NSString* key);
