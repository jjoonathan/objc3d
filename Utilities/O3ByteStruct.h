//
//  O3ByteStruct.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3Struct.h"

@interface O3ByteStruct : O3Struct {
	void* mBytes; ///< This should be considered protected: you are free to access it in subclasses. Note that all subclasses may not use it, some may define their own ivar to store data in, perhaps a NSData or a struct of some kind.
	BOOL mFreeWhenDone:1;
}

@end
