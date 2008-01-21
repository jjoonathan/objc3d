/**
 *  @file O3TestGLFWTime.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 12/18/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#include "O3TestGLFWTime.h"
#include <GL/glfw.h>

@implementation O3TestGLFWTime
O3DefaultO3InitializeImplementation

- (void)testTime {
	int samples = 100;
	
	glfwInit();
	double precisionAccumulator = 0;
	int i; for (i=0;i<samples;i++) precisionAccumulator += [self timerPrecision];
	precisionAccumulator /= samples;
	precisionAccumulator *= 1000;
	NSLog(@"Timer precision: %fms over %i samples\n\n", precisionAccumulator, samples);
	glfwTerminate();
}

- (double)timerPrecision {
	double start = glfwGetTime();
	double newtime;
	while (start==(newtime=glfwGetTime()));
	return newtime - start;
}

@end
