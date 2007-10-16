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
	NSMutableDictionary* mFileSources; ///< (NSString*)path -> (O3FileResSource*)fsource
	
	NSString* mCacheKey;
	NSArray* mCacheOrder;
}
- (O3DirectoryResSource*)initWithPath:(NSString*)path;

//O3ResSource stuff
- (O3DirectoryResSource*)initWithCoder:(NSCoder*)coder;
- (void)encodeWithCoder:(NSCoder*)coder;
- (double)searchPriorityForObjectNamed:(NSString*)key;
- (id)loadObjectNamed:(NSString*)name;
- (void)loadAllObjectsInto:(O3ResManager*)manager;
- (BOOL)isBig; ///<Always returns YES
- (NSString*)path;
- (void)setPath:(NSString*)path;

//Notifications (used by files)
- (void)fileDidClose:(O3FileResSource*)file;
@end
