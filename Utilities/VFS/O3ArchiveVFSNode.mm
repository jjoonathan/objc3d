/**
 *  @file O3ArchiveVFSNode.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 2007-06-16.
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3VFS.h"
#import "O3ArchiveVFSNode.h"

@implementation O3ArchiveVFSNode

- (NSString*)globalFilesystemPath {
	return mFilePath;
}

- (id)initWithPath:(NSString*)path vfs:(O3VFS*)vfs parent:(O3VFSNode*)parent {
	if (![super initWithvfs:vfs parent:parent]) return nil;
	mFilePath = [path retain];
	mReader = new O3BufferedReader((NSFileHandle*)[NSFileHandle fileHandleForReadingAtPath:path]);
	return self;
}

- (void)dealloc {
	[mFilePath autorelease];
	[mDirContents autorelease];
	if (mReader) delete mReader;
	O3SuperDealloc();
}

- (O3BufferedReader*)reader {
	return mReader;
}

@end
