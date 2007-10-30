/**
 *  @file O3Renderable.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 1/14/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
@class O3Camera;
typedef struct {
	O3Camera* camera;
} O3RenderContext;

//typedef void (*O3RenderWithContextFunc)(id self, SEL _cmd, O3RenderContext* context);

@protocol O3Renderable
- (void)renderWithContext:(O3RenderContext*)context; ///<Render with info about the context (hints, etc) \e context. Note that \e context may be nil. The default implementation calls doesNotRespondToSelector: (do not call super)
@end
