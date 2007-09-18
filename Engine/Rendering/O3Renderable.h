/**
 *  @file O3Renderable.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 1/14/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
typedef void O3RenderContext; ///@todo Implement this!

@protocol O3Renderable
- (void*)defaultUserData; ///<Create and return the default userData object. NULL is a perfectly acceptable return value.
- (void)destroyUserData:(void*)userData; ///<Destroy persistent user data. @note NULL is a perfectly valid value for \e userData (if -defaultUserData returned NULL)
- (void)renderWithUserData:(void*)userData context:(O3RenderContext*)context; ///<Render with info about the context (hints, etc) \e context and user data \e userData that stays across the context. @note userData may be NULL, in which case the receiver should proceed to render with default values.
@end
