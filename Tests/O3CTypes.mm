#import "O3CTypes.h"

extern "C" {


int O3CTypeSize(O3CType t) {
	switch (t) {
		#define DefCType(NAME,ID,CTYPE,OC_GET_SEL,OC_CLASS,OC_INIT_SEL) case NAME: return sizeof(CTYPE);
		O3CTypeDefines
		#undef DefCType
	}
	return 0;
}

int O3CTypeAlignment(O3CType t) {
	switch (t) {
		#define DefCType(NAME,ID,CTYPE,OC_GET_SEL,OC_CLASS,OC_INIT_SEL) case NAME: return __alignof__(CTYPE);
		O3CTypeDefines
		#undef DefCType
	}
	return 0;	
}

///@return a {bytes,len} pair that either contains the passed in tbytes buffer and 0, nil and 0 (signifying failure), or an automatically created buffer and its length
///@fstride the stride to read from or 0 for type default
///@tstride the stride to write to or 0 for type default
O3RawData O3CTypeTranslateFrom_at_stride_to_at_stride_count_(O3CType ftype, const void* fbytes, UIntP fstride, O3CType ttype, void* tbytes, UIntP tstride, UIntP count) {
	fstride = fstride ?: O3CTypeSize(ftype);
	tstride = tstride ?: O3CTypeSize(ttype);
	UIntP malloced_bytes = 0;
	if (!tbytes) {
		malloced_bytes = tstride*count;
		tbytes = malloc(malloced_bytes);
	}
	for (UIntP i=0; i<count; i++) O3CTypeTranslateFromTo(ftype, ttype, (UInt8*)fbytes+i*fstride, (UInt8*)tbytes+i*tstride);
	O3RawData ret = {tbytes,malloced_bytes};
	return ret;
}

///@return a {bytes,len} pair that either contains the passed in tbytes buffer and 0, nil and 0 (signifying failure), or an automatically created buffer and its length
O3RawData O3CTypeInterleave(O3CType type, const void* fbytes, UIntP fstride, void* tbytes, UIntP tstride, UIntP count) {
	fstride = fstride ?: O3CTypeSize(type);
	tstride = tstride ?: fstride;
	UIntP malloced_bytes = 0;
	if (!tbytes) {
		malloced_bytes = tstride*count;
		tbytes = malloc(malloced_bytes);
	}
	UIntP i;
	switch (type) {
		#define DefCType(NAME,ID,CTYPE,OC_GET_SEL,OC_CLASS,OC_INIT_SEL) case NAME: for (i=0; i<count; i++) *((CTYPE*)((UInt8*)tbytes+i*tstride))=*((CTYPE*)((UInt8*)fbytes+i*fstride)); break;
		O3CTypeDefines
		#undef DefCType
		default:
			O3AssertFalse(@"Unknown C type %i", type);
			O3RawData ret = {nil,0};
			return ret;
	}
	O3RawData ret = {tbytes,malloced_bytes};
	return ret;
}

///@param type the type of the data to be portabalized
///@param fbytes the data to be portabalized
///@param fstride 0 or the distance between the starts of "chunks" (groups of %felements values of type %type)
///@return a {bytes,len} pair that either contains the passed in tbytes buffer and 0, nil and 0 (signifying failure), or an automatically created buffer and its length
O3RawData O3CTypePortabalize(O3CType type, const void* fbytes, UIntP fstride, UIntP felements, UIntP count) {
	UIntP type_size = O3CTypeSize(type);
	felements = felements ?: 1;
	fstride = fstride ?: type_size*felements;
	UIntP chunk_count = count / felements; O3Asrt(!(count%felements));
	UIntP malloced_bytes = fstride*chunk_count;
	void *tbytes = malloc(malloced_bytes);
	
	UIntP i,j;
	switch (type) {
		#define DefCType(NAME,ID,CTYPE,OC_GET_SEL,OC_CLASS,OC_INIT_SEL) case NAME: for (i=0; i<chunk_count; i++) for (j=0; j<felements; j++) {\
			UIntP to_offset = (i+j)*type_size;\
			UIntP from_offset = i*fstride + j*type_size;\
			CTYPE val = O3ByteswapHostToLittle(*((const CTYPE*)((const UInt8*)fbytes+from_offset)));\
			*((CTYPE*)((UInt8*)tbytes+to_offset)) = val;\
			break;\
			}
		O3CTypeDefines
		#undef DefCType
		default:
			O3AssertFalse(@"Unknown C type %i", type);
			free(tbytes);
			O3RawData ret = {nil,0};
			return ret;
	}
	
	O3RawData ret = {tbytes,malloced_bytes};
	return ret;	
}

///@return a {bytes,len} pair that either contains the passed in tbytes buffer and 0, nil and 0 (signifying failure), or an automatically created buffer and its length
O3RawData O3CTypeDeportabalize(O3CType type, const void* fbytes, void* tbytes, UIntP tstride, UIntP count, UIntP elements) {
	UIntP type_size = O3CTypeSize(type);
	elements = elements ?: 1;
	tstride = tstride ?: type_size*elements;
	UIntP chunk_count = count / elements; O3Asrt(!(count%elements));
	UIntP malloced_bytes = 0;
	if (!tbytes) {
		malloced_bytes = tstride*chunk_count;
		tbytes = malloc(malloced_bytes);
	}
	
	UIntP i,j;
	switch (type) {
		#define DefCType(NAME,ID,CTYPE,OC_GET_SEL,OC_CLASS,OC_INIT_SEL) case NAME: for (i=0; i<chunk_count; i++) for (j=0; j<elements; j++) {\
			UIntP from_offset = (i+j)*type_size;\
			UIntP to_offset = i*tstride + j*type_size;\
			CTYPE val = O3ByteswapLittleToHost(*((const CTYPE*)((const UInt8*)fbytes+from_offset)));\
			*((CTYPE*)((UInt8*)tbytes+to_offset)) = val;\
			break;\
			}
		O3CTypeDefines
		#undef DefCType
		default:
			O3AssertFalse(@"Unknown C type %i", type);
			if (malloced_bytes) free(tbytes);
			O3RawData ret = {nil,0};
			return ret;
	}
	
	O3RawData ret = {tbytes,malloced_bytes};
	return ret;	
}

const char* O3CTypeName(O3CType t) {
	switch (t) {
		#define DefCType(NAME,ID,CTYPE,OC_GET_SEL,OC_CLASS,OC_INIT_SEL) case NAME: return #CTYPE;
		O3CTypeDefines
		#undef DefCType
		default:
			O3AssertFalse(@"Unknown C type %i", t);
	}	
	return nil;
}

NSString* O3CTypeObjCName(O3CType t) {
	switch (t) {
		#define DefCType(NAME,ID,CTYPE,OC_GET_SEL,OC_CLASS,OC_INIT_SEL) case NAME: return @#CTYPE;
		O3CTypeDefines
		#undef DefCType
		default:
			O3AssertFalse(@"Unknown C type %i", t);
	}	
	return nil;
}

const char* O3CTypeEnumName(O3CType t) {
	switch (t) {
		#define DefCType(NAME,ID,CTYPE,OC_GET_SEL,OC_CLASS,OC_INIT_SEL) case NAME: return #NAME;
		O3CTypeDefines
		#undef DefCType
		default:
			O3AssertFalse(@"Unknown C type %i", t);
	}	
	return nil;
}

NSString* O3CTypeEnumObjCName(O3CType t) {
	switch (t) {
		#define DefCType(NAME,ID,CTYPE,OC_GET_SEL,OC_CLASS,OC_INIT_SEL) case NAME: return @#NAME;
		O3CTypeDefines
		#undef DefCType
		default:
			O3AssertFalse(@"Unknown C type %i", t);
	}	
	return nil;
}

const char* O3CTypeEncoding(O3CType t) {
	switch (t) {
		#define DefCType(NAME,ID,CTYPE,OC_GET_SEL,OC_CLASS,OC_INIT_SEL) case NAME: return @encode(CTYPE);
		O3CTypeDefines
		#undef DefCType
		default:
			O3AssertFalse(@"Unknown C type %i", t);
	}	
	return nil;
}

O3CType O3CTypeFromName(const char* name) {
	#define DefCType(NAME,ID,CTYPE,OC_GET_SEL,OC_CLASS,OC_INIT_SEL) if (!strcmp(name,#CTYPE)) return NAME;
	O3CTypeDefines
	#undef DefCType
	O3AssertFalse(@"Unrecognized C type name %s", name);
	return O3InvalidCType;
}

O3CType O3CTypeFromEnumName(const char* name) {
	#define DefCType(NAME,ID,CTYPE,OC_GET_SEL,OC_CLASS,OC_INIT_SEL) if (!strcmp(name,#NAME)) return NAME;
	O3CTypeDefines
	#undef DefCType
	O3AssertFalse(@"Unrecognized C type name %s", name);
	return O3InvalidCType;
}

O3CType O3CTypeEncoded(const char* enc_name) {
	#define DefCType(NAME,ID,CTYPE,OC_GET_SEL,OC_CLASS,OC_INIT_SEL) if (!strcmp(enc_name,@encode(CTYPE))) return NAME;
	O3CTypeDefines
	#undef DefCType
	O3AssertFalse(@"Unrecognized C type name %s", enc_name);
	return O3InvalidCType;
}

GLenum O3CTypeGLType(O3CType t) {
	switch (t) {
		case O3FloatCType:  return GL_FLOAT;
	    case O3DoubleCType: return GL_DOUBLE;
	    case O3Int8CType:   return GL_BYTE;
	    case O3Int16CType:  return GL_SHORT;
	    case O3Int32CType:  return GL_INT;
		//case O3Int64CType:  return 0;
		case O3UInt8CType:  return GL_UNSIGNED_BYTE;
		case O3UInt16CType: return GL_UNSIGNED_SHORT;
		case O3UInt32CType: return GL_UNSIGNED_INT;
		//case O3UInt64CType: return 0;
		default:
		O3AssertFalse(@"Unknown GL type for C type %i",(int)t);
	}
	return GL_ZERO;
}

O3CType O3CTypeFromGLType(GLenum t) {
	switch (t) {
		case GL_FLOAT:          return O3FloatCType;
	    case GL_DOUBLE:         return O3DoubleCType;
	    case GL_BYTE:           return O3Int8CType;
	    case GL_SHORT:          return O3Int16CType;
	    case GL_INT:            return O3Int32CType;
		case GL_UNSIGNED_BYTE:  return O3UInt8CType;
		case GL_UNSIGNED_SHORT: return O3UInt16CType;
		case GL_UNSIGNED_INT:   return O3UInt32CType;
		default:
		O3AssertFalse(@"Unknown C type for GL type 0x%X",(int)t);
	}
	return O3InvalidCType;	
}

double O3CTypeDoubleValue(O3CType type, const void* bytes) {
	switch (type) {
		#define DefCType(NAME,ID,CTYPE,OC_GET_SEL,OC_CLASS,OC_INIT_SEL) case NAME: return *(CTYPE*)bytes;
		O3CTypeDefines
		#undef DefCType
	}
	O3AssertFalse(@"Unrecognized C type %i", (int)type);
	return 0;
}

void O3CTypeSetDoubleValue(O3CType type, void* bytes, double v) {
	switch (type) {
		#define DefCType(NAME,ID,CTYPE,OC_GET_SEL,OC_CLASS,OC_INIT_SEL) case NAME: *(CTYPE*)bytes = v; break;
		O3CTypeDefines
		#undef DefCType
		default: O3AssertFalse("Unknown type \"%i\"", (int)type);
	}
}

void O3CTypeSetNSValue(O3CType type, void* bytes, id v) {
	switch (type) {
		#define DefCType(NAME,ID,CTYPE,OC_GET_SEL,OC_CLASS,OC_INIT_SEL) case NAME: *(CTYPE*)bytes = [(OC_CLASS*)v OC_GET_SEL]; break;
		O3CTypeDefines
		#undef DefCType
		default: O3AssertFalse("Unknown type \"%i\"", (int)type);
	}
}

void O3CTypeSetNSValueWithMult(O3CType type, void* bytes, id v, double mult) {
	switch (type) {
		#define DefCType(NAME,ID,CTYPE,OC_GET_SEL,OC_CLASS,OC_INIT_SEL) case NAME: *(CTYPE*)bytes = [(OC_CLASS*)v OC_GET_SEL]*mult; break;
		O3CTypeDefines
		#undef DefCType
		default: O3AssertFalse("Unknown type \"%i\"", (int)type);
	}
}

id O3CTypeNSValue(O3CType type, const void* bytes) {
	switch (type) {
		#define DefCType(NAME,ID,CTYPE,OC_GET_SEL,OC_CLASS,OC_INIT_SEL) case NAME: return [[OC_CLASS alloc] OC_INIT_SEL *(CTYPE*)bytes];
		O3CTypeDefines
		#undef DefCType
		default: O3AssertFalse("Unknown type \"%i\"", (int)type);
	}
	return nil;
}

id O3CTypeNSValueWithMult(O3CType type, const void* bytes, double mult) {
	switch (type) {
		#define DefCType(NAME,ID,CTYPE,OC_GET_SEL,OC_CLASS,OC_INIT_SEL) case NAME: return [[OC_CLASS alloc] OC_INIT_SEL *(CTYPE*)bytes * mult];
		O3CTypeDefines
		#undef DefCType
		default: O3AssertFalse("Unknown type \"%i\"", (int)type);
	}
	return nil;
}

O3CType O3CTypeWithMaxVal(UInt64 maxval, BOOL isSigned) {
	O3CType newType = O3InvalidCType;
	UInt8 max8 = ~(UInt8)0;
	UInt16 max16 = ~(UInt16)0;
	UInt32 max32 = ~(UInt32)0;
	UInt64 max64 = ~(UInt64)0;
	if (maxval<=max8) newType = isSigned? O3Int8CType : O3UInt8CType;
	else if (maxval<=max16) newType = isSigned? O3Int16CType : O3UInt16CType;
	else if (maxval<=max32) newType = isSigned? O3Int32CType : O3UInt32CType;
	else if (maxval<=max64) newType = isSigned? O3Int64CType : O3UInt64CType;
	else {O3Asrt(false);}
	return newType;
}

} //extern "C"