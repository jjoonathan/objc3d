#import <Cocoa/Cocoa.h>
#import <ObjC3D/ObjC3D.h>
extern "C" {
#import <RubyCocoa/RBRuntime.h>
}

@interface TIC:NSObject
@end
@implementation TIC
- (O3Vec3r)vecer {return O3Vec3r(1,2,3);}
@end

int main(int argc, const char *argv[]) {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	O3Init();
	NSLog(@"%@", [TIC valueForKey:@"vecer"]);
    int ret = RBApplicationMain("console.rb", argc, argv);
	[pool release]; //Doesn't matter, but prevents whining
	return ret;
}
