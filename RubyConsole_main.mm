#import <Cocoa/Cocoa.h>
#import <ObjC3D/ObjC3D.h>
extern "C" {
#import <RubyCocoa/RBRuntime.h>
}

int main(int argc, const char *argv[]) {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	O3Init();
    int ret = RBApplicationMain("console.rb", argc, argv);
	[pool release]; //Doesn't matter, but prevents whining
	return ret;
}
