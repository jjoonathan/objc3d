/**
 *  @file O3VFS.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 2007-06-13.
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3VFS.h"
#import "O3VFSNode.h"

@implementation O3VFS
/************************************/ #pragma mark Memory Management /************************************/
///Can't have pathless vfs: returns nil
- (id)init {
	[self release];
	return nil;
}

- (id)initWithPath:(NSString*)path {
	O3SuperInitOrDie();
	mObjectParentMap = [[NSMutableDictionary alloc] init];
	mRoot = [O3VFSNode nodeWithPath:path vfs:self parent:nil];
	return self;
}

- (void)dealloc {
	[mObjectParentMap release];
	O3SuperDealloc();
}

/************************************/ #pragma mark Root /************************************/
- (O3VFSNode*)root {
	return mRoot;
}

/************************************/ #pragma mark Super Map Management /************************************/
void O3VFSAddObjectToParentMap(O3VFS* self, id obj, O3VFSNode* parent) {
	O3Assert([self isKindOfClass:[O3VFS class]], @"O3VFSAddObjectToParentMap can only be called with the self argument being an instance of O3VFS. Instead, self=%@",self);
	[self->mObjectParentMap setObject:parent forKey:obj];
}

void O3VFSRemoveObjectFromParentMap(O3VFS* self, id obj, O3VFSNode* parent) {
	O3Assert([self isKindOfClass:[O3VFS class]], @"O3VFSRemoveObjectFromParentMap can only be called with the self argument being an instance of O3VFS. Instead, self=%@",self);
	[self->mObjectParentMap removeObjectForKey:obj];
}

///@warning This method is expensive
///@return The path to obj or nil if it could not be found
- (NSString*)pathForObject:(id)obj {
	O3VFSNode* parent = [mObjectParentMap objectForKey:obj];
	if (parent) return [[(O3VFSNode*)parent path] stringByAppendingFormat:@"/%@", [parent keyForValue:obj]];
	if ([obj isKindOfClass:[O3VFSNode class]]) return [(O3VFSNode*)parent path];
	return nil;
}


@end
