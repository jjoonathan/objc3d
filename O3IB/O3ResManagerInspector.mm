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
