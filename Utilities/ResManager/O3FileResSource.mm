//
//  O3FileResSource.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 9/27/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3FileResSource.h"
#import "O3KeyedUnarchiver.h"
#import "O3DirectoryResSource.h"

int gO3KeyedUnarchiverLazyThreshhold = 1 * 1024 * 1024;

@implementation O3FileResSource
/************************************/ #pragma mark Private Accessors /************************************/
static O3KeyedUnarchiver* mUnarchiverP(O3FileResSource* self) {
	if (self->mUnarchiver && ![self needsUpdate]) return self->mUnarchiver;
	O3Destroy(self->mUnarchiver);
	NSFileHandle* rhandle = [NSFileHandle fileHandleForReadingAtPath:self->mPath];
	O3BufferedReader* br = new O3BufferedReader(rhandle);
	self->mUnarchiver = [[O3KeyedUnarchiver alloc] initForReadingWithReader:br deleteWhenDone:YES];
	O3Assign([NSDate date], self->mLastUpdatedDate);
	O3Destroy(self->mKeys);
	return self->mUnarchiver;
}

/************************************/ #pragma mark Init & Dealloc /************************************/
- (O3FileResSource*)initWithPath:(NSString*)path parentResSource:(O3DirectoryResSource*)drs {
	O3SuperInitOrDie();
	O3Assign(path, mPath);
	mContainerResSource = drs;
	return self;
}

- (void)dealloc {
	O3Release(mKeys);
	O3Release(mLastUpdatedDate);
	O3Release(mPath);
	O3Release(mLastUpdatedDate);
	O3Release(mUnarchiver);
	O3SuperDealloc();
}

- (NSDictionary*)keyLocationDict {
	O3KeyedUnarchiver* un = mUnarchiverP(self);
	if (mKeys) return mKeys;
	NSNumber* loc = O3CFDictionaryGetValue([un metadata], @"");
	mKeys = [un skimDictionaryAtOffset:O3NSNumberLongLongValue(loc) levelOne:YES];
	return mKeys;
}

- (NSString*)domain {
	O3KeyedUnarchiver* un = mUnarchiverP(self);
	return [un domain];
}

- (BOOL)needsUpdate {
	if (!mLastUpdatedDate) return YES;
	NSDate* modDate = [[[NSFileManager defaultManager] fileAttributesAtPath:mPath traverseLink:YES] objectForKey:NSFileModificationDate];
	if (!modDate) [self close];
	if ([mLastUpdatedDate timeIntervalSinceDate:modDate]<0) return YES;
	return NO;
}

- (void)close {
	[mContainerResSource fileDidClose:self];
}


/************************************/ #pragma mark ResSource /************************************/
double O3FileResSourceSearchPriority(O3FileResSource* self, NSString* key) {
	if (key==self->mCachedName) return self->mCachedPriority;
	self->mCachedName=key;
	NSString* domain = [self->mUnarchiver domain];
	if (domain) {
		if ([key hasPrefix:domain]) return 100;
		return 0;
	}
	if (self->mFullyLoaded) if (![self needsUpdate]) return 0;
	return self->mCachedPriority=[[domain commonPrefixWithString:[self->mPath lastPathComponent] options:0] length];	
}

- (double)searchPriorityForObjectNamed:(NSString*)key {
	return O3FileResSourceSearchPriority(self, key);
}

- (void)loadAllObjectsInto:(O3ResManager*)manager {
	if (mFullyLoaded) if (![self needsUpdate]) return;
	O3KeyedUnarchiver* un = mUnarchiverP(self);
	O3Assign([un readAndLoadIntoManager:manager returnDummyDict:YES],mKeys);
	O3Destroy(mUnarchiver); //After we have read it we can close it
	mFullyLoaded = YES;
}

- (id)loadObjectNamed:(NSString*)name {
	if (mFullyLoaded) if (![self needsUpdate]) O3LogWarn(@"Something strange happened in %@. It was supposedly loaded, but some object was missing, apparently", self);
	O3KeyedUnarchiver* un = mUnarchiverP(self);
	NSNumber* offs = [[self keyLocationDict] objectForKey:name];
	if (!offs) return nil;
	if ((NSNull*)offs==O3NSNull()) {
		O3Destroy(mKeys);
		offs = [[self keyLocationDict] objectForKey:name];
		if (!offs) return nil;
	}
	return [un readObjectAtOffset:O3NSNumberLongLongValue(offs)];
}

- (BOOL)isBig {
	if (mIsBigDetermined) return mIsBig;
	UIntP size = O3NSNumberLongLongValue([[[NSFileManager defaultManager] fileAttributesAtPath:mPath traverseLink:YES] objectForKey:NSFileSize]);
	mIsBig = size>gO3KeyedUnarchiverLazyThreshhold;
	return mIsBig;
}

@end