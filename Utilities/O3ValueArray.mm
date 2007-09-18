/**
 *  @file O3ValueArray.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 4/19/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3ValueArray.h"
#import "O3BufferedReader.h"
#import "O3BufferedWriter.h"
#import "O3EncodingInterpretation.h"
#import <string.h>

@implementation O3ValueArray
/************************************/ #pragma mark Private Mutators /************************************/
inline void setObjCTypeP(O3ValueArray* self, const char* newType) {
	if (self->mObjCType) free(self->mObjCType);
	self->mObjCType = strdup(newType);
	self->mObjCTypeSize = O3AlignedSizeofObjCEncodedType(self->mObjCType);
}

inline void setDimensionsP(O3ValueArray* self, O3MultiIndex newDims) {
	int end = 0;
	while (newDims[++end]!=O3MultiIndexEndSentinal);
	if (self->mMultipliers) delete[] self->mMultipliers;
	if (self->mDimensions) delete[] self->mDimensions;
	self->mMultipliers = new O3MultiIndexBase[end+1];
	self->mDimensions = new O3MultiIndexBase[end+1];
	self->mMultipliers[0] =   self->mDimensions[0]   = O3MultiIndexStartSentinal;
	self->mMultipliers[end] = self->mDimensions[end] = O3MultiIndexEndSentinal;
	O3MultiIndexBase accum = 1;
	int i; for (i=end-1; i>0; i++) {
		self->mMultipliers[i] = accum;
		O3MultiIndexBase newDims_i = newDims[i];
		self->mDimensions[i] = newDims_i;
		accum *= newDims_i;
	}
}

inline void setDataP(O3ValueArray* self, NSMutableData* dat) {
	self->mDataBytes = (unsigned char*)[dat mutableBytes];
	O3Fixme(); //Need to lazy load this for GPU data
	O3Assign(dat, self->mData);
}

inline unsigned char* objectAtIndexP(O3ValueArray* self, O3MultiIndex idx) {
	UInt64 flat_index = 0;
	int i; for (i=1; idx[i]!=O3MultiIndexEndSentinal; i++) {
		O3MultiIndexBase val = idx[i];
		if (val>=self->mDimensions[i])
			[NSException raise:NSRangeException format:@"Attempt to access out of bounds index (%qi>=%qi) in dimension %i of %@.", val, self->mDimensions[i], i, self];
		flat_index += val * self->mMultipliers[i];
	}
	return self->mDataBytes + self->mObjCTypeSize*flat_index;
}

inline UInt64 countP(O3ValueArray* self) {
	UInt64 dim, sum = 1;
	int i; for (i=1; (dim=self->mDimensions[i])!=O3MultiIndexEndSentinal; i++) 
		sum *= dim;
	return sum;
}

/************************************/ #pragma mark Initialization and Destruction /************************************/
- (id)initWithRawData:(NSData*)rawData objCType:(const char*)objCType dimensions:(O3MultiIndex)dims {
	O3SuperInitOrDie();
	setDataP(self, [rawData mutableCopy]);
	setObjCTypeP(self, objCType);
	setDimensionsP(self, dims);
	return self;
}

- (id)initWithPortableData:(NSData*)rawData {
	O3BufferedReader rdr(rawData);
	return [self initWithPortableBufferReader:&rdr];
}

///@fixme Security hole: make a large allocation (make limitSize: version?)
- (id)initWithPortableBufferReader:(O3BufferedReader*)br {
	O3SuperInitOrDie();
	setObjCTypeP(self, [br->ReadCCString() UTF8String]);
	UIntP elements = br->ReadUCIntAsUInt64();
	O3MultiIndex dims = new O3MultiIndexBase[elements+2];
	dims[0] = O3MultiIndexStartSentinal; dims[elements+1] = O3MultiIndexEndSentinal;
	UIntP i; for (i=1; i<=elements; i++) dims[i] = br->ReadUCIntAsUInt64();
	setDimensionsP(self, dims);
	delete[] dims;
	UInt64 count = countP(self);
	setDataP(self, [NSMutableData dataWithLength:count*mObjCTypeSize]);
	O3DeserializeDataOfType((void*)mDataBytes, (const char*)mObjCType, br, count);
	return self;
}

- (id)initWithObjCType:(const char*)objCType dimensions:(O3MultiIndex)dims {
	O3SuperInitOrDie();
	setObjCTypeP(self, objCType);
	setDimensionsP(self, dims);
	UInt64 count = countP(self);
	setDataP(self, [NSMutableData dataWithLength:count*mObjCTypeSize]);
	return self;
}

- (void)dealloc {
	if (mMultipliers) delete[] mMultipliers;
	if (mDimensions) delete[] mDimensions;
	if (self->mObjCType) free(self->mObjCType);
	O3SuperDealloc();
}
	
/************************************/ #pragma mark Inspectors /************************************/
- (UInt64)count {
	return countP(self);
}

- (void*)rawBytes {
	return mDataBytes;
}

- (NSData*)portableData {
	UIntP count = countP(self);
	NSMutableData* data = [[[NSMutableData alloc] initWithCapacity:count*mObjCTypeSize+50] autorelease];
	O3BufferedWriter bw(data);
	bw.WriteCCString(mObjCType);
	UIntP dimCount = O3MultiIndexCount(mDimensions);
	bw.WriteUCInt(dimCount);
	UIntP i; for (i=1; i<=dimCount; i++) bw.WriteUCInt(mDimensions[i]);
	O3SerializeDataOfType(mDataBytes, mObjCType, &bw, count);
	return data;
}

- (void)getValue:(void*)to atIndex:(O3MultiIndex)index {
	O3MoveDataOfType(objectAtIndexP(self, index), to, mObjCType);
}

- (NSValue*)valueAtIndex:(O3MultiIndex)index {
	O3ToImplement();
	return nil;
}

- (O3DynamicMatrix)matrixAtIndex:(O3MultiIndex)index {
	return O3DynamicMatrix(mObjCType, objectAtIndexP(self, index));
}

- (O3DynamicVector)vectorAtIndex:(O3MultiIndex)index {
	return O3DynamicVector(mObjCType, objectAtIndexP(self, index));
}



/************************************/ #pragma mark Mutators /************************************/
- (void)setValueAtIndex:(O3MultiIndex)index to:(void*)newVal {
	O3MoveDataOfType(newVal, objectAtIndexP(self, index), mObjCType);
}

- (void)setValueAtIndex:(O3MultiIndex)index toValue:(NSValue*)val {
	[val getValue:objectAtIndexP(self, index)];
}

- (void)setValueAtIndex:(O3MultiIndex)index toMatrix:(O3DynamicMatrix)val {
	O3DynamicMatrix(mObjCType, objectAtIndexP(self, index)).SetTo(val);
}

- (void)setValueAtIndex:(O3MultiIndex)index toVector:(O3DynamicVector)val {
	O3DynamicVector(mObjCType, objectAtIndexP(self, index)).SetTo(val);
}


@end
