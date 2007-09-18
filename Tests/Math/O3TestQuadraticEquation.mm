/**
 *  @file O3TestQuadraticEquation.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 11/20/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#include "O3TestQuadraticEquation.h"
#include "O3Global.h"

@implementation O3TestQuadraticEquation

- (void)testRootFinding {
	O3QuadraticEquation<real> an_equation(-13.45, 13.37, 420.56);
	double r1, r2; //roots
	an_equation.GetXIntercepts(&r1,&r2);
	STAssertTrue(O3Equals(r1, -5.116835069122084, .0000001), @"Automatic migration from CPTAssert. See source code.");
	STAssertTrue(O3Equals(r2, 6.11088711373175, .000001), @"Automatic migration from CPTAssert. See source code.");
	
	an_equation.Set(13.45, 13.37, 420.56);
	an_equation.GetXIntercepts(&r1,&r2);
	STAssertTrue(std::isnan(r1) && std::isnan(r2), @"Automatic migration from CPTAssert. See source code.");
}

- (void)testInterceptInit {
	O3QuadraticEquation<real> test_equation(5., 2.);
	STAssertTrue((float)O3Equals(test_equation(0.), (float)2., (float)O3Epsilon(real)), @"Automatic migration from CPTAssert. See source code.");
	STAssertTrue((float)O3Equals(test_equation(5.), (float)0., (float).00001), @"Automatic migration from CPTAssert. See source code.");
	STAssertTrue((float)O3Equals(test_equation(2.1702), (float)1.6232, (float).00005), @"Automatic migration from CPTAssert. See source code.");
}

@end
