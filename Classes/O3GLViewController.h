//
//  O3GLViewController.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 12/27/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import <Cocoa/Cocoa.h>
@class O3GLView;

@interface O3GLViewController : NSResponder <NSCoding> {
	O3GLView* mView;
	NSMutableDictionary* mKeyDownActions;
	NSMutableDictionary* mKeyUpActions;
	id mTarget; //The object to receive the action messages. Usually the O3GLViewActionCollection class
	UInt32 mFlags;
}
- (O3GLView*)representedView;
- (void)setRepresentedView:(O3GLView*)view;
- (NSMutableDictionary*)keyDownActions;
- (NSMutableDictionary*)keyUpActions;
- (id)target; ///<The object that will receive action messages. Defaults to self. The receiver owns the target, so it should probably be a custom class or something.
- (void)setDefaultActions;
@end
