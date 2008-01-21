/**
 *  @file O3Object.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 3/4/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3Object.h"


@implementation O3Object
O3DefaultO3InitializeImplementation

/*
- (id)init {
	O3SuperInitOrDie();
	return self;
}*/

- (void)dealloc {
	O3SuperDealloc();
}

- (NSMutableDictionary*)metadata {
	if (!mMetadata) mMetadata = [NSMutableDictionary new];
	return mMetadata;
}

///If a key is set that cannot be found, the value gets bumped into the metadata. NOTE: don't rely on this, it is for compatibility
- (void)setValue:(id)value forUndefinedKey:(NSString*)key {
	id orphan_key_group = [mMetadata valueForKey:@"OrphanKeys"];
	if (!orphan_key_group) {
		orphan_key_group = [NSMutableDictionary new];
		[mMetadata setValue:orphan_key_group forKey:@"OrphanKeys"];
	}
	[orphan_key_group setValue:value forKey:key];
}

///If a key cannot be found in the receiver, it is looked for in the OrphanKeys metadata key
- (id)valueForKey:(NSString*)key {
	id to_return = [super valueForKey:key];
	if (to_return) return to_return;
	id orphan_key_group = [mMetadata valueForKey:@"OrphanKeys"];
	return [orphan_key_group valueForKey:key];
}

@end
