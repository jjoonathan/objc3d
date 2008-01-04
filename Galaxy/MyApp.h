//
//  MyApp.h
//  Galaxy
//
//  Created by Jonathan deWerd on 11/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MyApp : NSObject {
	IBOutlet NSArrayController* oLibraryItems;
}
- (NSArrayController*)libraryItemController;
@end
