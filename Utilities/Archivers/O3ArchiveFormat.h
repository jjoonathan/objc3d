#pragma once
/**
 *  @file O3ArchiveFormat.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 5/17/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
enum O3PkgType { //See below for the full definitions of these types
	O3PkgTypeFalse=0,		//False, or 0. These both may be indicated by the absense of a key, though it is sometimes (for development) desireable to keep a 0/false key around.
	O3PkgTypeTrue=1,		//True, 1, or 1.
	O3PkgTypePositiveInt=2,		//Positive big endian integer (not a UCInt) of a variable length. 
	O3PkgTypeNegativeInt=3,		//Big endian negative integer (not a CInt) of a variable length. No sense in storing signed and unsigned if you can store positive and negative and win a bit!
	O3PkgTypeFloat=4,		//Variable length big endian half/float/double/bignum (float and bignum not implemented at present)
	//O3PkgTypeNil=5,	//Variable length value that is interpreted as unsigned_int_value/(pow(2,sizeof(data)*8)-1)
	O3PkgTypeIndexedString=6, //A O3PkgTypePositiveInt that is an index into the O3PkgTypeStringArray defined by the root key "ST"
	O3PkgTypeString=6,		//A non-null-terminated C string (not a CCString)
	O3PkgTypeValue=7,		//Stores both vectors and matricies.
	O3PkgTypeDictionary=8, 	//Stored as a dictionary. By default it is unarchived as a dictionary but because of the coder callbacks VFS is also a possibility
	O3PkgTypeArray=9,		//An array of objects in it's simplest form. Just a bunch of TypedObjs. See above.	
	O3PkgTypeValueArray=0xA,	//A bunch of efficiently stored @encoded types from an O3ValueArray.
	O3PkgTypeStringArray=0xB,//A bunch of CCStrings. 
	O3PkgTypeRawData=0xC,	//Basically an NSData.
	//O3PkgTypeSoftAlias=0xD,	//A StringArray where the strings are implicitly separated by "/". Note that this is perfectly legal: (CCString)"usr/lib" (CCString)"gcc" would result in "usr/lib/gcc". It is the VFS path to the resource the alias will point to. The alias is a proxy to the real object or a pointer to the real object depending on implementation, but the target is not loaded twice like a HardAlias.
	O3PkgTypeObject=0xE //An object that is encodeWithCoder:d
};

/* Root Keys
 * Eech package is esentially a dictionary. There are several "global keys" for package data, metadata, etc.
 * "C" is a dictionary of arrays with fallback classes in it
 * "KT" "ST" and "CT" are the Key Table, the String Table, and the Class Table
 * "" is the content of the archive itself.
 * "D" is the "domain" of the archive. When an archive is being loaded as a set of resources, the domain + "_" is prepended to all keys in the archive root.
 */

#ifdef __cplusplus
/* U?CInt
 * A U?CInt stores a signed or unsigned integer very efficiently. 
 * The MSB of every byte (byte&0x80) determines if there is another byte following it.
 * This preserves the zero property (0x00=0) and allows all integers less than 32 (for CInts) or 64 (for UCInts) to be stored in a single byte!
 * If the integer is signed, (first_byte&0x40) determines if it is negative (if the bit is set, the other bits represent a negative integer, otherwise a positive one.)
 * Example: (UCInt)0xAA  -> 0b10000010 01010101
 * Example2: (CInt)-0xAA -> 0b11000010 01010101
 * Example3: (UCInt)0x1  -> 0b10000000 10000000 00000001 //This is perfectly legal and can be used to speed up file writing
 */
template <typename uint_t>
unsigned O3BytesNeededForUCInt(uint_t number) { ///<Returns the number of bytes needed to store %number as a UCInt
	unsigned count = 1;
	while (number = number>>7) count++;
	return count;
}

template <typename int_t>
unsigned O3BytesNeededForCInt(int_t number) { ///<Returns the number of bytes needed to store %number as a CInt
	number = ::llabs(number);
	if (!(number = number>>6)) return 1;
	unsigned count = 2;
	while (number = number>>7) count++;
	return count;
}

template <typename uint_t>
unsigned O3BytesNeededForUInt(uint_t number) { ///<Returns the number of bytes needed to store %number as a UInt
	unsigned count = 1;
	while (number = number>>8) count++;
	return count;
}

template <typename int_t>
unsigned O3BytesNeededForInt(int_t number) { ///<Returns the number of bytes needed to store %number as a Int
	UInt64 num = ::llabs(number)<<1;
	unsigned count = 1;
	while (num = num>>8) count++;
	return count;
}

template <typename IntegerType>
	int O3WriteIntAsBytes(UInt8* wb, IntegerType value, int bytes) {
		IntegerType uval = value;
		if (uval<0) uval = -(uval+1);
		BOOL negative = value<0;
		if (uval>>1 >= 1ull<<(bytes*8-2) && bytes<=sizeof(IntegerType))
			[NSException raise:NSInconsistentArchiveException format:@"Definite loss of precision in O3BufferedWriter::WriteInt32AsBytes (%s%X does not fit in %i bytes)", negative?"-":"", uval, bytes];
		int i; for (i=bytes-1; i>=0; i--) {
			wb[i] = uval&0xFF;
			uval >>= 8;
		}
		if (negative)	wb[0] |= 0x80;
		else 			wb[0] &= 0x7F;
		return bytes;
	}
	
template <typename UIntegerType>
	int O3WriteUIntAsBytes(UInt8* writebytes, UIntegerType value, int bytes) {
		O3CLogDebug(@"WriteUIntAsBytes(0x%qX==%i, %i)", (UInt64)value, (UInt64)value, bytes);
		if (value>>1 >= 1ull<<(bytes*8-1) && bytes<=sizeof(UIntegerType))
			[NSException raise:NSInconsistentArchiveException format:@"Definite loss of precision in O3BufferedWriter::WriteInt32AsBytes (%X does not fit in %i bytes)", value, bytes];
		int i; for (i=bytes-1; i>=0; i--) {
			writebytes[i] = value&0xFF;
			value >>= 8;
		}
		return bytes;
	}

///Writes a CInt to writebytes
///@return The number of bytes written
template <typename IntegerType>
	int O3WriteCInt(UInt8* writebytes, IntegerType value) {
		O3CLogDebug(@"WriteUCInt(%s0x%qX==%qi)", (value<0)?"-":"", (UInt64)value, (Int64)value);
		int usedbytes=0;
		IntegerType uval = value;
		if (uval<0) uval = -(uval+1);
		BOOL negative = value<0;
		UInt8 b1 = uval&0x3F;
		uval >>= 6;
		if (negative) b1 |= 0x40;
		if (uval) b1 |= 0x80;
		writebytes[usedbytes++] = b1;
		while (uval) {
			UInt8 b = uval&0x7F;
			uval >>= 7;
			if (uval) b |= 0x80;
			writebytes[usedbytes++] = b;
		}
		return usedbytes;
	}

///Writes a UCInt to writebytes
///@return The number of bytes written
template <typename UIntegerType>
	int O3WriteUCInt(UInt8* writebytes, UIntegerType value) {
		O3CLogDebug(@"WriteUIntAsUCInt(0x%qX==%qi)", (UInt64)value, (UInt64)value);
		int usedbytes=0;
		if (!value) writebytes[usedbytes++] = 0;
		while (value) {
			UInt8 b = value&0x7F;
			value >>= 7;
			if (value) b |= 0x80;
			writebytes[usedbytes++] = b;
		}
		return usedbytes;
	}

/* CCString
* A CCString is an efficient representation of a CString, much like a pascal string.
* It consists of a CInt (not a UCInt), and if the CInt is positive or 0, the CInt is followed by that many bytes of a non null terminated UTF8 string.
* If the CInt is less than 0, the value of the string is the string in one of the file's string tables at index (-Cint-1).
* Which string table depends on the location of the CCString. If the CCString is in the name field of a type specifier, it is found in
* the TypeTable (file metadata key “TT“). If it is in the key field of a dictionary, it is found in the KeyTable (file metadata key “KT“), and if it is 
* anywhere else it is found in the GlobalStringTable (file metadata key “ST“). An index into one of the tables cannot be used in the file before the 
* definition of the table (an alias or an implicit table are considered to be the definition even if the actual definition may appear elsewhere or not at all).
*/

enum O3CCSTableType {
	O3CCSKeyTable,
	O3CCSClassTable,
	O3CCSStringTable
};

typedef struct {
	UIntP index;
	UIntP len;
} O3CCStringHint;

///@param hint_out a pointer to a struct to be filled with hint data for fast writing
inline UIntP O3BytesNeededForCCStringWithTable(NSString* str, NSDictionary* table, O3CCStringHint* hint_out = NULL) {
	if (!str) return 0;
	NSNumber* n = O3CFDictionaryGetValue(table, str);
	IntP idx = n?O3NSNumberLongLongValue(n):0;
	if (hint_out) hint_out->index = idx;
	if (idx) return O3BytesNeededForCInt(-idx);
	UIntP len = [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	if (hint_out) hint_out->len = len;
	return O3BytesNeededForCInt(len)+len;
}

///@brief Writes a CCString %str to %bytes
///@param index A "hint" as to str's index according to table. Note that this hint may not be wrong else bad things will happen. So it is not really a hint. Pass 0 to have this function manually comptue it.
///@param hint if present will supercede table to provide index / length data (get from BytesNeeded...)
inline UIntP O3WriteCCStringWithTableOrIndex(UInt8* bytes, NSString* str, NSDictionary* table = nil, const O3CCStringHint* hint = NULL) {
	O3AssertArg(bytes, @"Bytes is a required argument.");
	if (!str) return 0;
	
	IntP index = 0;
	if (hint) {
		index = hint->index;
	} else if (table) {
		NSNumber* n = str?O3CFDictionaryGetValue(table, str):nil;
		index = n?O3NSNumberLongLongValue(n):0;
	}
	
	if (index) return O3WriteCInt(bytes, -index);
	
	UIntP len = hint ? hint->len : [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	const char* rawstr = [str UTF8String];
	int ibytes = O3WriteCInt(bytes,len);
	memcpy(bytes+ibytes, rawstr, len);
	return ibytes + len;
}

/*TypedObj:
*	O3PkgType type : 4;
*	unsigned  size : 4;
*if (type==O3PkgTypeObject) CCString class; //This string can be an index into the TypeTable (header key “TT“)
*if (size==0xE) size = 64;
*if (size==0xD) size = 32;
*if (size==0xC) size = 16;
*if (size==0xB) size = 12;
*if (size==0xF) UCInt realsize;
*UInt8 data[size or realsize];
*/

///@param index_out Cache this and len_out for a performance win (feed it into O3WriteTypedObjectHeader). This is not a hint, so don't mess with it.
inline UIntP O3BytesNeededForTypedObjectHeader(UIntP size, NSString* className, NSDictionary* table = nil, O3CCStringHint* classNameHintOut = NULL) {
	UIntP writesize = 1;
	if (className) writesize += O3BytesNeededForCCStringWithTable(className, table, classNameHintOut);
	if (!(size<=0xA || size==12 || size==16 || size==32 || size==64)) writesize += O3BytesNeededForUCInt(size);
	return writesize;
}

inline UIntP O3WriteTypedObjectHeader(UInt8* buf, O3PkgType type, UIntP size, NSString* className, NSDictionary* table = nil, const O3CCStringHint* classNameHint = NULL) {
	O3AssertArg(buf, @"No null buffers for writing allowed!");
	O3AssertArg(!((className?YES:NO)^type==O3PkgTypeObject), @"In WriteKVHeaderAtPlaceholder, a className (%@) must be and must only be provided for type==O3PkgTypeObject==14 (%i)", className, type);
	UInt8& byte = buf[0];
	UIntP usedBytes=1;
	
	//Write className if necessary
	if (className) {
		usedBytes+=O3WriteCCStringWithTableOrIndex(buf+usedBytes, className, table, classNameHint);
	}
	
	//Write byte and write size
	if (size<=0xA) byte = size;
	else if (size==12) byte = 0xB;
	else if (size==16) byte = 0xC;
	else if (size==32) byte = 0xD;
	else if (size==64) byte = 0xE;
	else {
		byte = 0xF;
		usedBytes += O3WriteUCInt(buf+usedBytes, size);
	}
	byte |= (unsigned)type << 4;
	
	return usedBytes;
}



/*Int, UInt, Float:
*For Int and UInt, bytes are treated as the least significant big endian bytes of the number they represent.
*If the integer is signed, the most significant bit of the first byte is the sign (1 is negative).
*NOTE that this behavior is different from the internal storage of these types.
*A 4 byte float is a big endian IEEE754 “float“, and an 8 byte float is a big endian IEEE754 “double“.
*Exotic floats (2 byte “half“s in the NV_half format or bignum uberfloats) are possible but currently not supported.
*/

/*String:
*A String is a plain UTF8 string with OR WITHOUT the “sentinal byte“ (the null terminator).
*Always tack another 0x00 on the end, you can never really go wrong (but make sure to drop the last null byte when writing or the string will grow with every write).
*/

/*O3Mat:
* BYTE info;
*	//The 2 most significant bytes (info>>6) dictate type (0=float, 1=double, 2=CInt, 3=type follows)
*	//The next 3 (info>>3&0x7) dictate the number of rows (for a column vector this is the number of elements). 0x7 indicates that a UCInt follows with the number of rows.
*	//The next 3 (info&0x7) dictate the number of columns (1 for a column vector). 0x7 indicates that a UCInt follows with the number of columns.
* if (rows==0x7) UCInt realrows;
* if (columns==0x7) UCInt realcols;
* if (type==3) CCString realtype;
* type[rows*columns] data; //Row-major (first 0,0 then 1,0 then 2,0 then 0,1)
*/

/*Dictionary:
*CCString key; //This string can index into the KeyTable (header key “KT“)
*TypedObj val;
*/

/*Array:
*TypedObj objects[count]; //Just keep reading objects until the size specified in the TypedObj header has been reached
*/

/*FixedSizeArray:
*TypedObj-data element_type; //Gives the type of each of the elements. Obviously, the data field is N/A here (since an array of data fields follows)
*UInt8 data[element_type.size][count] //Just keep reading objects until the size specified in the TypedObj header has been reached
*/

/*FixedSizeMatrix:
*TypedObj-data element_type; //Gives the type of each of the elements. Obviously, the data field is N/A here (since an array of data fields follows)
*UCInt columns;  //Just keep reading objects until the size specified in the TypedObj header has been reached
*UInt8 data[element_type.size][rows][columns]; //Row-major (first 0,0 then 1,0 then 2,0 then 0,1)
*/

/*StringArray:
*CString strings[n]; //Just keep reading strings until the size specified in the TypedObj header has been reached.
*/

/*RawData:
*Just raw, untyped data
*/

/*Alias: *** DEPRICATED ***
*CCString path;
*/

/*Paths: (not really a type, but how they are used) *** DEPRICATED ***
* /... is relative to the VFS root
* ~/... is relative to the local package
* ./... is in the same virtual folder/object as the place it is specified
* ../... is in the folder above the place it is specified
*/

#endif /*defined(__cplusplus)*/