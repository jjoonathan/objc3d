//
//  O3Struct.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
@class O3Struct, O3StructType;

//Struct naming
O3StructType* O3StructTypeForName(NSString* name);
void O3StructTypeSetForName(O3StructType* type, NSString* name); ///<On +load, register your singletons here (for encoding/decoding)

///An abstract class to represent types of structures, and define an interface for reading, writing, introspecting, and converting them
@interface O3StructType : NSObject {
	NSString* mName;
}
//For classes that represent a single type of struct, this returns an instance to represent it (it should be a singleton registered for a certain name)
//+ (O3StructType*)representativeInstance; ///<Returns a singleton instance that will act as the struct "server". Things are done this way so a generic struct class can have instances that represent a type of structure (rather than having to hardcode a class) and so that compile-time protocol checking works better.
- (O3StructType*)initWithName:(NSString*)name;

//Conversion to raw data
- (UIntP)structSize;
- (Class)instanceClass; ///<The class (conforming to O3Struct's interface) which represents instances of this struct type

//Info
- (NSString*)name;
- (NSArray*)structKeys; ///<All KVC keys that represent struct items (used in automatic translation by some classes)

//(Hopefully accelerated) translation between formats
- (void*)portabalizeStructsAt:(const void*)bytes count:(UIntP)count;		///<Make %count structs at %bytes platform independent (it doesn't matter what this is as long as it is portable across architectures and 64/32-bitness). The returned buffer must be the same size as %bytes.
- (void*)deportabalizeStructsAt:(const void*)bytes count:(UIntP)conut;		///<Translate %count structs at %bytes into usable (platform-dependent) in-memory structs. The returned buffer must be the same size as %bytes.
- (void*)translateStructsAt:(const void*)bytes count:(UIntP)count toFormat:(O3StructType*)format; ///<Translates between two formates, returning a new buffer (that needs to be free()d) on success and nil on failure

//GL info (expected to remain constant over the lifetime of a type)
- (GLenum)glFormat;
- (GLint)glComponentCount;
- (GLsizeiptr)glOffset;
- (GLsizeiptr)glStride;
- (GLboolean)glNormalized;
- (int)glVertsPerStruct;
@end
