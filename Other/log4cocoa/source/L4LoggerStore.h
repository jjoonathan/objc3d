#import <Foundation/Foundation.h>
#import "L4LoggerProtocols.h"

@class L4Level, L4Logger;

// ### TODO Add support the L4RendererSupport protocol,
// called from the L4LoggingEvent:renderedMessage method
//
@interface L4LoggerStore : NSObject <L4LoggerRepository, L4LoggerFactory> {
	L4Logger *root; /**< The root logger.*/
	NSMutableDictionary *repository; /**< The collection of loggers by id.*/
	NSMutableArray *loggers;/**< The collection of loggers.*/
	int thresholdInt; /**< The minimum level as an int to log.*/
	L4Level *threshold; /**< The minimum level to log.*/
	BOOL emittedNoAppenderWarning; /**< Tracks if a warning should be created if there are no appenders configured.*/
	BOOL emittedNoResourceBundleWarning;/**< Tracks if a warning should be created if there is no resource bundle.*/
}

/**
 * enables thread locking, no need to lock if not mulit-threaded.
 * @param event
 */
+ (void) taskNowMultiThreaded:(NSNotification *) event;


/**
 * the following are L4LoggerRepository methods
 * @param rootLogger the root logger.
 */
- (id) initWithRoot:(id) rootLogger;

/**
 * Is the repository disabled for a given level? The answer depends
 * on the repository threshold and the parameter.
 * See also {@link #setThreshold} method.
 * @param aLevel the level to check.
 * @return YES if logging is disabled for the specified level; NO if it is not.
 */
- (BOOL) isDisabled:(int) aLevel;

/**
 * Accessor for the threshold attribute.
 * @return the current threshold.
 */
- (L4Level *) threshold;

/**
 * Mutator for the threshold attribute.
 * @param aLevel the new threshold to use.
 */
- (void) setThreshold:(L4Level *) aLevel;

/**
 * Sets the threshold to the level with a name that matches the parameter.
 * @param aLevelName the name of the level to set the threshold to.
 */
- (void) setThresholdByName:(NSString *) aLevelName;

/**
 * Accessor for the root logger.
 * @return the root logger.
 */
- (L4Logger *) rootLogger;

/**
 * Gets a logger for the class object, if it doesn't exist already
 * it is created by composing the pseudo-fqcn and then calling
 * loggerForName:factory: which does the hard work.
 */
- (L4Logger *) loggerForClass:(Class) aClass;

/** a wrapper for loggerForName:factory: with self as the factory */
- (L4Logger *) loggerForName:(NSString *) aName;

/**
 * returns a logger with name or creates it & inserts it into the
 * repository and hooks up all pointers to pre-existing parents
 * children efficiently (thanks to the Log4J folks algorithm).
 */
- (L4Logger *) loggerForName:(NSString *) aName factory:(id <L4LoggerFactory>) aFactory;

/**
 * Accessor for the collection of loggers.
 * @return the array of loggers.
 */
- (NSArray *) currentLoggers;

/**
 * Warn that aLogger has no appenders configured; only if no warning has already
 * been given.
 * @param aLogger the logger to warn about.
 */
- (void) emitNoAppenderWarning:(L4Logger *) aLogger;

/**
 * Resets the configuration of the log store.
 */
- (void) resetConfiguration;
/**
 Shut down logging.
 */
- (void) shutdown;

@end
// For copyright & license, see COPYRIGHT.txt.
