/**
 *  @file O3Mesh.h
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3Renderable.h"
#import "O3VertexFormats.h"
#import "O3VertexDataSource.h"
@class O3ResManager;

///@todo Assert that the proper data sources are attached for the material (else garbage ensues)
///@todo Refactor setMaterial to setDefaultMaterial

@interface O3MeshType : NSObject <O3Renderable, NSCoding> {
	NSMutableArray*                          mVertexDataSources;	///<Holds the vertx data sources associated with the mesh keyed by the type of data they represent as an unsigned integer. @note Index and "vertex location" arrays are opaquely stored in different variables.
	NSObject<O3MultipassDirector,NSCoding>*  mDefaultMaterial;	    ///<The object which directs the rendering of the receiver (usually the material, hence the name)
	NSString*                                mDefaultMaterialName;
}
/**********************************************/ #pragma mark Initialization /**********************************************/
- (id)initWithDataSources:(NSArray*)dataSources defaultMaterialName:(NSString*)materialName;

/**********************************************/ #pragma mark Accessors /**********************************************/
- (NSObject<O3MultipassDirector>*)defaultMaterial;	///<The material the receiver will be rendered with if a material isn't specified with the instance
- (void)setDefaultMaterial:(NSObject<O3MultipassDirector>*)newMaterial;

- (NSMutableArray*)vertexDataSources; ///<Modify this to modify vertex data sources
@end
