/**
 *  @file O3VFSNode.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 2007-06-13.
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3VFS.h"
#import "O3VFSNode.h"
#import "O3DirectoryVFSNode.h"
#import "O3ArchiveVFSNode.h"


static NSFileManager* fileManager = nil;
inline NSFileManager* fileManagerP() {return fileManager ?: fileManager=[NSFileManager defaultManager];}

@implementation O3VFSNode

- (NSArray*)keys {
	[NSException raise:@"Abstract Class Exception" format:@"Attempt to call instance method \"%s\" on semi-abstract class O3VFSNode!", _cmd];
	return nil;
}

- (void)loadRecursivelyToDepth:(int)depth {
	NSArray* k = [self keys];
	int i; int j = [k count];
	if (depth)
		for (i=0; i<j; i++) [[k valueForKey:[k objectAtIndex:i]] loadRecursivelyToDepth:depth-1];
	//Each key is lazy loaded on access so all this method has to do is touch each key that needs loading
}

- (O3VFSNode*)parentNode {
	return mParentNode;
}

///A VFS node may not be created without 
- (id)init {
	[self release];
	return nil;
}

- (id)initWithvfs:(O3VFS*)vfs parent:(O3VFSNode*)parent {
	O3SuperInitOrDie();
	mVFS = vfs;
	mParentNode = parent;
	return self;
}

+ (O3VFSNode*)nodeWithPath:(NSString*)path vfs:(O3VFS*)vfs parent:(O3VFSNode*)parent {
	NSFileManager* f = fileManagerP();
	BOOL dir; BOOL e = [f fileExistsAtPath:path isDirectory:&dir];
	if (!e) O3ToImplement(); //Find paths in archives
	O3Assert(e, @"Expected file/folder \"%@\" does not exist for VFS node %@.", path, self);
	if (dir) return [[O3DirectoryVFSNode alloc] initWithPath:path vfs:vfs parent:parent];
	return [[O3ArchiveVFSNode alloc] initWithPath:path vfs:vfs parent:parent];	
} 

///@warning Not very efficient
- (NSString*)path {
	NSString* s = [mParentNode path] ?: @"";
	return [s stringByAppendingPathComponent:[mParentNode keyForValue:self]];
}

- (O3VFS*)vfs {
	return mVFS;
}

- (id)valueForKey:(NSString*)key {
	[NSException raise:@"Abstract Class Exception" format:@"Attempt to call instance method \"%s\" on semi-abstract class O3VFSNode!", _cmd];
	return nil;
}

- (NSString*)keyForValue:(id)value {
	[NSException raise:@"Abstract Class Exception" format:@"Attempt to call instance method \"%s\" on semi-abstract class O3VFSNode!", _cmd];
	return nil;
}

@end
