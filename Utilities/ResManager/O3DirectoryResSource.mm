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

@implementation O3DirectoryResSource
O3DefaultO3InitializeImplementation

- (O3DirectoryResSource*)initWithPath:(NSString*)path {
	O3SuperInitOrDie(); //Don't mod without updating setStringValue
	[self setPath:path];
	return self;
}

- (void)dealloc {
	[mFileSources release];
	[mPath release];
	[mCacheKey release];
	[mCacheOrder release];
	O3SuperDealloc();
}

- (void)fileDidClose:(O3FileResSource*)file {
	NSArray* sources = [mFileSources allKeysForObject:file];
	[mFileSources removeObjectsForKeys:sources];
	O3Destroy(mCacheKey);
	O3Destroy(mCacheOrder);
}

- (O3DirectoryResSource*)initWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding]) {
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
		[self release];
		return nil;
	}
	[super initWithCoder:coder];
	[self setPath:[coder decodeObjectForKey:@"Path"]];	
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding])
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
	[coder encodeObject:mPath forKey:@"Path"];
}


/************************************/ #pragma mark O3ResSource stuff /************************************/
static int searchPrioritySort(O3FileResSource* l, O3FileResSource* r, void* vkey) {
	NSString* key = (NSString*)vkey;
	double ll = O3FileResSourceSearchPriority(l, key);
	double rr = O3FileResSourceSearchPriority(r, key);
	if (ll<rr) return NSOrderedDescending; //Swapped on purpose
	if (ll>rr) return NSOrderedAscending;
	return NSOrderedSame;
}

NSArray* prioritySortedFilesP(O3DirectoryResSource* self, NSString* key) {
	if (key==self->mCacheKey) return self->mCacheOrder;
	NSArray* files = [self->mFileSources allValues];
	files = [files sortedArrayUsingFunction:searchPrioritySort context:key];
	O3Assign(files, self->mCacheOrder);
	O3Assign(key, self->mCacheKey);	
	return files;
}

- (double)searchPriorityForObjectNamed:(NSString*)key {
	NSArray* files = prioritySortedFilesP(self, key);
	return [files count]? O3FileResSourceSearchPriority([files objectAtIndex:0], key) : 0;
}

- (id)loadObjectNamed:(NSString*)name {
	NSArray* files = prioritySortedFilesP(self, name);
	NSEnumerator* filesEnumerator = [files objectEnumerator];
	while (O3FileResSource* o = [filesEnumerator nextObject]) {
		id lobj = [o loadObjectNamed:name];
		if (lobj) return lobj;
		if (O3FileResSourceSearchPriority(o, name) <= 0.) return nil;
	}
	return nil;
}

- (void)loadAllObjectsInto:(O3ResManager*)manager {
	NSArray* files = [mFileSources allValues];
	NSEnumerator* filesEnumerator = [files objectEnumerator];
	while (O3FileResSource* o = [filesEnumerator nextObject]) {
		[o loadAllObjectsInto:manager];
	}
}

- (BOOL)isBig {
	return YES;
}

- (NSString*)path {
	return mPath;
}

- (void)setPath:(NSString*)path {
	if (![path isEqualToString:mPath]) {
		O3Assign(path, mPath);
		
		NSMutableDictionary* newSources = [[NSMutableDictionary alloc] init];
		NSArray* subpaths = [[NSFileManager defaultManager] subpathsAtPath:path];
		NSEnumerator* subpathsEnumerator = [subpaths objectEnumerator];
		while (NSString* p = [path stringByAppendingPathComponent:[subpathsEnumerator nextObject]]) {
			O3FileResSource* frs = [mFileSources objectForKey:p] ?: [[O3FileResSource alloc] initWithPath:p];
			[newSources setObject:frs forKey:p];
			[frs release];
		}
		
		O3Assign(newSources, mFileSources);
		[newSources release];
		[mCacheKey release];
		[mCacheOrder release];		
	}
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
