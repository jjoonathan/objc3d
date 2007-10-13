#import "O3ResManager+IB.h"
#import "O3ResManagerInspector.h"

@implementation O3ResManager (IB)

#include "IBKVCPatch.h"

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

- (BOOL)isInInterfaceBuilder {
	return YES;
}

@end