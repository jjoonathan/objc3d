/**
 *  @file O3EncodingInterpretation.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 1/13/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3EncodingInterpretation.h"
#import "O3BufferedWriter.h"
#import "O3BufferedReader.h"
#include <cstdlib>
#include "ObjCEncoding.h"

#undef O3AssumeGCCHack
#ifdef O3AssumeGCCHack
#define O3Alignof(type) __alignof__(type)
#else
#define O3Alignof(type) ({unsigned O3Alignof_align; NSGetSizeAndAlignment(@encode(type), nil, &O3Alignof_align); O3Alignof_align;})
#endif

#ifdef __ia32__
#undef O3Alignof
//__alignof__ and NSGetSizeAndAlignment are buggy
unsigned char O3AlignofLUT[] = {
	0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0,
	0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,
	                    /*!*/ 0,  /*"*/ 0,  /*#*/ 4,
	/*$*/ 0,  /*%*/ 0,  /*&*/ 0,  /*'*/ 0,  /*(*/ 0,
	/*)*/ 0,  /***/ 4,  /*+*/ 0,  /*,*/ 0,  /*-*/ 0,
	/*.*/ 0,  /*/*/ 0,  /*0*/ 0,  /*1*/ 0,  /*2*/ 0,
	/*3*/ 0,  /*4*/ 0,  /*5*/ 0,  /*6*/ 0,  /*7*/ 0,
	/*8*/ 0,  /*9*/ 0,  /*:*/ 4,  /*;*/ 0,  /*<*/ 0,
	/*=*/ 0,  /*>*/ 0,  /*?*/ 4,  /*@*/ 4,  /*A*/ 0,
	/*B*/ 0,  /*C*/ 1,  /*D*/ 0,  /*E*/ 0,  /*F*/ 0,
	/*G*/ 0,  /*H*/ 0,  /*I*/ 4,  /*J*/ 0,  /*K*/ 0,
	/*L*/ 4,  /*M*/ 0,  /*N*/ 0,  /*O*/ 0,  /*P*/ 0,
	/*Q*/ 4,  /*R*/ 0,  /*S*/ 2,  /*T*/ 0,  /*U*/ 0,
	/*V*/ 0,  /*W*/ 0,  /*X*/ 0,  /*Y*/ 0,  /*Z*/ 0,
	/*[*/ 0,  /*\*/ 0,  /*]*/ 0,  /*^*/ 4,  /*_*/ 0,
	/*`*/ 0,  /*a*/ 0,  /*b*/ 1,  /*c*/ 1,  /*d*/ 4,
	/*e*/ 0,  /*f*/ 4,  /*g*/ 0,  /*h*/ 0,  /*i*/ 4,
	/*j*/ 0,  /*k*/ 0,  /*l*/ 4,  /*m*/ 0,  /*n*/ 0,
	/*o*/ 0,  /*p*/ 0,  /*q*/ 4,  /*r*/ 0,  /*s*/ 2,
	/*t*/ 0,  /*u*/ 0,  /*v*/ 0,  /*w*/ 0,  /*x*/ 0,
	/*y*/ 0,  /*z*/ 0,  /*{*/ 0,  /*|*/ 0,  /*}*/ 0,
	/*~*/ 0,  /**/ 0,  /**/ 0,  /**/ 0,  /**/ 0,
	/**/ 0,  /**/ 0,  /*
*/ 0,  /**/ 0,  /**/ 0,
	/**/ 0,  /**/ 0,  /**/ 0,  /**/ 0,  /**/ 0,
	/**/ 0,  /**/ 0,  /**/ 0,  /**/ 0,  /**/ 0,
	/**/ 0,  /**/ 0,  /**/ 0,  /**/ 0,  /**/ 0,
	/**/ 0,  /**/ 0,  /**/ 0,  /**/ 0,  /**/ 0,
	/**/ 0,  /**/ 0,  /**/ 0,  /**/ 0,  /* */ 0,
	/*¡*/ 0,  /*¢*/ 0,  /*£*/ 0,  /*¤*/ 0,  /*¥*/ 0,
	/*¦*/ 0,  /*§*/ 0,  /*¨*/ 0,  /*©*/ 0,  /*ª*/ 0,
	/*«*/ 0,  /*¬*/ 0,  /*­*/ 0,  /*®*/ 0,  /*¯*/ 0,
	/*°*/ 0,  /*±*/ 0,  /*²*/ 0,  /*³*/ 0,  /*´*/ 0,
	/*µ*/ 0,  /*¶*/ 0,  /*·*/ 0,  /*¸*/ 0,  /*¹*/ 0,
	/*º*/ 0,  /*»*/ 0,  /*¼*/ 0,  /*½*/ 0,  /*¾*/ 0,
	/*¿*/ 0,  /*À*/ 0,  /*Á*/ 0,  /*Â*/ 0,  /*Ã*/ 0,
	/*Ä*/ 0,  /*Å*/ 0,  /*Æ*/ 0,  /*Ç*/ 0,  /*È*/ 0,
	/*É*/ 0,  /*Ê*/ 0,  /*Ë*/ 0,  /*Ì*/ 0,  /*Í*/ 0,
	/*Î*/ 0,  /*Ï*/ 0,  /*Ð*/ 0,  /*Ñ*/ 0,  /*Ò*/ 0,
	/*Ó*/ 0,  /*Ô*/ 0,  /*Õ*/ 0,  /*Ö*/ 0,  /*×*/ 0,
	/*Ø*/ 0,  /*Ù*/ 0,  /*Ú*/ 0,  /*Û*/ 0,  /*Ü*/ 0,
	/*Ý*/ 0,  /*Þ*/ 0,  /*ß*/ 0,  /*à*/ 0,  /*á*/ 0,
	/*â*/ 0,  /*ã*/ 0,  /*ä*/ 0,  /*å*/ 0,  /*æ*/ 0,
	/*ç*/ 0,  /*è*/ 0,  /*é*/ 0,  /*ê*/ 0,  /*ë*/ 0,
	/*ì*/ 0,  /*í*/ 0,  /*î*/ 0,  /*ï*/ 0,  /*ð*/ 0,
	/*ñ*/ 0,  /*ò*/ 0,  /*ó*/ 0,  /*ô*/ 0,  /*õ*/ 0,
	/*ö*/ 0,  /*÷*/ 0,  /*ø*/ 0,  /*ù*/ 0,  /*ú*/ 0,
	/*û*/ 0,  /*ü*/ 0,  /*ý*/ 0,  /*þ*/ 0,  /*ÿ*/ 0};
inline char O3Alignof_helper(unsigned char typecode) {
	char toret = O3AlignofLUT[typecode];
	O3Assert(toret, @"O3Alignof() does not know about the type \'%c\'.", typecode);
	return toret;
}
#define O3Alignof(type) O3Alignof_helper(*@encode(type))
#endif

O3EXTERN_C_BLOCK
NSMutableData* O3SerializeDataOfType(const void* from, const char* objCType, UIntP count, NSMutableData* data) {
	if (!data) data = [NSMutableData data];
	O3BufferedWriter bw(data);
	O3SerializeDataOfType(from, objCType, &bw, count);
	return data;
}

void O3DeserializeDataOfType(void* to, const char* objCType, NSData* dat) {
	O3BufferedReader br(dat);
	O3DeserializeDataOfType(to, objCType, &br);
}

void O3EncodedTypeCounterAdvanceWithStack(char inc_char, char dec_char, const char** encoding) { //Private
	unsigned stack = 1;
	char next_char;
	while (next_char = **encoding) {
		if (next_char==inc_char) stack++;
		if (next_char==dec_char) {
			stack--;
			if (!stack) return;
		}
		(*encoding)++;
	}
}

unsigned O3CountObjCEncodedElementsOfType(char type, const char* encoding) {
	char next_char;
	unsigned count = 0;
	while (next_char = *encoding) {
		if (next_char==type) count++;
		
		if (next_char==OCTYPE_ARY_B) {
			//stack++;
			encoding++; if(!*encoding) return count;
			count += atoi(encoding) * O3CountObjCEncodedElementsOfType(type, encoding);
			O3EncodedTypeCounterAdvanceWithStack(OCTYPE_ARY_B, OCTYPE_ARY_E, &encoding);
		}
		else if (next_char==OCTYPE_ARY_E) {
			return count;
		}
		else if (next_char==OCTYPE_STRUCT_B || next_char==OCTYPE_UNION_B) {
			const char* old_location = encoding;
			while ((*encoding) && (*encoding)!='=') encoding++;
			if (!*encoding) encoding = old_location;
		}
		else if (next_char==OCTYPE_PTR) {
			while((*encoding)==OCTYPE_PTR) encoding++;
			if (!(next_char = *encoding)) return count;
			if (next_char==OCTYPE_STRUCT_B) O3EncodedTypeCounterAdvanceWithStack(OCTYPE_STRUCT_B, OCTYPE_STRUCT_E, &encoding);
			if (next_char==OCTYPE_ARY_B) O3EncodedTypeCounterAdvanceWithStack(OCTYPE_ARY_B, OCTYPE_ARY_E, &encoding);
			if (next_char==OCTYPE_UNION_B) O3EncodedTypeCounterAdvanceWithStack(OCTYPE_UNION_B, OCTYPE_UNION_E, &encoding);
		}
		encoding++;
	}
	return count;
}


///@fixme Doesn't handle unions right
unsigned O3UnalignedSizeofObjCEncodedType(const char* encoding) {
	char next_char;
	double bytes = 0;
	while (next_char = *encoding) {
		switch (next_char) {
			case OCTYPE_INT: bytes += sizeof(int); break;
			case OCTYPE_SHT: bytes += sizeof(short); break;
			case OCTYPE_LNG: bytes += sizeof(long); break;
			case OCTYPE_LNG_LNG: bytes += sizeof(UIntP); break;
			case OCTYPE_UCHR: bytes += sizeof(unsigned char); break;
			case OCTYPE_UINT: bytes += sizeof(unsigned int); break;
			case OCTYPE_USHT: bytes += sizeof(unsigned short); break;
			case OCTYPE_ULNG: bytes += sizeof(unsigned long); break;
			case OCTYPE_ULNG_LNG: bytes += sizeof(unsigned UIntP); break;
			case OCTYPE_FLT: bytes += sizeof(float); break;
			case OCTYPE_DBL: bytes += sizeof(double); break;
			case OCTYPE_CHARPTR: bytes += sizeof(char *); break;
			case OCTYPE_BFLD: bytes += .125*atoi(encoding+1); break;
			case OCTYPE_UNDEF: bytes += sizeof(void*); break;
			case OCTYPE_ID: bytes += sizeof(id); break;
			case OCTYPE_CLASS: bytes += sizeof(Class); break;
			case OCTYPE_SEL: bytes += sizeof(@selector(alloc)); break;
			//case OCTYPE_VECTOR: bytes += sizeof(vector char); break;
			
			case OCTYPE_ARY_E: 
				return bytes;				
			
			case OCTYPE_UNION_B: {
				O3CToImplement();
				break;
			}
			
			case OCTYPE_ARY_B: {
				encoding++; if(!*encoding) return bytes;
				bytes += atoi(encoding) * O3UnalignedSizeofObjCEncodedType(encoding);
				O3EncodedTypeCounterAdvanceWithStack(OCTYPE_ARY_B, OCTYPE_ARY_E, &encoding);				
				break;
			}
			
			case OCTYPE_STRUCT_B: {
				const char* old_location = encoding;
				while ((*encoding) && (*encoding)!='=') encoding++;
				if (!*encoding) encoding = old_location;				
				break;
			}
			
			case OCTYPE_PTR: {
				bytes += sizeof(void*);
				while((*encoding)==OCTYPE_PTR) encoding++;
				if (!(next_char = *encoding)) return bytes;
				if (next_char==OCTYPE_STRUCT_B) O3EncodedTypeCounterAdvanceWithStack(OCTYPE_STRUCT_B, OCTYPE_STRUCT_E, &encoding);
				if (next_char==OCTYPE_ARY_B) O3EncodedTypeCounterAdvanceWithStack(OCTYPE_ARY_B, OCTYPE_ARY_E, &encoding);
				if (next_char==OCTYPE_UNION_B) O3EncodedTypeCounterAdvanceWithStack(OCTYPE_UNION_B, OCTYPE_UNION_E, &encoding);				
				break;
			}
			
		}
		encoding++;
	}
	return bytes;
}

unsigned O3AlignedSizeofObjCEncodedType(const char* encoding) {
	unsigned to_return;
	NSGetSizeAndAlignment(encoding, &to_return, nil);
	return to_return;
}

void O3MoveDataOfType(const void* from, void* to, const char* objCType, UIntP count) {
	if (count<1) return;
	if (!from || !to || !objCType) {
		O3CLogWarn(@"One of from, to, or objCType missing in call to O3MoveDataOfType. Aborted. (from=0x%X, to=0x%X, objCType=%s, count=%i", from, to, objCType, count);
		return;
	}	
	unsigned totalsize = O3AlignedSizeofObjCEncodedType(objCType);
	memcpy(to, from, totalsize*count);
}
O3END_EXTERN_C_BLOCK

///@fixme Doesn't handle unions or bitfields right
///@param align 0 (default) if alignment should be automatically determined, and 1 for "no alignment"
void O3SerializeDataOfType(const void* from, const char* objCType, O3BufferedWriter* writer, UIntP count) {
	//if (!align && *objCType==OCTYPE_STRUCT_B) NSGetSizeAndAlignment(objCType, nil, &align);
	O3BufferedWriter& appendTo = *writer;
	const char* oldObjCType = objCType;
	const char* c = (const char*)from;
	if (count<1) return;
	char next_char;
	UIntP i; for (i=0; i<count; i++) {
		objCType = oldObjCType;
		while (next_char = *objCType) {
			unsigned size = 0;
			const char* nextObjCType = objCType+1;
			switch (next_char) {
				case OCTYPE_CHR:
					c = (const char*)O3RoundUpToNearest((UIntP)c, O3Alignof(char));
					appendTo.WriteIntAsBytes(*(char*)c, 1);
					size = sizeof(char);
					break;
				case OCTYPE_INT:
					c = (const char*)O3RoundUpToNearest((UIntP)c, O3Alignof(int));
					appendTo.WriteCInt(*(int*)c);
					size = sizeof(int);
					break;
				case OCTYPE_SHT:
					c = (const char*)O3RoundUpToNearest((UIntP)c, O3Alignof(short));
					appendTo.WriteIntAsBytes(*(short*)c, 2);
					size = sizeof(short);				
					break;
				case OCTYPE_LNG:
					c = (const char*)O3RoundUpToNearest((UIntP)c, O3Alignof(long));
					appendTo.WriteCInt(*(long*)c);
					size = sizeof(long);				
					break;
				case OCTYPE_LNG_LNG:
					c = (const char*)O3RoundUpToNearest((UIntP)c, O3Alignof(long long));
					appendTo.WriteCInt(*(long long*)c);
					size = sizeof(long long);			
					break;
				case OCTYPE_UCHR:
					c = (const char*)O3RoundUpToNearest((UIntP)c, O3Alignof(unsigned char));
					appendTo.WriteUIntAsBytes(*(unsigned char*)c, 1);
					size = sizeof(unsigned char);		
					break;
				case OCTYPE_UINT:
					c = (const char*)O3RoundUpToNearest((UIntP)c, O3Alignof(unsigned int));
					appendTo.WriteUCInt(*(unsigned int*)c);
					size = sizeof(unsigned int);		
					break;
				case OCTYPE_USHT:
					c = (const char*)O3RoundUpToNearest((UIntP)c, O3Alignof(unsigned short));
					appendTo.WriteUIntAsBytes(*(unsigned short*)c, 2);
					size = sizeof(unsigned short);	
					break;
				case OCTYPE_ULNG:
					c = (const char*)O3RoundUpToNearest((UIntP)c, O3Alignof(unsigned long));
					appendTo.WriteUCInt(*(unsigned long*)c);
					size = sizeof(unsigned long);		
					break;
				case OCTYPE_ULNG_LNG:
					c = (const char*)O3RoundUpToNearest((UIntP)c, O3Alignof(unsigned long long));
					appendTo.WriteUCInt(*(unsigned long long*)c);
					size = sizeof(unsigned long long);
					break;
				case OCTYPE_FLT:
					c = (const char*)O3RoundUpToNearest((UIntP)c, O3Alignof(float));
					appendTo.WriteFloat(*(float*)c);
					size = sizeof(float);				
					break;
				case OCTYPE_DBL:
					c = (const char*)O3RoundUpToNearest((UIntP)c, O3Alignof(double));
					appendTo.WriteDouble(*(double*)c);
					size = sizeof(double);			
					break;
				case OCTYPE_CHARPTR:
					c = (const char*)O3RoundUpToNearest((UIntP)c, O3Alignof(char*));
					appendTo.WriteCCString(*(char**)c);
					size = sizeof(char*);			
					break;
				case OCTYPE_SEL:
					c = (const char*)O3RoundUpToNearest((UIntP)c, O3Alignof(SEL));
					appendTo.WriteCCString(NSStringFromSelector(*(SEL*)c));
					size = sizeof(SEL);	
					break;
				case OCTYPE_CLASS:
					c = (const char*)O3RoundUpToNearest((UIntP)c, O3Alignof(Class));
					appendTo.WriteCCString(NSStringFromClass(*(Class*)c));
					size = sizeof(Class);	
					break;								
				case OCTYPE_ARY_E: 
				case OCTYPE_STRUCT_E: 
				case OCTYPE_UNION_E: 
					nextObjCType="";
					size=0;		//Break out to the next iteration of the big for loop
					break;				
					
				case OCTYPE_UNDEF:
				case OCTYPE_VOID:
				case OCTYPE_BFLD:
				case OCTYPE_UNION_B:
				case OCTYPE_VECTOR:
					O3Assert(false, @"O3SerializeDataOfType cannot handle vectors, bitfields, unions, or voids (void*s are fine).")
					break;
					
				case OCTYPE_ARY_B: {
					unsigned arr_align;
					nextObjCType = NSGetSizeAndAlignment(objCType, &size, &arr_align);
					c = (const char*)O3RoundUpToNearest((UIntP)c, arr_align);
					objCType++;
					if (!*objCType)
						[NSException raise:NSInconsistentArchiveException format:@"Premature end of @encode string %s", oldObjCType];
					unsigned arr_count = atoi(objCType);
					while (isdigit(*objCType)) objCType++;
					O3SerializeDataOfType(c, objCType, &appendTo, arr_count);
					//O3EncodedTypeCounterAdvanceWithStack(OCTYPE_ARY_B, OCTYPE_ARY_E, &objCType);
					//nextObjCType=objCType+1;			
					break;
				}
					
				case OCTYPE_STRUCT_B: {
					unsigned struct_align;
					nextObjCType = NSGetSizeAndAlignment(objCType, &size, &struct_align);
					c = (const char*)O3RoundUpToNearest((UIntP)c, struct_align);
					objCType++;
					const char* structStartObjCType = objCType;
					while (*objCType && *objCType!=OCTYPE_STRUCT_E && *objCType!='=') objCType++;
					if (*objCType!='=') objCType = structStartObjCType; //Struct was unnamed
					else objCType++;
					O3SerializeDataOfType(c, objCType, &appendTo, 1);
					O3EncodedTypeCounterAdvanceWithStack(OCTYPE_STRUCT_B, OCTYPE_STRUCT_E, &objCType);			
					break;
				}
					
				case OCTYPE_ID:
				case OCTYPE_PTR: {
					c = (const char*)O3RoundUpToNearest((UIntP)c, O3Alignof(void*));
					while((*objCType)==OCTYPE_PTR) objCType++;
					if (!(next_char = *objCType))
						[NSException raise:NSInconsistentArchiveException format:@"Premature end of @encode string %s", oldObjCType];
					objCType++;
					if (next_char==OCTYPE_STRUCT_B) O3EncodedTypeCounterAdvanceWithStack(OCTYPE_STRUCT_B, OCTYPE_STRUCT_E, &objCType);
					if (next_char==OCTYPE_ARY_B) O3EncodedTypeCounterAdvanceWithStack(OCTYPE_ARY_B, OCTYPE_ARY_E, &objCType);
					if (next_char==OCTYPE_UNION_B) O3EncodedTypeCounterAdvanceWithStack(OCTYPE_UNION_B, OCTYPE_UNION_E, &objCType);		
					size = sizeof(void*);
					nextObjCType = objCType;
					break;
				}
			} /*switch(next_char)*/
			c += size;
			objCType = nextObjCType;
		} /*while(next_char)*/
	} /*for(i=0; i<count; i++)*/
}

///@fixme Doesn't handle unions or bitfields right
///@param align 0 (default) if alignment should be automatically determined, and 1 for "no alignment"
///@warn Type shrinkage is not checked for. For istance, if a 64-bit instance of O3DeserializeDataOfType saves 2^33 as a long and then sends the data to a 32 bit instance, the value would be truncated without warning, error, or exception.
///@fixme Type shrinkage (add exceptions)
void O3DeserializeDataOfType(void* to, const char* objCType, O3BufferedReader* reader, UIntP count) {
	//if (!align && *objCType==OCTYPE_STRUCT_B) NSGetSizeAndAlignment(objCType, nil, &align);
	O3BufferedReader& readFrom = *reader;
	const char* oldObjCType = objCType;
	char* c = (char*)to;
	if (count<1) return;
	char next_char;
	UIntP i; for (i=0; i<count; i++) {
		objCType = oldObjCType;
		while (next_char = *objCType) {
			unsigned size = 0;
			const char* nextObjCType = objCType+1;
			switch (next_char) {
				case OCTYPE_CHR:
					c = (char*)O3RoundUpToNearest((UIntP)c, O3Alignof(char));
					*(char*)c = readFrom.ReadBytesAsInt32(1);
					size = sizeof(char);
					break;
				case OCTYPE_INT:
					c = (char*)O3RoundUpToNearest((UIntP)c, O3Alignof(int));
					*(int*)c = readFrom.ReadCIntAsInt32();
					size = sizeof(int);
					break;
				case OCTYPE_SHT:
					c = (char*)O3RoundUpToNearest((UIntP)c, O3Alignof(short));
					*(short*)c = readFrom.ReadBytesAsInt32(2);
					size = sizeof(short);				
					break;
				case OCTYPE_LNG:
					c = (char*)O3RoundUpToNearest((UIntP)c, O3Alignof(long));
					*(long*)c = (long)readFrom.ReadCIntAsInt64();
					size = sizeof(long);				
					break;
				case OCTYPE_LNG_LNG:
					c = (char*)O3RoundUpToNearest((UIntP)c, O3Alignof(long long));
					*(long long*)c = readFrom.ReadCIntAsInt64();
					size = sizeof(long long);			
					break;
				case OCTYPE_UCHR:
				c = (char*)O3RoundUpToNearest((UIntP)c, O3Alignof(unsigned char));
					*(unsigned char*)c = readFrom.ReadBytesAsUInt32(1);
					size = sizeof(unsigned char);		
					break;
				case OCTYPE_UINT:
				c = (char*)O3RoundUpToNearest((UIntP)c, O3Alignof(unsigned int));
					*(unsigned int*)c = readFrom.ReadUCIntAsUInt32();
					size = sizeof(unsigned int);		
					break;
				case OCTYPE_USHT:
				c = (char*)O3RoundUpToNearest((UIntP)c, O3Alignof(unsigned short));
					*(unsigned short*)c = readFrom.ReadBytesAsUInt32(2);
					size = sizeof(unsigned short);	
					break;
				case OCTYPE_ULNG:
				c = (char*)O3RoundUpToNearest((UIntP)c, O3Alignof(unsigned long));
					*(unsigned long*)c = (unsigned long)readFrom.ReadUCIntAsUInt64();
					size = sizeof(unsigned long);		
					break;
				case OCTYPE_ULNG_LNG:
					c = (char*)O3RoundUpToNearest((UIntP)c, O3Alignof(unsigned long long));
					*(unsigned long long*)c = readFrom.ReadUCIntAsUInt64();
					size = sizeof(unsigned long long);
					break;
				case OCTYPE_FLT:
					c = (char*)O3RoundUpToNearest((UIntP)c, O3Alignof(float));
					c = (char*)O3RoundUpToNearest((UIntP)c, O3Alignof(float));
					*(float*)c = readFrom.ReadFloat();
					size = sizeof(float);				
					break;
				case OCTYPE_DBL:
					c = (char*)O3RoundUpToNearest((UIntP)c, O3Alignof(double));
					c = (char*)O3RoundUpToNearest((UIntP)c, O3Alignof(double));
					*(double*)c = readFrom.ReadDouble();
					size = sizeof(double);			
					break;
				case OCTYPE_CHARPTR:
					c = (char*)O3RoundUpToNearest((UIntP)c, O3Alignof(char*));
					NSString* str = readFrom.ReadCCString();
					O3CLogDebug(@"C string at %p probably leaked (deserialized into a struct)");
					*(const char**)c = strdup([str UTF8String]);
					size = sizeof(char*);			
					break;
				case OCTYPE_SEL:
					c = (char*)O3RoundUpToNearest((UIntP)c, O3Alignof(SEL));
					*(SEL*)c = NSSelectorFromString(readFrom.ReadCCString());
					size = sizeof(SEL);	
					break;
				case OCTYPE_CLASS:
					c = (char*)O3RoundUpToNearest((UIntP)c, O3Alignof(Class));
					*(Class*)c = NSClassFromString(readFrom.ReadCCString());
					size = sizeof(Class);	
					break;								
				case OCTYPE_ARY_E: 
				case OCTYPE_STRUCT_E: 
				case OCTYPE_UNION_E: 
					nextObjCType="";		//Break out to the next iteration of the big for loop
					size=0;
					break;				
					
				case OCTYPE_UNDEF:
				case OCTYPE_VOID:
				case OCTYPE_BFLD:
				case OCTYPE_UNION_B:
				case OCTYPE_VECTOR:
					O3Assert(false, @"O3DeserializeDataOfType cannot handle vectors, bitfields, unions, or voids (void*s are fine).")
					break;
					
				case OCTYPE_ARY_B: {
					unsigned arr_align;
					nextObjCType = NSGetSizeAndAlignment(objCType, &size, &arr_align);
					c = (char*)O3RoundUpToNearest((UIntP)c, arr_align);
					objCType++;
					if (!*objCType)
						[NSException raise:NSInconsistentArchiveException format:@"Premature end of @encode string %s", oldObjCType];
					unsigned arr_count = atoi(objCType);
					while (isdigit(*objCType)) objCType++;
					O3DeserializeDataOfType(c, objCType, reader, arr_count);			
					break;
				}
					
				case OCTYPE_STRUCT_B: {
					unsigned struct_align;
					nextObjCType = NSGetSizeAndAlignment(objCType, &size, &struct_align);
					c = (char*)O3RoundUpToNearest((UIntP)c, struct_align);
					objCType++;
					const char* structStartObjCType = objCType;
					while (*objCType && *objCType!=OCTYPE_STRUCT_E && *objCType!='=') objCType++;
					if (*objCType!='=') objCType = structStartObjCType; //Struct was unnamed
					else objCType++;
					O3DeserializeDataOfType(c, objCType, reader, 1);
					O3EncodedTypeCounterAdvanceWithStack(OCTYPE_STRUCT_B, OCTYPE_STRUCT_E, &objCType);			
					break;
				}
					
				case OCTYPE_ID:
				case OCTYPE_PTR: {
					c = (char*)O3RoundUpToNearest((UIntP)c, O3Alignof(void*));
					while((*objCType)==OCTYPE_PTR) objCType++;
					if (!(next_char = *objCType))
						[NSException raise:NSInconsistentArchiveException format:@"Premature end of @encode string %s", oldObjCType];
					objCType++;
					if (next_char==OCTYPE_STRUCT_B) O3EncodedTypeCounterAdvanceWithStack(OCTYPE_STRUCT_B, OCTYPE_STRUCT_E, &objCType);
					if (next_char==OCTYPE_ARY_B) O3EncodedTypeCounterAdvanceWithStack(OCTYPE_ARY_B, OCTYPE_ARY_E, &objCType);
					if (next_char==OCTYPE_UNION_B) O3EncodedTypeCounterAdvanceWithStack(OCTYPE_UNION_B, OCTYPE_UNION_E, &objCType);	
					*(void**)c = NULL;
					size = sizeof(void*);
					nextObjCType = objCType;
					break;
				}
			} /*switch(next_char)*/
			c += size;
			objCType = nextObjCType;
		} /*while(next_char)*/
	} /*for(i=0; i<count; i++)*/
	return;
}
