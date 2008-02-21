#import <Foundation/Foundation.h>

#define		  L4LogLog_PREFIX @"log4cocoa: "
#define  L4LogLog_WARN_PREFIX @"log4cocoa: WARN: "
#define L4LogLog_ERROR_PREFIX @"log4cocoa: ERROR: "

@interface L4LogLog : NSObject {
}

/**
 * Is internal debugging enabled?
 * @return YES if it is, NO if it is not.
 */
+ (BOOL) internalDebuggingEnabled;

/**
 * Changes the state of internal debugging.
 * @param enabled YES to enable, NO to disable.
 */
+ (void) setInternalDebuggingEnabled:(BOOL) enabled;

/**
 * Accessor for quietModeEnabled.
 * @return quietModeEnabled
 */
+ (BOOL) quietModeEnabled;

/**
 * Mutator for quietModeEnabled.
 * @param enabled the new value for quietModeEnabled.
 */
+ (void) setQuietModeEnabled:(BOOL) enabled;

/**
 * If debuging & !quietMode, debug messages get sent to standard out, because Log4Cocoa classes
 * can't use Log4Cocoa loggers.
 * @param message the message to log.
 */
+ (void) debug:(NSString *) message;

/**
 * If debuging & !quietMode, debug messages get sent to standard out, because Log4Cocoa classes
 * can't use Log4Cocoa loggers.
 * @param message the message to log.
 * @param e the exception to log.
 */
+ (void) debug:(NSString *) message exception:(NSException *) e;

/**
 * If !quietMode, warn & error messages get sent to standard error, because Log4Cocoa classes
 * can't use Log4Cocoa loggers.
 * @param message the message to log.
 */
+ (void) warn:(NSString *) message;

/**
 * If !quietMode, warn & error messages get sent to standard error, because Log4Cocoa classes
 * can't use Log4Cocoa loggers.
 * @param message the message to log.
 * @param e the exception to log.
 */
+ (void) warn:(NSString *) message exception:(NSException *) e;

/**
 * If !quietMode, error & error messages get sent to standard error, because Log4Cocoa classes
 * can't use Log4Cocoa loggers.
 * @param message the message to log.
 */
+ (void) error:(NSString *) message;

/**
 * If !quietMode, error & error messages get sent to standard error, because Log4Cocoa classes
 * can't use Log4Cocoa loggers.
 * @param message the message to log.
 * @param e the exception to log.
 */
+ (void) error:(NSString *) message exception:(NSException *) e;

/**
 * Writes the log message to the supplied fileHandle.
 * @param message the message to write.
 * @param prefix the string to write before message.
 * @param fileHandle to handle to write to.
 * @param e the exsception to log.
 */
+ (void) writeMessage:(NSString *) message withPrefix:(NSString *) prefix toFile:(NSFileHandle *) fileHandle exception:(NSException *) e;

@end
// For copyright & license, see COPYRIGHT.txt.
