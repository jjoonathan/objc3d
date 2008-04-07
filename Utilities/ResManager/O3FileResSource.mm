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
	BOOL needs_upd = [self needsUpdate];
	if (self->mRootsAreBad && !needs_upd) return nil;
	if (self->mUnarchiver && !needs_upd) return self->mUnarchiver;
	self->mRootsAreBad = self->mLoadAllIsBad = NO;
	[self->mKnownFailObjects removeAllObjects];
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
#if !defined(O3AllowBSDCalls)
	O3Assign([NSDate date], self->mLastUpdatedDate);
#else
	self->mLastUpdatedDate = time(NULL);
#endif
	return self->mUnarchiver;
}

/************************************/ #pragma mark Init & Dealloc /************************************/
- (O3FileResSource*)initWithPath:(NSString*)path parentResSource:(O3ResSource*)drs {
	O3SuperInitOrDie();
	O3Assign(path, mPath);
	mContainerResSource = drs;
	mResLock = [[NSLock alloc] init];
	self->mKnownFailObjects = [[NSMutableSet alloc] init];
	return self;
}

- (void)dealloc {
	O3Destroy(mKnownFailObjects);
	O3Destroy(mPath);
#if !defined(O3AllowBSDCalls)
	O3Destroy(mLastUpdatedDate);
#endif
	O3Destroy(mDomain);
	[self close];
	O3Destroy(mResLock);
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
#if defined(O3AllowBSDCalls)
	struct stat s;
	int fail = stat([mPath UTF8String], &s);
	if (fail) O3LogWarn(@"stat faild with errno %i", errno);
	time_t modtime = s.st_mtimespec.tv_sec+(s.st_mtimespec.tv_nsec*1.0e-9);
	if (modtime>mLastUpdatedDate) return YES;
#else
	NSDate* modDate = nil;
	NSDictionary* attrs = [[NSFileManager defaultManager] fileAttributesAtPath:mPath traverseLink:YES];
	modDate = [attrs objectForKey:NSFileModificationDate];
	if (!modDate && attrs) {
		O3LogWarn(@"No modification date could be read for file \"%@\". Assuming it is unmodified.");
		return NO;
	}
	if ([mLastUpdatedDate timeIntervalSinceDate:modDate]<0) return YES;
#endif
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
	@try {
		O3KeyedUnarchiver* ua = mUnarchiverP(self);
		std::vector<O3ChildEnt>* metadataRootEnts = [ua rootEnts];
		if (!metadataRootEnts) {
			self->mRootsAreBad=YES;
			O3Destroy(self->mUnarchiver);
		} else { //if we could find the root ents
			std::vector<O3ChildEnt>::iterator it=metadataRootEnts->begin(), e=metadataRootEnts->end();
			for (; it!=e; it++) {
				O3ChildEnt& ent = *it;
				if ([ent.key isEqualToString:@""]) {
					if (ent.type == O3PkgTypeCompressed) return nil;
					self->mRootEnts = new std::vector<O3ChildEnt>([ua entsForDictionary:ent]);
					break;
				}
			} //for all metadata roots
		} //if we could find the root ents
	} @catch (NSException* e) {
		self->mRootsAreBad = YES;
		O3Destroy(self->mUnarchiver);
	}
	return self->mRootEnts;
}

- (id)loadObjectNamed:(NSString*)name {
	std::vector<O3ChildEnt>* res = rootEntsP(self);
	if (!res) return nil;
	std::vector<O3ChildEnt>::iterator it=res->begin(), e=res->end();
	for (; it!=e; it++) {
		O3ChildEnt& ent = *it;
		if (ent.isBad) continue;
		if (![ent.key isEqualToString:name]) continue;
		id obj = nil;
		@try {
			obj = [mUnarchiverP(self) objectForEnt:ent];
		} @catch (NSException* e) {
			O3LogDebug(@"Caught object unarchiving exception: %@", e);
			[mKnownFailObjects addObject:name];
		}
		return obj;
	} //for all archive roots
	return nil;
}

- (NSDictionary*)loadAllObjects {
	if (mLoadAllIsBad) return nil;
	NSDictionary* ret = nil;
	@try {
		std::vector<O3ChildEnt>* res = [mUnarchiverP(self) rootEnts];
		if (!res) return nil;
		std::vector<O3ChildEnt>::iterator it=res->begin(), e=res->end();
		for (; it!=e; it++) {
			O3ChildEnt& ent = *it;
			if ([ent.key isEqualToString:@""]) {
				ret = [mUnarchiverP(self) objectForEnt:ent];
				break;
			}
		}
	} @catch (NSException* e) {
		O3LogDebug(@"Unarchiving exception caught: %@", e);
		mLoadAllIsBad = YES;
		ret = nil;
	}
	return ret;
}

inline BOOL loadAllInto_lookForNamed_(O3FileResSource* self, O3ResManager* rm, NSString* name) {
	O3Asrt(O3AssumeSimultaneousDictEnumeration);
	NSDictionary* d = [self loadAllObjects];
	if (!d) return NO;
	NSEnumerator* dEnumerator = [d objectEnumerator];
	NSEnumerator* dkEnumerator = [d keyEnumerator];
	BOOL loaded=NO; //If we found what we wanted
	while (1) {
		id o = [dEnumerator nextObject];
		NSString* k = [dkEnumerator nextObject];
		if (!o || !k) break;
		if ([k isEqualToString:name]) {[rm setValue:o forKey:k]; loaded=YES;}
		else [rm addPreloadedObject:o forKey:k];
	}
	self->mFullyLoaded = YES; //We are fully loaded even if we didn't find what we wanted
	return loaded;
}

///This method is lock-protected. The others aren't, since they are private and should only be called from protected methods.
- (BOOL)handleLoadRequest:(NSString*)requestedObject fromManager:(O3ResManager*)rm tryAgain:(BOOL*)temporaryFailure {
	BOOL nu = [self needsUpdate];
	BOOL already_determined = mFullyLoaded ?: [mKnownFailObjects containsObject:requestedObject];
	already_determined &= !nu;
	if (already_determined) { //Assume failure since we would have loaded otherwise
		*temporaryFailure = NO;
		return NO;
	}
	if (temporaryFailure&&*temporaryFailure) [mResLock lock];
	else if (![mResLock tryLock]) {
		if (temporaryFailure) *temporaryFailure = YES;
		return NO;
	}
	BOOL ret = NO;
	
	if ([self shouldLoadLazily]) {
		id obj = nil;
		if (temporaryFailure) *temporaryFailure = NO;
		obj = [self loadObjectNamed:requestedObject];
		if (!obj) ret = loadAllInto_lookForNamed_(self, rm, requestedObject);
		else {
			[rm setValue:obj forKey:requestedObject]; ///<Should already have a nonzero value in the GC table
			ret = YES;
		}
	} else {
			ret = loadAllInto_lookForNamed_(self, rm, requestedObject);
	}
	
	[mResLock unlock];
	return ret;
}

- (BOOL)shouldLoadLazily {
	if (mLoadAllIsBad) return YES; //May as well try individual objects if something went wrong higher up
	O3ResManagerLaziness lzy = [self laziness];
	if (lzy==O3ResManagerObjectLazy) return YES;
	if (lzy==O3ResManagerFileLazy) return NO;
	if (mIsBigDetermined) return mIsBig;
	//O3Optimizeable
#if defined(O3AllowBSDCalls)
	struct stat s;
	int fail = stat([mPath UTF8String], &s);
	if (fail) {
		O3LogWarn(@"stat faild with errno %i. Assuming unlazy loading is warranted, since its slightly safer.", errno);
		return NO;
	}
	UInt64 size = s.st_size;
#else
	NSDictionary* attrs = [[NSFileManager defaultManager] fileAttributesAtPath:mPath traverseLink:YES];
	if (!attrs) return NO;
	UInt64 size = O3NSNumberLongLongValue([attrs objectForKey:NSFileSize]);
#endif
	mIsBig = size>gO3KeyedUnarchiverLazyThreshhold;
	return mIsBig;
}

@end