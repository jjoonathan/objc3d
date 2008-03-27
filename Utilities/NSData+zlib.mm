//
//  NSData+zlib.m
//  ObjC3D
//
//  Created by Jonathan deWerd on 3/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import "NSData+zlib.h"
#import "O3GPUData.h"
#include <zlib.h>

@implementation NSData (o3_zlib)

- (NSMutableData*)o3Inflate {
	O3InflationOptions opts;
	opts.rawInflate = NO;
	opts.inflateInto = nil;
	return [self o3InflateWithOptions:opts];
}

- (NSMutableData*)o3InflateWithOptions:(O3InflationOptions)opts {
	UIntP len = [self length];
	if (!len) return [NSMutableData data];
	
	UIntP guess_expand_chunk = len<<1;
	UIntP inf_size_guess = len+ guess_expand_chunk;
	NSMutableData *decompressed = opts.inflateInto ?: [NSMutableData dataWithLength:inf_size_guess];
	
	z_stream strm;
	strm.next_in = (Bytef*)[self bytes];
	strm.avail_in = len;
	strm.total_out = 0;
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	
	if (inflateInit2(&strm, opts.rawInflate? -15 : 15) != Z_OK) {
		[self relinquishBytes];
		return nil;
	}
	
	int status;
	BOOL finished = NO;
	while (!finished) {
		if (strm.total_out >= [decompressed length])
			[decompressed increaseLengthBy:guess_expand_chunk];
		strm.next_out = (UInt8*)[decompressed mutableBytes] + strm.total_out;
		strm.avail_out = [decompressed length] - strm.total_out;
		
		status = inflate(&strm, Z_SYNC_FLUSH);
		if (status == Z_STREAM_END) finished = YES;
		else if (status != Z_OK) break;
	}
	if (inflateEnd(&strm)!=Z_OK || !finished) {
		[self relinquishBytes];
		return nil;
	}
	
	[decompressed setLength:strm.total_out];
	[decompressed relinquishBytes];
	return decompressed;
}

- (NSMutableData*)o3Deflate {
	O3DeflationOptions opts;
	opts.rawDeflate=NO;
	opts.windowBits=15;
	opts.memLevel=8;
	opts.compressionLevel=7;
	return [self o3DeflateWithOptions:opts];
}

- (NSMutableData*)o3DeflateWithOptions:(O3DeflationOptions)opts {
	UIntP len = [self length];
	if (!len) return [NSMutableData data];
	
	z_stream strm;
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	strm.opaque = Z_NULL;
	strm.total_out = 0;
	strm.next_in=(Bytef *)[self bytes];
	strm.avail_in = len;
	NSMutableData *compressed = [NSMutableData dataWithLength:len*2/3];
	
	if (deflateInit2(&strm, opts.compressionLevel, Z_DEFLATED, opts.rawDeflate? -opts.windowBits : opts.windowBits, opts.memLevel, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
	
	do {
		if (strm.total_out >= [compressed length])
			[compressed increaseLengthBy:16384];
		
		strm.next_out = (UInt8*)[compressed mutableBytes] + strm.total_out;
		strm.avail_out = [compressed length] - strm.total_out;
		
		deflate(&strm, Z_FINISH);  
	} while (strm.avail_out == 0);
	
	deflateEnd(&strm);
	[compressed setLength:strm.total_out];
	return compressed;
}

@end
