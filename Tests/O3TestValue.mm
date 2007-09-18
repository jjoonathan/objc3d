/**
 *  @file O3TestValue.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 3/23/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3TestValue.h"
#import "O3Value.h"

@implementation O3TestValue

- (void)testMatrixO3ValueEncapsulation {
	double matvals[] = { 1, 2, 3, 4,
						 5, 6, 7, 8,
						 9, 8, 7, 6,
						 5, 4, 3, 2  };
	O3Mat4x4d themat(matvals);
	O3Value* theval = [O3Value valueWithMatrix:themat];
	O3Mat4x4d themat2([theval matrixValue]);
	STAssertTrue(themat2==themat, @"O3Mat->O3Value->O3Mat test failed. %s != %s Intermediate O3Value: %@", themat.Description().c_str(), themat2.Description().c_str(), theval);
}

- (void)testVectorO3ValueEncapsulation {
	double vvals[] = {1., 2., 3., 4.};
	O3Vec4d thevec(vvals);
	O3Value* theval = [O3Value valueWithVector:thevec];
	O3Vec4d thevec2([theval vectorValue]);
	STAssertTrue(thevec2==thevec, @"O3Vec->O3Value->O3Vec test failed. %s != %s Intermediate O3Value: %@", thevec.Description().c_str(), thevec2.Description().c_str(), theval);
}

@end
