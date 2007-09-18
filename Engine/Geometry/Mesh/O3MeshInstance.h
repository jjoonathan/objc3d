/**
 *  @file O3MeshInstance.h
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
@interface O3MeshInstance {
	O3Mesh* mMesh; ///The mesh the object is an instance of
	NSObject<O3MultipassDirector>* mMaterial; ///This is called the material for historic reasons (multipass director would be a better name)
}

@end
