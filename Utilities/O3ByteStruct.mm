//
//  O3ByteStruct.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3ByteStruct.h"

@implementation O3ByteStruct

- (O3Struct*)initWithBytesNoCopy:(void*)bytes type:(O3StructType*)type freeWhenDone:(BOOL)fwd {
	O3SuperInitOrDie();
	mType=type;
	mBytes=bytes;
	mFreeWhenDone=fwd;
	return self;
}

- (void)writeToBytes:(void*)bytes {
	UIntP s = [mType structSize];
	mBytes = malloc(s);
	bcopy(mBytes, bytes, s);
}

- (void)dealloc {
	if (mFreeWhenDone) free(mBytes);
	O3SuperDealloc();
}


@end
