/**
 *  @file O3Locateable.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 2/5/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3Locateable.h"
#import "O3TRSSpace.h"
#import "O3KeyedArchiver.h"
#import <iostream>
using namespace std;
using namespace ObjC3D::Math;

@implementation O3Locateable
O3DefaultO3InitializeImplementation


/************************************/ #pragma mark Initialization /************************************/
- (O3Locateable*)init {
	O3SuperInitOrDie();
	mObjectSpace = [[O3TRSSpace alloc] init];
	return self;
}

- (void)dealloc {
	O3Destroy(mObjectSpace);
	O3SuperDealloc();
}

- (id)initWithCoder:(NSCoder*)coder {
	O3SuperInitOrDie();
	O3Assign([coder decodeObjectForKey:@"objectSpace"], mObjectSpace);
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
	[coder encodeObject:mObjectSpace forKey:@"objectSpace"];
}


/************************************/ #pragma mark Transformation /************************************/
- (void)moveBy:(O3Vec3d)amount inPOVOf:(id<O3Spatial>)pov {
	[mObjectSpace moveBy:amount inPOVOf:pov];
}

- (void)moveTo:(O3Vec3d)amount inPOVOf:(id<O3Spatial>)pov {
	[mObjectSpace moveTo:amount inPOVOf:pov];
}

- (void)rotateBy:(angle)theta over:(O3Vec3d)axis inPOVOf:(id<O3Spatial>)pov {
	[mObjectSpace rotateBy:theta over:axis inPOVOf:pov];
}

- (void)resize:(O3Vec3d)amount inPOVOf:(id<O3Spatial>)pov {
	[mObjectSpace resize:amount inPOVOf:pov];
}

- (void)recenter {
	[mObjectSpace clear];
}

- (O3Space*)space {
	return mObjectSpace;
}

- (void)setParentSpace:(id<O3Spatial>)s {
	
}

@end