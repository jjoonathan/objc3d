/**
* @file O3Accelerate.h
 * This file holds general documentation for O3Accelerate as well as some O3Accelerate functions for
 * common classes (NSString, NSDictionary, etc.)
 **/

/************************************/ #pragma mark Core Foundation Compatibility /************************************/
//Eventually we may want to port Own3D to a system without CF. This prepares for that.
//These are named using their CF names because CF is a bit more restrictive about input: it complains about nils and such, and the user ought to be aware of that before using these
//Also note that none of these are type safe.
#ifdef O3UseCoreFoundation
#define O3CFRetain(x) CFRetain((CFArrayRef)x)
#define O3CFRelease(x) CFRelease((CFArrayRef)x)
#define O3CFArrayGetCount(x) CFArrayGetCount((CFArrayRef)x)
#define O3CFDictionarySetValue(dict, key, value) CFDictionarySetValue((CFMutableDictionaryRef)dict, key, value)
#define O3CFDictionaryGetValue(dict, key)  CFDictionaryGetValue((CFDictionaryRef)dict, key)
#define O3CFDataGetBytes(dat)  CFDataGetBytePtr((CFDataRef)dat)
#define O3CFArrayGetValueAtIndex(arr, idx) CFArrayGetValueAtIndex((CFArrayRef)arr, idx)
#define O3NSNumberWithLong(l) [(NSNumber*)CFNumberCreate(NULL, kCFNumberLongType, &l) autorelease]
#define O3NSNumberWithLongLong(l) [(NSNumber*)CFNumberCreate(NULL, kCFNumberLongLongType, &l) autorelease]
#define O3CFArrayGetFirstIndexOfValue(arr, v) CFArrayGetFirstIndexOfValue((NSArray*)arr, (CFRange){0,0}, v)
#define O3CFArrayAppendValue(arr, v) CFArrayAppendValue((CFMutableArrayRef)arr, v)
#define O3CFSetAddValue(set, v) CFSetAddValue((CFMutableSetRef)set, v)
#define O3CFArraySetValueAtIndex(mutable_array, index, value) CFArraySetValueAtIndex((CFMutableArrayRef)mutable_array, index, value)
inline long long O3NSNumberLongLongValue(NSNumber* num) {
	long long val; CFNumberGetValue((CFNumberRef)num, kCFNumberLongLongType, &val);
	return val;
}
#else
#define O3CFRetain(x) [(NSObject*)x retain]
#define O3CFRelease(x) [(NSObject*)x release]
#define O3CFArrayGetCount(x) [(NSArray*)x count]
#define O3CFDictionarySetValue(dict, key, value) [(NSMutableDictionary*)dict setObject:value forKey:key] /**@warning set nil may not work**/
#define O3CFDictionaryGetValue(dict, key)  [(NSDictionary*)dict objectForKey:key]
#define O3CFDataGetBytes(dat)  [dat bytes]
#define O3CFArrayGetValueAtIndex(arr, idx) [(NSArray*)arr objectAtIndex:idx]
#define O3NSNumberWithLong(l) [NSNumber numberWithLong:l]
#define O3NSNumberWithLongLong(l) [NSNumber numberWithLongLong:l]
#define O3CFArrayGetFirstIndexOfValue(arr, v) [(NSArray*)arr indexOfObject:v]
#define O3CFArrayAppendValue(arr, v) [(NSMutableArray*)arr addObject:v]
#define O3CFSetAddValue(set, v) [(NSMutableSet*)set addObject:v]
#define O3NSNumberLongLongValue(num) [num longLongValue]
#define O3CFArraySetValueAtIndex(mutable_array, index, value) [(NSMutableArray*)mutable_array replaceObjectAtIndex:index withObject:value]
#endif

/************************************/ #pragma mark More Core Foundation stuff /************************************/
inline void NSDictionaryGetKeysAndValues(NSDictionary* dictionary, NSArray** keys, NSArray** values) {
/*#ifdef O3UseCoreFoundation
	if (!keys && !values) return;
	UIntP kvcount = (CFDictionaryRef)dictionary);
	const void** raw_keys = (const void**)malloc(2*kvcount*sizeof(const void*));
	const void** raw_values = raw_keys + kvcount;
	CFDictionaryGetKeysAndValues((CFDictionaryRef)dictionary, raw_keys, raw_values);
	if (keys) keys = [(NSArray*) autorelease];
#else*/
	if (keys) *keys = [[dictionary keyEnumerator] allObjects];
	if (values) *values = [[dictionary objectEnumerator] allObjects];
//#endif
}

#ifndef O3UseCoreFoundation
static IMP NSStringInitWithBytesLengthEncoding = nil;
static IMP NSStringInitWithBytesNoCopyEtc = nil;
static IMP NSStringAutoreleaseMethod = nil;
#endif
static id NSStringAllocPlaceholder = nil;

static void O3AccelerateInitialize() {
	static BOOL initialized = NO; if (initialized) return; initialized = YES;
	#ifndef O3UseCoreFoundation
	NSStringAllocPlaceholder = [NSString allocWithZone:nil];
	NSStringInitWithBytesLengthEncoding = [NSStringAllocPlaceholder methodForSelector:@selector(initWithBytes:length:encoding:)];
	NSStringInitWithBytesNoCopyEtc = [NSStringAllocPlaceholder methodForSelector:@selector(initWithBytesNoCopy:length:encoding:freeWhenDone:)];
	#endif
	NSStringAutoreleaseMethod = [NSString methodForSelector:@selector(autorelease)];
}

inline NSString* NSStringWithUTF8String(const char* str, IntP len = -1) {
	O3AccelerateInitialize();
	if (len==-1) len = strlen(str);
	#ifndef O3UseCoreFoundation
	NSString* nsstr = NSStringInitWithBytesLengthEncoding(NSStringAllocPlaceholder, @selector(initWithBytes:length:encoding:),   str, len, NSUTF8StringEncoding);
	return NSStringAutoreleaseMethod(nsstr, @selector(autorelease));
	#else
	return NSStringAutoreleaseMethod(   CFStringCreateWithBytes(NULL, str, len, false)   );
	#endif
}

inline NSString* NSStringWithUTF8StringNoCopy(const char* str, IntP len = -1, BOOL freeWhenDone = YES) {
	O3AccelerateInitialize();
	if (len==-1) len = strlen(str);
	#ifndef O3UseCoreFoundation
	NSString* nsstr = NSStringInitWithBytesNoCopyEtc(NSStringAllocPlaceholder, @selector(initWithBytesNoCopy:length:encoding:freeWhenDone:),   str, len, NSUTF8StringEncoding, freeWhenDone);
	return NSStringAutoreleaseMethod(nsstr, @selector(autorelease));
	#else
	return NSStringAutoreleaseMethod(   CFStringCreateWithBytesNoCopy(NULL, str, len, NSUTF8StringEncoding, false, kCFAllocatorDefault)   );
	#endif
}

/************************************/ #pragma mark NSString Acceleration /************************************/
inline const char* NSString_cString(NSString* self) {
	//	const char* to_return = NULL;
	//#ifdef __COREFOUNDATION__
	//	to_return = CFStringGetCStringPtr((CFStringRef)self, NSUTF8StringEncoding);
	//	if (!to_return) to_return = CFStringGetCharactersPtr((CFStringRef)self);
	//#elif
	//	//O3LogInfo(@"NSString_cString(NSString* self) should be compiled with Core Foundation available for maximum speed.");
	//#endif
	//	if (!to_return) {
	typedef const char* (*O3UTF8StringMethodPtr)(NSString*, SEL);
	static O3UTF8StringMethodPtr O3NSStringGetUTF8String;
	if (!O3NSStringGetUTF8String) O3NSStringGetUTF8String = (O3UTF8StringMethodPtr)[NSString instanceMethodForSelector:@selector(UTF8String)];
	const char* to_return = O3NSStringGetUTF8String(self, @selector(UTF8String));
	//		O3LogInfo(@"NSString_cString(NSString* self) had to use the fallback method of NSString -> cString conversion on *(char*)0x%X = \"%s\".", to_return, to_return);
	//	}
	return to_return;
}

inline NSString* NSString_allocInitWithBytesNoCopy_length_encoding_freeWhenDone_(const void* bytes, unsigned length, NSStringEncoding encoding, BOOL freeWhenDone) {
	typedef NSString* (*massive_method_t)(NSString* self, SEL cmd, const void* bytes, unsigned len, NSStringEncoding enc, BOOL freeWhenDone);
	typedef NSString* (*alloc_t)(Class strclass, SEL cmd);
	
	static int allocation_method = -1; //-1=undetermined, 1=constant_placeholder, 0=real_alloc
	if (allocation_method==-1) {
		NSString* a = [NSString alloc];
		NSString* b = [NSString alloc];
		allocation_method = a==b;
		[a release];
		[b release];
	}
	if (allocation_method) {
		static NSString* placeholder = nil;
			if (!placeholder) placeholder = [NSString alloc];
		static massive_method_t NSString_initWithBytesNoCopyEtc;
			if (!NSString_initWithBytesNoCopyEtc) NSString_initWithBytesNoCopyEtc = (massive_method_t)[placeholder methodForSelector:@selector(initWithBytesNoCopy:length:encoding:freeWhenDone:)];
		return NSString_initWithBytesNoCopyEtc(placeholder, @selector(initWithBytesNoCopy:length:encoding:freeWhenDone:), bytes, length, encoding, freeWhenDone);
	} else {
		static alloc_t NSString_alloc = nil;
			if (!NSString_alloc) NSString_alloc = (alloc_t)[NSString methodForSelector:@selector(alloc)];
		Class NSString_class = nil;
			if (!NSString_class) NSString_class = [NSString class];
			
		NSString* alloced_string = NSString_alloc(NSString_class, @selector(alloc));
		
		static massive_method_t NSString_initWithBytesNoCopyEtc;
			if (!NSString_initWithBytesNoCopyEtc) NSString_initWithBytesNoCopyEtc = (massive_method_t)[alloced_string methodForSelector:@selector(initWithBytesNoCopy:length:encoding:freeWhenDone:)];
		
		return NSString_initWithBytesNoCopyEtc(alloced_string, @selector(initWithBytesNoCopy:length:encoding:freeWhenDone:), bytes, length, encoding, freeWhenDone);
	}
	O3AssertFalse();
	return nil;
}

inline void NSMutableArray_addObjectsFromCArray(NSMutableArray* self, id* carray, unsigned count) {
	unsigned i;
	IMP addObjectImp = [self methodForSelector:@selector(addObject:)];
	for (i=0;i<count;i++) 
		addObjectImp(self, @selector(addObject:), carray[i]);
}

inline void NSMutableArray_addObjectsFromVector(NSMutableArray* self, std::vector<id> objects) {
	std::vector<id>::iterator it = objects.begin();
	std::vector<id>::iterator end = objects.end();
	IMP addObjectImp = [self methodForSelector:@selector(addObject:)];
	for (; it!=end; it++)
		addObjectImp(self, @selector(addObject:), *it);
}

inline NSApplication* NSApplicationSharedApplication() {
	static NSApplication* app = nil; 
	if (!app) app = [NSApplication sharedApplication];
	return app;
}

