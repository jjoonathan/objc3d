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
#import "L4FileAppender.h"
#import "L4Layout.h"

// OK I'M GOING TO CHANGE THE BEHAVIOUR SLIGHTLY BECAUSE I
// WANT TO MAKE THE DATE ROLLING LOG FILE A SUB CLASS OF THIS
// SO THAT YOU CAN HAVE A FILE ROLL ON TIME OR ON SIZE.
// THE DEFAULT WILL MAKE IT BEHAVE JUST LIKE ITS SUPER CLASS

@interface L4RollingFileAppender : L4FileAppender {

}

- (id) init;

- (id) initWithLayout: (L4Layout *) aLayout
             fileName: (NSString *) aName; // throws IOException

- (id) initWithLayout: (L4Layout *) aLayout
             fileName: (NSString *) aName
               append: (BOOL) append; // throws IOException

- (int) maxBackupIndex;
- (long) maximumFileSize;

@end

/*
 public
 long getMaximumFileSize()

 public // synchronization not necessary since doAppend is alreasy synched
 void rollOver()

 public
 synchronized
 void setFile(String fileName, boolean append, boolean bufferedIO, int bufferSize) 
 throws IOException

 public
 void setMaxBackupIndex(int maxBackups)

 public
 void setMaximumFileSize(long maxFileSize)

 public
 void setMaxFileSize(String value)

 protected
 void setQWForFiles(Writer writer)

 protected
 void subAppend(LoggingEvent event)
 */