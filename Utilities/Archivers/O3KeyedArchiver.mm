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

NSString* O3UnkeyedMethodSendToKeyedArchiverException = @"O3UnkeyedMethodSendToKeyedArchiverException";
NSPropertyListFormat O3ArchiveFormat0 = (NSPropertyListFormat)'O';

@implementation O3KeyedArchiver
O3DefaultO3InitializeImplementation

#define dieIfArchiving(retval) {if (mArchivingBegun) {O3LogWarn(@"Archiving has already begun on O3KeyedArchiver %@, yet %s was called.", self, NSStringFromSelector(_cmd)); return retval;}}

/************************************/ #pragma mark Creation and Destruction /************************************/
inline void initP(O3KeyedArchiver* self) {
	self->mCompatibility = YES;
	self->mCompress = YES;
	self->mWriter = new O3NonlinearWriter();
}

- (void)dealloc {
	[mCT release];
	[mKT release];
	[mST release];
	[mClassNameMappings release];
	[mDat release];
	[mWrittenClasses release];
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
	mWriter = writer;
	return self;
}*/


+ (NSData*)archivedDataWithRootObject:(id)obj {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSMutableData* d = [NSMutableData dataWithCapacity:32];
	O3KeyedArchiver* a = [[O3KeyedArchiver alloc] initForWritingWithMutableData:d];
	[a encodeObject:obj forKey:@""];
	[a finishEncoding];
	[a release];
	return d;
	[pool release];
}

+ (void)archiveRootObject:(id)obj toFile:(NSString*)file {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	int f = open([file UTF8String], O_RDONLY, 0444);
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

void finishCompressionInitP(O3KeyedArchiver* self) {
	self->mWriter->mKT = [O3ArchiveStringMapFromArray(self->mKT) retain];
	self->mWriter->mST = [O3ArchiveStringMapFromArray(self->mST) retain];
	self->mWriter->mCT = [O3ArchiveStringMapFromArray(self->mCT) retain];
	if ([self->mWriter->mKT count]) [self encodeObject:self->mKT forKey:@"KT"];
	if ([self->mWriter->mST count]) [self encodeObject:self->mST forKey:@"ST"];
	if ([self->mWriter->mCT count]) [self encodeObject:self->mCT forKey:@"CT"];
}

#define beginEncodingIfNecessaryP(obj, theKey) {                                                               \
	if (!self->mArchivingBegun) {                                                                              \
		self->mHeader = self->mWriter->ReservePlaceholder();                                                   \
		self->mArchivingBegun = YES;                                                                           \
		if (self->mCompatibility) {                                                                            \
			self->mWrittenClasses = [NSMutableSet new];                                                        \
		}                                                                                                      \
		if (self->mCompress) {                                                                                 \
			[O3ArchiveStatisticsGatherer gatherStatisticsForRootObject:obj                                     \
    	                                                           key:theKey                                  \
    	                                                            KT:&(self->mKT)                            \
    	                                                            ST:&(self->mST)                            \
																	CT:&(self->mCT)                            \
														  classNameMap:self->mClassNameMappings];              \
			finishCompressionInitP(self);                                                                      \
		}                                                                                                      \
	}                                                                                                          \
}

///Doesn't actually finish encoding, just flushes it to the data. Note that this is probably inefficient (data copy). Use the class methods if you can.
///Worst hack I've ever done.
- (void)finishEncoding {
	O3AssertIvar(mWriter && (mDat || mFD));
	[mDelegate archiverWillFinish:(NSKeyedArchiver*)self];
	
	beginEncodingIfNecessaryP(nil, nil);
	if (mCompatibility) {
		O3Optimizable();
		NSMutableData* dat = [NSMutableData new];
		O3KeyedArchiver* arch = [[O3KeyedArchiver alloc] initForWritingWithMutableData:dat];
		[arch retain];
		NSMutableDictionary* dict = [NSMutableDictionary new];
		NSEnumerator* classEnum = [mWrittenClasses objectEnumerator];
		while (Class curclass = [classEnum nextObject]) {
			NSArray* fallbacks = [curclass classFallbacksForKeyedArchiver];
			if (fallbacks) [dict setObject:fallbacks forKey:[curclass className]];
		}
		[arch encodeObject:dict forKey:@"C"];
		mWriter->WriteDataAtPlaceholder(dat, mHeader);
		[dict release];
		[arch release];
		[dat release];
	}
	
	if (mDat) [mDat appendData:mWriter->Data()];
	else if (mFD) mWriter->WriteToFileDescriptor(mFD);
	O3Asrt(!mDat&&mFD || mDat&&!mFD);
	[mDelegate archiverDidFinish:(NSKeyedArchiver*)self];
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
- (void)encodeBool:(BOOL)v forKey:(NSString*)k {
	O3AssertIvar(mWriter); beginEncodingIfNecessaryP([NSNumber numberWithBool:NO], k);
	mWriter->WriteKVHeaderAtPlaceholder(k, nil, 0, v?O3PkgTypeTrue:O3PkgTypeFalse, mWriter->ReservePlaceholder());
}

- (void)encodeBytes:(void*)ptr length:(UIntP)len forKey:(NSString*)k {
	O3AssertIvar(mWriter); beginEncodingIfNecessaryP([NSData dataWithBytesNoCopy:ptr length:len freeWhenDone:NO], k);
	mWriter->WriteKVHeaderAtPlaceholder(k, nil, len, O3PkgTypeRawData, mWriter->ReservePlaceholder());
	mWriter->WriteBytesAtPlaceholder(ptr, len, mWriter->ReservePlaceholder());
}

- (void)encodeConditionalObject:(id)obj forKey:(NSString*)k {
	//O3AssertIvar(mWriter);  beginEncodingIfNecessaryP(self);
	//Note to self: fill this in in the dummy archiver as well
	O3Assert(false, @"-encodeConditionalObject is not supported in O3KeyedArchiver");
}

- (void)encodeDouble:(double)v forKey:(NSString*)k {
	O3AssertIvar(mWriter); beginEncodingIfNecessaryP([NSNumber numberWithDouble:v], k);
	mWriter->WriteKVHeaderAtPlaceholder(k, nil, sizeof(double), O3PkgTypeFloat, mWriter->ReservePlaceholder());
	mWriter->WriteDoubleAtPlaceholder(v, mWriter->ReservePlaceholder());
}

- (void)encodeFloat:(float)v forKey:(NSString*)k {
	O3AssertIvar(mWriter); beginEncodingIfNecessaryP([NSNumber numberWithFloat:v], k);
	mWriter->WriteKVHeaderAtPlaceholder(k, nil, sizeof(float), O3PkgTypeFloat, mWriter->ReservePlaceholder());
	mWriter->WriteFloatAtPlaceholder(v, mWriter->ReservePlaceholder());
}

inline void encodeInt64P(O3KeyedArchiver* self, NSString* k, UInt64 v, BOOL negative = NO) {
	O3AssertIvar(self->mWriter); beginEncodingIfNecessaryP(negative?[NSNumber numberWithLongLong:v]:[NSNumber numberWithUnsignedLongLong:v], k);
	int size = O3BytesNeededForUInt(v);
	self->mWriter->WriteKVHeaderAtPlaceholder(k, nil, size, negative?O3PkgTypeNegativeInt:O3PkgTypePositiveInt, self->mWriter->ReservePlaceholder());
	self->mWriter->WriteUIntAsBytesAtPlaceholder(v, size, self->mWriter->ReservePlaceholder());
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

inline void writeValueP(O3KeyedArchiver* self, NSValue* v, NSString* k) {
	O3AssertIvar(self->mWriter);  beginEncodingIfNecessaryP(v, k);
	UIntP header_placeholder = self->mWriter->ReservePlaceholder();
	const char* vtype = [v objCType];
	unsigned int size; NSGetSizeAndAlignment(vtype, &size, nil);
	void* buf = malloc(size);
	self->mWriter->WriteBytesAtPlaceholder(buf, size, self->mWriter->ReservePlaceholder(), NO);
	self->mWriter->WriteKVHeaderAtPlaceholder(k, nil, size, O3PkgTypeValue, header_placeholder);
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

///@todo Add runtime response checks
- (void)encodeObject:(id)obj forKey:(NSString*)k {
	if (!obj) return;
	O3AssertIvar(mWriter);  beginEncodingIfNecessaryP(obj, k);
	[mDelegate archiver:(NSKeyedArchiver*)self willEncodeObject:obj];
	static NSNumber* trueNumber = nil;  if (!trueNumber)  trueNumber  = [NSNumber numberWithBool:YES];
	static NSNumber* falseNumber = nil; if (!falseNumber) falseNumber = [NSNumber numberWithBool:NO];
	if ([obj isSpeciallyHandledByO3Archiver]) {
		if ([obj isKindOfClass:[NSValue class]]) {
			if ([trueNumber isEqual:obj])
				mWriter->WriteKVHeaderAtPlaceholder(k, nil, 0, O3PkgTypeTrue, mWriter->ReservePlaceholder());
			else if ([falseNumber isEqual:obj])
				mWriter->WriteKVHeaderAtPlaceholder(k, nil, 0, O3PkgTypeFalse, mWriter->ReservePlaceholder());
			else {
				const char* t = [obj objCType];
				switch (*t) {
					case 'd': [self encodeDouble:[(NSNumber*)obj doubleValue] forKey:k]; break;
					case 'f': [self encodeFloat:[(NSNumber*)obj floatValue] forKey:k]; break;
					case 'c': case 'C': 
					case 's': case 'S':
					case 'i': case 'I':
					case 'l': case 'q': {
						Int64 v = [(NSNumber*)obj longLongValue];
						encodeInt64P(self, k, ::llabs(v), v<0);
						break;
					}
					case 'Q': case 'L': encodeInt64P(self, k, [(NSNumber*)obj unsignedLongLongValue], NO); break;
					default: writeValueP(self, (NSValue*)obj, k);
				} //Switch
			} //else
		} //is NSValue
		else if ([obj isKindOfClass:[NSData class]]) {
			mWriter->WriteKVHeaderAtPlaceholder(k, nil, [(NSData*)obj length], O3PkgTypeRawData, mWriter->ReservePlaceholder());
			mWriter->WriteDataAtPlaceholder((NSData*)obj, mWriter->ReservePlaceholder());
		}
		else if ([obj isKindOfClass:[NSString class]]) {
			UIntP header_placeholder = mWriter->ReservePlaceholder();
			mWriter->WriteBytesAtPlaceholder([(NSString*)obj UTF8String], [(NSString*)obj lengthOfBytesUsingEncoding:NSUTF8StringEncoding], mWriter->ReservePlaceholder());
			UIntP size = mWriter->BytesWrittenAfterPlaceholder(header_placeholder);
			mWriter->WriteKVHeaderAtPlaceholder(k, nil, size, O3PkgTypeString, header_placeholder);
		}
		else if ([obj isKindOfClass:[NSArray class]]) {
			UIntP header_placeholder = mWriter->ReservePlaceholder();
			UIntP i,j = [(NSArray*)obj count];
			for (i=0; i<j; i++) [self encodeObject:[(NSArray*)obj objectAtIndex:i] forKey:nil];
			UIntP size = mWriter->BytesWrittenAfterPlaceholder(header_placeholder);
			mWriter->WriteKVHeaderAtPlaceholder(k, nil, size, O3PkgTypeArray, header_placeholder);
		}
		else if ([obj isKindOfClass:[NSDictionary class]]) {
			UIntP header_placeholder = mWriter->ReservePlaceholder();
			NSEnumerator* keyE = [(NSDictionary*)obj keyEnumerator];
			NSEnumerator* valE = [(NSDictionary*)obj objectEnumerator];
			NSString* key;
			NSObject* val;
			while (key = [keyE nextObject]) {
				val = [valE nextObject]; O3Asrt(val);
				[self encodeObject:val forKey:key];
			}
			UIntP size = mWriter->BytesWrittenAfterPlaceholder(header_placeholder);
			mWriter->WriteKVHeaderAtPlaceholder(k, nil, size, O3PkgTypeDictionary, header_placeholder);
			
		}
		else O3AssertFalse(@"No special case found, but %@ (for key %@) responds YES to isSpeciallyHandledByO3Archiver", obj, k);
		return;
	}
	obj = [obj replacementObjectForKeyedArchiver:(NSKeyedArchiver*)self]?:obj;
	UIntP header_placeholder = mWriter->ReservePlaceholder();
	[obj encodeWithCoder:self];
	UIntP size = mWriter->BytesWrittenAfterPlaceholder(header_placeholder);
	Class theClass = [obj classForKeyedArchiver]?:[obj class];
	NSString* className = O3KeyedArchiverEncodedNameOfClass(self, theClass);
	if (mCompatibility) O3CFSetAddValue(mWrittenClasses, theClass);
	mWriter->WriteKVHeaderAtPlaceholder(k, className, size, O3PkgTypeObject, header_placeholder);
	[mDelegate archiver:(NSKeyedArchiver*)self didEncodeObject:obj];
}

- (void)encodePoint:(NSPoint)pt forKey:(NSString*)k {
	writeValueP(self, [NSValue valueWithPoint:pt], k);
}

- (void)encodeRect:(NSRect)r forKey:(NSString*)k {
	writeValueP(self, [NSValue valueWithRect:r], k);
}

- (void)encodeSize:(NSSize)s forKey:(NSString*)k {
	writeValueP(self, [NSValue valueWithSize:s], k);
}

@end

#define ClassIsSpeciallyHandledByO3Archiver(class, special) @implementation class (O3KeyedArchiverSpecialness) - (BOOL)isSpeciallyHandledByO3Archiver {return special;} @end
ClassIsSpeciallyHandledByO3Archiver(NSObject, NO);
ClassIsSpeciallyHandledByO3Archiver(NSValue, YES);
ClassIsSpeciallyHandledByO3Archiver(NSData, YES);
ClassIsSpeciallyHandledByO3Archiver(NSString, YES);
ClassIsSpeciallyHandledByO3Archiver(NSArray, YES);
ClassIsSpeciallyHandledByO3Archiver(NSDictionary, YES);
#undef ClassIsSpeciallyHandledByO3Archiver
