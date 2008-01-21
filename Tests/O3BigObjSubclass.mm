/**
 *  @file O3BigObjSubclass.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 6/14/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3BigObjSubclass.h"

@implementation O3BigObjSubclass
O3DefaultO3InitializeImplementation

- (void)dealloc {
	[NSException raise:@"Dealloc Exception" format:@""];
	O3SuperDealloc();
}

@end
