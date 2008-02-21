/**
 *  @file O3TestMatrix.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 2/3/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import <SenTestingKit/SenTestingKit.h>

@interface O3TestMatrix : SenTestCase {
}
- (void)testTranslationInversion;
- (void)testRotationInversion;
- (void)testTRSInversion;
- (void)testCofactors;
- (void)testBigTimesSmall;
@end
