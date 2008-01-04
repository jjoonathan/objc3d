//
//  O3GLViewActionCollection.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 12/28/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
@class O3GLView;

///Provides a default set of actions for O3GLViews.
@interface O3GLViewActionCollection : NSObject {}
+ (void)startFlyingForward:(O3GLView*)view;
+ (void)stopFlyingForward:(O3GLView*)view;
+ (void)startFlyingBackward:(O3GLView*)view;
+ (void)stopFlyingBackward:(O3GLView*)view;
+ (void)startFlyingLeft:(O3GLView*)view;
+ (void)stopFlyingLeft:(O3GLView*)view;
+ (void)startFlyingRight:(O3GLView*)view;
+ (void)stopFlyingRight:(O3GLView*)view;
@end
