//
//  NSData+zlib.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 3/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

typedef struct _O3DeflationOptions {
	BOOL rawDeflate; //=NO by default. YES if the header and trailer should be dropped
	int windowBits; //=15 by default
	int memLevel; //=8 by default
	int compressionLevel; //= 7(/9) by default
	#ifdef __cplusplus
	_O3DeflationOptions() : rawDeflate(NO), windowBits(15), memLevel(8), compressionLevel(7) {}
	#endif
} O3DeflationOptions;

typedef struct _O3InflationOptions {
	BOOL rawInflate; //YES if rawDeflate was used when deflating the data (defaults to NO)
	NSMutableData* inflateInto; //inflateInto will be used (and returned) as a target for the inflation. Allows "hinting" about the 
	#ifdef __cplusplus
	_O3InflationOptions() : rawInflate(NO), inflateInto(nil) {}
	#endif
} O3InflationOptions;

//Category named to avoid conflicts
@interface NSData (o3_zlib)
- (NSMutableData*)o3Inflate; ///Returns a NSMutableData with 1 autorelease
- (NSMutableData*)o3InflateWithOptions:(O3InflationOptions)opts; ///Returns a NSMutableData with 1 autorelease
- (NSMutableData*)o3Deflate; ///Returns a NSMutableData with 1 autorelease
- (NSMutableData*)o3DeflateWithOptions:(O3DeflationOptions)opts; ///Returns a NSMutableData with 1 autorelease
@end