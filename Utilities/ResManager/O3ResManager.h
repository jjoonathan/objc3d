//
//  O3ResManager.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 9/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
@class O3ResSource

@interface O3ResManager : NSObject {
	NSMutableArray* mResourceSources;
	NSMutableDictionary* mObjectsForNames;
	
}
//Construction
- (O3ResManager*)init;
+ (O3ResManager*)sharedManager;

//KVC
- (void)setValue:(id)obj forKey:(NSString*)key;
- (id)valueForKey:(NSString*)key;
- (void)setValue:(id)obj forKeyPath:(NSString*)path;
- (id)valueForKeyPath:(NSString*)path;

@end
