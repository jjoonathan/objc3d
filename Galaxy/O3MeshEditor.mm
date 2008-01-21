//
//  O3MeshEditor.mm
//  Galaxy
//
//  Created by Jonathan deWerd on 11/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3MeshEditor.h"

@implementation O3MeshEditor
O3DefaultO3InitializeImplementation

+ (void)initialize {
	[O3Editor addEditorClass:self];
}

@end
