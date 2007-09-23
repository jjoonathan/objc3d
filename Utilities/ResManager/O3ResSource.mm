//
//  O3ResSource.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 9/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "O3ResSource.h"


@implementation O3ResSource
- (double)searchPriorityForObjectNamed:(NSString*)key {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)tryToLoadObjectNamed:(NSString*)key intoResManager:(O3ResManager*)manager sideEffects:(BOOL)loadSiblings {
	[self doesNotRecognizeSelector:_cmd];	
	return nil;
}

- (NSArray*)allKeys {
	[self doesNotRecognizeSelector:_cmd];	
	return nil;
}

- (id)tryToReloadObjectNamed:(NSString*)key intoResManager:(O3ResManager*)manager sideEffects:(BOOL)loadSiblings {
	[self doesNotRecognizeSelector:_cmd];	
	return nil;
}

@end
