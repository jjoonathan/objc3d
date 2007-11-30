//
//  O3StructType.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3StructType.h"
#import "O3GPUData.h"

/************************************/ #pragma mark Struct naming /************************************/
NSMutableDictionary* gO3StructTypesForNames = nil;
///@todo make completely +load safe
O3StructType* O3StructTypeForName(NSString* name) {
	return [gO3StructTypesForNames objectForKey:name];
}

void O3StructTypeSetForName(O3StructType* type, NSString* name) {
	if (!gO3StructTypesForNames) gO3StructTypesForNames = [NSMutableDictionary new];
	[gO3StructTypesForNames setObject:type forKey:name];
}


@implementation O3StructType : NSObject

/************************************/ #pragma mark Init /************************************/
- (O3StructType*)initWithName:(NSString*)name {
	O3SuperInitOrDie();
	O3StructType* existingType = name? O3StructTypeForName(name) : nil;
	if (existingType) {
		[self release];
		return existingType;
	}
	O3Assign(name, mName);
	if (name) O3StructTypeSetForName(self, name);
	return self;
}

- (void)dealloc {
	O3Destroy(mName);
	O3SuperDealloc();
}

/************************************/ #pragma mark Access /************************************/
- (NSString*)name {
	return mName;
}

- (UIntP)structSize {
	[self doesNotRecognizeSelector:_cmd];
	return 0;
}

- (NSDictionary*)dictWithBytes:(const void*)bytes {
	return [self dictWithData:[NSData dataWithBytesNoCopy:(void*)bytes length:[self structSize] freeWhenDone:NO]];
}

- (NSDictionary*)dictWithData:(NSData*)data {
	O3Assert([self methodForSelector:@selector(dictWithData:)]!=[O3StructType instanceMethodForSelector:@selector(dictWithData:)], @"%@ struct type must override one of dictWithBytes: or dictWithData:.", self);
	O3Assert([data length]==[self structSize], @"%@ was not the correct size for struct type %@", data, self);
	NSDictionary* dict = [self dictWithBytes:[data bytes]];
	[data relinquishBytes];
	return dict;
}

- (void)writeDict:(NSDictionary*)dict toBytes:(void*)bytes {
	NSData* dat = [self writeDictToData:dict];
	const void* b = [dat bytes];
	memcpy(bytes, b, [dat length]);
}

- (NSData*)writeDictToData:(NSDictionary*)dict {
	O3Assert([self methodForSelector:@selector(writeDict:toBytes:)]!=[O3StructType instanceMethodForSelector:@selector(writeDict:toBytes:)], @"%@ struct type must override one of writeDictToData: or writeDict:toBytes:.", self);
	UIntP s = [self structSize];
	void* b = malloc(s);
	[self writeDict:dict toBytes:b];
	return [NSData dataWithBytesNoCopy:b length:s freeWhenDone:YES];
}

- (NSMutableData*)portabalizeStructs:(NSData*)indata {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSMutableData*)deportabalizeStructs:(NSData*)indata {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSMutableData*)translateStructs:(NSData*)instructs toFormat:(O3StructType*)format {
	UIntP insize = [self structSize];
	UIntP outsize = [format structSize];
	UIntP count = [instructs length] / insize;
	NSMutableData* rdata = [[NSMutableData alloc] initWithLength:count*outsize];
	UInt8* outbytes = (UInt8*)[rdata mutableBytes];
	UInt8* inbytes = (UInt8*)[instructs bytes];
	NSAutoreleasePool *pool = [NSAutoreleasePool new];	
	UIntP i; for(i=0; i<count; i++) {
		NSDictionary* d = [self dictWithBytes:inbytes+i*insize];
		[format writeDict:d toBytes:outbytes+i*outsize];
	}
	[pool release];
	return [rdata autorelease];
}

- (GLenum)glFormatForType:(O3VertexDataType)type {
	[self doesNotRecognizeSelector:_cmd];
	return GL_ZERO;
}

- (GLint)glComponentCountForType:(O3VertexDataType)type {
	return 0;
}

- (GLsizeiptr)glOffsetForType:(O3VertexDataType)type {
	return 0;
}

- (GLsizeiptr)glStride {
	return 0;
}

- (GLboolean)glNormalizedForType:(O3VertexDataType)type {
	return GL_FALSE;
}

- (int)glVertsPerStruct {
	return 1;
}


@end
