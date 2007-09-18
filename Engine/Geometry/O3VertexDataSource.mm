/**
 *  @file O3VertexDataSource.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 1/21/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3VertexDataSource.h"


@implementation O3VertexDataSource

- (void)bind {
	[NSException raise:@"O3AbstractClassException" format:@"Attempt to use un-overridden abstract method -(void)bind of O3VertexDataSource!"];
}

- (void)unbind {
	[NSException raise:@"O3AbstractClassException" format:@"Attempt to use un-overridden abstract method -(void)unbind of O3VertexDataSource!"];
}

- (O3RawVertexDataSource*)rawVertexDataSource {
	[NSException raise:@"O3AbstractClassException" format:@"Attempt to use a non-raw vertex data source as a raw vertex data source. Implicit vertex and index generation is not allowed, so their data sources must be raw data."];
	return nil;
}

- (O3VertexDataType)type {
	[NSException raise:@"O3AbstractClassException" format:@"Attempt to use un-overridden abstract method -(O3VertexDataType)type of O3VertexDataSource!"];
	return O3VertexAttribute9DataType; //Hopefully this will get caught later on, heh
}

- (GLenum)format {
	[NSException raise:@"O3AbstractClassException" format:@"Attempt to use un-overridden abstract method -(GLenum)format of O3VertexDataSource!"];
	return GL_ZERO; //Hopefully this will get caught later on, heh	
}

- (GLvoid*)indicies {
	[NSException raise:@"O3AbstractClassException" format:@"Attempt to use un-overridden abstract method - (GLvoid*)indicies of O3VertexDataSource!"];
	return NULL; //Hopefully this will get caught later on, heh	
}

@end
