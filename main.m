/**
 *  @file main.m
 *  @license MIT License (see LICENSE.txt)
 *  @date 8/17/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
using namespace ObjC3D::Engine;

int main(int argc, char *argv[]) {
	return NSApplicationMain(argc,  (const char **) argv);
}

/*@implementation O3FrameworkLoader
+ (void)load {
	NSBundle* bundle = [NSBundle bundleForClass:[self class]];
	NSString* pfpath = [bundle privateFrameworksPath];
	
	NSString* l4cPath = [pfpath stringByAppendingPathComponent:@"/log4cocoa.framework"];
	NSBundle* l4c = [NSBundle bundleWithPath:l4cPath];
	BOOL l4cLoaded = [l4c load];
	if (!l4cLoaded) NSLog(@"Could not load log4cocoa framework at path \"%@\". Bundle = %@.", l4cPath, l4c);
	
	NSString* cgPath = [pfpath stringByAppendingPathComponent:@"/Cg.framework"];
	NSBundle* cg = [NSBundle bundleWithPath:cgPath];
	BOOL cgLoaded = [cg load];
	if (!cgLoaded) NSLog(@"Could not load Cg framework at path \"%@\". Bundle = %@.", cgPath, cg);
}
@end*/