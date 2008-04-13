/**
 *  @file O3MatrixSpace.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 4/12/08.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2008 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3Space.h"

@interface O3MatrixSpace : O3Space {
	O3Mat4x4d mMatToSuper;
}
- (void)setMatrixToSuper:(O3Mat4x4d)mat;
@end
