//
//  O3DirectoryResSource.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 9/23/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3DirectoryResSource.h"
#import "O3KeyedUnarchiver.h"
#import "O3FileResSource.h"
#import "O3ResManager.h"

@implementation O3DirectoryResSource
O3DefaultO3InitializeImplementation

- (O3DirectoryResSource*)initWithPath:(NSString*)path parentResSource:(O3ResSource*)prs {
	O3SuperInitOrDie(); //Don't mod without updating setStringValue
	mParentResSource = prs;
	[self setPath:path];
	return self;
}

- (void)dealloc {
	[mSubSources release];
	[mPath release];
	O3Destroy(mSubSourceArray);
	O3SuperDealloc();
}

- (void)subresourceDied:(O3FileResSource*)file {
	NSArray* sources = [mSubSources allKeysForObject:file];
	[mSubSources removeObjectsForKeys:sources];
}

- (O3DirectoryResSource*)initWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding]) {
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
		[self release];
		return nil;
	}
	[super initWithCoder:coder];
	[self setPath:[coder decodeObjectForKey:@"path"]];	
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding])
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
	[coder encodeObject:mPath forKey:@"path"];
}

inline NSArray* mSubSourceArrayP(O3DirectoryResSource* self) {
	if (self->mSubSourceArray) return self->mSubSourceArray;
	O3Assign([self->mSubSources allValues], self->mSubSourceArray);
	return self->mSubSourceArray;
}


/************************************/ #pragma mark O3ResSource stuff /************************************/
- (BOOL)handleLoadRequest:(NSString*)requestedObject fromManager:(O3ResManager*)rm tryAgain:(BOOL*)ta {
	if (ta) *ta = NO;
	NSArray* ssrcs = mSubSourceArrayP(self);
	BOOL primary_success = O3ResSourcesLoadNamed_fromPreloadCache_orSources_intoManager_(requestedObject, nil, ssrcs, rm);
	if (primary_success) return YES;
	if (![self updatePaths]) return NO;
	BOOL secondary_success = O3ResSourcesLoadNamed_fromPreloadCache_orSources_intoManager_(requestedObject, nil, ssrcs, rm);
	return secondary_success;
}

- (double)searchPriorityForObjectNamed:(NSString*)key {
	NSEnumerator* ssEnumerator = [mSubSourceArrayP(self) objectEnumerator];
	double max = 0; //Can't be negative, or we will never try to load and paths will never be updated
	while (O3ResSource* o = [ssEnumerator nextObject]) {
		max = O3Max(max, [o searchPriorityForObjectNamed:key]);
	}
	return max;
}

- (BOOL)shouldLoadLazily {
	return YES;
}

- (NSString*)path {
	return mPath;
}

- (BOOL)updatePaths {
	@try {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSFileManager* dm = [NSFileManager defaultManager];
	NSArray* subpaths = [dm subpathsAtPath:mPath];
	if (!subpaths) {
		[mParentResSource subresourceDied:self];
		return NO;
	}
	NSEnumerator* subpathsEnumerator = [subpaths objectEnumerator];
	NSMutableDictionary* newSources = [[[NSMutableDictionary alloc] init] autorelease];
	while (NSString* o = [subpathsEnumerator nextObject]) {
		NSString* path = [mPath stringByAppendingPathComponent:o];
		BOOL dir; BOOL exists = [dm fileExistsAtPath:path isDirectory:&dir];
		if (!exists) continue;
		O3ResSource* newSource = [mSubSources objectForKey:path]; //First try old source = new source
		if (!newSource) { //But if that doesn't work
			if (dir) { //Make a new subdirectory res source
				//Unneeded: each directory res source will automatically find all the files in all subdirectories
				//newSource = [[O3DirectoryResSource alloc] initWithPath:path parentResSource:self];
			} else { //Make a new file resource
				newSource = [[O3FileResSource alloc] initWithPath:path parentResSource:self];
			}
		}
		if (newSource) [newSources setObject:newSource forKey:path];
	}
	O3Assign(newSources, mSubSources);
	O3Destroy(mSubSourceArray);
	[pool release];
	} @catch (NSException* e) {}
	return YES;
}

- (void)setPath:(NSString*)path {
	O3Assign(path, mPath);
	[self updatePaths];
}

- (NSArray*)resourceSources {
	return mSubSourceArrayP(self);
}

/************************************/ #pragma mark Bindings /************************************/
- (NSString*)stringValue {
	return mPath;
}

- (void)setStringValue:(NSString*)string {
	[self setPath:string];
}

/************************************/ #pragma mark Comparison /************************************/
- (UIntP)hash {
	return [mPath hash];
}

- (BOOL)isEqual:(O3DirectoryResSource*)other {
	if (![other isKindOfClass:[O3DirectoryResSource class]]) return NO;
	return [mPath isEqual:[other path]];
}
@end
