Log4Cocoa Usage (May 7, 2003) --- draft 0.0.a.3
   
To make Log4Cocoa easier, there are several high level macros, as follows:

log4Debug((message));
log4Info((message));
log4Warn((message));
log4Error((message));
log4Fatal((message));

log4DebugWithException((message), e);
log4InfoWithException((message), e);
log4WarnWithException((message), e);
log4ErrorWithException((message), e);
log4FatalWithException((message), e);

log4Assert(assertion, (message));


**VERY IMPORTANT NOTE**: The second set of parenthesis around the log message are technically optional, however read the following note.  

Since these are macros, if you have a comma "," in your log message, the gcc processor will assume that you have 2 arguments, even if you only have one.  Therefore, if you have a comma anywhere in your log message, you must wrap it in an extra set of parens or rewrite it without commas.

This statement: 

    log4Info([NSString stringWithFormat: @"Duration: %f", [end timeIntervalSinceDate: start]]);

will result in this error: 

    MyClass.m:44: too many args (2) to macro 'log4Info' (1 expected)

Solution 1 - Wrapping:

    log4Info(([NSString stringWithFormat: @"Duration: %f", [end timeIntervalSinceDate: start]]));

Solution 2 - Rewriting:
    
    log4Info([@"Duration: " stringByAppendingString: [[NSNumber numberWithDouble: [end timeIntervalSinceDate: start]] stringValue]]);
    

Obviously the second way can be coded in numeruous ways, but I just wanted to point out the two approaches.  Also, both versions of the Debug & Info macros expand into methods that are wrapped by an "isEnabled" if statement, like so:

if([[self logger] isInfoEnabled]) [[self logger] lineNumber: __LINE__ 
                                                   fileName: __FILE__ 
                                                 methodName: __PRETTY_FUNCTION__ 
                                                       info: message 
                                                  exception: e]

All of the other levels expand out to their counterparts, but are not enclosed by the "isEnabled" if statement.  Also, FYI, __LINE__, __FILE__, and __PRETTY_FUNCTION__  are macros GCC built in as predefined macros to generate the appropriate information.  log4Assert() takes an BOOL as an assertion expression that must evaluate to YES, or else it logs the message as an error.

NOTE: none of these macro's do not include a final semi-colon, so make sure to use one when invoking them.

The 2 core logging convenience methods are implemented as categories on NSObject (if you want to log off of an NSProxy, you'll need to implement these there too ... maybe we'll provide these convenience methods there, but we haven't yet).

    @interface NSObject (L4CocoaMethods)

    + (L4Logger *) logger;
    - (L4Logger *) logger;

    @end

Therefore, [self logger] returns a L4Logger instance based on the calling class object.  To log a message, without using the above macros, the usage is: 

    [[self logger] l4fatal: @"Crap something fatal happened.  You're screwed.  Game Over."];

    [[self logger] l4debug: @"Debug info goes here.  La de da.  All the King's horses & all the kings men couldn't put Humpty Dumpty back together again."];

Frankly, I don't know why you wouldn't want to use these macros, but the non-macro versions are still there in case that's what you want or for some reason you can't use the macro versions.

Since, +logger; & -logger; are implmented as categories on NSObject, you can override them if you don't want the default logger for your class or you want cache the logger.


II. Embedding Log4Cocoa

To actually embed Log4Cocoa in your application, you'll need to add a copy phase to your build target.  Your application will run as long as Log4Cocoa is installed in your Framework search path but embedding it will make deployment much easier and gdb gets messed up when you use an embedded framework but don't actually embed it.

From Apple's Documentation: 

http://developer.apple.com/techpubs/macosx/DeveloperTools/ProjectBuilder/ProjectBuilder.help/Contents/Resources/English.lproj/Frameworks/chapter_19_section_3.html

Copy the Framework Into the Application

In the application’s target, you need to add a copy-files build phase that copies the framework into the application.


1) Add the framework to the application’s target. See “Adding Files and Frameworks”. If the application’s target and framework’s target are in the same project, you should also make the application’s target dependent on the framework’s target. See “Managing Target Dependencies”.

2) In the project window, click the Targets tab and open the application target.

3) Click the last build phase under Build Phases, and choose Project > New Build Phase > New Copy Files Build Phase.

4) Choose Frameworks from the Where pop-up menu, select the “Copy only when installing” option, and drag the framework to the Files field.

You can find the framework in the Products group in the project’s Files list.


Copyright (c) 2002, 2003, Bob Frank
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

 - Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

 - Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

 - Neither the name of Log4Cocoa nor the names of its contributors or owners
   may be used to endorse or promote products derived from this software
   without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

