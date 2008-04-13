/**
 *  @file O3MatrixSpace.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 4/12/08.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2008 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3MatrixSpace.h"

@implementation O3MatrixSpace
- (id)init {
	O3SuperInitOrDie();
	mMatToSuper.Identitize();
	return self;
}

- (id)initWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding]) {
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
		[self release];
		return nil;
	}
	O3SuperInitOrDie();
	O32DStructArray* sa = [coder decodeObjectForKey:@"matrix"];
	if (sa) mMatToSuper.SetValue(sa);
	else mMatToSuper.Identitize();
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding])
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
	[coder encodeObject:mMatToSuper.Value() forKey:@"matrix"];
}

- (void)setMatrixToSuper:(O3Mat4x4d)mat {
	mMatToSuper = mat;
}

- (O3Mat4x4d)matrixToSuper {
	return mMatToSuper;
}

@end
