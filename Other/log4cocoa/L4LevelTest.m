//
//  L4LevelTest.m
//  Log4Cocoa
//
//  Created by bob frank on Sun May 04 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "L4LevelTest.h"

@implementation L4LevelTest


- (void) testLevelIntValues {
    L4Level *debug = [L4Level debug];
    L4Level *info = [L4Level info];
    L4Level *warn = [L4Level warn];
    L4Level *error = [L4Level error];
    L4Level *fatal = [L4Level fatal];

    [self assertInt: DEBUG_INT equals: 10 message: @"Debug Int should equal 10."];
    [self assertInt: [debug intValue] equals: DEBUG_INT message: @"[debug intValue] should equal DEBUG_INT"];

    [self assertInt: INFO_INT equals: 20 message: @"Debug Int should equal 20."];
    [self assertInt: [info intValue] equals: INFO_INT message: @"[info intValue] should equal INFO_INT"];

    [self assertInt: WARN_INT equals: 30 message: @"Debug Int should equal 30."];
    [self assertInt: [warn intValue] equals: WARN_INT message: @"[warn intValue] should equal WARN_INT"];

    [self assertInt: ERROR_INT equals: 40 message: @"Debug Int should equal 40."];
    [self assertInt: [error intValue] equals: ERROR_INT message: @"[error intValue] should equal ERROR_INT"];

    [self assertInt: FATAL_INT equals: 50 message: @"Debug Int should equal 50."];
    [self assertInt: [fatal intValue] equals: FATAL_INT message: @"[fatal intValue] should equal FATAL_INT"];
}

- (void) testLevelHierarchies {
    // - (void)assertTrue:(BOOL)condition message:(NSString *)message;
    [self assertTrue: [[L4Level fatal] isGreaterOrEqual: [L4Level debug]] message: @"Fatal should be >= debug"];
    [self assertTrue: [[L4Level fatal] isGreaterOrEqual: [L4Level info]] message: @"Fatal should be >= info"];
    [self assertTrue: [[L4Level fatal] isGreaterOrEqual: [L4Level warn]] message: @"Fatal should be >= warn"];
    [self assertTrue: [[L4Level fatal] isGreaterOrEqual: [L4Level error]] message: @"Fatal should be >= error"];
    [self assertTrue: [[L4Level fatal] isGreaterOrEqual: [L4Level fatal]] message: @"Fatal should be >= fatal"];
    [self assertFalse: [[L4Level info] isGreaterOrEqual: [L4Level fatal]] message: @"info should not be >= fatal"];
}

- (void) testGettingLevelsByName {
    [self assertTrue: [[L4Level levelWithName: @"DEBUG"] isEqual: [L4Level debug]] message: @"DEBUG string should yield 'debug' object"];
    [self assertTrue: [[L4Level levelWithName: @"INFO"] isEqual: [L4Level info]] message: @"INFO string should yield 'info' object"];
    [self assertTrue: [[L4Level levelWithName: @"WARN"] isEqual: [L4Level warn]] message: @"WARN string should yield 'warn' object"];
    [self assertTrue: [[L4Level levelWithName: @"ERROR"] isEqual: [L4Level error]] message: @"ERROR string should yield 'error' object"];
    [self assertTrue: [[L4Level levelWithName: @"FATAL"] isEqual: [L4Level fatal]] message: @"FATAL string should yield 'fatal' object"];
}

@end
