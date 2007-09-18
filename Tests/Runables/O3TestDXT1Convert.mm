/**
 *  @file O3TestDXT1Convert.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 12/21/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3Texture.h"

int main(int argc, char *argv[]) {
	[NSApplication sharedApplication];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	glfwInit();
	glfwOpenWindow(/*width:*/		0,
				   /*height:*/		0,
				   /*redbits:*/		8,
				   /*greenbits:*/	8,
				   /*bluebits:*/	8,
				   /*alphabits:*/	8,
				   /*depthnbits:*/	32,
				   /*stencilbits:*/	0,
				   /*mode:*/		GLFW_WINDOW);   
	if (argc<3) {
		printf("DXT1 conversion utility, copyright 2007 jjoo, all rights reserved.\n");
		printf("Useage: %s input_file.tiff output_file.dxt1\n", argv[0]);
		return 0;
	}
	O3Texture* tex = [[O3Texture alloc] initWithImage:[[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:argv[1]]] internalFormat:GL_COMPRESSED_RGB_S3TC_DXT1_EXT];
	O3CHECK_GL_ERROR;
	if (!tex) {
		printf("There was an error reading the file or converting the image.\n");
		return 0;
	}
	NSString *str = [NSString stringWithUTF8String:argv[2]];
	[tex hintWillGetTextureData];
	[[tex textureData] writeToFile:str atomically:YES];
	[pool release];
	return 0;
}
