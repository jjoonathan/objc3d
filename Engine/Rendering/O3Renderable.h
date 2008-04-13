/**
 *  @file O3Renderable.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 1/14/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
@class O3Camera, O3GLView, O3Context, O3Space;

typedef struct {
	void* scratch[5]; ///<You can use this for internal communication in a "stack" of objects. Always clear to NULL. scratch[4] should only be used to point to another, larger structure so you don't run out of space.
	Class objCCompatibility;
	O3GLView* view;
	O3Camera* camera;
	O3Space* cameraSpace;
	double elapsedTime; ///<The time elapsed since the last frame. Note that elapsedTime is in "seconds," but may be positive, 0, or negative (you may want to pause or rewind, so to speak.)
	O3Context* ctx;
	NSOpenGLContext* glContext;
	void* reserved[5];
} O3RenderContext;

//typedef void (*O3RenderWithContextFunc)(id self, SEL _cmd, O3RenderContext* context);

@protocol O3Renderable
- (void)tickWithContext:(O3RenderContext*)context; ///<Advances the receiver's state (to get elapsed time since last frame etc, check in context). Default implementation does nothing.
- (void)renderWithContext:(O3RenderContext*)context; ///<Render with info about the context (hints, etc) \e context. Note that \e context may be nil. There is no default implementation.
@end
