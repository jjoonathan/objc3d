/**
 *  @file O3DirectoryVFSNode.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 2007-06-14.
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3VFSNode.h"

@interface O3DirectoryVFSNode : O3VFSNode {
	NSMutableDictionary* mDirContents;
	NSString* mDirectoryPath;
}
- (id)initWithPath:(NSString*)path vfs:(O3VFS*)vfs parent:(O3VFSNode*)parent;
- (NSString*)globalFilesystemPath; ///The path to the receiver in the *real* file system
@end
