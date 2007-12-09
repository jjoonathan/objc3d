//
//  O3StructType.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3VertexFormats.h"
@class O3StructType;

//Struct naming
O3StructType* O3StructTypeForName(NSString* name);
void O3StructTypeSetForName(O3StructType* type, NSString* name); ///<On +load, register your singletons here (for encoding/decoding)

///An abstract class to represent types of structures, and define an interface for reading, writing, introspecting, and converting them.
///To subclass, override -structSize, -dictionaryWithBytes: OR -dictWithData:, -writeDict:toBytes: OR writeDictToData:, and optionally portabalizeStructs:, deportabalizeStructs:, and translateStructs:toFormat:.
@interface O3StructType : NSObject {
	NSString* mName;
}
//For classes that represent a single type of struct, this returns an instance to represent it (it should be a singleton registered for a certain name)
//+ (O3StructType*)representativeInstance; ///<Returns a singleton instance that will act as the struct "server". Things are done this way so a generic struct class can have instances that represent a type of structure (rather than having to hardcode a class) and so that compile-time protocol checking works better.
- (O3StructType*)initWithName:(NSString*)name;

//Conversion between raw data and introspectable dictionaries
- (UIntP)structSize;
- (NSDictionary*)dictWithBytes:(const void*)bytes;
- (NSDictionary*)dictWithData:(NSData*)data;
- (void)writeDict:(NSDictionary*)dict toBytes:(void*)bytes;
- (NSData*)writeDictToData:(NSDictionary*)dict;

//Info
- (NSString*)name;

//(Hopefully accelerated) translation between formats
- (NSMutableData*)portabalizeStructsAt:(void*)at count:(UIntP)ct stride:(UIntP)s;
- (void)deportabalizeStructs:(NSData*)indata to:(void*)bytes stride:(UIntP)s;
- (NSMutableData*)translateStructs:(NSData*)instructs stride:(UIntP)s toFormat:(O3StructType*)format;

//GL info (expected to remain constant over the lifetime of a type)
- (GLenum)glFormatForType:(O3VertexDataType)type;
- (GLint)glComponentCountForType:(O3VertexDataType)type;
- (GLsizeiptr)glOffsetForType:(O3VertexDataType)type;
- (GLsizeiptr)glStride;
- (GLboolean)glNormalizedForType:(O3VertexDataType)type;
- (int)glVertsPerStruct;
@end
