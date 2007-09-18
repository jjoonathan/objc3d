/**
 *  @file O3Object.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 3/4/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import <Cocoa/Cocoa.h>

@interface O3Object : NSObject {
	NSMutableDictionary* mMetadata;
}
//Metadata
- (NSMutableDictionary*)metadata; ///<Returns a KV-able table with the receiver's metadata

@end
