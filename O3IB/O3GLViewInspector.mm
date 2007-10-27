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
