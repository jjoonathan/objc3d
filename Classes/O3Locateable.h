/**
 *  @file O3Locateable.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 2/5/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import <Cocoa/Cocoa.h>
#import "O3Space.h"
#import "O3Renderable.h"
@class O3Camera;
#ifdef __cplusplus
using namespace ObjC3D::Math;
#endif

@interface O3Locateable : NSObject {
#ifdef __cplusplus
	O3Translation3 mTranslation;
	O3Rotation3 mRotation;
	O3Scale3 mScale;
	O3Space3 mSpace;
#else
	float mTRS[9];
	//Ah, screw it. The size'll be off in C.
#endif
	BOOL mSpaceNeedsUpdate; ///<Weather the space needs to be remade from mTranslation etc. @note In the current implementation this really isn't used: the space is updated right after changes.
}
- (O3Locateable*)initWithCoder:(NSCoder*)coder;
- (void)encodeWithCoder:(NSCoder*)coder;

#ifdef __cplusplus
- (O3Space3*)space;		///<Returns the receiver's space (object space)
- (O3Space3*)superspace;	///<Returns the receiver's superspace (space above object space)
#endif
- (void)setSuperspaceToThatOfLocateable:(O3Locateable*)locateable;

- (void)rotateBy:(O3Rotation3)relativeRotation;
- (void)rotateOverOSAxis:(O3Vec3d)axis angle:(angle)theta; ///<Rotate over an object space axis
- (void)rotateOverAxis:(O3Vec3d)axis angle:(angle)theta; ///<Rotate over an object space axis
- (void)translateBy:(O3Vec3d)trans;
- (void)translateInObjectSpaceBy:(O3Vec3d)trans;
- (void)scaleBy:(O3Vec3d)scale;

- (O3Rotation3)rotation;
- (void)setRotation:(O3Rotation3)newRot;
- (O3Vec3d)eulerRotation;
- (void)setEulerRotation:(O3Vec3d)erot;
- (void)setRotation:(O3Rotation3)newRot;
- (O3Vec3d)translation; ///<The location of the receiver in its superspace
- (void)setTranslation:(O3Vec3d)newTrans;
- (O3Vec3d)scale;
- (void)setScale:(O3Vec3d)newScale;

- (O3Mat4x4d)matrixToSpace:(O3Space3*)targetspace;
- (O3Mat4x4d)matrixToSpaceOfLocateable:(O3Locateable*)locateable;
- (void)setMatrixToSpace:(O3Space3*)targetspace; ///<glLoads the matrix to transform from the receiver's space to targetspace

- (void)debugDrawIntoSpace:(const O3Space3*)intospace;
@end

typedef O3Locateable<O3Renderable> O3SceneObj;

void O3LocateableBeginRender(O3Locateable* self, O3RenderContext* ctx); ///<Subclasses should always call this to move into the receiver's space before drawing