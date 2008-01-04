//
//  O3ObjectEditor.mm
//  Galaxy
//
//  Created by Jonathan deWerd on 11/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3ObjectEditor.h"
#import "RootObject.h"
#import "MyDocument.h"
#import "O3Editor.h"

NSNib* gObjectEditorNib = nil;

@implementation O3ObjectEditor
@dynamic object, document;
@synthesize editors=mEditors;

- (MyDocument*)doc {
	return mRootObject.document;
}

- (id)object {
	return mRootObject.object;
}

- (NSWindow*)editorWindow {
	return oEditorWindow;
}

- (NSTabView*)tabView {
	return oTabView;
}

- (O3ObjectEditor*)initWithObject:(RootObject*)object {
	O3SuperInitOrDie();
	if (![NSBundle loadNibNamed:@"ObjectEditor" owner:self]) {
		[self release];
		return nil;
	}
	[oEditorWindow bind:@"title" toObject:object withKeyPath:@"name" options:nil];
	mEditors = [NSMutableArray new];
	for (Class c in [O3Editor editorClassesForObject:object.object]) {
		O3Editor* e = [[c alloc] initWithObjectEditor:self];
		if (e) [mEditors addObject:e];
		[e release];
	}
	return self;
}

- (void)dealloc {
	[oEditorWindow release];
	[mEditors release];
	O3SuperDealloc();
}

@end
