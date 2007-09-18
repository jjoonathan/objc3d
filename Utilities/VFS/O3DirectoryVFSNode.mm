/**
 *  @file O3DirectoryVFSNode.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 2007-06-14.
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3DirectoryVFSNode.h"
#import "O3ArchiveVFSNode.h"

static NSFileManager* fileManager = nil;
inline NSFileManager* fileManagerP() {return fileManager ?: fileManager=[NSFileManager defaultManager];}

@implementation O3DirectoryVFSNode

inline NSMutableDictionary* directoryContentsP(O3DirectoryVFSNode* self) {return self->mDirContents ?: self->mDirContents=[NSMutableDictionary new];}

- (id)init {
	[self release];
	return nil;
}

- (id)initWithPath:(NSString*)path vfs:(O3VFS*)vfs parent:(O3VFSNode*)parent {
	if (![super initWithvfs:vfs parent:parent]) return nil;
	BOOL dir; BOOL e = [fileManagerP() fileExistsAtPath:path isDirectory:&dir]; dir; e;
	O3Assert(e && dir, @"Directory expected but not found for [O3DirectoryVFSNode initWithPath:@\"%@\" vfs:%@ parent:%@].",path,vfs,parent);
	O3Assign(path, mDirectoryPath);
	return self;
}

- (NSArray*)keys {
	return [fileManagerP() directoryContentsAtPath:mDirectoryPath];
}

- (NSString*)globalFilesystemPath {
	return mDirectoryPath;
}

- (id)valueForKey:(NSString*)key {
	NSMutableDictionary* dc = directoryContentsP(self);
	id cachedVal = [dc valueForKey:key];
	if (cachedVal) return cachedVal;
	
	NSString* absolutePath = [mDirectoryPath stringByAppendingPathComponent:key];
	NSFileManager* f = fileManagerP();
	O3VFSNode* node = nil;
	BOOL dir; BOOL e = [f fileExistsAtPath:absolutePath isDirectory:&dir]; dir; e;
	O3Assert(e, @"Expected file/folder \"%@\" does not exist for VFS node %@ looking for key %@.", absolutePath, self, key);
	if (dir) {
		node = [[O3DirectoryVFSNode alloc] initWithPath:absolutePath];
	} else {
		node = [[O3ArchiveVFSNode alloc] initWithPath:absolutePath];
	}
	[dc setValue:node forKey:key];
	[node release]; //mDirectoryContents owns it now
	return node;
}

- (void)dealloc {
	[mDirContents autorelease];
	[mDirectoryPath autorelease];
	O3SuperDealloc();
}

@end
