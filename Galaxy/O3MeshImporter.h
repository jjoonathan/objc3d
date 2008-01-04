//
//  O3MeshImporter.h
//  Galaxy
//
//  Created by Jonathan deWerd on 11/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "DropableCollectionView.h"

@interface O3MeshImporter : NSObject <O3Importer> {
}
+ (id)importFromFile:(NSString*)file;
+ (BOOL)canImportFromFile:(NSString*)file;
@end
