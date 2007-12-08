//
//  O3CompoundStructType.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 12/1/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

@interface O3CompoundStructType : NSObject {
	NSArray* /*O3StructType*/ mComponentTypes;
	UIntP mSize;
}
- (O3CompoundStructType*)initWithName:(NSString*)name types:(NSArray*)types;
- (NSArray*)types;
@end
