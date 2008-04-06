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
static void readRootEnts(O3KeyedUnarchiver* self);
- (NSZone*)objectZone {return mObjectZone;}
- (void)setObjectZone:(NSZone*)zone {mObjectZone = zone;}
- (BOOL)allowsKeyedCoding {return YES;}
- (NSString*)domain {readRootEnts(self); return mDomain;}
- (NSDictionary*)classFallbacks {readRootEnts(self); return mClassFallbacks;}

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
	if (mBr) {
		[mBr->mKT release];
		[mBr->mST release];
		[mBr->mCT release];
		if (mDeleteBr) delete mBr;
	}
	[mClassFallbacks release];
	[mClassOverrides release];
	[mDomain release];
	[mMetadata release];
	O3SuperDealloc();
}

/************************************/ #pragma mark Read /************************************/
//Returns the value or nil if it doesn't know what to do. If it didn't know what to do, it didn't read it.
id handleMetadataKeyP(O3KeyedUnarchiver* self, O3ChildEnt ent) {
	NSString* k = ent.key;
	if ([k isEqualToString:@""]) return nil;
	self->mMetadata = self->mMetadata ?: [[NSMutableDictionary alloc] init];
	id obj = self->mBr->ReadObject(self, self->mObjectZone, ent);
	[self->mMetadata setObject:obj forKey:k];
	if ([k isEqualToString:@"KT"])
		return O3Assign(obj, self->mBr->mKT);
	else if ([k isEqualToString:@"ST"])
		return O3Assign(obj, self->mBr->mST);
	else if ([k isEqualToString:@"CT"])
		return O3Assign(obj, self->mBr->mCT);
	else if ([k isEqualToString:@"C"])
		return O3Assign(obj, self->mClassFallbacks);
	else if ([k isEqualToString:@"D"])
		return O3Assign(obj, self->mDomain);
	return nil;
}

static void readRootEnts(O3KeyedUnarchiver* self) {
	if (self->mHasReadRootEnts) return;
	self->mHasReadRootEnts = YES;
	self->mBr->SeekToOffset(0);
	self->mRootEnts = self->mBr->ReadChildEntsOfTotalLength(self->mBr->TotalLength(), YES);
	std::vector<O3ChildEnt>::iterator it=self->mRootEnts.begin(), e=self->mRootEnts.end();
	for (; it!=e; it++) {
		O3ChildEnt& ent = *it;
		if (handleMetadataKeyP(self, ent)) continue;
		if (![ent.key isEqualToString:@""])
			O3LogWarn(@"Unknown root key encountered: \"%@\". Ignoring it.", ent.key);
	}
}

///@warning One-shot: only call read once, since it leaves the read position at the end of the buffer. Calling twice without calling -reset will produce an error.
- (id)read {
	O3AssertIvar(mBr);
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	id to_return;
	readRootEnts(self);
	std::vector<O3ChildEnt>::iterator it=mRootEnts.begin(), e=mRootEnts.end();
	for (; it!=e; it++) {
		O3ChildEnt& ent = *it;
		if ([ent.key isEqualToString:@""]) {
			ent.domain = [mDomain retain];
			to_return = [mBr->ReadObject(self, mObjectZone, ent) retain];
			break;
		}
	}
	[pool release];
	return [to_return autorelease];
}

- (NSDictionary*)metadata {
	readRootEnts(self);
	return mMetadata;
}

- (std::vector<O3ChildEnt>*)rootEnts {
	readRootEnts(self);
	return &mRootEnts;
}

- (std::vector<O3ChildEnt>)entsForDictionary:(O3ChildEnt&)dict {
	O3Asrt(dict.type==O3PkgTypeDictionary || dict.type==O3PkgTypeObject);
	O3Asrt(mBr);
	mBr->SeekToOffset(dict.offset);
	return mBr->ReadChildEntsOfTotalLength(dict.len, YES);
}

- (id)objectForEnt:(O3ChildEnt&)ent {
	O3Asrt(ent.type==O3PkgTypeDictionary || ent.type==O3PkgTypeObject);
	O3Asrt(mBr);
	return mBr->ReadObject(self, mObjectZone, ent);
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
	return nil; //Causes the bufferedreader to default
}

- (NSArray*)readO3AArrayFrom:(O3BufferedReader*)reader size:(UIntP)size {
	return nil; //Causes the bufferedreader to default
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
	std::vector<O3ChildEnt> ents = reader->ReadChildEntsOfTotalLength(size, YES);
	std::vector<O3ChildEnt>::iterator it=ents.begin(), e=ents.end();
	NSDictionary* oldDict = mObjDict;
	mObjDict = [[NSMutableDictionary alloc] init];
	mDepth++;
	for (; it!=e; it++) {
		O3ChildEnt& ent = *it;
		O3CFDictionarySetValue(mObjDict, ent.key, reader->ReadObject(self, mObjectZone, ent));
	}
	mDepth--;
	NSObject* to_return = [[[objClass alloc] initWithCoder:self] autorelease];
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

/************************************/ #pragma mark Debug/Testing /************************************/
+ (void)testUnarchivingData:(NSData*)dat {
	for (UIntP i=0; i<100000; i++) {
		NSAutoreleasePool *pool = [NSAutoreleasePool new];
		[O3KeyedUnarchiver unarchiveObjectWithData:dat];
		[pool release];
	}
}

@end
