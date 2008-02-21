/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import "L4LogLog.h"


static BOOL internalDebugging = NO;
static BOOL quietMode = NO;
static NSData *lineBreakChar;

@implementation L4LogLog
+ (void) initialize
{
	lineBreakChar = [[@"\n" dataUsingEncoding: NSASCIIStringEncoding allowLossyConversion: YES] retain];
}

+ (BOOL) internalDebuggingEnabled
{
	return internalDebugging;
}

+ (void) setInternalDebuggingEnabled: (BOOL) enabled
{
	internalDebugging = enabled;
}

+ (BOOL) quietModeEnabled
{
	return quietMode;
}

+ (void) setQuietModeEnabled: (BOOL) enabled
{
	quietMode = enabled;
}

+ (void) debug: (NSString *) message
{
	[self debug: message exception: nil];
}

+ (void) debug: (NSString *) message exception: (NSException *) e
{
	if(internalDebugging && !quietMode) {
		[self writeMessage: message
				withPrefix: L4LogLog_PREFIX
					toFile: [NSFileHandle fileHandleWithStandardOutput]
				 exception: e];
	}
}

+ (void) warn: (NSString *) message
{
	[self warn: message exception: nil];
}

+ (void) warn: (NSString *) message exception: (NSException *) e
{
	if(!quietMode)
	{
		[self writeMessage: message
				withPrefix: L4LogLog_WARN_PREFIX
					toFile: [NSFileHandle fileHandleWithStandardError]
				 exception: e];
	}
}

+ (void) error: (NSString *) message
{
	[self error: message exception: nil];
}

+ (void) error: (NSString *) message exception: (NSException *) e
{
	if(!quietMode) {
		[self writeMessage: message
				withPrefix: L4LogLog_ERROR_PREFIX
					toFile: [NSFileHandle fileHandleWithStandardError]
				 exception: e];
	}
}

// ### TODO *** HELP --- need a unix file expert.  Should I need to flush after printf?
// it doesn't work right otherwise.
//
// Ok, I changed and just used an NSFileHandle because its easier and it just works.
// What are the performance implications, if any?
// ### TODO -- must test under heavy load and talk to performance expert.
//
+ (void) writeMessage: (NSString *) message
		   withPrefix: (NSString *) prefix
			   toFile: (NSFileHandle *) fileHandle
			exception: (NSException *) e
{
	@try {
		[fileHandle writeData:
		 [[prefix stringByAppendingString: message] dataUsingEncoding: NSASCIIStringEncoding
												 allowLossyConversion: YES]];
		[fileHandle writeData: lineBreakChar];
		
		if( e != nil ) {
			[fileHandle writeData:
			 [[prefix stringByAppendingString: [e description]] dataUsingEncoding: NSASCIIStringEncoding allowLossyConversion: YES]];
			[fileHandle writeData:lineBreakChar];
		}
	}
	@catch (NSException * e) {
		// ### TODO WTF? WE'RE SCRWEDED HERE ... ABORT? EXIT? RAISE? Write Error Haiku?
	}
}

@end
