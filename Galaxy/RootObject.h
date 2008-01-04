//
//  RootObject.h
//  Galaxy
//
//  Created by Jonathan deWerd on 11/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
@class MyDocument, O3ObjectEditor;

extern UIntP RootObjectNameNotUniqueError;

@interface RootObject : NSObject {
	MyDocument* mDocument;
	id mObject;
	NSString* mName;
	O3ObjectEditor* mEditor;
}
@property(retain, readwrite) NSString* name;
@property(retain, readwrite) id object;
@property(assign, readwrite) MyDocument* document;
@property(readonly) NSImage* icon;
@property(readwrite, retain) O3ObjectEditor* editor;
- (IBAction)openEditor:(id)sender;
@end
