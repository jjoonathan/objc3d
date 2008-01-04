//
//  O3Group.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 10/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3Renderable.h"

@protocol O3Group <O3Renderable>

//Accessors
- (void)addObject:(id<O3Renderable>*)aObject;
- (void)insertObject:(id<O3Renderable>*)aObject atIndex:(UIntP)i;
- (id<O3Renderable>*)objectAtIndex:(UIntP)i;
- (UIntP)indexOfObject:(id<O3Renderable>*)aObject;
- (void)removeObjectAtIndex:(UIntP)i;
- (NSArray*)objects;
- (void)setObjects:(NSArray*)newObjects;

@end
