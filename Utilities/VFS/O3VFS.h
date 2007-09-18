/**
 *  @file O3VFS.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 2007-06-13.
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
@class O3VFSNode;
@class O3VFS;

///Methods that an object who is part of the VFS can implement
@interface NSObject (O3VFSMember)
- (void)wasAddedToVFS:(O3VFS*)vfs atNode:(O3VFSNode*)node;
- (void)wasRemovedFromVFS:(O3VFS*)vfs atNode:(O3VFSNode*)node;
- (void)awakeFromVFS:(O3VFS*)vfs atNode:(O3VFSNode*)node;
@end

/**O3VFS is a meta-singleton that contains the root of a Virtual File System. +shsaredVFS will return a shared VFS instance, but
 *you are also free to make your own seperate instances if you like.*/
@interface O3VFS : NSObject {
	O3VFSNode* mRoot;
	NSMutableDictionary* mObjectParentMap;
}
- (id)initWithPath:(NSString*)path;
- (O3VFSNode*)root;
- (NSString*)pathForObject:(id)obj;
@end

void O3VFSAddObjectToParentMap(O3VFS* self, id obj, O3VFSNode* parent); ///O3VFS must keep a map of the parent of each object since it needs to be able to find the path of a given oject yet it can't store the path in each object
void O3VFSRemoveObjectFromParentMap(O3VFS* self, id obj, O3VFSNode* parent); ///See O3VFSAddObjectToSuperMap (this is called on object removal)
