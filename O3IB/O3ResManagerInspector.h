//
//  O3ResSourceInspector.h
//  O3IB
//
//  Created by Jonathan deWerd on 10/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import <InterfaceBuilderKit/InterfaceBuilderKit.h>
#import <ObjC3D/O3ResManager.h>

@interface O3ResManagerInspector : IBInspector {
}
//Attribs
- (NSString *)label;
- (NSString *)viewNibName;
+ (BOOL)supportsMultipleObjectInspection;
@end

@interface O3ResManager (IB)
- (NSImage*)ibDefaultImage;
@end