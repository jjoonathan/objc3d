#import "O3KVCHelper.h"

/**
 *  @file O3KVCHelper.mm
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 *  @warn IMP caching is used, so the user must call flushIMPCache whenever a getter or setter method is swizzled.
 */
@implementation O3KVCHelper
O3DefaultO3InitializeImplementation

- (id)initWithTarget:(NSObject*)obj valueForKeyMethod:(SEL)getMethod setValueForKeyMethod:(SEL)setMethod listKeysMethod:(SEL)listKeys {
	O3SuperInitOrDie();
	mTarget = obj;
	mValueForKeyMethod = getMethod;
	mSetValueForKeyMethod = setMethod;
	mListKeysMethod = listKeys;
	[self flushIMPCache];
	return self;
}

- (void)flushIMPCache {
	mValueForKeyImp = (O3KVCGetterMethod)[mTarget methodForSelector:mValueForKeyMethod];
	mSetValueForKeyImp = (O3KVCSetterMethod)[mTarget methodForSelector:mSetValueForKeyMethod];
	mListKeysImp = (O3KVCListMethod)[mTarget methodForSelector:mListKeysMethod];
}

///@note Returns nil if the target lacks the valueForKeyMethod selector
- (id)valueForKey:(NSString*)key {
	if (!mValueForKeyImp) return nil;
	return mValueForKeyImp(mTarget, mValueForKeyMethod, key);
}

///@note Does nothing if the target lacks the setValueForKeyMethod selector
- (void)setValue:(id)newValue forKey:(NSString*)key {
	if (!mValueForKeyImp) return;
	mSetValueForKeyImp(mTarget, mSetValueForKeyMethod, newValue, key);
}

///@note Returns nil if the target lacks the listKeysMethod selector
- (NSArray*)keys {
	if (!mListKeysImp) return nil;
	return mListKeysImp(mTarget, mListKeysMethod);
}

+ (void)gdbBreak {
	O3Break();
}

+ (void)glBreak {
	O3GLBreak();
}

@end
