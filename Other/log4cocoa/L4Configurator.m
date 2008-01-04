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

#import "L4Configurator.h"
#import "L4Logger.h"
#import "L4Level.h"
#import "L4ConsoleAppender.h"
#import "L4Layout.h"

static NSData *lineBreakChar;

@implementation L4Configurator

+ (void) initialize
{
    // Making sure that we capture the startup time of
    // this application.  This sanity check is also in
    // +[L4Logger initialize] too.
    //
    [L4LoggingEvent startTime];
	[self basicConfiguration];
}

+ (void) basicConfiguration
{
    [[L4Logger rootLogger] setLevel: [L4Level warn]];
    [[L4Logger rootLogger] addAppender:
        [[L4ConsoleAppender alloc] initStandardOutWithLayout: [L4Layout simpleLayout]]];
}

+ (void) autoConfigure
{
    // [[NSFileManager defaultManager] currentDirectoryPath];
}

+ (id) propertyForKey: (NSString *) aKey
{
    return nil;
}

+ (void) resetLineBreakChar
{
    [lineBreakChar autorelease];
    lineBreakChar = nil;
}

+ (NSData *) lineBreakChar
{
    if( lineBreakChar == nil )
    {
        id breakChar = [self propertyForKey: LINE_BREAK_SEPERATOR_KEY];
        if( breakChar != nil )
        {
            lineBreakChar = [[breakChar dataUsingEncoding: NSASCIIStringEncoding
                                     allowLossyConversion: YES] retain];
        }
        else
        {
            // DEFAULT VALUE
            lineBreakChar = [[@"\n" dataUsingEncoding: NSASCIIStringEncoding
                                 allowLossyConversion: YES] retain];
        }
    }

    return lineBreakChar;
}

@end
