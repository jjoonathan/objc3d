//
//  DropableCollectionView.h
//  Galaxy
//
//  Created by Jonathan deWerd on 11/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

@protocol O3Importer
+ (id)importFromFile:(NSString*)file;
+ (BOOL)canImportFromFile:(NSString*)file;
@end

@interface DropableCollectionView : NSCollectionView {
	NSMutableDictionary* mFileImportableCache; //If a non-nil value is returned for a key, that file has been determined to be loadable. This is cleared after the completion of every drag op, and shold not be used outside drag ops.
	IBOutlet NSArrayController* oObjects;
}
+ (void)addImporter:(id<O3Importer>)aImporter;
+ (void)insertImporter:(id<O3Importer>)aImporter atIndex:(UIntP)i;
+ (id)importerAtIndex:(UIntP)i;
+ (UIntP)indexOfImporter:(id<O3Importer>)aImporter;
+ (void)removeImporterAtIndex:(UIntP)i;
+ (NSArray*)importers;
+ (void)setImporters:(NSArray*)newImporters;

+ (BOOL)canImportFromFile:(NSString*)file;
@end
