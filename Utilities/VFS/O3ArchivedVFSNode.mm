/**
 *  @file O3ArchivedVFSNode.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 2007-06-17.
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3ArchivedVFSNode.h"
#import "O3BufferedReader.h"

@implementation O3ArchivedVFSNode

- (id)initWithFile:(O3ArchiveVFSNode*)file offset:(UIntP)offset {
	return [self initWithFileHandle:handle offset:offset lazy:YES];
}

- (id)initWithFile:(O3ArchiveVFSNode*)file offset:(UIntP)offset lazy:(BOOL)lazy {
	O3SuperInitOrDie();
	mContents = [[NSMutableDictionary alloc] init];
	O3Assign(file, mFile);
	mDataOffset = offset;
	
	if (!mDataOffset) {
		
	}
}

- (void)dealloc {
	[mFile autorelease];
	O3SuperDealloc();
}

@end
