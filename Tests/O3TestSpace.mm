/**
 *  @file O3TestSpace.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 2/3/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#include "O3TestSpace.h"
#include "O3Space.h"
//#include "O3TRSSpace.h"
#include <iostream>
using namespace std;

@implementation O3TestSpace

- (void)testNestedTranslations {
	Space3 space, space2;
	space += O3Translation3(1,2,3);
	space -= O3Translation3(1,2,3);
	space2 = space2 + O3Translation3(1,2,3) - O3Translation3(1,2,3);
	STAssertTrue(space.MatrixFromSuper().IsIdentity(), @"Migrated CPTAssertion failed, look at the source.");
	STAssertTrue(space2.MatrixFromSuper().IsIdentity(), @"Migrated CPTAssertion failed, look at the source.");
	STAssertTrue(space.MatrixToSuper().IsIdentity(), @"Migrated CPTAssertion failed, look at the source.");
	STAssertTrue(space2.MatrixToSuper().IsIdentity(), @"Migrated CPTAssertion failed, look at the source.");
	STAssertTrue(space.IsValid(), @"Migrated CPTAssertion failed, look at the source.");
	space2 = space + O3Translation3(1,2,3);
	space += O3Translation3(1,2,3);
	STAssertTrue(space2==space, @"Migrated CPTAssertion failed, look at the source.");
	STAssertTrue(space.IsValid(), @"Migrated CPTAssertion failed, look at the source.");
	
	space2.SetSuperspace(&space);
	space += O3Translation3(1,1,1);
	const O3Mat4x4r& space2mat = space2.MatrixFromRoot();
	STAssertTrue(O3Equals(space2mat(0,3), 3.f, 1.0e-4f), @"Migrated CPTAssertion failed, look at the source.");
	STAssertTrue(O3Equals(space2mat(1,3), 5.f, 1.0e-4f), @"Migrated CPTAssertion failed, look at the source.");
	STAssertTrue(O3Equals(space2mat(2,3), 7.f, 1.0e-4f), @"Migrated CPTAssertion failed, look at the source.");
}

- (void)testNestedTRS {
	Space3 thespace;
	thespace += O3Translation3(2,10,10);
	Space3 aspace(&thespace);
	aspace += O3Rotation3(O3DegreesToRadians(90),0,0);
	Space3 scalespace(O3Scale3(2,2,2), &aspace);
	Space3 otherspace(O3Translation3(1,1,1), NULL);
	STAssertTrue(aspace.IsValid(1.0e-5), @"Migrated CPTAssertion failed, look at the source.");	
}

- (void)testDeepNest {
	Space3 space1(O3Translation3(1,1,1), NULL);
	Space3 space2(O3Translation3(1,1,1), &space1);
	Space3 space3(O3Translation3(1,1,1), &space2);
	Space3 space4(O3Translation3(1,1,1), &space3);
	Space3 space5(O3Translation3(1,1,1), &space4);
	Space3 space6(O3Translation3(1,1,1), &space5);
	Space3 space7(O3Translation3(1,1,1), &space6);
	Space3 space8(O3Translation3(1,1,1), &space7);
	Space3 space9(O3Translation3(1,1,1), &space8);
	Space3 space10(O3Translation3(1,1,1), &space9);
	O3Mat4x4r trans = space10.MatrixToRoot();
	space1 += O3Translation3(1,1,1);
	STAssertTrue(!(trans==space10.MatrixToRoot()), @"Migrated CPTAssertion failed, look at the source.");
	
}

/* //Disabled, TRSSpace abandoned in favor of direct usage of plain Space.
- (void)testTRSSpace {
	TRSSpace3 space1(O3Translation3(1,2,3));
	cout<<space1.MatrixFromSuper();
	Space3 space2(O3Translation3(1,1,1), &space1);
	Space3 space3(O3Translation3(1,1,1), &space2);
	Space3 space4(O3Translation3(1,1,1), &space3);
	TRSSpace3 space5(O3Translation3(0,0,0), O3Rotation3(O3DegreesToRadians(90),0,0), O3Scale3(1,1,1), &space4);
	O3Mat4x4r trans = space5.MatrixToRoot();
	space1 += O3Translation3(1,1,1);
	cout<<trans<<space5.MatrixToRoot();
	STAssertTrue(!(trans==space5.MatrixToRoot()), @"Migrated CPTAssertion failed, look at the source.");
}
*/

@end
