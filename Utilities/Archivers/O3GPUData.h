//
//  O3GPUData.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/24/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3BufferedReader.h"

typedef struct {
	GLuint id;
	UInt32 references;
} O3GLBufferObj;

@interface O3GPUData : NSMutableData <NSCopying, NSCoding> {
	O3GLBufferObj* mBuffer;
	UIntP mLength; ///<May differ from the capacity of mBuffer
	int mCapacityOverruns; ///<For hinting how much to increase capacity when the length is overrun
}
//Use NSMutableData's methods. The ones listed below are specific to O3GPUData.
#ifdef __cplusplus
- (O3GPUData*)initWithReader:(O3BufferedReader*)r length:(UIntP)len hint:(GLenum)usageHint;
#endif
- (O3GPUData*)initWithBytesNoCopy:(void*)bytes length:(UIntP)len freeWhenDone:(BOOL)fwd hint:(GLenum)usageHint;
- (O3GPUData*)initWithCapacity:(UIntP)cap hint:(GLenum)hint;
- (void)relinquishBytes;

//Accessors
- (void*)writeOnlyBytes;
- (GLenum)usageHint;

//Semi-private (you can call them, but doing so is depricated)
- (UIntP)capacity;
@end

@interface NSData (O3GPUDataAdditions)
- (void)relinquishBytes; ///<Invalidates the receiver's -bytes pointer. It is recommended (and often required) to give the pointer back to GL once you are done with it.
- (BOOL)isGPUData; ///<YES if the receiver is an instance of O3GPUData
- (O3GPUData*)gpuCopy; ///<Makes a GPUData copy of the receiver, uploading it to the GPU
- (GLvoid*)glPtrForBindingArray;
- (GLvoid*)glPtrForBindingElements;
@end