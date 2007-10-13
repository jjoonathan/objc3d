//
//  O3ResSourceInspector.mm
//  O3IB
//
//  Created by Jonathan deWerd on 10/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3ResManagerInspector.h"


@implementation O3ResManagerInspector

//Attribs
- (NSString *)label {
	return @"Resource Manager";
}

- (NSString *)viewNibName {
	return @"O3ResManagerInspector";
}

+ (BOOL)supportsMultipleObjectInspection {
	return YES;
}

@end

@implementation O3ResManager (IB)

///A bug? In any case, it makes KVB work
- (id)valueForKey:(NSString*)k {
	return [super valueForKey:k];
}

- (NSImage*)ibDefaultImage {
	NSImage* img = [NSImage imageNamed:@"O3ResManager"];
	if (img) return img;
	NSBundle* thisBundle = [NSBundle bundleForClass:[O3ResManagerInspector class]];
	NSString* path = [thisBundle pathForImageResource:@"O3ResManager"];
	img = [[NSImage alloc] initWithContentsOfFile:path];
	[img setName:@"O3ResManager"];
	return img;
}

- (void)ibPopulateKeyPaths:(NSMutableDictionary *)keyPaths {
    [super ibPopulateKeyPaths:keyPaths];
	[[keyPaths objectForKey:IBToManyRelationshipKeyPaths] addObjectsFromArray:[NSArray arrayWithObjects:@"resourceSources", nil]];
	[[keyPaths objectForKey:IBToOneRelationshipKeyPaths] addObjectsFromArray:[NSArray arrayWithObjects:@"parentManager", nil]];
    [[keyPaths objectForKey:IBAttributeKeyPaths] addObjectsFromArray:[NSArray arrayWithObjects:@"encodedAsShared", nil]];
}

- (void)ibPopulateAttributeInspectorClasses:(NSMutableArray *)classes {
    [super ibPopulateAttributeInspectorClasses:classes];
    [classes addObject:[O3ResManagerInspector class]];
}

@end