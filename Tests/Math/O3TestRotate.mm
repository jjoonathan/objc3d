/**
 *  @file O3TestRotate.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 11/20/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#include "O3TestRotate.h"
#include "O3Global.h"
#include "O3Quaternion.h"
using namespace ObjC3D::Math;

inline void PMat(const char* name, O3Vec3r& vec) {
	printf("%s: %f %f %f\n", name, vec.X(), vec.Y(), vec.Z());
}

@implementation O3TestRotation

- (void)testEulerToQuatAndQuatToMatrix {
	/*
	O3Vec3r rot360x = O3Rotation3(2*M_PI, 0., 0.).GetMatrix()*O3Vec3r(0,0,1);
	STAssertTrue(rot360x.IsEqualTo(O3Vec3r(0,0,1), .000001), @"Automatic migration from CPTAssert. See source code.");
	O3Vec3r rot180x = O3Rotation3(M_PI, 0., 0.).GetMatrix()*O3Vec3r(0,0,1);
	STAssertTrue(rot180x.IsEqualTo(O3Vec3r(0,0,-1), .000001), @"Automatic migration from CPTAssert. See source code.");
	O3Vec3r rot90x = O3Rotation3(.5*M_PI, 0., 0.).GetMatrix()*O3Vec3r(0,0,1);
	STAssertTrue(rot90x.IsEqualTo(O3Vec3r(0,1,0), .000001), @"Automatic migration from CPTAssert. See source code.");
	
	O3Vec3r rot360y = O3Rotation3(0, 2*M_PI, 0.).GetMatrix()*O3Vec3r(0,0,1);
	STAssertTrue(rot360y.IsEqualTo(O3Vec3r(0,0,1), .000001), @"Automatic migration from CPTAssert. See source code.");
	O3Vec3r rot180y = O3Rotation3(0, M_PI, 0.).GetMatrix()*O3Vec3r(0,0,1);
	STAssertTrue(rot180y.IsEqualTo(O3Vec3r(0,0,-1), .000001), @"Automatic migration from CPTAssert. See source code.");
	O3Vec3r rot90y = O3Rotation3(0, .5*M_PI, 0.).GetMatrix()*O3Vec3r(0,0,1);
	STAssertTrue(rot90y.IsEqualTo(O3Vec3r(-1,0,0), .000001), @"Automatic migration from CPTAssert. See source code.");
	 */
}

- (void)testQuatToEuler {
	/*
	O3Rotation3 testRot(O3Quaternion(-0.625212, 0.807772, -0.379874));
	real euler_x, euler_y, euler_z; testRot.GetQuaternion().GetEuler(&euler_x, &euler_y, &euler_z);
	STAssertTrue(O3Equals(euler_x, -0.625212, .00001), @"Automatic migration from CPTAssert. See source code.");
	STAssertTrue(O3Equals(euler_y, 0.807772,  .00001), @"Automatic migration from CPTAssert. See source code.");
	STAssertTrue(O3Equals(euler_z, -0.379874, .00001), @"Automatic migration from CPTAssert. See source code.");
	 */
}

@end

