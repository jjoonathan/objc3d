/**
 *  @file O3Space.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 4/12/08.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2008 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
@class O3Space;
#import "O3Renderable.h"

@protocol O3Spatial
- (O3Space*)space;
@end

@interface O3Space : NSObject <O3Spatial, NSCoding> {
	BOOL mIsTRSSpace:1;
	O3Space* mSuperspace;
}
- (O3Space*)superspace;
- (void)setSuperspace:(O3Space*)ss; ///<Sets the superspace and adjusts the receiver's transformation to stay in the same place relative to the root
- (void)setSuperspaceWithoutAdjusting:(O3Space*)ss; ///<Sets the superspace but does not keep the receiver stationary relative to the root

//GL
- (void)push:(O3RenderContext*)ctx; ///<Push, then multiply the GL modelview matrix stack by the receiver's matrix.
- (void)pop:(O3RenderContext*)ctx; ///<Pop 1 level off the GL modelview stack.

//Matrix interface
- (void)clear; ///<Sets everything back to the identity
- (void)setMatrixToRoot:(O3Mat4x4d)mat;
- (void)setMatrixToSuper:(O3Mat4x4d)mat;
- (O3Mat4x4d)matrixToSuper; ///<The row-major matrix that when postmultiplied with a row-vector will transform it from the receiver's space to its superspace
- (O3Mat4x4d)matrixFromSuper; ///<The row-major matrix that when postmultiplied with a row-vector will transform it from the receiver's superspace to its space

- (void)applyTransformation:(O3Mat4x4d)trans inSpace:(O3Space*)sp;
- (void)setTransformation:(O3Mat4x4d)trans inSpace:(O3Space*)sp;

//Moving between spaces
- (O3Mat4x4d)matrixToSpace:(O3Space*)tospace; //nil is root
- (O3Mat4x4d)matrixFromSpace:(O3Space*)fromspace; //nil is root

//Debugging
- (double)drift; ///<Should be close to zero. The larger, the further matrixFromSuper*matrixToSuper is from the identity, and (ponentially) the less stable the transformaion is.
@end

///<Dynamically uses TRS shortcuts if possible. If converting en masse, you should probably get a matrix though.
O3EXTERN_C O3Vec4d O3PointFromSpaceToSpace(const O3Vec4d& p, O3Space* from, O3Space* to);
O3EXTERN_C O3Mat4x4d O3SpaceMatrixFromTo(O3Space* fromspace, O3Space* tospace);