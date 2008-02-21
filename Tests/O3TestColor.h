/**
 *  @file O3TestColor.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 11/16/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#include <CPlusTest/CPlusTest.h>
#include "O3Color.h"

namespace ObjC3D {
namespace Tests {
		
class ColorTest : public TestCase {
public:
    ColorTest(TestInvocation* invocation);
    virtual ~ColorTest();
	
public: //Tests
	void TestInitializationBGRA8();
	void TestInitializationBGRA16();
	void TestInitializationRGB565();
};

ColorTest InitializationBGRA8(TEST_INVOCATION(ColorTest,TestInitializationBGRA8));
ColorTest InitializationBGRA16(TEST_INVOCATION(ColorTest,TestInitializationBGRA16));
ColorTest InitializationRGB565(TEST_INVOCATION(ColorTest,TestInitializationRGB565));

} //end namespace Tests
} //end namespace ObjC3D
