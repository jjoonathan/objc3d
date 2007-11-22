/**
 *  @file O3Locateable.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 2/5/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import <Cocoa/Cocoa.h>
#import "O3Space.h"

@interface O3Locateable : NSObject {
#ifdef __cplusplus
	O3Translation3* mTranslation;
	O3Rotation3* mRotation;
	O3Scale3* mScale;
	Space3* mSpace;
#else
	void* mTranslation;
	void* mRotation;
	void* mScale;
	void* mSpace;
#endif
	BOOL mSpaceNeedsUpdate; ///<Weather the space needs to be remade from mTranslation etc. @note In the current implementation this really isn't used: the space is updated right after changes.
}

#ifdef __cplusplus
- (Space3*)space;		///<Returns the receiver's space (object space)
- (Space3*)superspace;	///<Returns the receiver's superspace (space above object space)

- (void)rotateBy:(O3Rotation3)relativeRotation;
- (void)translateBy:(O3Translation3)trans;
- (void)translateInObjectSpaceBy:(O3Translation3)trans;
- (void)scaleBy:(O3Scale3)scale;

- (O3Rotation3)rotation;
- (O3Translation3)translation; ///<The location of the receiver in its superspace
- (O3Scale3)scale;

- (void)setRotation:(O3Rotation3)newRot;
- (void)setTranslation:(O3Translation3)newTrans;
- (void)setScale:(O3Scale3)newScale;

- (O3Mat4x4d)matrixToSpace:(Space3*)targetspace;
- (void)setMatrixToSpace:(Space3*)targetspace;

- (void)debugDrawIntoSpace:(const Space3&)intospace;
#endif
@end
