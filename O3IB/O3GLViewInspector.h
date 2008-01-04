//
//  O3GLViewInspector.h
//  O3IB
//
//  Created by Jonathan deWerd on 10/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import <InterfaceBuilderKit/InterfaceBuilderKit.h>
#import <ObjC3D/O3GLView.h>

@interface O3GLViewInspector : IBInspector {
	NSString* colorString;
	NSString* depthString;
	NSString* stencilString;
	NSString* accumString;
	NSString* auxBuffersString;
	NSString* samplingString;
	NSString* aaStyleString;
	NSString* rendererString;
	NSString* policyString;
}
//Attribs
- (NSString*)label;
- (NSString*)viewNibName;
+ (BOOL)supportsMultipleObjectInspection;
@end
