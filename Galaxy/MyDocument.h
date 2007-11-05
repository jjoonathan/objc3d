//
//  MyDocument.h
//  Galaxy
//
//  Created by Jonathan deWerd on 9/17/07.
//  Copyright __MyCompanyName__ 2007 . All rights reserved.
//

@interface MyDocument : NSDocument {
	IBOutlet NSArrayController* oObjects;
}
- (id)objectForKey:(NSString*)name;
- (NSString*)nextUntitledName;
@end
