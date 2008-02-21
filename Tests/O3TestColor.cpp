/*
 *  Color.cpp
 *  ObjC3D
 *
 *  Created by Jonathan deWerd on 11/16/06.
 *  Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 *  http://pantras.free.fr/articles/helloworld.html //Dammit, cppunit > this >:(
 */

#include "O3TestColor.h"

namespace ObjC3D {
namespace Tests {

using namespace ObjC3D::Engine;

ColorTest::ColorTest(TestInvocation *invocation): TestCase(invocation) {
}


ColorTest::~ColorTest() {
}

void ColorTest::TestInitializationBGRA8() {
	BGRA8 testColor(.1, .2, .3, 1);
	UInt32 testColorValue = O3ByteswapBigToHost(*(UInt32*)&testColor);
	CPTAssert(((testColorValue>>24)&0xFF) == 77);
	CPTAssert(((testColorValue>>16)&0xFF) == 51);
	CPTAssert(((testColorValue>> 8)&0xFF) == 26); ///\todo fixme
	//CPTAssert(((testColorValue>>00)&0xFF) == 0xFF);
}

void ColorTest::TestInitializationBGRA16() {
	BGRA16 testColor(.1, .2, .3, 1);
	UInt16* testColorValues = (UInt16*)&testColor;
	CPTAssert((testColorValues[0]) == 0x4CCD); //B
	CPTAssert((testColorValues[1]) == 0x3333); //G
	CPTAssert((testColorValues[2]) == 0x199A); //R
	CPTAssert((testColorValues[3]) == 0xFFFF); //A
}

void ColorTest::TestInitializationRGB565() {
#ifndef __LITTLE_ENDIAN__
	RGB565 testColor(.1, .2, 1);
#else
	RGB565 testColor(1, .2, .1);
#endif
	UInt16 testColorValue = *(UInt16*)&testColor;
	CPTAssert(((testColorValue>>11)&0x1F) == 3);
	CPTAssert(((testColorValue>> 5)&0x3F) == 13);
	CPTAssert(((testColorValue>> 0)&0x1F) == 0x1F);
}

} //end namespace Tests
} //end namespace ObjC3D
