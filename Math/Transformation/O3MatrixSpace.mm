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
	mMat.Identitize();
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
	if (sa) mMat.SetValue(sa);
	else mMat.Identitize();
	mMatIsToSuper = [coder decodeBoolForKey:@"isToSuper"];
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding])
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
	[coder encodeObject:mMat.Value() forKey:@"matrix"];
	[coder encodeBool:mMatIsToSuper forKey:@"isToSuper"];
}

- (void)setMatrixToSuper:(O3Mat4x4d)mat {
	mMatIsToSuper = YES;
	mMat = mat;
}

- (void)setMatrixFromSuper:(O3Mat4x4d)mat {
	mMatIsToSuper = NO;
	mMat = mat;
}

- (O3Mat4x4d)matrixToSuper {
	if (mMatIsToSuper) return mMat;
	O3Mat4x4d im = mMat;
	im.InvertLU();
	return im;
}

- (O3Mat4x4d)matrixFromSuper {
	if (!mMatIsToSuper) return mMat;
	O3Mat4x4d im = mMat;
	im.InvertLU();
	return im;
}

@end
