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
#import "O3ResManager.h"

int gO3KeyedUnarchiverLazyThreshhold = 1 * 1024 * 1024;

@implementation O3FileResSource
O3DefaultO3InitializeImplementation
/************************************/ #pragma mark Private Accessors /************************************/
static O3KeyedUnarchiver* mUnarchiverP(O3FileResSource* self) {
	if (self->mUnarchiver && ![self needsUpdate]) return self->mUnarchiver;
	O3Destroy(self->mUnarchiver);
	O3Destroy(self->mDomain);
	if (self->mRootEnts) {
		delete self->mRootEnts;
		self->mRootEnts = nil;
	}
	NSFileHandle* rhandle = [NSFileHandle fileHandleForReadingAtPath:self->mPath];
	if (!rhandle) {
		[self->mContainerResSource subresourceDied:self];
		return nil;
	}
	O3BufferedReader* br = new O3BufferedReader(rhandle);
	self->mUnarchiver = [[O3KeyedUnarchiver alloc] initForReadingWithReader:br deleteWhenDone:YES];
	O3Assign([NSDate date], self->mLastUpdatedDate);
	return self->mUnarchiver;
}

/************************************/ #pragma mark Init & Dealloc /************************************/
- (O3FileResSource*)initWithPath:(NSString*)path parentResSource:(O3ResSource*)drs {
	O3SuperInitOrDie();
	O3Assign(path, mPath);
	mContainerResSource = drs;
	mResLock = [[NSLock alloc] init];
	return self;
}

- (void)dealloc {
	O3Release(mPath);
	O3Release(mLastUpdatedDate);
	O3Release(mDomain);
	[self close];
	O3Release(mResLock);
	if (mRootEnts) delete mRootEnts;
	O3SuperDealloc();
}

- (NSString*)domain {
	if (mDomain&&![self needsUpdate]) return mDomain;
	O3KeyedUnarchiver* un = mUnarchiverP(self);
	O3Assign([un domain], mDomain);
	return mDomain;
}

- (BOOL)needsUpdate {
	if (!mLastUpdatedDate) return YES;
	NSDictionary* attrs = [[NSFileManager defaultManager] fileAttributesAtPath:mPath traverseLink:YES];
	NSDate* modDate = [attrs objectForKey:NSFileModificationDate];
	if (!modDate && attrs) {
		O3LogWarn(@"No modification date could be read for file \"%@\". Assuming it is unmodified.");
		return NO;
	}
	if ([mLastUpdatedDate timeIntervalSinceDate:modDate]<0) return YES;
	return NO;
}

- (void)close {
	O3Destroy(mUnarchiver);
}


/************************************/ #pragma mark ResSource /************************************/
double O3FileResSourceSearchPriority(O3FileResSource* self, NSString* key) {
	if (self->mCachedName==key) return self->mCachedPriority;
	self->mCachedName=key;
	NSString* domain = [self domain];
	if (domain) {
		if ([key hasPrefix:domain]) return 100.;
		return 0.;
	}
	if (self->mFullyLoaded) if (![self needsUpdate]) return 0;
	return self->mCachedPriority=[[domain commonPrefixWithString:[self->mPath lastPathComponent] options:0] length];	
}

- (double)searchPriorityForObjectNamed:(NSString*)key {
	double p = 0;
	@try {
		p = O3FileResSourceSearchPriority(self, key);
	} @catch (NSException* e) {
		return -1.0;
	}
	return p;
}

//Returns nil if the archive root is compressed
static std::vector<O3ChildEnt>* rootEntsP(O3FileResSource* self) {
	if (self->mRootEnts) return self->mRootEnts;
	O3KeyedUnarchiver* ua = mUnarchiverP(self);
	if (!ua) return nil;
	std::vector<O3ChildEnt>* metadataRootEnts = [ua rootEnts];
	std::vector<O3ChildEnt>::iterator it=metadataRootEnts->begin(), e=metadataRootEnts->end();
	for (; it!=e; it++) {
		O3ChildEnt& ent = *it;
		if ([ent.key isEqualToString:@""]) {
			if (ent.type == O3PkgTypeCompressed) return nil;
			return self->mRootEnts = new std::vector<O3ChildEnt>([ua entsForDictionary:ent]);
		}
	}
	return NULL;
}

- (id)loadObjectNamed:(NSString*)name {
	std::vector<O3ChildEnt>* res = rootEntsP(self);
	if (!res) return nil;
	std::vector<O3ChildEnt>::iterator it=res->begin(), e=res->end();
	for (; it!=e; it++) {
		O3ChildEnt& ent = *it;
		if (![ent.key isEqualToString:name]) continue;
		return [mUnarchiverP(self) objectForEnt:ent];
	}
	return nil;
}

- (NSDictionary*)loadAllObjects {
	std::vector<O3ChildEnt>* res = [mUnarchiverP(self) rootEnts];
	if (!res) return nil;
	std::vector<O3ChildEnt>::iterator it=res->begin(), e=res->end();
	for (; it!=e; it++) {
		O3ChildEnt& ent = *it;
		if ([ent.key isEqualToString:@""]) {
			return [mUnarchiverP(self) objectForEnt:ent];
		}
	}
	return nil;
}

inline BOOL loadAllInto_lookForNamed_(O3FileResSource* self, O3ResManager* rm, NSString* name) {
	O3Asrt(O3AssumeSimultaneousDictEnumeration);
	NSDictionary* d = [self loadAllObjects];
	if (!d) return NO;
	NSEnumerator* dEnumerator = [d objectEnumerator];
	NSEnumerator* dkEnumerator = [d keyEnumerator];
	BOOL loaded=NO;
	while (1) {
		id o = [dEnumerator nextObject];
		NSString* k = [dkEnumerator nextObject];
		if (!o || !k) break;
		if ([k isEqualToString:name]) {[rm setValue:o forKey:k]; loaded=YES;}
		else [rm addPreloadedObject:o forKey:k];
	}
	return loaded;
}

///This method is lock-protected. The others aren't, since they are private.
- (BOOL)handleLoadRequest:(NSString*)requestedObject fromManager:(O3ResManager*)rm tryAgain:(BOOL*)temporaryFailure {
	if (temporaryFailure&&*temporaryFailure) [mResLock lock];
	else if (![mResLock tryLock]) {
		if (temporaryFailure) *temporaryFailure = YES;
		return NO;
	}
	BOOL ret = NO;
	
	if ([self shouldLoadLazily]) {
		id obj = [self loadObjectNamed:requestedObject];
		if (temporaryFailure) *temporaryFailure = NO;
		if (!obj) {
			O3Return(loadAllInto_lookForNamed_(self, rm, requestedObject));
		}
		[rm setValue:obj forKey:requestedObject]; ///<Should already have a nonzero value in the GC table
		O3Return(YES);
	} else {
		O3Return(loadAllInto_lookForNamed_(self, rm, requestedObject));
	}
	
	end:
	[mResLock unlock];
	return ret;
}

- (BOOL)shouldLoadLazily {
	O3ResManagerLaziness lzy = [self laziness];
	if (lzy==O3ResManagerObjectLazy) return YES;
	if (lzy==O3ResManagerFileLazy) return NO;
	if (mIsBigDetermined) return mIsBig;
	NSDictionary* attrs = [[NSFileManager defaultManager] fileAttributesAtPath:mPath traverseLink:YES];
	if (!attrs) return NO;
	UIntP size = O3NSNumberLongLongValue([attrs objectForKey:NSFileSize]);
	mIsBig = size>gO3KeyedUnarchiverLazyThreshhold;
	return mIsBig;
}

@end