/**
 *  @file O3TestRotate.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 11/20/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import <SenTestingKit/SenTestingKit.h>
#import "O3Rotation.h"

@interface O3TestRotation : SenTestCase {
}
- (void)testEulerToQuatAndQuatToMatrix;
- (void)testQuatToEuler;
@end
