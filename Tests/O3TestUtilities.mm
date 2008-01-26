/**
 *  @file O3TestUtilities.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 11/19/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#include "O3TestUtilities.h"

@implementation O3TestUtilities
O3DefaultO3InitializeImplementation

- (void)testByteswap {
	UInt32 swap_32 = 0x11223344;
	UInt64 swap_64 = 0x1122334455667788ULL;
	swap_32 = O3Byteswap(swap_32);
	swap_64 = O3Byteswap(swap_64);
	STAssertTrue(swap_32==0x44332211, @"32 bit O3Byteswap failure. 0x11223344 should O3Swap to 0x44332211, but it swapped to 0x%X.", swap_32);
	STAssertTrue(swap_64=0x8877665544332211ULL, @"64 bit O3Byteswap failure. 0x1122334455667788ULL should O3Swap to 0x8877665544332211ULL, but it swapped to 0x%qX.", swap_64);
}

@end
