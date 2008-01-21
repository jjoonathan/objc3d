/**
 *  @file O3TestBigObject.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 6/13/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3TestBigObject.h"
#import "O3BigObjSubclass.h"

@implementation O3TestBigObject
O3DefaultO3InitializeImplementation

- (void)testRetainRelease {
	O3BigObjSubclass* a = [[O3BigObjSubclass alloc] init];
	STAssertTrue([a retainCount]==1, @"After allocation an O3BigObject should have 1 implicit retain.");
	STAssertThrows([a release], @"Alloc/init followed by release should cause a release");
	a = [[O3BigObjSubclass alloc] init];
	[a retain];
	STAssertTrue([a retainCount]==2, @"After allocation and a retain an O3BigObject should have 2 retains.");
	[a release];
	STAssertThrows([a release], @"Alloc/init+retain+release followed by release should cause a release");
}

@end
