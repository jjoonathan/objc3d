/**
 *  @file O3KeyedUnarchiver.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 4/18/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3BufferedReader.h"

@interface O3KeyedUnarchiver : NSCoder <O3UnarchiverCallbackable> {
	O3BufferedReader* mBr;
	NSZone* mObjectZone;
	NSMutableDictionary* mClassOverrides; ///<NSString->Class
	NSDictionary* mClassFallbacks; ///<NSString->NSString
	NSDictionary* mObjDict; ///<Dict for the current object being initialized
	BOOL mDeleteBr;
}

//Accessors
- (NSZone*)objectZone;
- (void)setObjectZone:(NSZone*)zone;

//Construction
- (O3KeyedUnarchiver*)initForReadingWithData:(NSData*)dat;
- (O3KeyedUnarchiver*)initForReadingWithReader:(O3BufferedReader*)br deleteWhenDone:(BOOL)shouldDelete;

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
