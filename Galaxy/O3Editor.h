//
//  O3Editor.h
//  Galaxy
//
//  Created by Jonathan deWerd on 11/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
@class O3ObjectEditor;

extern NSMutableArray* O3EditorClasses;

@interface O3Editor : NSObject {
	NSArray* mTopLevelObjects; //NSBundle makes us release these
}
+ (NSString*)nibName;
+ (BOOL)canEditObject:(id)obj;
- (O3Editor*)initWithObjectEditor:(O3ObjectEditor*)objEd;

+ (void)addEditorClass:(Class)editorClass;
+ (NSArray*)editorClasses;
+ (NSArray*)editorClassesForObject:(id)obj;
@end
