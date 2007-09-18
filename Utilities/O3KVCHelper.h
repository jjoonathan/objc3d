/**
 *  @file O3KVCHelper.h
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
typedef id (*O3KVCGetterMethod)(id, SEL, NSString*);
typedef id (*O3KVCSetterMethod)(id, SEL, id, NSString*);
typedef NSArray* (*O3KVCListMethod)(id, SEL);

@interface O3KVCHelper : NSObject {
	SEL mValueForKeyMethod;
	SEL mSetValueForKeyMethod;
	SEL mListKeysMethod;
	O3KVCGetterMethod mValueForKeyImp;
	O3KVCSetterMethod mSetValueForKeyImp;
	O3KVCListMethod   mListKeysImp;
	/*weak*/ NSObject* mTarget;
}
- (id)initWithTarget:(NSObject*)obj valueForKeyMethod:(SEL)getMethod setValueForKeyMethod:(SEL)setMethod listKeysMethod:(SEL)listKeys;
- (void)flushIMPCache; ///<Call whenever the implementation of the cached selectors changes
@end
