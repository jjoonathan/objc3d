//
//  O3DirectoryResSource.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 9/23/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3ResSource.h"

@interface O3DirectoryResSource : NSObject {
	NSString* mPath;
	NSMutableDictionary* mFileSources; ///< (NSString*)path -> (O3FileResSource*)fsource
}

@end

@interface O3FileResSource : NSObject {
	NSString* mPath;
	NSDate* mLastUpdatedDate;
	NSMutableDictionary* mKeys;
	NSString* mDomain; ///<Domain to prepend to all keys (actually domain + "_")
}
- (O3FileResSource*)initWithPath:(NSString*)path;
- (NSArray*)keys; ///<This always returns an up to date list of the keys in the file represented by the receiver.
- (NSArray*)cachedKeys; ///<The keys that have already been read and had their locations cached
- (NSString*)domain;

//Private
- (BOOL)needsUpdate;
@end