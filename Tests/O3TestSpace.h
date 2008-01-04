/**
 *  @file O3TestSpace.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 2/3/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import <SenTestingKit/SenTestingKit.h>

@interface O3TestSpace : SenTestCase {
}
- (void)testNestedTranslations;
- (void)testNestedTRS;
- (void)testDeepNest;

//- (void)testTRSSpace; //Disabled, TRSSpace abandoned in favor of direct usage.
@end
