/**
 *  @file NSImageAdditions.h
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import <QuartzCore/QuartzCore.h>

@interface NSImage (Bitmap)
	- (NSBitmapImageRep *)bitmap;
@end
