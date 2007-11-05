//
//  MyDocument.m
//  Galaxy
//
//  Created by Jonathan deWerd on 9/17/07.
//  Copyright __MyCompanyName__ 2007 . All rights reserved.
//
#import "MyDocument.h"
#import "RootObject.h"
#import <ObjC3D/O3BufferedReader.h>
#import <ObjC3D/O3KeyedUnarchiver.h>
#import <ObjC3D/O3KeyedArchiver.h>

@implementation MyDocument

- (id)init {
    self = [super init];
    if (self) {
	}
    return self;
}

- (void)dealloc {
	[super dealloc];
}

- (NSString *)windowNibName {
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController {
    [super windowControllerDidLoadNib:aController];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
	NSMutableDictionary* pkgRoot = [[NSMutableDictionary alloc] init];
	for (RootObject* o in [oObjects arrangedObjects]) {
		[pkgRoot setObject:o.object forKey:o.name];
	}
	
	NSData* outData = nil;
	@try {
		outData = [O3KeyedArchiver archivedDataWithRootObject:pkgRoot];
	} @catch (NSException* e) {
		NSString* desc = [NSString stringWithFormat:@"An error occured while savang the file. Reason:\n%@", [e reason]];
		NSDictionary* info = [NSDictionary dictionaryWithObject:desc forKey:NSLocalizedDescriptionKey];
		if (outError) *outError = [NSError errorWithDomain:O3DefaultErrorDomain code:2 userInfo:info];
	}
   
	[pkgRoot release];
	return outData;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
	@try {
 		NSDictionary* dict = [O3KeyedUnarchiver unarchiveObjectWithData:data];
		NSEnumerator* ke = [dict keyEnumerator];
		NSEnumerator* oe = [dict objectEnumerator];
		while (1) {
			NSString* k;
			NSString* o;
			if (!(k=[ke nextObject])) break;
			if (!(o=[oe nextObject])) break;
			RootObject* obj = [RootObject new];
				obj.name = k;
				obj.document = self;
				obj.object = o;
			[oObjects addObject:obj];
		}
	} @catch (NSException* e) {
		NSString* desc = [NSString stringWithFormat:@"An error occured while opening the file. Reason:\n%@", [e reason]];
		NSDictionary* info = [NSDictionary dictionaryWithObject:desc forKey:NSLocalizedDescriptionKey];
		if (outError) *outError = [NSError errorWithDomain:O3DefaultErrorDomain code:2 userInfo:info];
		return NO;
	}
   return YES;
}

- (id)objectForKey:(NSString*)name {
	for (RootObject* obj in [[oObjects arrangedObjects] objectEnumerator]) {
		if ([obj.name isEqualToString:name]) return obj;
	}
	return nil;
}

- (NSString*)nextUntitledName {
	return [NSString stringWithFormat:@"Untitled %i", [oObjects.arrangedObjects count]];
}

@end
