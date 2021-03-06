/**
 *  @file O3MeshInstance.mm
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3MeshInstance.h"
#import "O3MeshType.h"
#import "O3ResManager.h"

@implementation O3MeshInstance
O3DefaultO3InitializeImplementation
/************************************/ #pragma mark Creation and Destruction /************************************/
inline void initP(O3MeshInstance* self) {
}

- (O3MeshInstance*)initWithMaterial:(NSString*)matName meshType:(NSString*)meshTypeName {
	O3SuperInitOrDie(); initP(self);
	[self setMaterialName:matName];
	[self setMeshTypeName:meshTypeName];
	return self;
}

- (id)initWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding]) {
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
		[self release];
		return nil;
	}
	[super initWithCoder:coder];
	NSString* matName = [coder decodeObjectForKey:@"materialName"];
	if (matName) [self setMaterialName:matName];
	else         [self setMaterial:[coder decodeObjectForKey:@"material"]];
	[self setMeshTypeName:[coder decodeObjectForKey:@"meshTypeName"]];	
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding])
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
	[super encodeWithCoder:coder];
	[coder encodeObject:mMaterialName forKey:@"materialName"];
	[coder encodeObject:mMeshName forKey:@"meshTypeName"];
	if (!mMaterialName && mMaterial) [coder encodeObject:mMaterial forKey:@"material"];
}

- (void)dealloc {
	if (mMaterialName) [self unbind:@"material"];
	[mMaterialName release];
	if (mMeshName) [self unbind:@"meshType"];
	[mMeshName release];
	[mMaterial release];
	[mMeshType release];
	O3SuperDealloc();
}

/************************************/ #pragma mark Accessors /************************************/
- (NSObject<O3MultipassDirector>*)material {
	return mMaterial;
}

- (void)setMaterial:(NSObject<O3MultipassDirector>*)mat {
	O3Assign(mat,mMaterial);
	if ([gO3ResManagerSharedInstance valueForKey:mMaterialName]!=mMaterial) O3Destroy(mMaterialName);
}

- (NSString*)materialName {
	return mMaterialName;
}

- (void)setMaterialName:(NSString*)newName {
	if (mMaterialName) [self unbind:@"material"];
	O3Assign(newName,mMaterialName);
	if (mMaterialName) [self bind:@"material" toObject:O3RMGM() withKeyPath:newName options:nil];
}

- (NSString*)meshTypeName {
	return mMeshName;
}

- (void)setMeshTypeName:(NSString*)newName {
	if (mMeshName) [self unbind:@"meshType"];
	O3Assign(newName,mMeshName);
	if (newName) [self bind:@"meshType" toObject:O3RMGM() withKeyPath:newName options:nil];
}

- (O3MeshType*)meshType {
	return mMeshType;
}

- (void)setMeshType:(O3MeshType*)mesh {
	O3Assign(mesh,mMeshType);
	if ([O3RMGM() valueForKey:mMeshName]!=mMeshType) O3Destroy(mMeshName);
}

/************************************/ #pragma mark Rendering /************************************/
- (void)tickWithContext:(O3RenderContext*)context {}
- (void)renderWithContext:(O3RenderContext*)context {
 	[mObjectSpace push:context];
	context->scratch[0] = mMaterial;
	[mMeshType renderWithContext:context];
	context->scratch[0] = nil;
 	[mObjectSpace pop:context];
}

/************************************/ #pragma mark Convenience /************************************/
- (void)uploadToGPU {
	[mMeshType uploadToGPU];
}

@end