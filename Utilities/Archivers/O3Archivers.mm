/**
 *  @file O3Archivers.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 2007-06-23.
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3Archivers.h"

static O3Archivers* SharedInstance;

@implementation O3Archivers
+ (O3Archivers*)sharedInstance
{
	return SharedInstance ?: [[O3Archivers new] autorelease];
}

- (id)init
{
	if(SharedInstance)
	{
		[self release];
	}
	else if(self = SharedInstance = [[super init] retain])
	{
		/* init code */
	}
	return SharedInstance;
}
@end
