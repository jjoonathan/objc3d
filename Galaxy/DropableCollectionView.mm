//
//  DropableCollectionView.mm
//  Galaxy
//
//  Created by Jonathan deWerd on 11/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "DropableCollectionView.h"

NSMutableArray* gO3FileImporters;

inline NSMutableArray* gO3FileImportersP() {
	if (!gO3FileImporters) gO3FileImporters = [NSMutableArray new];
	return gO3FileImporters;
}

@implementation DropableCollectionView

inline NSMutableDictionary* fileImportableCacheP(DropableCollectionView* self) {
	return self->mFileImportableCache ?: (self->mFileImportableCache = [NSMutableDictionary new]);
}

- (DropableCollectionView*)initWithFrame:(NSRect)frame {
	if (![super initWithFrame:frame]) return nil;
	[self registerForDragTypes:NSFilenamesPboardType];
	return self;
}

- (void)dealloc {
	[mFileImportableCache release];
	O3SuperDealloc();
}

/************************************/ #pragma mark Dragging /************************************/
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
	NSPasteboard* pb = [sender draggingPasteboard];
	NSArray* pbTypes = [pb types];
	if ([pbTypes containsObject:NSFilenamesPboardType]) {
        NSArray *files = [pb propertyListForType:NSFilenamesPboardType];
        for (NSString* f in files)
			if ([self canImportFromFile:f]) {
				[fileImportableCacheP(self) setObject:@"" forKey:f];
				return NSDragOperationCopy&[sender draggingSourceOperationMask];
			}
    }
	return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender {
	NSPasteboard* pb = [sender draggingPasteboard];
	NSArray* pbTypes = [pb types];
	if ([pbTypes containsObject:NSFilenamesPboardType]) {
        NSArray *files = [pb propertyListForType:NSFilenamesPboardType];
        for (NSString* f in files)
			if ([mFileImportableCache objectForKey:f]) {
				return NSDragOperationCopy&[sender draggingSourceOperationMask];
			}
    }
	return NSDragOperationNone;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
	NSPasteboard* pb = [sender draggingPasteboard];
	NSArray* pbTypes = [pb types];
	if ([pbTypes containsObject:NSFilenamesPboardType]) {
        NSArray *files = [pb propertyListForType:NSFilenamesPboardType];
		for (NSString* f in files) [mFileImportableCache removeObjectForKey:f];
    }
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {	
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
	NSPasteboard* pb = [sender draggingPasteboard];
	NSArray* pbTypes = [pb types];
	if ([pbTypes containsObject:NSFilenamesPboardType]) {
        NSArray *files = [pb propertyListForType:NSFilenamesPboardType];
		for (NSString* f in files) {
			[mFileImportableCache removeObjectForKey:f];
			id toInsert = nil;
			@try {
				toInsert = [DropableCollectionView importFile:f];
			} @catch (NSException* e) {}
			if (toInsert) [oObjects add:toInsert];
		}
    }	
}

+ (id)importFile:(NSString*)fileName {
	for (id<O3Importer> imp in gO3FileImportersP()) {
		if ([imp canImportFromFile:file]) {
			id obj = [imp importFromFile:file];
			if (obj) return obj;
		}
	}
	return nil;	
}

+ (BOOL)canImportFromFile:(NSString*)file {
	for (id<O3Importer> imp in gO3FileImportersP()) {
		if ([imp canImportFromFile:file]) return YES;
	}
	return NO;
}

/************************************/ #pragma mark Importer Accessors /************************************/
+ (void)addImporter:(id<O3Importer>)aImporter {
	[gO3FileImportersP() addObject:aImporter];
}

+ (void)insertImporter:(id<O3Importer>)aImporter atIndex:(UIntP)i  {
	[gO3FileImportersP() insertObject:aImporter atIndex:i];
}

+ (id)importerAtIndex:(UIntP)i {
	return [gO3FileImportersP() objectAtIndex:i];
}

+ (UIntP)indexOfImporter:(id<O3Importer>)aImporter {
	return [gO3FileImportersP() indexOfObject:aImporter];
}

+ (void)removeImporterAtIndex:(UIntP)i {
	[gO3FileImportersP() removeObjectAtIndex:i];
}

+ (void)removeImporter:(id<O3Importer>)aImporter {
	[gO3FileImportersP() removeObject:aImporter];
}

+ (UIntP)countOfImporters {
	return [gO3FileImportersP() count];
}

+ (NSgO3FileImportersP()*)importers {
	return gO3FileImportersP();
}

+ (void)setImporters:(NSgO3FileImportersP()*)newImporters {
	[gO3FileImportersP() setArray:newImporters];
}

@end
