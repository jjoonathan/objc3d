//
//  O3DirectoryResSource.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 9/23/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3DirectoryResSource.h"

@implementation O3DirectoryResSource



@end




@implementation O3FileResSource

- (O3FileResSource*)initWithPath:(NSString*)path {
	O3SuperInitOrDie();
	O3Assign(path, mPath);
	mKeys = [[NSMutableDictionary alloc] init];
	return self;
}

- (void)dealloc {
	O3Release(mPath);
	O3Release(mLastUpdatedDate);
	O3Release(mKeys);
	O3SuperDealloc();
}

void loadKeysP(O3FileResSource* self) {
	if (![self needsUpdate]) return;
	O3ToImplement();
	[self->mKeys removeAllObjects];
	O3Destroy(self->mDomain);
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	@try {
		NSFileHandle* h = [NSFileHandle fileHandleForReadingAtPath:self->mPath];
		if (!h) {
			O3LogError(@"Could not open %@ for reading to peek at its keys", self->mPath);
			return;
		}
		O3BufferedReader r(h);
		r.mBlockSize = 32;
		
		while (!r.IsAtEnd()) {
			NSString* globalKey = r.ReadCCString(O3CCSKeyTable);
			if ([globalKey isEqualToString:@""]) {
				UIntP size;
				r.ReadObjectHeader(&size);
				UIntP endOffset = r.Offset()+size;
				while (r.Offset()<endOffset) {
					NSString* localKey = r.ReadCCString(O3CCSKeyTable);
					if (self->mDomain) localKey = [self->mDomain stringByAppendingString:localKey];
					O3CFDictionarySetValue(self->mKeys, localKey, O3NSNumberWithLongLong(r.Offset()));
					r.SkipObject();
				}		
				break;
			} //if gkey @""
			else if ([globalKey isEqualToString:@"D"]) {
				O3Assign([r.ReadObject() stringByAppendingString:@"_"], self->mDomain);
			}
			r.SkipObject();
		} //while not at end
	} @catch (NSException* e) {
		O3LogError(@"Couldn't get the keys from file %@. Partial keyset = %@. Removing partial keys since archive is probably corrupt.", self->mPath, self->mKeys);
		[self->mKeys removeAllObjects];
	}
	[pool release];
}

- (NSArray*)keys {
	loadKeysP(self);
	return [[mKeys keyEnumerator] allObjects];
}

- (NSArray*)cachedKeys {
	return [[mKeys keyEnumerator] allObjects];
}

- (NSString*)domain {
	return mDomain;
}

- (BOOL)needsUpdate {
	if (!mLastUpdatedDate) return YES;
	NSDate* modDate = [[[NSFileManager defaultManager] fileAttributesAtPath:mPath traverseLink:YES] objectForKey:NSFileModificationDate];
	if ([mLastUpdatedDate timeIntervalSinceDate:modDate]<0) return YES;
	return NO;
}

/************************************/ #pragma mark ResSource /************************************/
- (double)searchPriorityForObjectNamed:(NSString*)key {
	double numerator = 1.;
	double recip_denom = 1.;
	if (mDomain) {
		if ([key hasPrefix:mDomain]) numerator *= [mDomain length];
	} else {
		NSArray* keys = [self cachedKeys];
		NSString* first = [keys count]?[keys objectAtIndex:0]:nil;
		if (first) numerator *= [[key commonPrefixWithString:first options:nil] length];
	}
	return numerator*recip_denom;
}

- (id)tryToLoadObjectNamed:(NSString*)key intoResManager:(O3ResManager*)manager allowSideEffects:(BOOL)loadSiblings {
	loadKeysP(self);
	NSNumber* offset = O3CFDictionaryGetValue(mKeys, key);
		if (!offset) return nil;
	NSFileHandle* h = [NSFileHandle fileHandleForReadingAtPath:self->mPath];
		if (!h) return nil;
	O3BufferedReader r(h);
	r.SeekToOffset(O3NSNumberLongLongValue(offset));
	return r.ReadObject(); //need an unarchiver, dammit
}

//- (NSArray*)allKeys; ///<Finds all keys in the source, but does not load them. This method may return old data, since it is allowed to cache. Try to reload some nonexsistant key with sideEffects:NO to update said (optional) cache.
//- (id)tryToReloadObjectNamed:(NSString*)key intoResManager:(O3ResManager*)manager allowSideEffects:(BOOL)loadSiblings;

@end