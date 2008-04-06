//
//  O3DirectoryResSource.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 9/23/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3ResSource.h"
@class O3KeyedUnarchiver, O3FileResSource;

@interface O3DirectoryResSource : O3ResSource {
	NSString* mPath;
	O3ResSource* mParentResSource;
	NSMutableDictionary* mSubSources; ///< (NSString*)path -> (O3ResSource*)fsource
	NSArray* mSubSourceArray;
	
	NSString* mCacheKey;
	NSArray* mCacheOrder;
}
- (O3DirectoryResSource*)initWithPath:(NSString*)path parentResSource:(O3ResSource*)prs;

//O3ResSource stuff
- (O3DirectoryResSource*)initWithCoder:(NSCoder*)coder;
- (void)encodeWithCoder:(NSCoder*)coder;
- (double)searchPriorityForObjectNamed:(NSString*)key;
- (BOOL)handleLoadRequest:(NSString*)requestedObject fromManager:(O3ResManager*)rm tryAgain:(BOOL*)ta;
- (BOOL)shouldLoadLazily; ///<Always returns YES
- (NSString*)path;
- (void)setPath:(NSString*)path;

//Notifications (used by files) and other private methods
- (void)subresourceDied:(O3FileResSource*)file; //Removes file as a res source, since it is gone now
- (BOOL)updatePaths; //Finds any previously undiscovered files and adds them. Also gets rid of files that have disappeared. Returns NO if the dir the receiver represents disappeared, and the current operation should be aborted.

//Convenience
- (NSArray*)resourceSources;
@end
