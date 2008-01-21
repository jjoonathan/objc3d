/**
 *  @file O3BigObject.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 6/13/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3BigObject.h"

@implementation O3BigObject
O3DefaultO3InitializeImplementation

- (id)retain {
	mRetainCount++;
	if (!mRetainCount) { //If overflow
		mRetainCount--; //De-overflow
		[super retain]; //And let super handle it
	}
	return self;
}

- (void)release {
	if (!mRetainCount) [super release];
	else			   mRetainCount--;
}

- (UIntP)retainCount {
	return mRetainCount + [super retainCount];
}

@end
