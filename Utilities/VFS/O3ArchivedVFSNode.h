/**
 *  @file O3ArchivedVFSNode.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 2007-06-17.
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3VFSNode.h"
@class O3VFS;
@class O3File;
class O3BufferedReader;

@interface O3ArchivedVFSNode : O3VFSNode {
	O3ArchiveVFSNode* mFile;
	NSMutableDictionary* mContents;
	UIntP mDataOffset;
}
- (id)initWithFile:(O3ArchiveVFSNode*)file offset:(UIntP)offset; ///@param offset The offset in %handle, or 0. No seeking will be done if the offset is 0.
- (id)initWithFile:(O3ArchiveVFSNode*)file offset:(UIntP)offset lazy:(BOOL)lazy; ///@param offset The offset in %handle, or 0. No seeking will be done if the offset is 0.
@end
