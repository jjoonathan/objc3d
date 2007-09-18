/**
 *  @file O3ArchiveVFSNode.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 2007-06-16.
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3VFSNode.h"
@class O3VFS;

@interface O3ArchiveVFSNode : O3VFSNode {
	NSMutableDictionary* mDirContents;
	O3BufferedReader* mReader;
	NSString* mFilePath;
}
- (id)initWithPath:(NSString*)path vfs:(O3VFS*)vfs parent:(O3VFSNode*)parent;
- (NSString*)globalFilesystemPath; ///The path to the receiver in the *real* file system
- (O3BufferedReader*)reader;
 @end
