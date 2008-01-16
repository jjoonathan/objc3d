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
///@param name nil is a valid value
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

- (id)objectWithBytes:(const void*)bytes {
	return [self objectWithData:[NSData dataWithBytesNoCopy:(void*)bytes length:[self structSize] freeWhenDone:NO]];
}

- (id)objectWithData:(NSData*)data {
	O3Assert([self methodForSelector:@selector(objectWithData:)]!=[O3StructType instanceMethodForSelector:@selector(objectWithData:)], @"%@ struct type must override one of objectWithBytes: or objectWithData:.", self);
	O3Assert([data length]==[self structSize], @"%@ was not the correct size for struct type %@", data, self);
	NSDictionary* dict = [self objectWithBytes:[data bytes]];
	[data relinquishBytes];
	return dict;
}

- (void)writeObject:(id)dict toBytes:(void*)bytes {
	NSData* dat = [self writeObjectToData:dict];
	const void* b = [dat bytes];
	memcpy(bytes, b, [dat length]);
}

- (NSData*)writeObjectToData:(NSDictionary*)dict {
	O3Assert([self methodForSelector:@selector(writeObject:toBytes:)]!=[O3StructType instanceMethodForSelector:@selector(writeObject:toBytes:)], @"%@ struct type must override one of writeObjectToData: or writeObject:toBytes:.", self);
	UIntP s = [self structSize];
	void* b = malloc(s);
	[self writeObject:dict toBytes:b];
	return [NSData dataWithBytesNoCopy:b length:s freeWhenDone:YES];
}

- (NSMutableData*)portabalizeStructs:(NSData*)indata stride:(UIntP)s {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSData*)portabalizeStructs:(NSData*)dat {
	UIntP slen = [self structSize];
	NSData* ret = [self portabalizeStructsAt:[dat bytes] count:[dat length]/slen stride:slen];
	[dat relinquishBytes];
	return ret;
}

- (NSData*)deportabalizeStructs:(NSData*)dat {
	return [self deportabalizeStructs:dat to:nil stride:0];
}

- (NSData*)portabalizeStructsAt:(const void*)at count:(UIntP)ct stride:(UIntP)s {
	[self doesNotRecognizeSelector:_cmd];
	return nil;	
}

///Deportabalizes the structs of the receiver's type in indata. If %s = 0 it is replaced with [self structSize] and if %bytes is nil a new buffer is allocated and returned. Returned value is unspecified if %bytes!=0, and can be ignored in such cases.
- (NSData*)deportabalizeStructs:(NSData*)indata to:(void*)bytes stride:(UIntP)s {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSMutableData*)translateStructs:(NSData*)instructs stride:(UIntP)s toFormat:(O3StructType*)format {
	UIntP outsize = [format structSize];
	UIntP count = [instructs length] / s;
	NSMutableData* rdata = [[NSMutableData alloc] initWithLength:count*outsize];
	UInt8* outbytes = (UInt8*)[rdata mutableBytes];
	UInt8* inbytes = (UInt8*)[instructs bytes];
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	UIntP i; for(i=0; i<count; i++) {
		NSDictionary* d = [self objectWithBytes:inbytes+i*s];
		[format writeObject:d toBytes:outbytes+i*outsize];
	}
	[pool release];
	[instructs relinquishBytes];
	return [rdata autorelease];
}

- (void)getFormat:(out GLenum*)format components:(out GLsizeiptr*)components offset:(out GLint*)offset stride:(out GLint*)stride normed:(out GLboolean*)normed vertsPerStruct:(out int*)vps forType:(in O3VertexDataType)type {
	[self doesNotRecognizeSelector:_cmd];	
}

- (GLenum)glFormatForType:(O3VertexDataType)type {
	GLenum r; [self getFormat:&r components:nil offset:nil stride:nil normed:nil vertsPerStruct:nil forType:type];
	return r;
}

- (GLint)glComponentCountForType:(O3VertexDataType)type {
	GLsizeiptr c; [self getFormat:nil components:&c offset:nil stride:nil normed:nil vertsPerStruct:nil forType:type];
	return c;
}

- (GLsizeiptr)glOffsetForType:(O3VertexDataType)type {
	GLint o; [self getFormat:nil components:nil offset:&o stride:nil normed:nil vertsPerStruct:nil forType:type];
	return o;
}

- (GLsizeiptr)glStride {
	GLint s; [self getFormat:nil components:nil offset:nil stride:&s normed:nil vertsPerStruct:nil forType:O3InvalidVertexDataType];
	return s;
}

- (GLboolean)glNormalizedForType:(O3VertexDataType)type {
	GLboolean n; [self getFormat:nil components:nil offset:nil stride:nil normed:&n vertsPerStruct:nil forType:type];
	return n;
}

- (int)glVertsPerStruct {
	int v; [self getFormat:nil components:nil offset:nil stride:nil normed:nil vertsPerStruct:&v forType:O3InvalidVertexDataType];
	return v;
}

- (O3StructArrayComparator)defaultComparator {
	[self doesNotRecognizeSelector:_cmd];	
	return NULL;
}


@end
