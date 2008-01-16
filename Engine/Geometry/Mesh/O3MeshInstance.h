/**
 *  @file O3MeshInstance.h
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3Renderable.h"
#import "O3Locateable.h"
@class O3MeshType;

@interface O3MeshInstance : O3Locateable <NSCoding, O3Renderable> {
	O3MeshType* mMeshType; ///The mesh the object is an instance of
	NSObject<O3MultipassDirector>* mMaterial; ///This is called the material for historic reasons (multipass director might be a better name).
	NSString* mMaterialName;
	NSString* mMeshName;
}
//Init
- (O3MeshInstance*)initWithMaterial:(NSString*)matName meshType:(NSString*)meshTypeName;

//Acc
- (NSString*)materialName;
- (void)setMaterialName:(NSString*)newName;
- (NSString*)meshTypeName;
- (void)setMeshTypeName:(NSString*)newName;

//Semi-private (you should be naming everything, as that's what is archived)
- (NSObject<O3MultipassDirector>*)material;
- (void)setMaterial:(NSObject<O3MultipassDirector>*)mat;
- (O3MeshType*)meshType;
- (void)setMeshType:(O3MeshType*)mesh;

//Convenience
- (void)uploadToGPU;
@end
