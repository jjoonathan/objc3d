//
//  O3IB.m
//  O3IB
//
//  Created by Jonathan deWerd on 10/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "O3IB.h"

@implementation O3IB
- (NSArray *)libraryNibNames {
    return [NSArray arrayWithObject:@"O3IBLibrary"];
}

- (NSArray*)requiredFrameworks {
	NSString* p = [[NSBundle mainBundle] privateFrameworksPath];
	return [NSArray arrayWithObject:[NSBundle bundleWithPath:p]];
}

@end
