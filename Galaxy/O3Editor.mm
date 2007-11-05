//
//  O3Editor.mm
//  Galaxy
//
//  Created by Jonathan deWerd on 11/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3Editor.h"

NSMutableArray* O3EditorClasses;

@implementation O3Editor

+ (NSString*)nibName {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

+ (BOOL)canEditObject:(id)obj {
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

- (O3Editor*)initWithObjectEditor:(O3ObjectEditor*)objEd {
	O3SuperInitOrDie();
	mTopLevelObjects = [NSMutableArray new];
	if (![NSBundle loadNibFile:[[self class] nibName] externalNameTable:[NSDictionary dictionaryWithObject:mTopLevelObjects forKey:NSNibTopLevelObjects] withZone:nil]) {
		O3LogWarn(@"Could not load nib named \"%@\" for editor of class %@ for object %@", [self nibName], [self className], objEd.object);
		[self release];
		return nil;
	}
	return self;
}

- (void)dealloc {
	[mTopLevelObjects makeObjectsPerformSelector:@selector(release)];
	[mTopLevelObjects release];
	[super dealloc];
}


+ (void)addEditorClass:(Class)editorClass {
	if (!O3EditorClasses) O3EditorClasses = [NSMutableArray new];
	[O3EditorClasses addObject:editorClass];
}

+ (NSArray*)editorClasses {
	if (!O3EditorClasses) O3EditorClasses = [NSMutableArray new];
	return O3EditorClasses;
}

+ (NSArray*)editorClassesForObject:(id)obj {
	NSMutableArray* ret = [NSMutableArray array];
	for (Class c in O3EditorClasses)
		if ([c canEditObject:obj]) [ret addObject:c];
	return ret;
}

@end
