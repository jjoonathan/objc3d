//
//  O3Struct.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3Struct.h"
#import "O3StructType.h"

@implementation O3Struct

- (O3Struct*)initWithType:(O3StructType*)type {
	O3SuperInitOrDie();
	mType = type;
	return self;
}

- (O3Struct*)initWithData:(NSData*)data type:(O3StructType*)type {
	UIntP s = [data length];
	if (s!=[type structSize]) {
		O3Assert(false, @"Cannot init a struct with data (%@) whose size is not the struct size (%i)", data, [type structSize]);
		[self release];
		return nil;
	}
	void* bbytes = malloc(s);
	memcpy(bbytes, [data bytes], s);
	return [self initWithBytesNoCopy:bbytes type:type freeWhenDone:YES];
}

- (O3Struct*)initWithBytes:(const void*)bytes type:(O3StructType*)type {
	UIntP s = [type structSize];
	void* bbytes = malloc(s);
	memcpy(bbytes, bytes, s);
	return [self initWithBytesNoCopy:bbytes type:type freeWhenDone:YES];
}

- (O3Struct*)initWithBytesNoCopy:(void*)bytes type:(O3StructType*)type freeWhenDone:(BOOL)fwd {
	O3Assert([self methodForSelector:@selector(initWithData:type:)]!=[O3Struct instanceMethodForSelector:@selector(initWithData:type:)], @"You must override either initWithBytesNoCopy:type:freeWhenDone: or initWithData:type: for all subclasses of O3Struct. You must also not call super initWithBytes... or initWithData..., you need to call initWithType:");
	return [self initWithData:[NSData dataWithBytesNoCopy:bytes length:[type structSize] freeWhenDone:fwd] type:type];
}

- (O3StructType*)structType {
	return mType;
}

- (UIntP)structSize {
	[self doesNotRecognizeSelector:_cmd];
	return 0;
}

- (void)writeToBytes:(void*)bytes {
	NSData* dat = [self bytesAsData];
	UIntP s = [dat length];
	const void* b = [dat bytes];
	memcpy(bytes, b, s);
}

- (NSData*)bytesAsData {
	O3Assert([self methodForSelector:@selector(writeToBytes:)]!=[O3Struct instanceMethodForSelector:@selector(writeToBytes:)], @"You must override writeToBytes: or bytesAsData in all subclasses of O3Struct, but class %@ doesn't seem to.", [self className]);
	UIntP s = [self structSize];
	void* b = malloc(s);
	[self writeToBytes:b];
	return [NSData dataWithBytesNoCopy:b length:s freeWhenDone:YES];
}

- (NSArray*)structKeys {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

@end

double O3DoubleValueOfType_at_withIndex_(enum O3VecStructElementType type, const void* bytes, UIntP idx) {
	switch (type) {
		case O3VecStructFloatElement:  return *((float*)bytes+idx);
		case O3VecStructDoubleElement: return *((double*)bytes+idx);
		case O3VecStructInt8Element:   return *((Int8*)bytes+idx);
		case O3VecStructInt16Element:  return *((Int16*)bytes+idx);
		case O3VecStructInt32Element:  return *((Int32*)bytes+idx);
		case O3VecStructInt64Element:  return *((Int64*)bytes+idx);
		case O3VecStructUInt8Element:  return *((UInt8*)bytes+idx);
		case O3VecStructUInt16Element: return *((UInt16*)bytes+idx);
		case O3VecStructUInt32Element: return *((UInt32*)bytes+idx);
		case O3VecStructUInt64Element: return *((UInt64*)bytes+idx);
	}
	O3AssertFalse(@"Unknown type %i", (int)type);
	return 0;
}

Int64 O3Int64ValueOfType_at_withIndex_(enum O3VecStructElementType type, const void* bytes, UIntP idx) {
	switch (type) {
		case O3VecStructFloatElement:  return *((float*)bytes+idx);
		case O3VecStructDoubleElement: return *((double*)bytes+idx);
		case O3VecStructInt8Element:   return *((Int8*)bytes+idx);
		case O3VecStructInt16Element:  return *((Int16*)bytes+idx);
		case O3VecStructInt32Element:  return *((Int32*)bytes+idx);
		case O3VecStructInt64Element:  return *((Int64*)bytes+idx);
		case O3VecStructUInt8Element:  return *((UInt8*)bytes+idx);
		case O3VecStructUInt16Element: return *((UInt16*)bytes+idx);
		case O3VecStructUInt32Element: return *((UInt32*)bytes+idx);
		case O3VecStructUInt64Element: return *((UInt64*)bytes+idx);
	}
	O3AssertFalse(@"Unknown type %i", (int)type);
	return 0;
}

UInt64 O3UInt64ValueOfType_at_withIndex_(enum O3VecStructElementType type, const void* bytes, UIntP idx) {
	switch (type) {
		case O3VecStructFloatElement:  return *((float*)bytes+idx);
		case O3VecStructDoubleElement: return *((double*)bytes+idx);
		case O3VecStructInt8Element:   return *((Int8*)bytes+idx);
		case O3VecStructInt16Element:  return *((Int16*)bytes+idx);
		case O3VecStructInt32Element:  return *((Int32*)bytes+idx);
		case O3VecStructInt64Element:  return *((Int64*)bytes+idx);
		case O3VecStructUInt8Element:  return *((UInt8*)bytes+idx);
		case O3VecStructUInt16Element: return *((UInt16*)bytes+idx);
		case O3VecStructUInt32Element: return *((UInt32*)bytes+idx);
		case O3VecStructUInt64Element: return *((UInt64*)bytes+idx);
	}
	O3AssertFalse(@"Unknown type %i", (int)type);
	return 0;
}

void O3SetValueOfType_at_toDouble_withIndex_(enum O3VecStructElementType type, void* bytes, double v, UIntP idx) {
	switch (type) {
		case O3VecStructFloatElement:  *((float*)bytes+idx)  = v; return;  
		case O3VecStructDoubleElement: *((double*)bytes+idx) = v; return; 
		case O3VecStructInt8Element:   *((Int8*)bytes+idx)   = v; return;   
		case O3VecStructInt16Element:  *((Int16*)bytes+idx)  = v; return;  
		case O3VecStructInt32Element:  *((Int32*)bytes+idx)  = v; return;  
		case O3VecStructInt64Element:  *((Int64*)bytes+idx)  = v; return;  
		case O3VecStructUInt8Element:  *((UInt8*)bytes+idx)  = v; return;  
		case O3VecStructUInt16Element: *((UInt16*)bytes+idx) = v; return; 
		case O3VecStructUInt32Element: *((UInt32*)bytes+idx) = v; return; 
		case O3VecStructUInt64Element: *((UInt64*)bytes+idx) = v; return; 
	}
	O3AssertFalse("Unknown type \"%i\"", (int)type);
}

void O3SetValueOfType_at_toInt64_withIndex_(enum O3VecStructElementType type, void* bytes, Int64 v, UIntP idx) {
	switch (type) {
		case O3VecStructFloatElement:  *((float*)bytes+idx)  = v; return;  
		case O3VecStructDoubleElement: *((double*)bytes+idx) = v; return; 
		case O3VecStructInt8Element:   *((Int8*)bytes+idx)   = v; return;   
		case O3VecStructInt16Element:  *((Int16*)bytes+idx)  = v; return;  
		case O3VecStructInt32Element:  *((Int32*)bytes+idx)  = v; return;  
		case O3VecStructInt64Element:  *((Int64*)bytes+idx)  = v; return;  
		case O3VecStructUInt8Element:  *((UInt8*)bytes+idx)  = v; return;  
		case O3VecStructUInt16Element: *((UInt16*)bytes+idx) = v; return; 
		case O3VecStructUInt32Element: *((UInt32*)bytes+idx) = v; return; 
		case O3VecStructUInt64Element: *((UInt64*)bytes+idx) = v; return; 
	}
	O3AssertFalse("Unknown type \"%i\"", (int)type);	
}

void O3SetValueOfType_at_toUInt64_withIndex_(enum O3VecStructElementType type, void* bytes, UInt64 v, UIntP idx) {
	switch (type) {
		case O3VecStructFloatElement:  *((float*)bytes+idx)  = v; return;  
		case O3VecStructDoubleElement: *((double*)bytes+idx) = v; return; 
		case O3VecStructInt8Element:   *((Int8*)bytes+idx)   = v; return;   
		case O3VecStructInt16Element:  *((Int16*)bytes+idx)  = v; return;  
		case O3VecStructInt32Element:  *((Int32*)bytes+idx)  = v; return;  
		case O3VecStructInt64Element:  *((Int64*)bytes+idx)  = v; return;  
		case O3VecStructUInt8Element:  *((UInt8*)bytes+idx)  = v; return;  
		case O3VecStructUInt16Element: *((UInt16*)bytes+idx) = v; return; 
		case O3VecStructUInt32Element: *((UInt32*)bytes+idx) = v; return; 
		case O3VecStructUInt64Element: *((UInt64*)bytes+idx) = v; return; 
	}
	O3AssertFalse("Unknown type \"%i\"", (int)type);	
}
