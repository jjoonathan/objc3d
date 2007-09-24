/**
 *  @file O3KeyedUnarchiver.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 4/18/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3BufferedReader.h"
@class O3ResManager;

@interface O3KeyedUnarchiver : NSCoder <O3UnarchiverCallbackable> {
	O3BufferedReader* mBr;
	NSZone* mObjectZone;
	NSMutableDictionary* mClassOverrides; ///<NSString->Class
	NSDictionary* mClassFallbacks; ///<NSString->NSString
	NSDictionary* mObjDict; ///<Dict for the current object being initialized
	NSString* mDomain; ///< mDomain + "_" is prepended to all 1st level keys
	NSDictionary* mMetadata; ///<Only a cache for the -metadata method, it is not normally filled
	UInt16 mDepth; ///<During reading, the distance to the root through the read tree. 0=metadata, 1 is the start of normal objects
	BOOL mDeleteBr;
}

//Accessors
- (NSZone*)objectZone;
- (void)setObjectZone:(NSZone*)zone;

//Fine control
- (O3KeyedUnarchiver*)initForReadingWithData:(NSData*)dat;
- (O3KeyedUnarchiver*)initForReadingWithReader:(O3BufferedReader*)br deleteWhenDone:(BOOL)shouldDelete;
- (void)reset;
- (id)read;
- (id)readAndLoadIntoManager:(O3ResManager*)manager;
- (NSDictionary*)metadata; ///<All level 0 keys (except @"" which is reported as the offset of the archive contents rather than the contents themselves), which are info about the archive. Also sets the appropriate values for the rest of the unarchiving.
- (id)readObjectAtOffset:(UIntP)offset; ///<Returns an object at an arbitrary offset. Note that mDepth is set to 100 to avoid any ill effects of resetting what is level 1 (where keys are prepended by the domain)
- (NSDictionary*)skimDictionaryAtOffset:(UIntP)offs  levelOne:(BOOL)prependDomainToKeys; ///<Returns a (NSString*)key->(NSNumber*)offset dictionary for the dictionary at offs

//Archive info
- (NSDictionary*)classFallbacks;
- (NSString*)domain;

//Class methods
+ (id)unarchiveObjectWithData:(NSData *)data;
+ (id)unarchiveObjectWithFile:(NSString *)path;

//Unarchiving protocol
- (NSObject*)readO3ADictionaryFrom:(O3BufferedReader*)reader size:(UIntP)size;
- (NSArray*)readO3AArrayFrom:(O3BufferedReader*)reader size:(UIntP)size;
- (id)readO3AObjectOfClass:(NSString*)className from:(O3BufferedReader*)reader size:(UIntP)size;

//Class overriding
+ (void)setClass:(Class)c forClassName:(NSString*)cname;
+ (Class)classForClassName:(NSString*)cname;
- (void)setClass:(Class)c forClassName:(NSString*)cname;
- (Class)classForClassName:(NSString*)cname;

//Unarchiver methods
- (BOOL)containsValueForKey:(NSString*)key;
- (BOOL)decodeBoolForKey:(NSString*)key;
- (UInt8*)decodeBytesForKey:(NSString*)key returnedLength:(UIntP*)len;
- (double)decodeDoubleForKey:(NSString*)key;
- (float)decodeFloatForKey:(NSString*)key;
- (int)decodeIntForKey:(NSString*)key;
- (Int32)decodeInt32ForKey:(NSString*)key;
- (Int64)decodeInt64ForKey:(NSString*)key;
- (id)decodeObjectForKey:(NSString*)key;

- (void)finishDecoding;

@end
