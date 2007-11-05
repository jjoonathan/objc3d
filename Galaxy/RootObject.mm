//
//  RootObject.mm
//  Galaxy
//
//  Created by Jonathan deWerd on 11/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "MyDocument.h"
#import "RootObject.h"
#import "O3ObjectEditor.h"

UIntP RootObjectNameNotUniqueError = 1;

@implementation RootObject
@dynamic icon, name;
@synthesize object=mObject, document=mDocument, editor=mEditor;

+ (void)initialize {
	[self setKeys:[NSArray arrayWithObjects:@"object"] triggerChangeNotificationsForDependentKey:@"icon"];
}

- (NSImage*)icon {
	return [mObject icon];
}

- (void)dealloc {
	[mName release];
	[super dealloc];
}

- (NSString*)name {
	if (!mName) self.name = [self.document nextUntitledName];
	return mName;
}

- (void)setName:(NSString*)newName {
	if ([self.document objectForKey:newName]) {
		NSBeep();
		return;
	}
	O3Assign(newName, mName);
}

- (BOOL)validateName:(NSString**)name error:(NSError**)e {
	if (![self.document objectForKey:*name]) return YES;
	NSString* desc = [NSString stringWithFormat:@"There is already an object named \"%@\" in this document.", name];
	NSDictionary* ui = [NSDictionary dictionaryWithObject:desc forKey:NSLocalizedDescriptionKey];
	*e = [NSError errorWithDomain:O3DefaultErrorDomain code:RootObjectNameNotUniqueError userInfo:ui];
	return NO;
}

- (IBAction)openEditor:(id)sender {
	self.editor = [[O3ObjectEditor alloc] initWithObject:self];
}

@end
