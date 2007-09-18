/**
 *  @file O3VFSNode.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 2007-06-13.
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
@class O3VFS;

@interface O3VFSNode : O3BigObject {
	O3VFSNode* mParentNode; ///A weak reference to "..".
	O3VFS* mVFS; ///The VFS the object is part of
}

//Init
+ (O3VFSNode*)nodeWithPath:(NSString*)path vfs:(O3VFS*)vfs parent:(O3VFSNode*)parent;
- (void)loadRecursivelyToDepth:(int)depth;
- (id)initWithvfs:(O3VFS*)vfs parent:(O3VFSNode*)parent; ///Meant for subclasses

//Accessors
- (O3VFSNode*)parentNode; ///".."
- (O3VFS*)vfs; ///The VFS the object is part of
- (NSString*)path; ///The path relative to the VFS root that the node is located at

//KVC
- (NSArray*)keys;
- (id)valueForKey:(NSString*)key;
- (NSString*)keyForValue:(id)value;

@end
