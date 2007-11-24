/**
 *  @file O3KeyedArchiver.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 4/18/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#ifdef __cplusplus
class O3NonlinearWriter;
#endif
extern NSString* O3UnkeyedMethodSendToKeyedArchiverException;
extern NSPropertyListFormat O3ArchiveFormat0;

///Conditional objects are written as aliases, but they must be defered until the end of archiving if they are not found at first
///O3KeyedArchiver doesn't deal with conditional objects outside of a VFS.
/*typedef struct {
	UIntP p1, p2; //Placeholders
	id obj; //Deferred object
} O3KeyedArchiverDeferedAlias;*/

///@todo Make classFallbacksForKeyedArchiver work
@interface O3KeyedArchiver : NSCoder {
	NSMutableSet* mWrittenClasses;
#ifdef __cplusplus
	O3NonlinearWriter* mWriter;
#else
	void* mWriter;
#endif
	NSMutableDictionary* mClassNameMappings; ///<Class->NSString
	id mDelegate;
	BOOL mRootObjectWritten;
	BOOL mArchivingBegun; ///<Some variables cannot be changed once archiving has begun
	BOOL mCompatibility; ///<Should write compatibility data (fallback classes). Defaults to YES.
	BOOL mCompress; ///<Should go through compression? Defaults to YES.
	NSMutableData* mDat; ///<The data to write to when finishEncoding is called
	int mFD; ///<The file descriptor to write to when done
	UIntP mHeader; ///<A placeholder for writing the compatibility header
	NSArray* mCT;
	NSArray* mKT;
	NSArray* mST;
}
//Init
- (id)initForWritingWithMutableData:(NSMutableData*)dat;
- (id)initForWritingWithFileDescriptor:(int)fd;
//- (id)initForWritingWithWriter:(O3NonlinearWriter*)writer; ///@warning dat will be deleted when the receiver is dealloced

//Archiving
+ (NSData*)archivedDataWithRootObject:(id)obj;				
+ (void)archiveRootObject:(id)obj toFile:(NSString*)file;
+ (void)archiveRootObject:(id)obj toFileDescriptor:(int)fd;	
- (void)finishEncoding;

//All encode:forKey: methods are supported.
- (void)encodeUInt64:(UInt64)v forKey:(NSString*)k;

//Accessors
- (NSPropertyListFormat)outputFormat;
- (void)setOutputFormat:(NSPropertyListFormat)newFormat;
- (id)delegate;
- (void)setDelegate:(id)newDelegate;
- (BOOL)writesCompatibilityData; ///<Defaults to NO
- (void)setWritesCompatibilityData:(BOOL)shouldWrite;
- (BOOL)shouldCompress; ///<Weather or not the receiver compresses strings
- (void)setShouldCompress:(BOOL)shouldCompress;

//Class name remaping
+ (void)setClassName:(NSString*)mapTo forClass:(Class)mapFrom; ///<@note Shared with NSKeyedArchiver
+ (NSString*)classNameForClass:(Class)theClass; ///<@note Shared with NSKeyedArchiver
- (void)setClassName:(NSString*)mapTo forClass:(Class)mapFrom;
- (NSString*)classNameForClass:(Class)theClass;
O3EXTERN_C NSString* O3KeyedArchiverEncodedNameOfClass(O3KeyedArchiver* self, Class c); ///<This is used in the actual encoding process, it can be useful elsewhere.
@end

@interface NSObject (O3KeyedArchiverSpecialness)
- (BOOL)isSpeciallyHandledByO3Archiver; ///Returns YES if the receiver needs to be handled specially (archived as an int rather than as an object, etc)
@end
