//
//  O3FileResSource.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 9/27/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#ifdef __cplusplus
#import <map>
#endif

#import "O3ResSource.h"
#import "O3ArchiveFormat.h"

#if defined(O3AllowBSDCalls)
#include <sys/types.h>
#include <sys/stat.h>
#endif

@class O3DirectoryResSource, O3KeyedUnarchiver;

extern int gO3KeyedUnarchiverLazyThreshhold; ///1MB default for lazy loading

@interface O3FileResSource : O3ResSource {
	NSString* mPath;
#if defined(O3AllowBSDCalls)
	time_t mLastUpdatedDate;
#else
	NSDate* mLastUpdatedDate;
#endif
	O3KeyedUnarchiver* mUnarchiver;
	O3ResSource* mContainerResSource;
	NSLock* mResLock;
	
	//Info about the data itself. Kill if the file changes.
	NSString* mDomain;
	#ifdef __cplusplus
	std::vector<O3ChildEnt>* mRootEnts; //Note: these are not metadata roots, these are archive root objects
	#endif
	
	NSString* mCachedName;
	float     mCachedPriority;
	NSMutableSet* mKnownFailObjects; //Objects for whom reading failed
	BOOL mFullyLoaded:1;
	BOOL mIsBig:1; BOOL mIsBigDetermined:1;
	BOOL mRootsAreBad:1; //True if reading the whole archive threw an exception at one point
	BOOL mLoadAllIsBad:1; //True if loading all objects failed
}
- (O3FileResSource*)initWithPath:(NSString*)path parentResSource:(O3ResSource*)drs;
- (NSString*)domain;

//Private loading methods
- (id)loadObjectNamed:(NSString*)name; //Not lock protected
- (NSDictionary*)loadAllObjects; //Not lock protected

//O3ResSource abstract methods
- (double)searchPriorityForObjectNamed:(NSString*)key;
- (BOOL)handleLoadRequest:(NSString*)requestedObject fromManager:(O3ResManager*)rm tryAgain:(BOOL*)temporaryFailure;
- (BOOL)shouldLoadLazily;

- (BOOL)needsUpdate;
- (void)close;
@end

double O3FileResSourceSearchPriority(O3FileResSource* self, NSString* key);
