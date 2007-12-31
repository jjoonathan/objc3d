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

+ (void)startFlyingForward:(O3GLView*)view {   [[view viewState] setObject:O3TrueObject() forKey:@"flyingForward"];   }
+ (void)stopFlyingForward:(O3GLView*)view {    [[view viewState] removeObjectForKey:@"flyingForward"];   }
+ (void)startFlyingBackward:(O3GLView*)view {  [[view viewState] setObject:O3TrueObject() forKey:@"flyingBackward"];   }
+ (void)stopFlyingBackward:(O3GLView*)view {   [[view viewState] removeObjectForKey:@"flyingBackward"];   }
+ (void)startFlyingLeft:(O3GLView*)view {      [[view viewState] setObject:O3TrueObject() forKey:@"flyingLeft"];   }
+ (void)stopFlyingLeft:(O3GLView*)view {       [[view viewState] removeObjectForKey:@"flyingLeft"];   }
+ (void)startFlyingRight:(O3GLView*)view {     [[view viewState] setObject:O3TrueObject() forKey:@"flyingRight"];   }
+ (void)stopFlyingRight:(O3GLView*)view {      [[view viewState] removeObjectForKey:@"flyingRight"];   }

@end
