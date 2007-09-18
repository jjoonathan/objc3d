/**
 *  @file O3KeyedUnarchiver.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 4/18/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3KeyedUnarchiver.h"

@interface O3KeyedUnarchiver (Private)
- (id)read;
@end

@implementation O3KeyedUnarchiver
/************************************/ #pragma mark Accessors /************************************/
- (NSZone*)objectZone {return mObjectZone;}
- (void)setObjectZone:(NSZone*)zone {mObjectZone = zone;}
- (BOOL)allowsKeyedCoding {return YES;}

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
	O3SuperDealloc();
}

/************************************/ #pragma mark Read /************************************/
- (id)read {
	O3AssertIvar(mBr);
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	id to_return;
	while (!mBr->IsAtEnd()) {
		NSString* key = mBr->ReadCCString(O3CCSKeyTable); //Should never be in the key table, but we have to be pedantic about following specs
		if ([key isEqualToString:@"KT"])
			mBr->mKT = [mBr->ReadObject(self, mObjectZone) retain];
		else if ([key isEqualToString:@"ST"])
			mBr->mST = [mBr->ReadObject(self, mObjectZone) retain];
		else if ([key isEqualToString:@"CT"])
			mBr->mCT = [mBr->ReadObject(self, mObjectZone) retain];
		else if ([key isEqualToString:@"C"])
			mClassFallbacks = [mBr->ReadObject(self, mObjectZone) retain];
		else if ([key isEqualToString:@""])
			to_return = [mBr->ReadObject(self, mObjectZone) retain];
		else {
			O3LogWarn(@"Unknown root key encountered: \"%@\" -> %@. Reading an object and ignoring", key, mBr->ReadObject(self, mObjectZone));
		}
	}
	[pool release];
	return [to_return autorelease];
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
	while(offset<end) {
		NSString* k = reader->ReadCCString(O3CCSKeyTable);
		O3Assert(reader->Offset()<end, @"Archive corrupt");
		NSObject* v = reader->ReadObject(self, mObjectZone);
		if (v) O3CFDictionarySetValue(dict, k, v);
		offset = reader -> Offset();
	}
	return dict;
}

- (NSArray*)readO3AArrayFrom:(O3BufferedReader*)reader size:(UIntP)size {
	NSMutableArray* arr = [[[NSMutableArray alloc] init] autorelease];
	UIntP offs = reader->Offset();
	UIntP end = offs + size;
	while(offs<end) {
		O3CFArrayAppendValue(arr, reader->ReadObject(self, mObjectZone));
		offs = reader->Offset();
	};
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
	do {
		NSString* k = reader->ReadCCString(O3CCSKeyTable);
		NSObject* v = reader->ReadObject(self, mObjectZone);
		O3CFDictionarySetValue(mObjDict, k, v);
	} while(reader->Offset()<end);
	NSObject* to_return = [[objClass alloc] initWithCoder:self];
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
