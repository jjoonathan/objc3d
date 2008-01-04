//
//  O3GLViewInspector.mm
//  O3IB
//
//  Created by Jonathan deWerd on 10/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3GLViewInspector.h"


@implementation O3GLViewInspector

//Attribs
- (NSString *)label {
	return @"ObjC3D OpenGL View";
}

- (NSString *)viewNibName {
	return @"O3GLViewInspector";
}

+ (BOOL)supportsMultipleObjectInspection {
	return YES;
}

@end



@implementation O3GLView (IB)

- (void)ibPopulateKeyPaths:(NSMutableDictionary *)keyPaths {
    [super ibPopulateKeyPaths:keyPaths];
	//[[keyPaths objectForKey:IBToManyRelationshipKeyPaths] addObjectsFromArray:[NSArray arrayWithObjects:@"resourceSources", nil]];
	[[keyPaths objectForKey:IBToOneRelationshipKeyPaths] addObjectsFromArray:[NSArray arrayWithObjects:@"sceneName", @"camera", @"backgroundColor", @"resourceManager", @"context", nil]];
    //[[keyPaths objectForKey:IBAttributeKeyPaths] addObjectsFromArray:[NSArray arrayWithObjects:@"encodedAsShared", nil]];
}

- (void)ibPopulateAttributeInspectorClasses:(NSMutableArray *)classes {
    [super ibPopulateAttributeInspectorClasses:classes];
    [classes addObject:[O3GLViewInspector class]];
}

@end