/****************************
*
* Copyright (c) 2002, 2003, Bob Frank
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions
* are met:
*
*  - Redistributions of source code must retain the above copyright
*    notice, this list of conditions and the following disclaimer.
*
*  - Redistributions in binary form must reproduce the above copyright
*    notice, this list of conditions and the following disclaimer in the
*    documentation and/or other materials provided with the distribution.
*
*  - Neither the name of Log4Cocoa nor the names of its contributors or owners
*    may be used to endorse or promote products derived from this software
*    without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
* "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
* LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
* A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
* OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
* SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
* TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
* OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
* OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
****************************/

// #import "Log4Cocoa.h"
#import <Foundation/Foundation.h>
#import "L4AppenderAttachableImpl.h"
#import "L4AppenderProtocols.h"
#import "L4LoggerProtocols.h"
#import "L4Level.h"
#import "L4LoggingEvent.h"
#import "L4LogManager.h"
#import "L4LogLog.h"

/**
 * LOGGING MACROS: These macros are convience macros that easily
 * allow the capturing of line number, source file, and method
 * name information without interupting the flow of your
 * source code.
 *
 * To use these macros, instead of
 *   [[self log] info: @"Your Log message."];
 * use
 *   L4Info( @"Your Log message." );
 * or
 *   L4InfoWithException( @"Your Log message.", andException);
 *
 * Frankly, I don't know why you would not want to use these macros, but
 * I've left the simple methods in place just in case that's what you want
 * to do or can't use these macros for some reason.
 */

#define L4_LOCATION lineNumber: __LINE__ fileName:(char*)__FILE__ methodName:(char*)__PRETTY_FUNCTION__

#define L4LogDebug  L4_LOCATION debug
#define L4LogInfo   L4_LOCATION info
#define L4LogWarn   L4_LOCATION warn
#define L4LogError  L4_LOCATION error
#define L4LogFatal  L4_LOCATION fatal
#define L4LogAssert L4_LOCATION assert

#define log4Debug(message) if([[self?:@"nil" logger] isDebugEnabled]) [[self logger] L4LogDebug: message]
#define log4Info(message)  if([[self?:@"nil" logger] isInfoEnabled]) [[self logger] L4LogInfo: message]
#define log4Warn(message)  [[self?:@"nil" logger] L4LogWarn: message]
#define log4Error(message) [[self?:@"nil" logger] L4LogError: message]
#define log4Fatal(message) [[self?:@"nil" logger] L4LogFatal: message]

#define log4DebugWithException(message, e) if([[self?:@"nil" logger] isDebugEnabled]) [[self logger] L4LogDebug: message exception: e]
#define log4InfoWithException(message, e)  if([[self?:@"nil" logger] isInfoEnabled]) [[self logger] L4LogInfo: message exception: e]
#define log4WarnWithException(message, e)  [[self?:@"nil" logger] L4LogWarn: message exception: e]
#define log4ErrorWithException(message, e) [[self?:@"nil" logger] L4LogError: message exception: e]
#define log4FatalWithException(message, e) [[self?:@"nil" logger] L4LogFatal: message exception: e]

#define log4Assert(assertion, message) [[self?:@"nil" logger] L4LogAssert: assertion log: message]

/*****
 * NOTE: THESE FOLLOWING MACROS WILL GO AWAY IN 1.0.  THEY ARE JUST BEING KEPT AROUND FOR
 * TEMPORARY COMATIBILITY REASONS WITH EARLIER PRE-BETA VERSIONS.
 */
//
#define L4Debug(message) if([[self logger] isDebugEnabled]) [[self logger] L4LogDebug: message]
#define L4Info(message)  if([[self logger] isInfoEnabled]) [[self logger] L4LogInfo: message]
#define L4Warn(message)  [[self logger] L4LogWarn: message]
#define L4Error(message) [[self logger] L4LogError: message]
#define L4Fatal(message) [[self logger] L4LogFatal: message]

#define L4DebugWithException(message, e) if([[self logger] isDebugEnabled]) [[self logger] L4LogDebug: message exception: e]
#define L4InfoWithException(message, e)  if([[self logger] isInfoEnabled]) [[self logger] L4LogInfo: message exception: e]
#define L4WarnWithException(message, e)  [[self logger] L4LogWarn: message exception: e]
#define L4ErrorWithException(message, e) [[self logger] L4LogError: message exception: e]
#define L4FatalWithException(message, e) [[self logger] L4LogFatal: message exception: e]

#define L4Assert(assertion, message) [[self logger] L4LogAssert: assertion log: message]



@class L4AppenderAttachableImpl;

@interface L4Logger : NSObject {
    NSString *name;
    L4Level *level;
    L4Logger *parent;
    id <L4LoggerRepository> repository;
    BOOL additive;
    L4AppenderAttachableImpl *aai;
}

+ (void) taskNowMultiThreaded: (NSNotification *) event;

// DON'T USE, only for use of log manager
- (id) initWithName: (NSString *) loggerName;

- (BOOL) additivity;
- (void) setAdditivity: (BOOL) newAdditivity;

- (L4Logger *) parent; // root Logger returs nil
- (void) setParent: (L4Logger *) theParent;

- (NSString *) name;
- (id <L4LoggerRepository>) loggerRepository;
- (void) setLoggerRepository: (id <L4LoggerRepository>) aRepository;

- (L4Level *) effectiveLevel;

- (L4Level *) level;
- (void) setLevel: (L4Level *) aLevel; // nil is ok, because then we just pick up the parent's level

@end

@interface L4Logger (AppenderRelatedMethods)

- (void) callAppenders: (L4LoggingEvent *) event;

- (L4AppenderAttachableImpl *) aai;

- (NSArray *) allAppendersArray;
- (NSEnumerator *) allAppenders;
- (id <L4Appender>) appenderWithName: (NSString *) aName; // returns appender if in list, otherwise nil

- (void) addAppender: (id <L4Appender>) appender; // SYNCHRONIZED
- (BOOL) isAttached: (id <L4Appender>) appender;

- (void) closeNestedAppenders;

- (void) removeAllAppenders;
- (void) removeAppender: (id <L4Appender>) appender;
- (void) removeAppenderWithName: (NSString *) aName;

@end

@interface L4Logger (CoreLoggingMethods)

/* ALL < DEBUG < INFO < WARN < ERROR < FATAL < OFF */

- (BOOL) isDebugEnabled;
- (BOOL) isInfoEnabled;
- (BOOL) isWarnEnabled;   /* added not in Log4J */
- (BOOL) isErrorEnabled;  /* added not in Log4J */ 
- (BOOL) isFatalEnabled;  /* added not in Log4J */

- (BOOL) isEnabledFor: (L4Level *) aLevel;

- (void) assert: (BOOL) anAssertion
            log: (NSString *) aMessage;

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
             assert: (BOOL) anAssertion
                log: (NSString *) aMessage;

/* Debug */

- (void) debug: (id) aMessage;

- (void) debug: (id) aMessage
     exception: (NSException *) e;

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
              debug: (id) aMessage;

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
              debug: (id) aMessage
          exception: (NSException *) e;

/* Info */

- (void) info: (id) aMessage;

- (void) info: (id) aMessage
    exception: (NSException *) e;

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
               info: (id) aMessage;

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
               info: (id) aMessage
          exception: (NSException *) e;

/* Warn */

- (void) warn: (id) aMessage;

- (void) warn: (id) aMessage
    exception: (NSException *) e;

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
               warn: (id) aMessage;

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
               warn: (id) aMessage
          exception: (NSException *) e;

/* Error */

- (void) error: (id) aMessage;

- (void) error: (id) aMessage
     exception: (NSException *) e;

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
              error: (id) aMessage;

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
              error: (id) aMessage
          exception: (NSException *) e;

/* Fatal */

- (void) fatal: (id) aMessage;

- (void) fatal: (id) aMessage
     exception: (NSException *) e;

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
              fatal: (id) aMessage;

- (void) lineNumber: (int) lineNumber
           fileName: (char *) fileName
         methodName: (char *) methodName
              fatal: (id) aMessage
          exception: (NSException *) e;

/* Legacy primitive logging methods               */
/* See below, forcedLog: (L4LoggingEvent *) event */

- (void) log: (id) aMessage
       level: (L4Level *) aLevel;

- (void) log: (id) aMessage
       level: (L4Level *) aLevel
   exception: (NSException *) e;

- (void) log: (id) aMessage
       level: (L4Level *) aLevel
   exception: (NSException *) e
  lineNumber: (int) lineNumber
    fileName: (char *) fileName
  methodName: (char *) methodName;

- (void) forcedLog: (id) aMessage
             level: (L4Level *) aLevel
         exception: (NSException *) e
        lineNumber: (int) lineNumber
          fileName: (char *) fileName
        methodName: (char *) methodName;

/* This is the designated logging method that the others invoke. */

- (void) forcedLog: (L4LoggingEvent *) event;

@end


@interface L4Logger (LogManagerCoverMethods)

+ (L4Logger *) rootLogger;

+ (L4Logger *) loggerForClass: (Class) aClass;
+ (L4Logger *) loggerForName: (NSString *) aName;
+ (L4Logger *) loggerForName: (NSString *) aName
                     factory: (id <L4LoggerFactory>) aFactory;

/* returns logger if it exists, otherise nil */
+ (L4Logger *) exists: (NSString *) loggerName;

+ (NSArray *) currentLoggersArray;
+ (NSEnumerator *) currentLoggers;

@end

