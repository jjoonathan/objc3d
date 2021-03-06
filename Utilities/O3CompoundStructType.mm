//
//  O3CompoundStructType.m
//  ObjC3D
//
//  Created by Jonathan deWerd on 12/1/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3CompoundStructType.h"
#import "O3BufferedWriter.h"
#import "O3BufferedReader.h"

@implementation O3CompoundStructType
O3DefaultO3InitializeImplementation

- (O3CompoundStructType*)initWithName:(NSString*)name types:(NSArray*)types {
	if (![super initWithName:name]) return nil;
	O3Assign(types, mComponentTypes);
	return self;
}

- (NSArray*)types {
	return mComponentTypes;
}

- (UIntP)structSize {
	if (mSize) return mSize;
	UIntP j = [mComponentTypes count];
	UIntP i; for(i=0; i<j; i++) {
		mSize += [[mComponentTypes objectAtIndex:i] structSize];
	}
	return mSize;
}

- (id)objectWithBytes:(const void*)bytes {
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	UIntP j = [mComponentTypes count];
	const UInt8* b = (const UInt8*)bytes;
	UIntP i; for(i=0; i<j; i++) {
		O3StructType* type = [mComponentTypes objectAtIndex:i];
		[dict setObject:[type objectWithBytes:b] forKey:[type name]];
		b += [type structSize];
	}
	return dict;
}

- (void)writeObject:(id)dict toBytes:(void*)bytes {
	UIntP j = [mComponentTypes count];
	UInt8* b = (UInt8*)bytes;
	UIntP i; for(i=0; i<j; i++) {
		O3StructType* type = [mComponentTypes objectAtIndex:i];
		[type writeObject:[dict objectForKey:[type name]] toBytes:b];
		b += [type structSize];
	}
}

- (NSData*)portabalizeStructsAt:(const void*)at count:(UIntP)ct stride:(UIntP)s {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSMutableData* dat = [NSMutableData data];
	O3BufferedWriter bw(dat);
	UIntP j = [mComponentTypes count];
	UInt8* src = (UInt8*)at;
	UIntP i; for(i=0; i<j; i++) {
		O3StructType* type = [mComponentTypes objectAtIndex:i];
		NSData* d = [type portabalizeStructsAt:src count:ct stride:s];
		bw.WriteUCInt([d length]);
		bw.WriteData(d);
		src += [type structSize];
	}
	[pool release];
	return dat;
}

- (NSData*)deportabalizeStructs:(NSData*)indata to:(void*)target stride:(UIntP)s {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	if (!s) s = [self structSize];
	UIntP count = [indata length]/s;
	BOOL had_to_malloc_target = target? NO : YES;
	if (!target) target = malloc(s*count);
	O3BufferedReader r(indata);
	UInt8* to = (UInt8*)target;
	UIntP i; for(i=0; i<count; i++) {
		O3StructType* type = [mComponentTypes objectAtIndex:i];
		UIntP len = r.ReadUCIntAsUInt64();
		[type deportabalizeStructs:r.ReadDataNoCopy(len) to:to stride:s];
		to += [type structSize];
	}
	[pool release];
	return had_to_malloc_target? [NSData dataWithBytesNoCopy:target length:s*count freeWhenDone:YES] : nil;
}

- (NSMutableData*)translateStructs:(NSData*)instructs stride:(UIntP)s toFormat:(O3StructType*)format {
	return nil;
}



@end
