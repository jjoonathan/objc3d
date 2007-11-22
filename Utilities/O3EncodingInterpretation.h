#pragma once
/**
 *  @file O3EncodingInterpretation.h
 *  @encode 
 *  @license MIT License (see LICENSE.txt)
 *  @date 1/13/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3BufferedWriter.h"
#import "O3BufferedReader.h"

#ifdef __cplusplus
#define DEFAULT_TO_1ULL =1ull
#define DEFAULT_TO_NULL =NULL
#else
#define DEFAULT_TO_1ULL 
#define DEFAULT_TO_NULL
#endif

unsigned O3CountObjCEncodedElementsOfType(char type, const char* encoding); ///<Counts the number of elements of encoding type \e type in \e encoding (made with @encode()). For instance, O3CountObjCEncodedElementsOfType('i', "[5i]d") would return 5.
unsigned O3UnalignedSizeofObjCEncodedType(const char* encoding); ///<Counts the number of bytes taken by Objective C encoding \e encoding in a completely unaligned format.Use the NSGetSizeAndAlignment function to get the aligned size (Note: as of now, apple's docs suck. NSGetSizeAndAlignment returns the aligned size (sizeof for simple types, aligned size for structs) in size and for structs, returns the alignment of the sub-types in alignment. For regular types, align=size)
unsigned O3AlignedSizeofObjCEncodedType(const char* encoding);
void O3MoveDataOfType(const void* from, void* to, const char* objCType, UIntP count DEFAULT_TO_1ULL);
#ifdef __cplusplus
void O3SerializeDataOfType(const void* from, const char* objCType, O3BufferedWriter* writer, UIntP count DEFAULT_TO_1ULL);
void O3DeserializeDataOfType(void* to, const char* objCType, O3BufferedReader* reader, UIntP count DEFAULT_TO_1ULL);
#endif

NSMutableData* O3SerializeDataOfType(const void* from, const char* objCType, UIntP count DEFAULT_TO_1ULL, NSMutableData* data DEFAULT_TO_NULL);
void O3DeserializeDataOfType(void* to, const char* objCType, NSData* dat);

#ifdef __cplusplus
static void* O3DeserializedBytesOfType(const char* objCType, O3BufferedReader* reader, UIntP count, UIntP* size DEFAULT_TO_NULL) {
	UIntP unpacked_size = O3AlignedSizeofObjCEncodedType(objCType)*count;
	void* buffer = malloc(unpacked_size);
	O3DeserializeDataOfType(buffer, objCType, reader, count);
	if (size) *size = unpacked_size;
	return buffer;
}
#endif

#undef DEFAULT_TO_1ULL
#undef DEFAULT_TO_NULL