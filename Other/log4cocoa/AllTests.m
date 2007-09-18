//
//  AllTests.m
//  Log4Cocoa
//
//  Created by bob frank on Sun May 04 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "AllTests.h"
#import "L4LevelTest.h"

@implementation AllTests

+ (TestSuite *) suite {

    TestSuite *suite = [TestSuite suiteWithName: @"My Tests"];

    // Add your tests here ...
    //
    [suite addTest: [TestSuite suiteWithClass: [L4LevelTest class]]];

    return suite;
}


@end
