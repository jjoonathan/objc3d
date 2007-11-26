/**
 *  @file O3ValueArray.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 4/19/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#ifdef __cplusplus
class O3BufferedReader;
#endif

typedef IntP O3MultiIndexBase;
///@warning O3MultiIndexes are indexed starting with 1, not 0, because of the sentinal value
typedef O3MultiIndexBase* O3MultiIndex; ///<An O3MultiIndexBase is defined as an array of O3MultiIndexBase typed values, starting with O3MultiIndexStartSentinal and ending with O3MultiIndexEndSentinal. This is guarenteed to be defined, use it to make your own O3MultiIndexes
static const O3MultiIndexBase O3MultiIndexStartSentinal	= - 0x4D494458ll; ///<This marks the beginning of an O3MultiIndex and is guarenteed to be defined. You can use it in your code to make multi-indexes of your own
static const O3MultiIndexBase O3MultiIndexEndSentinal	= - 1ll; ///<This marks the end of an O3MultiIndex and is guarenteed to be defined. You can use it in your code to make multi-indexes of your own
#define O3MakeMultiIndex(args...) ({O3MultiIndexBase O3MakeMultiIndexVal[]={O3MultiIndexStartSentinal, ##args ,O3MultiIndexEndSentinal}; O3MakeMultiIndexVal;})
inline UIntP O3MultiIndexCount(O3MultiIndex idx) {
	UIntP count = 0;
	while (idx[++count]!=O3MultiIndexEndSentinal);
	return count-1;
}

/**
 * O3ValueArray is an implicitly mutable multi-dimensonal NSValue for massive arrays 
 */
@interface O3ValueArray : NSObject {
	char* mObjCType;
	Int32 mObjCTypeSize;
	NSMutableData* mData;
	unsigned char* mDataBytes;
	O3MultiIndex mDimensions;
	O3MultiIndex mMultipliers;
}

//Initialization
- (id)initWithRawData:(NSData*)rawData objCType:(const char*)objCType dimensions:(O3MultiIndex)dims; ///Init with an in-memory C array of structs
- (id)initWithPortableData:(NSData*)rawData; ///Init with portable data (which is used when going from one computer to another.)
- (id)initWithObjCType:(const char*)objCType dimensions:(O3MultiIndex)dims; ///Create an empty value array with undefined contents
#ifdef __cplusplus
- (id)initWithPortableBufferReader:(O3BufferedReader*)br; ///The same as initWithPortableData, except read from \e br instead of a NSData.
#endif

//Inspectors
- (UInt64)count;
- (void*)rawBytes;
- (NSData*)portableData; ///Portable data should be used whenever transferring a O3ValueArray from one computer to another.
- (void)getValue:(void*)to atIndex:(O3MultiIndex)index;
- (NSValue*)valueAtIndex:(O3MultiIndex)index;
#ifdef __cplusplus
- (O3DynamicMatrix)matrixAtIndex:(O3MultiIndex)index;
- (O3DynamicVector)vectorAtIndex:(O3MultiIndex)index;
#endif

//Mutators
- (void)setValueAtIndex:(O3MultiIndex)index to:(void*)newVal;
- (void)setValueAtIndex:(O3MultiIndex)index toValue:(NSValue*)val;
#ifdef __cplusplus
- (void)setValueAtIndex:(O3MultiIndex)index toMatrix:(O3DynamicMatrix)val;
- (void)setValueAtIndex:(O3MultiIndex)index toVector:(O3DynamicVector)val;
#endif

@end
