//
//  O3MeshImporter.mm
//  Galaxy
//
//  Created by Jonathan deWerd on 11/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3MeshImporter.h"
#import "DropableCollectionView.h"

@implementation O3MeshImporter

+ (void)initialize {
	[DropableCollectionView addImporter:self];
}

+ (id)importFromFile:(NSString*)file {
	
}

+ (BOOL)canImportFromFile:(NSString*)file {
	if ([[file pathExtension] isEqualToString:@"raw"]) return YES;
	return NO;
}

@end
