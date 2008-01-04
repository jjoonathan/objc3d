/**
 *  @file O3VertexDataSource.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 1/21/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3VertexFormats.h"
@class O3RawVertexDataSource;

/**
 * An abstract class to represent all sources of vertex data. 
 * Sources of vertex data can be literal (see O3RawVertexDataSource) or generated (see O3GeneratedVertexDataSource).
 */
@interface O3VertexDataSource : NSObject {
	
}
//Accessors
- (GLvoid*)indicies;		///<If the receiver stores vertex indicies (not color indicies), this should return the offset into the currently bound index array that the renderer should start at, the pointer the real data is at (if VBOs aren't supported), or NULL.
- (GLenum)format;			///<Returns the format (GL_UNSIGNED_SHORT, GL_INT, etc) of the receiver
- (O3VertexDataType)type;	///<Returns the type of vertex data represented by the receiver. The default implementation throws an exception.

//Use
- (void)bind;	///<Bind the receiver for rendering. The caller must call -(void)unbind when it is done rendering with the receiver.
- (void)unbind;	///<Unbinds the receiver as a vertex data source for rendering.

//Type assertion
- (O3RawVertexDataSource*)rawVertexDataSource; ///<Raises an exception if the receiver isn't a raw vertex data source, otherwise it returns the receiver.
@end
