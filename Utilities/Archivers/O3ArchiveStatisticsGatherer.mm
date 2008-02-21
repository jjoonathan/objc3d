/**
 *  @file O3ArchiveStatisticsGatherer.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 7/19/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3ArchiveStatisticsGatherer.h"
#import "O3KeyedArchiver.h"
#import "O3ArchiveFormat.h"

@implementation O3ArchiveStatistic
O3DefaultO3InitializeImplementation
+ (id)alloc {id s = [super alloc]; if (!s) O3Asrt(false /*Allocation failed!*/); return s;}
inline NSString* getKey(O3ArchiveStatistic* self) {return self->key;}
inline void      setKey(O3ArchiveStatistic* self, NSString* k) {self->key = k;}
inline UIntP getCount(O3ArchiveStatistic* self) {return self->numOccurances;}
inline void      incCount(O3ArchiveStatistic* self) {self->numOccurances++;}
inline IntP getWinnage(O3ArchiveStatistic* self) {
	if (self->winnage) return self->winnage;
	UIntP stringlen = [self->key lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	UIntP ccStringLen = stringlen + O3BytesNeededForCInt(stringlen);
	self->winnage = (self->numOccurances-1)*ccStringLen - 3;
	return self->winnage;
}
- (NSString*)description {return [NSString stringWithFormat:@"<%@>%@:%i",[self className],getKey(self),getWinnage(self)];}
@end

@implementation NSCoder (O3StatisticGatherer)
- (BOOL)isStatisticGatherer {return NO;}
@end

@implementation O3ArchiveStatisticsGatherer (O3StatisticGatherer)
- (BOOL)isStatisticGatherer {return YES;}
@end

@implementation O3ArchiveStatisticsGatherer
O3DefaultO3InitializeImplementation
/************************************/ #pragma mark Creation and Destruction /************************************/
- (id)init {
	O3SuperInitOrDie();
	mKT = [NSMutableDictionary new];
	mST = [NSMutableDictionary new];
	mCT = [NSMutableDictionary new];
	return self;
}

- (void)dealloc {
	[mKT release];
	[mST release];
	[mCT release];
	O3SuperDealloc();
}

/************************************/ #pragma mark Processing /************************************/
+ (void)gatherStatisticsForRootObject:(id)obj KT:(NSArray**)kt ST:(NSArray**)st CT:(NSArray**)ct {[O3ArchiveStatisticsGatherer gatherStatisticsForRootObject:obj key:nil KT:kt ST:st CT:ct classNameMap:nil];}
///@param cmap The Class->className dictionary for statistic gathering. Note that it is not memory managed.
+ (void)gatherStatisticsForRootObject:(id)obj key:(NSString*)k KT:(NSArray**)kt ST:(NSArray**)st CT:(NSArray**)ct classNameMap:(NSDictionary*)cmap {
	O3ArchiveStatisticsGatherer* a = [O3ArchiveStatisticsGatherer new];
	a->mClassNameMappings = cmap; //No need to retain
	[a encodeObject:obj forKey:k];
	[a gatherStatisticsIntoKT:kt ST:st CT:ct];
	[a release];
}

int winnageSort(id l, id r, void* context) {
	IntP left = getWinnage(l);
	IntP right = getWinnage(r);
	if (left<right) return NSOrderedDescending;
	if (left>right) return NSOrderedAscending;
	return NSOrderedSame;
}

///Makes a dictionary that maps each element of %a to its index + 1
NSDictionary* O3ArchiveStringMapFromArray(NSArray* a) {
	UIntP count = O3CFArrayGetCount(a);
	NSMutableDictionary* md = [[NSMutableDictionary alloc] initWithCapacity:count];
	UIntP i; for(i=0; i<count; i++) {
		NSString* k = O3CFArrayGetValueAtIndex(a, i);
		O3CFDictionarySetValue(md, k, O3NSNumberWithLongLong(i+1));
	}
	return md;
}

inline NSArray* putIntoArrayOrderAndCutLosses(NSDictionary* dict) {
	NSMutableArray* arr = [[dict allValues] mutableCopy];
	UIntP count = O3CFArrayGetCount(arr);
	[arr sortUsingFunction:winnageSort context:nil];
	UIntP i; for(i=0; i<count; i++) {
		O3ArchiveStatistic* stat = O3CFArrayGetValueAtIndex(arr, i);
		IntP winnage = getWinnage(stat);
		if (winnage<=0) {
			[arr removeObjectsInRange:NSMakeRange(i,count-i)];
			break;
		}
		O3CFArraySetValueAtIndex(arr, i, getKey(stat));	
	}
	return arr;	
}


///@param kt the key table dictionary (NSString->NSNumber) with 1 retain and no autoreleases
///@param st the key table dictionary (NSString->NSNumber) with 1 retain and no autoreleases
///@param ct the key table dictionary (NSString->NSNumber) with 1 retain and no autoreleases
///@todo <st>Use a binary search to be efficient</st> we have to transform the objects anyways
- (void)gatherStatisticsIntoKT:(NSArray**)kt ST:(NSArray**)st CT:(NSArray**)ct {
	if (kt) *kt = putIntoArrayOrderAndCutLosses(mKT);
	if (st) *st = putIntoArrayOrderAndCutLosses(mST);
	if (ct) *ct = putIntoArrayOrderAndCutLosses(mCT);
}

/************************************/ #pragma mark Dummy Archiving Methods /************************************/
- (void)encodeRect:(NSRect*)r {}
- (void)encodePoint:(NSPoint)pt {}
- (void)encodeObject:(id)obj {}
- (void)encodeNXObject:(id)obj {}
- (void)encodeDataObject:(NSData*)obj {}
- (void)encodeConditionalObject:(id)obj {}
- (void)encodeBytes:(void*)ptr length:(UIntP)len {}
- (void)encodeByrefObject:(id)obj {}
- (void)encodeBycopyObject:(id)obj {}
- (void)encodeArrayOfObjCType:(const char*)type count:(UIntP)ct at:(void*)ptr {}
- (void)encodeValueOfObjCType:(const char*)type at:(void*)ptr {}

#ifdef O3AllowInitHack
#define incrementKeyCounter(key) {O3ArchiveStatistic* arcs = [mKT objectForKey:key];    if (!arcs) {[mKT setObject:arcs=[O3ArchiveStatistic alloc] forKey:key]; setKey(arcs, key);} incCount(arcs);}
#define incrementStringCounter(key) {O3ArchiveStatistic* arcs = [mST objectForKey:key]; if (!arcs) {[mST setObject:arcs=[O3ArchiveStatistic alloc] forKey:key]; setKey(arcs, key);} incCount(arcs);}
#define incrementClassCounter(key) {O3ArchiveStatistic* arcs = [mCT objectForKey:key];  if (!arcs) {[mCT setObject:arcs=[O3ArchiveStatistic alloc] forKey:key]; setKey(arcs, key);} incCount(arcs);}
#else
#define incrementKeyCounter(key) {O3ArchiveStatistic* arcs = [mKT objectForKey:key];    if (!arcs) {[mKT setObject:arcs=[[O3ArchiveStatistic alloc] init] forKey:key]; setKey(arcs, key);} incCount(arcs);}
#define incrementStringCounter(key) {O3ArchiveStatistic* arcs = [mST objectForKey:key]; if (!arcs) {[mST setObject:arcs=[[O3ArchiveStatistic alloc] init] forKey:key]; setKey(arcs, key);} incCount(arcs);}
#define incrementClassCounter(key) {O3ArchiveStatistic* arcs = [mCT objectForKey:key];  if (!arcs) {[mCT setObject:arcs=[[O3ArchiveStatistic alloc] init] forKey:key]; setKey(arcs, key);} incCount(arcs);}
#endif

inline NSString* classNameForClassCP(Class c) {
	static Class NSKeyedArchiverClass = nil;
	static IMP NSKeyedArchiverClassNameForClass = nil;
		if (!NSKeyedArchiverClassNameForClass) NSKeyedArchiverClassNameForClass = [(NSKeyedArchiverClass=[NSKeyedArchiver class]) methodForSelector:@selector(classNameForClass:)];
	return NSKeyedArchiverClassNameForClass(NSKeyedArchiverClass, @selector(classNameForClass:));
}

/************************************/ #pragma mark O3WriteTypedObjectKey Writing Methods /************************************/
- (void)encodeBool:(BOOL)v forKey:(NSString*)k {incrementKeyCounter(k);}
- (void)encodeBytes:(void*)ptr length:(UIntP)len forKey:(NSString*)k {incrementKeyCounter(k);}
- (void)encodeConditionalObject:(id)obj forKey:(NSString*)k {incrementKeyCounter(k);}
- (void)encodeDouble:(double)v forKey:(NSString*)k {incrementKeyCounter(k);}
- (void)encodeFloat:(float)v forKey:(NSString*)k {incrementKeyCounter(k);}
- (void)encodeInt:(int)v forKey:(NSString*)k {incrementKeyCounter(k);}
- (void)encodeInt32:(Int32)v forKey:(NSString*)k {incrementKeyCounter(k);}
- (void)encodeInt64:(Int64)v forKey:(NSString*)k {incrementKeyCounter(k);}
- (void)encodeUInt64:(UInt64)v forKey:(NSString*)k {incrementKeyCounter(k);}
- (void)encodePoint:(NSPoint)pt forKey:(NSString*)k {incrementKeyCounter(k);}
- (void)encodeRect:(NSRect)r forKey:(NSString*)k {incrementKeyCounter(k);}
- (void)encodeSize:(NSSize)s forKey:(NSString*)k {incrementKeyCounter(k);}
- (void)encodeObject:(id)obj forKey:(NSString*)k {
	if (k) incrementKeyCounter(k);
	if ([obj isSpeciallyHandledByO3Archiver]) {
		//if ([obj isKindOfClass:[NSValue class]]) {}
		if ([obj isKindOfClass:[NSString class]]) {incrementStringCounter(obj);}
		else if ([obj isKindOfClass:[NSArray class]]) {
			UIntP i,j = [(NSArray*)obj count];
			for (i=0; i<j; i++) [self encodeObject:[(NSArray*)obj objectAtIndex:i] forKey:nil];
		}
		else if ([obj isKindOfClass:[NSDictionary class]]) {
			NSEnumerator* keyE = [(NSDictionary*)obj keyEnumerator];
			NSEnumerator* valE = [(NSDictionary*)obj objectEnumerator];
			NSString* key;
			NSObject* val;
			while (key = [keyE nextObject]) {
				val = [valE nextObject]; O3Asrt(val);
				[self encodeObject:val forKey:key];
			}
		}
		return;
	}
	[obj encodeWithCoder:self];
	Class theClass = [obj classForKeyedArchiver] ?: [obj class];
	NSString* archiverOverride = [mClassNameMappings objectForKey:theClass];
	NSString* className = archiverOverride?:[theClass className];
	if (!archiverOverride) {
		NSString* archiverClassOverride = classNameForClassCP(theClass);
		className = archiverClassOverride?:[theClass className];		
	}
	if (theClass) incrementClassCounter(className); //May be NULL because obj may be null
}

- (BOOL)allowsKeyedCoding {return YES;}
@end
