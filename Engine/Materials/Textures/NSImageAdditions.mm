/**
 *  @file NSImageAdditions.mm
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
@implementation NSImage (Bitmap)
	- (NSBitmapImageRep *)bitmap {
		NSSize imgSize = [self size];
		NSBitmapImageRep* to_return = [NSBitmapImageRep alloc];
		[self lockFocus];
		[to_return initWithFocusedViewRect:NSMakeRect(0.0, 0.0, imgSize.width, imgSize.height)]; 
		[self unlockFocus];
		return to_return;
	}	
@end
