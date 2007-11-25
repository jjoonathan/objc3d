/**
 *  @file O3Mesh.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 12/27/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3MeshType.h"
#import "O3VertexDataSource.h"
#import "O3ResManager.h"

///@todo Make KVC compliant
@implementation O3Mesh

/**********************************************/ #pragma mark Initialization /**********************************************/
- (id)initWithDataSources:(NSArray*)dataSources  defaultMaterialName:(NSString*)materialName {
	O3SuperInitOrDie();
	[self setDefaultMaterialName:materialName];
	mVertexDataSources = [[NSMutableArray alloc] initWithArray:dataSources];
	return self;
}

- (id)initWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding]) {
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
		[self release];
		return nil;
	}
	return [self initWithDataSources:[coder decodeObjectForKey:@"dataSources"] defaultMaterialName:[coder decodeObjectForKey:@"defaultMaterialName"]];
}

- (void)encodeWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding])
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
	[coder encodeObject:mVertexDataSources forKey:@"dataSources"];
	[coder encodeObject:mDefaultMaterialName forKey:@"defaultMaterialName"];
}

- (void)dealloc {
	[mDefaultMaterial release];
	[self setDefaultMaterialName:nil];
	[mVertexDataSources release];
	O3SuperDealloc();
}

/**********************************************/ #pragma mark Accessors /**********************************************/
- (NSObject<O3MultipassDirector>*)defaultMaterial {
	return mDefaultMaterial;
}

- (void)setDefaultMaterial:(NSObject<O3MultipassDirector>*)newMaterial {
	O3Assign(newMaterial, mDefaultMaterial);
}

- (NSString*)defaultMaterialName {
	return mDefaultMaterialName;
}

- (void)setDefaultMaterialName:(NSString*)newMaterialName {
	O3Assign(newMaterialName, mDefaultMaterialName);
	if (mDefaultMaterialName) [self unbind:@"defaultMaterial"];
	else [O3ResManager sharedManager];
	if (newMaterialName) [self bind:@"defaultMaterial" toObject:gO3ResManagerSharedInstance withKeyPath:mDefaultMaterialName options:nil];
}

- (NSMutableArray*)vertexDataSources {
	return mVertexDataSources;
}

@end
