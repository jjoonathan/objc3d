/**
 *  @file O3KeyedUnarchiver.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 4/18/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3KeyedUnarchiver.h"
#import "O3ResManager.h"

@implementation O3KeyedUnarchiver
O3DefaultO3InitializeImplementation
/************************************/ #pragma mark Accessors /************************************/
- (NSZone*)objectZone {return mObjectZone;}
- (void)setObjectZone:(NSZone*)zone {mObjectZone = zone;}
- (BOOL)allowsKeyedCoding {return YES;}
- (NSString*)domain {return mDomain;}
- (NSDictionary*)classFallbacks {return mClassFallbacks;}

/************************************/ #pragma mark Construction /************************************/
- (O3KeyedUnarchiver*)initForReadingWithData:(NSData*)dat {
	O3SuperInitOrDie();
	mBr = new O3BufferedReader(dat);
	mDeleteBr = YES;
	return self;
}

- (O3KeyedUnarchiver*)initForReadingWithFile:(NSString*)file {
	O3SuperInitOrDie();
	O3AssertArg(file, @"initForReadingWithFile: needs a valid file path.");
	NSFileHandle* de = [NSFileHandle fileHandleForReadingAtPath:file];
	mBr = new O3BufferedReader(de);
	[de release];
	mDeleteBr = YES;
	return self;
}

- (O3KeyedUnarchiver*)initForReadingWithReader:(O3BufferedReader*)br deleteWhenDone:(BOOL)shouldDelete {
	O3SuperInitOrDie();
	mBr = br;
	mDeleteBr = shouldDelete;
	return self;
}

- (void)dealloc {
	[mBr->mKT release];
	[mBr->mST release];
	[mBr->mCT release];
	if (mDeleteBr&&mBr) delete mBr;
	[mClassFallbacks release];
	[mClassOverrides release];
	[mDomain release];
	O3SuperDealloc();
}

/************************************/ #pragma mark Read /************************************/
//Returns the value or nil if it doesn't know what to do. If it didn't know what to do, it didn't read it.
id handleMetadataKeyP(O3KeyedUnarchiver* self, NSString* key) {
	if ([key isEqualToString:@"KT"])
		return O3Assign(self->mBr->ReadObject(self, self->mObjectZone), self->mBr->mKT);
	else if ([key isEqualToString:@"ST"])
		return O3Assign(self->mBr->ReadObject(self, self->mObjectZone), self->mBr->mST);
	else if ([key isEqualToString:@"CT"])
		return O3Assign(self->mBr->ReadObject(self, self->mObjectZone), self->mBr->mCT);
	else if ([key isEqualToString:@"C"])
		return O3Assign(self->mBr->ReadObject(self, self->mObjectZone), self->mClassFallbacks);
	else if ([key isEqualToString:@"D"])
		return O3Assign(self->mBr->ReadObject(self, self->mObjectZone), self->mDomain);
	return nil;
}

- (void)reset {
	O3AssertIvar(mBr);
	mBr->SeekToOffset(0);
}

///@warning One-shot: only call read once, since it leaves the read position at the end of the buffer. Calling twice without calling -reset will produce an error.
- (id)read {
	O3AssertIvar(mBr);
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	id to_return;
	while (!mBr->IsAtEnd()) {
		NSString* key = mBr->ReadCCString(O3CCSKeyTable); //Should never be in the key table, but we have to be pedantic about following specs
		if (!handleMetadataKeyP(self, key)) {
			if ([key isEqualToString:@""])
				to_return = [mBr->ReadObject(self, mObjectZone) retain];
			else {
				O3LogWarn(@"Unknown root key encountered: \"%@\" -> %@. Reading its value, but ignoring it.", key, mBr->ReadObject(self, mObjectZone));
			}
		}
	}
	[pool release];
	mHasReadMetadata = YES;
	return [to_return autorelease];
}

///@warning One-shot. Either call read or readAndLoadIntoManager, but not both, as the second will cause issues. Use -reset if you must readAndLoadIntoManager after reading.
///@param returnDummyDict if YES, the dictionary returned is full of [NSNull null] rather than anything useful. Often the receiver might want to know what keys were loaded, but not retain them. Using the null object works great in these situatios. NSSet would be more logical, but less convenient.
- (id)readAndLoadIntoManager:(O3ResManager*)manager returnDummyDict:(BOOL)returnDummyDict {
	NSDictionary* loaded_objects = [self read];
	NSEnumerator* k = [loaded_objects keyEnumerator];
	id nullval = returnDummyDict?O3NSNull():nil;
	#ifdef O3AssumeSimultaneousDictEnumeration
	NSEnumerator* o = [loaded_objects objectEnumerator];
	while (id obj = [o nextObject]) {
		id val = (returnDummyDict?nullval:obj);
		[manager setValue:val forKey:[k nextObject]];
	}
	#else
	while (id key = [k nextObject]) {
		id val = (returnDummyDict?nullval:[loaded_objects objectForKey:key]);
		[manager setValue:val forKey:key];
	}	
	#endif
	return loaded_objects;
}

- (NSDictionary*)metadata {
	if (mMetadata) return mMetadata;
	O3AssertIvar(mBr);
	UInt64 oldoffset = mBr->Offset();
	mBr->SeekToOffset(0);
	mDepth+=100;
	
	NSMutableDictionary* mdata = [[[NSMutableDictionary alloc] init] autorelease];
	while (!mBr->IsAtEnd()) {
		NSString* key = mBr->ReadCCString(O3CCSKeyTable); //Should never be in the key table, but we have to be pedantic about following specs
		id value = handleMetadataKeyP(self, key);
		if (!value) {
			if ([key isEqualToString:@""]) {
				value = O3NSNumberWithLongLong(mBr->Offset());
				mBr->SkipObject();
			}
			else value = mBr->ReadObject(self, mObjectZone);
		}
		O3CFDictionarySetValue(mdata,key,value);
	}
	
	mDepth-=100;
	mHasReadMetadata = YES;
	mBr->SeekToOffset(oldoffset);
	O3Assign(mdata, mMetadata);
	return mdata;
}

///@param prependDomainToKeys O3Archives by default prepend every key in their root level (every key that is globally visible without calling accessors) with the domain. skimDictionaryAtOffset has no way of knowing if we are in the root level (level 1), so you must provide this info.
///@warning Be sure to call readMetadata first, or this will likely burn and die with an archive corrupt message
- (NSDictionary*)skimDictionaryAtOffset:(UIntP)offs levelOne:(BOOL)prependDomainToKeys {
	if (!mHasReadMetadata) {
		O3LogWarn(@"Skimming was requested of unarchiver %@. This is not a good idea without having first read metadata, since you won't know what you are skimming. Metadata was automatically read to assure consistency.");
		[self metadata];
	}
	mDepth+=100; //Just to be safe, we get away from other special behavior
	NSMutableDictionary* to_return = [[[NSMutableDictionary alloc] init] autorelease];
	O3AssertIvar(mBr);
	mBr->SeekToOffset(offs);
	UIntP size;
	enum O3PkgType type = mBr->ReadObjectHeader(&size);
	if (!(type==O3PkgTypeObject || type==O3PkgTypeDictionary))
		[NSException raise:NSInconsistentArchiveException format:@"Tried to skim non-dictionary & non-object thing at %p"];
	UIntP endOffset = mBr->Offset()+size;
	while (mBr->Offset()<endOffset) {
		NSString* localKey = mBr->ReadCCString(O3CCSKeyTable);
		if (self->mDomain&&prependDomainToKeys) localKey = [self->mDomain stringByAppendingString:localKey];
		O3CFDictionarySetValue(to_return, localKey, O3NSNumberWithLongLong(mBr->Offset()));
		mBr->SkipObject();
	}
	mDepth-=100;
	return to_return;
}

- (id)readObjectAtOffset:(UIntP)offset {
	if (!mHasReadMetadata) {
		O3LogWarn(@"Raw object reading was requested of unarchiver %@. This is not a good idea without having first read metadata, since you won't know what you are jumping to. Metadata was automatically read to assure consistency.");
		[self metadata];
	}
	mDepth+=100; //Just to be safe, we get away from other special behavior
	O3AssertIvar(mBr);
	mBr->SeekToOffset(offset);
	id to_return = mBr->ReadObject(self, mObjectZone);
	mDepth-=100;
	return to_return;
}



/************************************/ #pragma mark Class methods /************************************/
+ (id)unarchiveObjectWithData:(NSData *)data {
	O3KeyedUnarchiver* a = [[O3KeyedUnarchiver alloc] initForReadingWithData:data];
	id to_return = [a read];
	[a release];
	return to_return;
}

+ (id)unarchiveObjectWithFile:(NSString *)path {
	O3KeyedUnarchiver* a = [[O3KeyedUnarchiver alloc] initForReadingWithFile:path];
	id to_return = [a read];
	[a release];
	return to_return;
}

/************************************/ #pragma mark Unarchiving protocol /************************************/
- (NSObject*)readO3ADictionaryFrom:(O3BufferedReader*)reader size:(UIntP)size {
	NSMutableDictionary* dict = [[[NSMutableDictionary alloc] init] autorelease];
	UIntP offset = reader->Offset();
	UIntP end = offset + size;
	mDepth++;
	while(offset<end) {
		NSString* k = reader->ReadCCString(O3CCSKeyTable);
		O3Assert(reader->Offset()<end, @"Archive corrupt");
		if (mDepth==1&&mDomain) k = [mDomain stringByAppendingString:k];
		NSObject* v = reader->ReadObject(self, mObjectZone);
		if (v) O3CFDictionarySetValue(dict, k, v);
		offset = reader -> Offset();
	}
	mDepth--;
	return dict;
}

- (NSArray*)readO3AArrayFrom:(O3BufferedReader*)reader size:(UIntP)size {
	NSMutableArray* arr = [[[NSMutableArray alloc] init] autorelease];
	UIntP offs = reader->Offset();
	UIntP end = offs + size;
	mDepth++;
	while(offs<end) {
		O3CFArrayAppendValue(arr, reader->ReadObject(self, mObjectZone));
		offs = reader->Offset();
	};
	mDepth--;
	return arr;
}

///@todo make more efficient
- (id)readO3AObjectOfClass:(NSString*)className from:(O3BufferedReader*)reader size:(UIntP)size {
	NSString* override = [mClassOverrides objectForKey:className];
	Class objClass = override? NSClassFromString(override) : [NSKeyedUnarchiver classForClassName:className];
	objClass = objClass ?: NSClassFromString(className);
	if (!objClass) {
		NSEnumerator* fallbackEnumerator = [[mClassFallbacks objectForKey:className] objectEnumerator];
		while (!objClass) {
			NSString* name = [fallbackEnumerator nextObject];
			if (!name) {
				[NSException raise:NSInconsistentArchiveException format:@"No class substitute could be found to read a %@.", className];
				return nil;
			}
			objClass = NSClassFromString(name);
		}
	}
	
	NSDictionary* oldDict = mObjDict;
	mObjDict = [[NSMutableDictionary alloc] init];
	UIntP end = reader->Offset() + size;
	mDepth++;
	do {
		NSString* k = reader->ReadCCString(O3CCSKeyTable);
		NSObject* v = reader->ReadObject(self, mObjectZone);
		O3CFDictionarySetValue(mObjDict, k, v);
	} while(reader->Offset()<end);
	mDepth--;
	NSObject* to_return = [[[objClass alloc] initWithCoder:self] autorelease];
	//O3Optimizeable();
	[mObjDict release];
	mObjDict = oldDict;
	return to_return;
}

/************************************/ #pragma mark Class overriding /************************************/
///Is exactly the same as NSKeyedUnarchiver classForClassName: (O3KeyedUnarchiver and NSKeyedUnarchiver share class overrides)
+ (void)setClass:(Class)c forClassName:(NSString*)cname {
	[NSKeyedUnarchiver setClass:c forClassName:cname];
}

///Is exactly the same as NSKeyedUnarchiver classForClassName: (O3KeyedUnarchiver and NSKeyedUnarchiver share class overrides)
+ (Class)classForClassName:(NSString*)cname {
	return [NSKeyedUnarchiver classForClassName:cname];
}

- (void)setClass:(Class)c forClassName:(NSString*)cname {
	if (!mClassOverrides) mClassOverrides = [[NSMutableDictionary alloc] init];
	O3CFDictionarySetValue(mClassOverrides,cname,c);
}

- (Class)classForClassName:(NSString*)cname {
	return [mClassOverrides objectForKey:cname];
}

/************************************/ #pragma mark Unarchiver methods /************************************/
///@todo Support lazy/direct decoding better. There could be quite a speed boost in that. Measure first, though.
- (BOOL)containsValueForKey:(NSString*)key {
	return O3CFDictionaryGetValue(mObjDict, key)?YES:NO;
}

- (BOOL)decodeBoolForKey:(NSString*)key {
	id obj = O3CFDictionaryGetValue(mObjDict, key);
	return [obj boolValue];
}

- (UInt8*)decodeBytesForKey:(NSString*)key returnedLength:(UIntP*)len {
	NSData* obj = (NSData*)O3CFDictionaryGetValue(mObjDict, key);
	if (!obj) {
		if (len) *len = NULL;
		return NULL;
	}
	return (UInt8*)O3CFDataGetBytes(obj);
}

- (double)decodeDoubleForKey:(NSString*)key {
	id obj = O3CFDictionaryGetValue(mObjDict, key);
	return [obj doubleValue];	
}

- (float)decodeFloatForKey:(NSString*)key {
	id obj = O3CFDictionaryGetValue(mObjDict, key);
	double dval = [obj doubleValue];
	#ifdef O3DEBUG
	float fval = dval;
	if (!O3Equals(dval, fval, .1)) O3LogWarn(@"Significant loss of precision in [%@ %@:%@]. Was %f!=%f.", self, NSStringFromSelector(_cmd), key,dval,(double)fval);
	#endif
	return dval;	
}

- (int)decodeIntForKey:(NSString*)key {
	NSNumber* num = O3CFDictionaryGetValue(mObjDict, key);
	if (!num) return 0;
	long long llnum = O3NSNumberLongLongValue(num);
	if (O3Abs(llnum)>O3TypeMax(long long)) [NSException raise:NSRangeException format:@"%@ tried to unarchive a value (%qX) > 2^31 into an Int32 (key %@).", NSStringFromSelector(_cmd), llnum, key];
	return llnum;
}

- (Int32)decodeInt32ForKey:(NSString*)key {
	NSNumber* num = O3CFDictionaryGetValue(mObjDict, key);
	if (!num) return 0;
	long long llnum = O3NSNumberLongLongValue(num);
	if (O3Abs(llnum)>O3TypeMax(long long)) [NSException raise:NSRangeException format:@"%@ tried to unarchive a value (%qX) > 2^31 into an Int32 (key %@).", NSStringFromSelector(_cmd), llnum, key];
	return llnum;
}

- (Int64)decodeInt64ForKey:(NSString*)key {
	NSNumber* num = O3CFDictionaryGetValue(mObjDict, key);
	if (!num) return 0;
	long long llnum = O3NSNumberLongLongValue(num);
	return llnum;
}

- (id)decodeObjectForKey:(NSString*)key {
	return O3CFDictionaryGetValue(mObjDict, key);
}

- (void)finishDecoding {
	if (mDeleteBr) {
		delete mBr;
		mBr = NULL;
	}
}

@end
