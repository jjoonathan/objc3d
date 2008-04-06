/**
 *  @file O3KeyedArchiver.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 4/18/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3ArchiveFormat.h"
#import "O3KeyedArchiver.h"
#import "O3NonlinearWriter.h"
#import "O3ArchiveStatisticsGatherer.h"
#import "NSData+zlib.h"
#import "O3GPUData.h"

NSString* O3UnkeyedMethodSendToKeyedArchiverException = @"O3UnkeyedMethodSendToKeyedArchiverException";
NSPropertyListFormat O3ArchiveFormat0 = (NSPropertyListFormat)'O';

@implementation O3KeyedArchiver
O3DefaultO3InitializeImplementation

#define dieIfArchiving(retval) {if (mArchivingBegun) {O3LogWarn(@"Archiving has already begun on O3KeyedArchiver %@, yet %s was called.", self, NSStringFromSelector(_cmd)); return retval;}}

/************************************/ #pragma mark Creation and Destruction /************************************/
inline void initP(O3KeyedArchiver* self) {
	self->mCompatibility = YES;
	self->mCompress = YES;
	self->mArchInfo = new O3ArchiveInfo();
	self->mArchInfo->writer = new O3NonlinearWriter();
	self->mArchInfo->archiver = self;
}

- (void)dealloc {
	[mCT release];
	[mKT release];
	[mST release];
	[mClassNameMappings release];
	[mDat release];
	[mWrittenClasses release];
	if (mArchInfo) {
		[mArchInfo->writer->mKT release];
		[mArchInfo->writer->mST release];
		[mArchInfo->writer->mCT release];
		delete mArchInfo->writer;
		delete mArchInfo;
		mArchInfo=NULL;
	}
	O3SuperDealloc();
}

///@param dat nil is acceptable (a data will be created)
- (id)initForWritingWithMutableData:(NSMutableData*)dat {
	O3SuperInitOrDie();
	initP(self);
	O3Assign(dat, mDat);
	return self;
}

- (id)initForWritingWithFileDescriptor:(int)fd {
	O3SuperInitOrDie();
	initP(self);
	mFD = fd;
	return self;	
}

/*- (id)initForWritingWithWriter:(O3NonlinearWriter*)writer {
	O3SuperInitOrDie();
	initP(self);
	mArchInfo->writer = writer;
	return self;
}*/


+ (NSData*)archivedDataWithRootObject:(id)obj {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSMutableData* d = [NSMutableData dataWithCapacity:512];
	O3KeyedArchiver* a = [[O3KeyedArchiver alloc] initForWritingWithMutableData:d];
	[a encodeObject:obj forKey:@""];
	[a finishEncoding];
	[a release];
	[d retain];
	[pool release];
	return [d autorelease];
}

+ (void)archiveRootObject:(id)obj toFile:(NSString*)file {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	int f = open([file UTF8String], O_WRONLY+O_TRUNC+O_CREAT, 0666);
	O3KeyedArchiver* a = [[O3KeyedArchiver alloc] initForWritingWithFileDescriptor:f];
	[a encodeObject:obj forKey:@""];
	[a finishEncoding];
	[a release];
	close(f);
	[pool release];
}

+ (void)archiveRootObject:(id)obj toFileDescriptor:(int)fd {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	O3KeyedArchiver* a = [[O3KeyedArchiver alloc] initForWritingWithFileDescriptor:fd];
	[a encodeObject:obj forKey:@""];
	[a finishEncoding];
	[a release];
	[pool release];
}


/************************************/ #pragma mark O3WriteTypedObjectKey Remaping /************************************/
inline NSString* classNameForClassCP(Class c) {
	static Class NSKeyedArchiverClass = nil;
	static IMP NSKeyedArchiverClassNameForClass = nil;
		if (!NSKeyedArchiverClassNameForClass) NSKeyedArchiverClassNameForClass = [(NSKeyedArchiverClass=[NSKeyedArchiver class]) methodForSelector:@selector(classNameForClass:)];
	return NSKeyedArchiverClassNameForClass(NSKeyedArchiverClass, @selector(classNameForClass:));
}

+ (void)setClassName:(NSString*)mapTo forClass:(Class)mapFrom {
	[NSKeyedArchiver setClassName:mapTo forClass:mapFrom];
}

+ (NSString*)classNameForClass:(Class)theClass {
	return classNameForClassCP(theClass);
}

- (void)setClassName:(NSString*)mapTo forClass:(Class)mapFrom {
	if (!mClassNameMappings) mClassNameMappings = [NSMutableDictionary new];
	[mClassNameMappings setObject:mapTo forKey:mapFrom];
}

- (NSString*)classNameForClass:(Class)theClass {
	return [mClassNameMappings objectForKey:theClass];
}

/************************************/ #pragma mark Accessors /************************************/
///This class ONLY allows keyed coding
- (BOOL)allowsKeyedCoding {return YES;}
- (NSPropertyListFormat)outputFormat {return O3ArchiveFormat0;}
- (void)setOutputFormat:(NSPropertyListFormat)newFormat {O3AssertArg(newFormat==O3ArchiveFormat0, @"Right now O3KeyedArchiver can only archive in the O3ArchiveFormat0 format");}
- (id)delegate {return mDelegate;}
- (void)setDelegate:(id)newDelegate {mDelegate = newDelegate;}
- (BOOL)writesCompatibilityData {return mCompatibility;}
- (void)setWritesCompatibilityData:(BOOL)shouldWrite {dieIfArchiving(); mCompatibility = shouldWrite;}
- (BOOL)shouldCompress {return mCompress;}
- (void)setShouldCompress:(BOOL)shouldCompress {dieIfArchiving(); mCompress = shouldCompress;}

/************************************/ #pragma mark Subclass-revoked methods /************************************/
#define RaiseSubclassRevoked() [NSException raise:O3UnkeyedMethodSendToKeyedArchiverException \
format:@"%@ can't handle method \"%s\" since it is meant for an unkeyed archiver, so it doesn't make sense to call it on a keyed archiver.", self, _cmd] 
- (void)encodeRect:(NSRect*)r {RaiseSubclassRevoked();}
- (void)encodePoint:(NSPoint)pt {RaiseSubclassRevoked();}
- (void)encodeObject:(id)obj {RaiseSubclassRevoked();}
- (void)encodeNXObject:(id)obj {RaiseSubclassRevoked();}
- (void)encodeDataObject:(NSData*)obj {RaiseSubclassRevoked();}
- (void)encodeConditionalObject:(id)obj {RaiseSubclassRevoked();}
- (void)encodeBytes:(void*)ptr length:(UIntP)len {RaiseSubclassRevoked();}
- (void)encodeByrefObject:(id)obj {RaiseSubclassRevoked();}
- (void)encodeBycopyObject:(id)obj {RaiseSubclassRevoked();}
- (void)encodeArrayOfObjCType:(const char*)type count:(UIntP)ct at:(void*)ptr {RaiseSubclassRevoked();}
- (void)encodeValueOfObjCType:(const char*)type at:(void*)ptr {RaiseSubclassRevoked();}
#undef RaiseSubclassRevoked

/************************************/ #pragma mark O3WriteTypedObjectKey Writing Methods /************************************/
inline void beginWithArchiver_key_tenativeObj_(O3KeyedArchiver* a, NSString* k, id obj) {
	if (!a->mArchivingBegun) [a beginEncodingWithTenativeRoot:obj];
	O3AssertIvar(a->mArchInfo->writer);
	O3ChildEnt ent;
	ent.key = [k retain];
	ent.offset = a->mArchInfo->writer->LastPlaceholder();
	a->mArchInfo->children.top().push_back(ent);
}

inline void endWithArchiver_className_pkgType(O3KeyedArchiver* a, NSString* cname, O3PkgType ptype) {
	O3ChildEnt& e = a->mArchInfo->children.top().back();
	e.className = [cname retain];
	e.len = a->mArchInfo->writer->BytesWrittenAfterPlaceholder(e.offset);
	e.type = ptype;
}

- (void)encodeBool:(BOOL)v forKey:(NSString*)k {
	beginWithArchiver_key_tenativeObj_(self, k, nil);
	endWithArchiver_className_pkgType(self, nil, v?O3PkgTypeTrue:O3PkgTypeFalse);
}

- (void)encodeBytes:(const void*)ptr length:(UIntP)len forKey:(NSString*)k {
	void* myptr = O3MemDup(ptr, len);
	beginWithArchiver_key_tenativeObj_(self, k, nil);
	mArchInfo->writer->WriteBytesAtPlaceholder(myptr, len, mArchInfo->writer->ReservePlaceholder(), YES);
	endWithArchiver_className_pkgType(self, nil, O3PkgTypeRawData);
}

- (void)encodeConditionalObject:(id)obj forKey:(NSString*)k {
	//O3AssertIvar(mArchInfo->writer);  beginEncodingIfNecessaryP(self);
	//Note to self: fill this in in the dummy archiver as well
	O3Assert(false, @"-encodeConditionalObject is not supported in O3KeyedArchiver");
}

- (void)encodeDouble:(double)v forKey:(NSString*)k {
	Int64 iv = v; if (iv==v) return [self encodeInt64:iv forKey:k];
	float fv = v; if (fv==v) return [self encodeFloat:v forKey:k];
	beginWithArchiver_key_tenativeObj_(self, k, nil);
	mArchInfo->writer->WriteDoubleAtPlaceholder(v, mArchInfo->writer->ReservePlaceholder());
	endWithArchiver_className_pkgType(self, nil, O3PkgTypeFloat);
}

- (void)encodeFloat:(float)v forKey:(NSString*)k {
	Int64 iv = v; if (iv==v) return [self encodeInt64:iv forKey:k];
	beginWithArchiver_key_tenativeObj_(self, k, nil);
	mArchInfo->writer->WriteFloatAtPlaceholder(v, mArchInfo->writer->ReservePlaceholder());
	endWithArchiver_className_pkgType(self, nil, O3PkgTypeFloat);
}

inline void encodeInt64P(O3KeyedArchiver* self, NSString* k, UInt64 v, BOOL negative = NO) {
	beginWithArchiver_key_tenativeObj_(self, k, nil);
	UIntP p = self->mArchInfo->writer->ReservePlaceholder();
	self->mArchInfo->writer->WriteUIntAsBytesAtPlaceholder(v, O3BytesNeededForUInt(v), p);
	endWithArchiver_className_pkgType(self, nil, negative?O3PkgTypeNegativeInt:O3PkgTypePositiveInt);
}

- (void)encodeInt:(int)v forKey:(NSString*)k {
	encodeInt64P(self, k, ::llabs(v), v<0);
}

- (void)encodeInt32:(Int32)v forKey:(NSString*)k {
	encodeInt64P(self, k, ::llabs(v), v<0);
}

- (void)encodeInt64:(Int64)v forKey:(NSString*)k {
	encodeInt64P(self, k, ::llabs(v), v<0);
}

- (void)encodeUInt64:(UInt64)v forKey:(NSString*)k {
	encodeInt64P(self, k, v, NO);
}

NSString* O3KeyedArchiverEncodedNameOfClass(O3KeyedArchiver* self, Class c) {
	NSString* className = [c className]; //Technically the metaclass but it appears to work
	NSString* archiverOverride = [self->mClassNameMappings objectForKey:c];
	className = archiverOverride?:className;
	if (!archiverOverride) {
		NSString* archiverClassOverride = classNameForClassCP(c);
		className = archiverClassOverride?:className;		
	}
	return className;
}

inline NSString* encodeNameOfObjClass(O3KeyedArchiver* self, id obj) {
	Class theClass = [obj classForKeyedArchiver]?:[obj class];
	NSString* className = O3KeyedArchiverEncodedNameOfClass(self, theClass);
	if (self->mCompatibility) O3CFSetAddValue(self->mWrittenClasses, theClass);
	return className;
}

- (void)encodeObject:(id)obj forKey:(NSString*)k {
	#ifdef O3DEBUG
	if (![obj respondsToSelector:@selector(encodeWithO3ArchiveInfo:key:)]) {
		O3LogWarn(@"Ignoring object which does not respond to encodeWithO3ArchiveInfo:key:. Ignoring IN DEBUG MODE ONLY.");
		return;
	}
	#endif
	[obj encodeWithO3ArchiveInfo:mArchInfo key:k];
}

- (void)encodePoint:(NSPoint)pt forKey:(NSString*)k {
	beginWithArchiver_key_tenativeObj_(self, k, nil);
	O3StructType* t = (sizeof(pt.x)==sizeof(float))? O3FloatType() : O3DoubleType();
	O3StructArrayWrite(t, &pt, 2, 0, self->mArchInfo->writer);
	endWithArchiver_className_pkgType(self, nil, O3PkgTypeStructArray);
}

- (void)encodeRect:(NSRect)r forKey:(NSString*)k {
	beginWithArchiver_key_tenativeObj_(self, k, nil);
	O3StructType* t = (sizeof(r.origin.x)==sizeof(float))? O3FloatType() : O3DoubleType();
	O3StructArrayWrite(t, &r, 4, 0, self->mArchInfo->writer);
	endWithArchiver_className_pkgType(self, nil, O3PkgTypeStructArray);
}

- (void)encodeSize:(NSSize)s forKey:(NSString*)k {
	beginWithArchiver_key_tenativeObj_(self, k, nil);
	O3StructType* t = (sizeof(s.width)==sizeof(float))? O3FloatType() : O3DoubleType();
	O3StructArrayWrite(t, &s, 2, 0, self->mArchInfo->writer);
	endWithArchiver_className_pkgType(self, nil, O3PkgTypeStructArray);
}


/************************************/ #pragma mark Init, Finalization of Encoding Process /************************************/
///@param tr The tenative root is used to calculate the frequencies of keys and generate the name tables
- (void)beginEncodingWithTenativeRoot:(id)tr {
	O3Asrt(!mArchivingBegun);
	mArchivingBegun = YES;
	mArchInfo->children.push(O3ArchiveInfo::child_arr_t());
	mHeader = mArchInfo->writer->ReservePlaceholder();
	if (mCompatibility) {
		mWrittenClasses = [NSMutableSet new];
	}
	if (mCompress) {
		if (tr) {
			[O3ArchiveStatisticsGatherer gatherStatisticsForRootObject:tr
																   key:nil
																	KT:&(mKT)
																	ST:&(mST)
																	CT:&(mCT)
														  classNameMap:mClassNameMappings];
			if ([mKT count]) [self encodeObject:mKT forKey:@"KT"];
			if ([mST count]) [self encodeObject:mST forKey:@"ST"];
			if ([mCT count]) [self encodeObject:mCT forKey:@"CT"];
			mArchInfo->writer->mKT = [O3ArchiveStringMapFromArray(mKT) retain];
			mArchInfo->writer->mST = [O3ArchiveStringMapFromArray(mST) retain];
			mArchInfo->writer->mCT = [O3ArchiveStringMapFromArray(mCT) retain];
		}
		mArchInfo->data_compression_level = 8; //zlib level 7
	}
}

- (void)finishEncoding {
	O3AssertIvar(mArchInfo->writer && (mDat || mFD));
	[mDelegate archiverWillFinish:(NSKeyedArchiver*)self];
	
	if (!mArchivingBegun) [self beginEncodingWithTenativeRoot:nil];
	if (mCompatibility && [mWrittenClasses count]) {
		NSMutableDictionary* dict = [NSMutableDictionary new];
		NSEnumerator* classEnum = [mWrittenClasses objectEnumerator];
		while (Class curclass = [classEnum nextObject]) {
			NSArray* fallbacks = [curclass classFallbacksForKeyedArchiver];
			if (fallbacks) [dict setObject:fallbacks forKey:[curclass className]];
		}
		if ([dict count]) [self encodeObject:dict forKey:@"C"];
		[dict release];
	}
	mArchInfo->writer->WriteChildrenHeaderAtPlaceholder(&(mArchInfo->children.top()), mHeader, mArchInfo->writer->mKT, mArchInfo->writer->mCT);
	mArchInfo->children.pop();
	
	if (mDat) [mDat appendData:mArchInfo->writer->Data()];
	if (mFD) mArchInfo->writer->WriteToFileDescriptor(mFD);
	[mDelegate archiverDidFinish:(NSKeyedArchiver*)self];
}

/************************************/ #pragma mark Testing /************************************/
#ifdef O3DEBUG
+ (void)testMem {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSArray* a = [NSArray arrayWithObjects:[NSNumber numberWithInt:1],[NSNumber numberWithInt:2],[NSNumber numberWithInt:3],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:6],@"somestring",@"str2",nil];
	for (UIntP i=0; i<1000; i++) {
		[O3KeyedArchiver archivedDataWithRootObject:a];
	}
	[pool release];
}
#endif

@end



@implementation NSObject (O3KeyedArchiving)
- (void)encodeWithO3ArchiveInfo:(O3ArchiveInfo*)arch key:(NSString*)k {
	beginWithArchiver_key_tenativeObj_(arch->archiver, k, self);
	UIntP headerp = arch->writer->ReservePlaceholder();
	arch->children.push(O3ArchiveInfo::child_arr_t());
	[(id<NSCoding>)self encodeWithCoder:arch->archiver];
	arch->writer->WriteChildrenHeaderAtPlaceholder(&(arch->children.top()), headerp, arch->writer->mKT, arch->writer->mCT);
	arch->children.pop();
	endWithArchiver_className_pkgType(arch->archiver, encodeNameOfObjClass(arch->archiver, self), O3PkgTypeObject);
}
@end

@implementation NSDictionary (O3KeyedArchiving)
- (void)encodeWithO3ArchiveInfo:(O3ArchiveInfo*)arch key:(NSString*)k {
	beginWithArchiver_key_tenativeObj_(arch->archiver, k, self);
	arch->children.push(O3ArchiveInfo::child_arr_t());
	UIntP headerp = arch->writer->ReservePlaceholder();
	NSEnumerator* keyEnum = [self keyEnumerator];
	if (O3AssumeSimultaneousDictEnumeration) {
		NSEnumerator* objEnum = [self objectEnumerator];
		while (id k = [keyEnum nextObject]) {
			id o = [objEnum nextObject];
			[o encodeWithO3ArchiveInfo:arch key:k];
		}
	} else {
		while (id k = [keyEnum nextObject]) {
			id o = [self objectForKey:k];
			[o encodeWithO3ArchiveInfo:arch key:k];
		}
	}
	arch->writer->WriteChildrenHeaderAtPlaceholder(&(arch->children.top()), headerp, arch->writer->mKT, arch->writer->mCT);
	arch->children.pop();
	endWithArchiver_className_pkgType(arch->archiver, nil, O3PkgTypeDictionary);
}
@end

@implementation NSString (O3KeyedArchiving)
- (void)encodeWithO3ArchiveInfo:(O3ArchiveInfo*)arch key:(NSString*)k {
	beginWithArchiver_key_tenativeObj_(arch->archiver, k, nil);
	NSNumber* num = [arch->writer->mST objectForKey:self];
	if (num) {
		UIntP idx = O3NSNumberLongLongValue(num)-1;
		arch->writer->WriteUIntAsBytesAtPlaceholder(idx, O3BytesNeededForUInt(idx),arch->writer->ReservePlaceholder());
		endWithArchiver_className_pkgType(arch->archiver, nil, O3PkgTypeIndexedString);
		return;
	}
	const char* str = NSStringUTF8String(self); UIntP len = strlen(str);
	UIntP ph = arch->writer->ReservePlaceholder();
	arch->writer->WriteBytesAtPlaceholder(str, len, ph);
	endWithArchiver_className_pkgType(arch->archiver, nil, O3PkgTypeString);
}
@end

@implementation NSData (O3KeyedArchiving)
- (void)encodeWithO3ArchiveInfo:(O3ArchiveInfo*)arch key:(NSString*)k {
	UIntP len = [self length];
	BOOL will_compress = arch->data_compression_level;
	beginWithArchiver_key_tenativeObj_(arch->archiver, k, nil);
	if (will_compress) {
		O3DeflationOptions dopts;
		dopts.rawDeflate = YES;
		dopts.compressionLevel=arch->data_compression_level-1;
		NSMutableData* deflated = [self o3DeflateWithOptions:dopts];
		UIntP dlen = [deflated length];
		UIntP dhlen = dlen + O3BytesNeededForTypedObjectHeader(len, nil);
		if (dhlen<len) {
			arch->writer->WriteTypedObjectHeaderAtPlaceholder(nil, len, O3PkgTypeRawData, arch->writer->ReservePlaceholder());
			arch->writer->WriteBytesAtPlaceholder([deflated mutableBytes], dlen, arch->writer->ReservePlaceholder(), NO);
			endWithArchiver_className_pkgType(arch->archiver, nil, O3PkgTypeCompressed);
			return;
		}
	}
	arch->writer->WriteDataAtPlaceholder(self, arch->writer->ReservePlaceholder());
	endWithArchiver_className_pkgType(arch->archiver, nil, O3PkgTypeRawData);
}
@end

@implementation NSArray (O3KeyedArchiving)
- (void)encodeWithO3ArchiveInfo:(O3ArchiveInfo*)arch key:(NSString*)k {
	beginWithArchiver_key_tenativeObj_(arch->archiver, k, self);
	arch->children.push(O3ArchiveInfo::child_arr_t());
	UIntP h = arch->writer->ReservePlaceholder();
	NSEnumerator* selfEnumerator = [self objectEnumerator];
	while (NSObject* o = [selfEnumerator nextObject]) {
		[o encodeWithO3ArchiveInfo:arch key:nil];
	}
	arch->writer->WriteChildrenHeaderAtPlaceholder(&(arch->children.top()), h, arch->writer->mKT, arch->writer->mCT);
	arch->children.pop();
	endWithArchiver_className_pkgType(arch->archiver, nil, O3PkgTypeArray);	
}
@end

@implementation O3StructArray (O3KeyedArchiving)
- (void)encodeWithO3ArchiveInfo:(O3ArchiveInfo*)arch key:(NSString*)k {
	beginWithArchiver_key_tenativeObj_(arch->archiver, k, self);
	NSData* d = [self rawData];
	O3StructArrayWrite([self structType], [d bytes], [self count], 0, arch->writer);
	[d relinquishBytes];
	endWithArchiver_className_pkgType(arch->archiver, nil, O3PkgTypeStructArray);	
}
@end

@implementation NSValue (O3KeyedArchiving)
- (void)encodeWithO3ArchiveInfo:(O3ArchiveInfo*)arch key:(NSString*)k {
	static NSNumber* trueNumber = nil;  if (!trueNumber)  trueNumber  = [NSNumber numberWithBool:YES];
	static NSNumber* falseNumber = nil; if (!falseNumber) falseNumber = [NSNumber numberWithBool:NO];
	if ([trueNumber isEqual:self]) {[arch->archiver encodeBool:YES forKey:k]; return;}
	if ([falseNumber isEqual:self]) {[arch->archiver encodeBool:NO forKey:k]; return;}
	const char* t = [self objCType];
	switch (*t) {
		case 'd': [arch->archiver encodeDouble:[(NSNumber*)self doubleValue] forKey:k]; return;
		case 'f': [arch->archiver encodeFloat:[(NSNumber*)self floatValue] forKey:k]; return;
		case 'c': case 'C': 
		case 's': case 'S':
		case 'i': case 'I':
		case 'l': case 'q': {
			Int64 v = [(NSNumber*)self longLongValue];
			[arch->archiver encodeInt64:v forKey:k];
			return;
		}
		case 'Q': case 'L': {
			UInt64 v = [(NSNumber*)self unsignedLongLongValue];
			[arch->archiver encodeUInt64:v forKey:k];
			return;
		}
	} //Switch
	[super encodeWithO3ArchiveInfo:arch key:k];
}
@end