//
//  O3CompoundStructType.m
//  ObjC3D
//
//  Created by Jonathan deWerd on 12/1/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3CompoundStructType.h"

@implementation O3CompoundStructType

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
}

- (NSDictionary*)dictWithBytes:(const void*)bytes {
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	UIntP j = [mComponentTypes count];
	const UInt8* b = (const UInt8*)bytes;
	UIntP i; for(i=0; i<j; i++) {
		O3StructType* type = [mComponentTypes objectAtIndex:i];
		[dict addObject:[type dictWithBytes:b] forKey:[type name]];
		b += [type structSize];
	}
	return dict;
}

- (void)writeDict:(NSDictionary*)dict toBytes:(void*)bytes {
	UIntP j = [mComponentTypes count];
	const UInt8* b = (const UInt8*)bytes;
	UIntP i; for(i=0; i<j; i++) {
		O3StructType* type = [mComponentTypes objectAtIndex:i];
		[type writeDict:[dict objectForKey:[type name]] toBytes:b];
		b += [type structSize];
	}
}

- (NSMutableData*)portabalizeStructs:(NSData*)indata stride:(UIntP)s {
	NSMutableData* dat = [NSMutableData data];
	O3BufferedWriter bw(dat);
	UIntP j = [mComponentTypes count];
	UIntP i; for(i=0; i<j; i++) {
		O3StructType* type = [mComponentTypes objectAtIndex:i];
		NSData* d = [type portabalizeStructs:indata ]
		NSData* d = [type writeDictToData:[dict objectForKey:[type name]]];
		bw.WriteUCInt([d length]);
		bw.WriteData(d);
	}
	return dat;
}

- (void)deportabalizeStructs:(NSData*)indata to:(void*)target stride:(UIntP)s {
	UIntP count = [indata length]/mSize;
	UInt8* bytes = [indata bytes];
	if (!s) s = mSize;
	UIntP i; for(i=0; i<count; i++) {
		O3StructType* type = [mComponentTypes objectAtIndex:i];
		UInt8* startbytes = bytes+[type structSize];
		
	}
}

- (NSMutableData*)translateStructs:(NSData*)instructs stride:(UIntP)s toFormat:(O3StructType*)format {
	
}



@end
