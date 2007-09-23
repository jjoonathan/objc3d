//
//  O3ResManager.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 9/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3ResManager.h"

O3ResManager* gO3ResManagerSharedInstance = nil;

@implementation O3ResManager
/************************************/ #pragma mark Construction /************************************/
- (O3ResManager*)init {
	O3SuperInitOrDie();
	mObjectsForNames = [[NSMutableDictionary alloc] init];
	mResourceSources = [[NSMutableArray alloc] init];
	return self;
}

- (void)dealloc {
	[mObjectsForNames release];
	[mResourceSources release];
	[super dealloc];
}

+ (O3ResManager*)sharedManager {
	return gO3ResManagerSharedInstance ?: gO3ResManagerSharedInstance=[[self alloc] init];
}



/************************************/ #pragma mark KVC /************************************/
- (void)setValue:(id)obj forKey:(NSString*)key {
	[mObjectsForNames setValue:obj forKey:key];
}

- (id)valueForKey:(NSString*)key {
	return [mObjectsForNames valueForKey:key];
}

- (void)setValue:(id)obj forKeyPath:(NSString*)path {
	return [mObjectsForNames setValue:obj forKeyPath:path];
}

- (id)valueForKeyPath:(NSString*)path {
	id val = [mObjectsForNames valueForKeyPath:path];
	return ;
}

@end
