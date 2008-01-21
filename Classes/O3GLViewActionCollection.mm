//
//  O3GLViewActionCollection
//  ObjC3D
//
//  Created by Jonathan deWerd on 12/28/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3GLViewActionCollection.h"
#import "O3GLView.h"

@implementation O3GLViewActionCollection
O3DefaultO3InitializeImplementation

+ (void)startFlyingForward:(O3GLView*)view {   [[view viewState] setObject:O3TrueObject() forKey:@"flyingForward"];   }
+ (void)stopFlyingForward:(O3GLView*)view {    [[view viewState] removeObjectForKey:@"flyingForward"];   }
+ (void)startFlyingBackward:(O3GLView*)view {  [[view viewState] setObject:O3TrueObject() forKey:@"flyingBackward"];   }
+ (void)stopFlyingBackward:(O3GLView*)view {   [[view viewState] removeObjectForKey:@"flyingBackward"];   }
+ (void)startFlyingLeft:(O3GLView*)view {      [[view viewState] setObject:O3TrueObject() forKey:@"flyingLeft"];   }
+ (void)stopFlyingLeft:(O3GLView*)view {       [[view viewState] removeObjectForKey:@"flyingLeft"];   }
+ (void)startFlyingRight:(O3GLView*)view {     [[view viewState] setObject:O3TrueObject() forKey:@"flyingRight"];   }
+ (void)stopFlyingRight:(O3GLView*)view {      [[view viewState] removeObjectForKey:@"flyingRight"];   }
+ (void)startFlyingDown:(O3GLView*)view {      [[view viewState] setObject:O3TrueObject() forKey:@"flyingDown"];   }
+ (void)stopFlyingDown:(O3GLView*)view {       [[view viewState] removeObjectForKey:@"flyingDown"];   }
+ (void)startFlyingUp:(O3GLView*)view {     [[view viewState] setObject:O3TrueObject() forKey:@"flyingUp"];   }
+ (void)stopFlyingUp:(O3GLView*)view {      [[view viewState] removeObjectForKey:@"flyingUp"];   }
+ (void)startFlyingFast:(O3GLView*)view {     [[view viewState] setObject:O3TrueObject() forKey:@"flyingFast"];   }
+ (void)stopFlyingFast:(O3GLView*)view {      [[view viewState] removeObjectForKey:@"flyingFast"];   }

@end
