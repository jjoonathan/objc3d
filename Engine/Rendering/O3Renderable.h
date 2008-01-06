/**
 *  @file O3Renderable.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 1/14/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3Space.h"
@class O3Camera, O3GLView;

typedef struct {
	Class objCCompatibility;
	O3GLView* view;
	O3Camera* camera;
	O3Space3*   cameraSpace;
	double elapsedTime; ///<The time elapsed since the last frame. Note that elapsedTime is in "seconds," but may be positive, 0, or negative (you may want to pause or rewind, so to speak.)
} O3RenderContext;

//typedef void (*O3RenderWithContextFunc)(id self, SEL _cmd, O3RenderContext* context);

@protocol O3Renderable
- (void)tickWithContext:(O3RenderContext*)context; ///<Advances the receiver's state (to get elapsed time since last frame etc, check in context). Default implementation does nothing.
- (void)renderWithContext:(O3RenderContext*)context; ///<Render with info about the context (hints, etc) \e context. Note that \e context may be nil. There is no default implementation.
@end
