//
//  O3Struct.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3Struct.h"

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

- (UIntP)structSize {
	[self doesNotRecognizeSelector:_cmd];
	return 0;
}

- (Class)instanceClass {
	[self doesNotRecognizeSelector:_cmd];
	return Nil;
}

- (NSArray*)structKeys {
	[self doesNotRecognizeSelector:_cmd];
	return nil;	
}

- (void)portabalizeStructsAt:(void*)bytes count:(UIntP)count {
	[self doesNotRecognizeSelector:_cmd];	
}

- (void)deportabalizeStructsAt:(void*)bytes count:(UIntP)conut {
	[self doesNotRecognizeSelector:_cmd];	
}

- (void*)translateStructsAt:(const void*)bytes count:(UIntP)count toFormat:(O3StructType*)format {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

@end
