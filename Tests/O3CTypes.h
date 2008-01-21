#import "O3StructType.h"

#define O3CTypeDefines /*NAME, ID, CTYPE, OC_GET_SEL, OC_CLASS, OC_INIT_SEL*/\
DefCType(O3FloatCType,	1,	float, floatValue, NSNumber, initWithFloat:)\
DefCType(O3DoubleCType,	2,	double, doubleValue, NSNumber, initWithDouble:)\
DefCType(O3Int8CType,	3,	Int8, charValue, NSNumber, initWithChar:)\
DefCType(O3Int16CType,	4,	Int16, shortValue, NSNumber, initWithShort:)\
DefCType(O3Int32CType,	5,	Int32, intValue, NSNumber, initWithInt:)\
DefCType(O3Int64CType,	6,	Int64, longLongValue, NSNumber, initWithLongLong:)\
DefCType(O3UInt8CType,	7,	UInt8, unsignedCharValue, NSNumber, initWithUnsignedChar:)\
DefCType(O3UInt16CType,	8,	UInt16, unsignedShortValue, NSNumber, initWithUnsignedShort:)\
DefCType(O3UInt32CType,	9,	UInt32, unsignedIntValue, NSNumber, initWithUnsignedInt:)\
DefCType(O3UInt64CType,	10,	UInt64, unsignedLongLongValue, NSNumber, initWithUnsignedLongLong:)

typedef enum {
	O3InvalidCType=0,
	#define DefCType(NAME,ID,CTYPE,OC_GET_SEL,OC_CLASS,OC_INIT_SEL) NAME = ID,
	O3CTypeDefines
	#undef DefCType
} O3CType;

extern "C" {
int O3CTypeSize(O3CType t);
int O3CTypeAlignment(O3CType t);
O3RawData O3CTypeTranslateFrom_at_stride_to_at_stride_count_(O3CType ftype, const void* fbytes, UIntP fstride, O3CType ttype, void* tbytes, UIntP tstride, UIntP count);
O3RawData O3CTypeInterleave(O3CType type, const void* fbytes, UIntP fstride, void* tbytes, UIntP tstride, UIntP count);
O3RawData O3CTypePortabalize(O3CType type, const void* fbytes, UIntP fstride, UIntP felements, UIntP count);
O3RawData O3CTypeDeportabalize(O3CType type, const void* fbytes, void* tbytes, UIntP tstride, UIntP count, UIntP elements);
const char* O3CTypeName(O3CType t);
NSString* O3CTypeObjCName(O3CType t);
const char* O3CTypeEnumName(O3CType t);
NSString* O3CTypeEnumObjCName(O3CType t);
const char* O3CTypeEncoding(O3CType t);
GLenum O3CTypeGLType(O3CType t);

double O3CTypeDoubleValue(O3CType type, const void* bytes);
void O3CTypeSetDoubleValue(O3CType type, void* bytes, double v);
id O3CTypeNSValue(O3CType type, const void* bytes);
id O3CTypeNSValueWithMult(O3CType type, const void* bytes, double mult);
void O3CTypeSetNSValue(O3CType type, void* bytes, id v);
void O3CTypeSetNSValueWithMult(O3CType type, void* bytes, id v, double mult);

O3CType O3CTypeFromName(const char* name);
O3CType O3CTypeFromEnumName(const char* name);
O3CType O3CTypeFromGLType(GLenum t);
}

inline void O3CTypeTranslateFromTo(O3CType from_t, O3CType to_t, const void* from, void* to) {
	#define SwapVal(Tf,Tt) *((Tt*)to)=*((Tf*)from); break;
	#define SwapFrom(Tf) switch (to_t) {                      \
		case O3FloatCType:  SwapVal(Tf, float);     \
		case O3DoubleCType: SwapVal(Tf, double);    \
		case O3Int8CType:   SwapVal(Tf, Int8);      \
		case O3Int16CType:  SwapVal(Tf, Int16);     \
		case O3Int32CType:  SwapVal(Tf, Int32);     \
		case O3Int64CType:  SwapVal(Tf, Int64);     \
		case O3UInt8CType:  SwapVal(Tf, UInt8);     \
		case O3UInt16CType: SwapVal(Tf, UInt16);    \
		case O3UInt32CType: SwapVal(Tf, UInt32);    \
		case O3UInt64CType: SwapVal(Tf, UInt64);	   \
	}; break;
	switch (from_t) {
		case O3FloatCType:  SwapFrom(float);
		case O3DoubleCType: SwapFrom(double);
		case O3Int8CType:   SwapFrom(Int8);
		case O3Int16CType:  SwapFrom(Int16);
		case O3Int32CType:  SwapFrom(Int32);
		case O3Int64CType:  SwapFrom(Int64);
		case O3UInt8CType:  SwapFrom(UInt8);
		case O3UInt16CType: SwapFrom(UInt16);
		case O3UInt32CType: SwapFrom(UInt32);
		case O3UInt64CType: SwapFrom(UInt64);
		default:
			O3AssertFalse(@"Unknown C type %i", from_t);
	}
}