/**
 * This appender appends logging messages to a file whose path you specify.  This class is a subclass of L4WriterAppender.
 * The L4FileAppender does not support buffering configuration.  Any methods or arguments that refer to buffering are ignored.
 * For copyright & license, see COPYRIGHT.txt.
 */

#import <Foundation/Foundation.h>
#import "L4WriterAppender.h"

@interface L4FileAppender : L4WriterAppender
{
	BOOL			append; /**< Tracks if we should append or over-right.*/
	NSString*		fileName; /**< The name of the file we write to.*/
}

/**
 * A basic initializer.
 * This method calls <code>initWithLayout:fileName:append:bufferIO:bufferSize:</code> with layout and file name set to nil,
 * append is NO, bufferIO is NO, bufferSize is 0
*/
- (id) init;

/**
 * Initializes an L4FileAppender instance with the specified layout and file path name.
 * This method calls <code>initWithLayout:fileName:append:bufferIO:bufferSize:</code> with the specified layout and file name, 
 * append is NO, bufferIO is NO, bufferSize is 0
 * @param aLayout The layout that this appender should use
 * @param aName The file path of the file you want log output to be written to.  If the file does not exist, it will be created if possible.  If the file cannot be created for some reason, a FileNotFoundException will be raised.
 * @throws 
 * @return An initialized L4FileAppender object
*/
- (id) initWithLayout:(L4Layout *) aLayout fileName:(NSString *) aName;

/**
 * Initializes an L4FileAppender instance with the specified layout, file path name, and append option.
 * This method calls <code>initWithLayout:fileName:append:bufferIO:bufferSize:</code> with the specified layout, file name, and append
 * option, bufferIO is NO, bufferSize is 0
 * @param aLayout The layout that this appender should use
 * @param aName The file path of the file you want log output to be written to.  If the file does not exist, it will be created if possible.  If the file cannot be created for some reason, a FileNotFoundException will be raised.
 * @param flag YES = log output should be appended to the file.  NO = the file's previous contents should be overwritten
 * @throws
 * @return An initialized L4FileAppender object
*/
- (id) initWithLayout:(L4Layout *) aLayout fileName:(NSString *) aName append:(BOOL) flag;

/**
 * The path to the file to which log output should be written.
 * @return The path to the file to which log output should be written.
 */
- (NSString *) fileName;

/**
 * The append option of this object.
 * @return YES = output will be appended to the end of the file, NO = output will overwrite the previous contents of the file
 */
- (BOOL) append;

@end

/**
 * These methods are "protected" methods and should not be called except by subclasses.
 */
@interface L4FileAppender (ProtectedMethods)

/**
 * This method closes and releases the underlying file handle.
 */
- (void) closeFile;

/**
 * This method is called to insure the file is set up to write to.
 */
- (void)setupFile;


@end
// For copyright & license, see COPYRIGHT.txt.
