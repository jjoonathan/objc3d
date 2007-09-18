/**
 *  @file O3TestMatrix.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 2/3/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#include "O3TestMatrix.h"
#include <iostream>
#include <cmath>
#include <cstdlib>
using namespace std;

#define AssertInverse(m1, m2) {\
	STAssertTrue((m1*m2).IsIdentity(1.0e-4), @"O3Mat %s is not the inverse of %s (they multiply to %s)", m2.Description().c_str(), m1.Description().c_str(), (m1*m2).Description().c_str());\
	STAssertTrue((m2*m1).IsIdentity(1.0e-4), @"O3Mat %s is not the inverse of %s (they multiply to %s)", m2.Description().c_str(), m1.Description().c_str(), (m2*m1).Description().c_str());\
}

#define CheckInverseMethods(matrix) {\
	O3Mat4x4r inv4x3(matrix);\
	O3Mat4x4r invAdj(matrix);\
	O3Mat4x4r inv(matrix);\
	inv4x3.Invert3x4();\
	invAdj.InvertAdjoint();\
	inv.Invert();\
	AssertInverse(invAdj, matrix);\
	AssertInverse(inv4x3, matrix);\
	AssertInverse(inv, matrix);\
}

@implementation O3TestMatrix

- (void)testTranslationInversion {
	O3Mat4x4r a = O3Translation3(1,2,3).GetMatrix();
	O3Mat4x4r b = O3Translation3(-1,-2,-3).GetMatrix();
	AssertInverse(a,b);
	CheckInverseMethods(a);
}

- (void)testRotationInversion {
	O3Mat4x4r a = O3Rotation3(1,2,3).GetMatrix().Get4x4();
	//O3Mat4x4r b = (-O3Rotation3(1,2,3)).GetMatrix().Get4x4(); //O3Quaternion negation and get matrix return a different (but rotationally equal) matrix to inverse
	CheckInverseMethods(a);
}

- (void)testTRSInversion {
	O3Mat4x4r a = O3Translation3(1,2,3).GetMatrix() * O3Scale3(2,2,2).GetMatrix();
	O3Mat4x4r b = (-O3Scale3(2,2,2)).GetMatrix() * (-O3Translation3(1,2,3)).GetMatrix();
	AssertInverse(a,b);
	CheckInverseMethods(a);
}

- (void)testCofactors {
	real dat[] = {1,2,3,  0,4,5,  1,0,6};
	O3Mat3x3r a(dat);
	O3Mat3x3r cofac = a.GetCofactorMatrix();
	real expected_dat[] = {24,5,-4,  -12,3,2,  -2,-5,4};
	STAssertTrue(cofac.Equals(O3Mat3x3r(expected_dat)), @"Cofactor matrix is %s but it should be %s", cofac.Description().c_str(), O3Mat3x3r(expected_dat).Description().c_str());
	STAssertTrue(a.GetAdjointMatrix().Transpose().Equals(cofac), @"Adjoint matrix does not match expected values.");
}

- (void)testBigTimesSmall {
	sranddev();
	int i;
	O3Mat4x4d mat1;
	for (i=0;i<16;i++) mat1(i) = (double)rand() / RAND_MAX * 1000;
	O3Mat3x3d mat2;
	for (i=0;i<9;i++) mat2(i) = (double)rand() / RAND_MAX * 1000;
	STAssertTrue((mat2*mat1).IsEqual((mat2.Get4x4())*mat1), @"Automatic CPTAssert migration. See source code.");
	STAssertTrue((mat1*mat2).IsEqual(mat1*(mat2.Get4x4())), @"Automatic CPTAssert migration. See source code.");
}

@end
