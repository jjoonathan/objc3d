#include "O3Space.h"
#include "O3TRSSpace.h"
#include <iostream>
using namespace std;
using namespace ObjC3D::Engine;
using namespace ObjC3D::Math;
///\todo Delete me! (the sole purpose of this file is to allow the use of a debugger on what would be a test case. gurr.)


int main(int argc, char *argv[]) {
	TRSSpace3 space1(O3Translation3(1,1,1));
	Space3 space2(O3Translation3(1,1,1), &space1);
	Space3 space3(O3Translation3(1,1,1), &space2);
	Space3 space4(O3Translation3(1,1,1), &space3);
	TRSSpace3 space5(O3Translation3(0,0,0), O3Rotation3(O3DegreesToRadians(90),0,0), O3Scale3(1,1,1), &space4);
	O3Mat4x4r trans = space5.MatrixToRoot();
	space1 += O3Translation3(1,1,1);
	cout<<trans<<space5.MatrixToRoot();
	//CPTAssert(!(trans==space5.MatrixToRoot()));
	
	return 0;
}