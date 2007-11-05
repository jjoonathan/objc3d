//
//  O3ObjectEditor.h
//  Galaxy
//
//  Created by Jonathan deWerd on 11/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
@class MyDocument, RootObject;

@interface O3ObjectEditor : NSObject {
	IBOutlet NSWindow* oEditorWindow;
	IBOutlet NSTabView* oTabView;
	RootObject* mRootObject;
	NSMutableArray* mEditors;
}
@property(readonly) id object; //The actual object being edited
@property(readonly) MyDocument* document;
@property(readonly) NSMutableArray* editors;
- (NSWindow*)editorWindow;
- (NSTabView*)tabView;
- (O3ObjectEditor*)initWithObject:(RootObject*)object;
@end
