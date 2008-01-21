/**
 *  @file O3TestAccelerate.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 4/15/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3TestAccelerate.h"


@implementation O3TestAccelerate
O3DefaultO3InitializeImplementation

- (void)testNSStringAllocInitWithBytesEtc {
	NSString* str = @"Nobody expects the spanish inquisition!";
	const char* bytes = [str UTF8String];
	unsigned len = strlen(bytes);
	NSString* str2 = NSString_allocInitWithBytesNoCopy_length_encoding_freeWhenDone_(bytes,len,NSUTF8StringEncoding,NO);
	STAssertTrue([str2 isEqualToString:str], @"NSString_allocInitWithBytesNoCopy_length_encoding_freeWhenDone_ isn't working. It is \"%@\" and it should be \"%@\"", str2, str);
}

@end
