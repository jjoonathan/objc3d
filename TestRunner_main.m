//Test rig compliments of Dave Dribin, with modifications by Jonathan deWerd
#import <SenTestingKit/SenTestingKit.h>

int main(int argc, char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    NSEnumerator * arguments = [[[NSProcessInfo processInfo] arguments] objectEnumerator];
    // Skip argv[0]
    [arguments nextObject];
    NSString * bundlePath;
    NSString * lastBundlePath;
    while (bundlePath = [arguments nextObject]) {
        NSBundle * bundleToLoad = [NSBundle bundleWithPath: bundlePath];
        if ([bundleToLoad load]) {
            NSLog(@"Loaded bundle: %@", bundlePath);
            lastBundlePath = bundlePath;
        }
    }

	[[NSUserDefaults standardUserDefaults] setObject:lastBundlePath forKey:SenTestedUnitPath];
	[[NSUserDefaults standardUserDefaults] setObject:@"All" forKey:@"SenTest"];
	[[SenTestProbe class] performSelector:@selector(runTests:) withObject:nil];
    //SenTestSuite * suite;
    //suite = [SenTestSuite testSuiteForBundlePath: lastBundlePath];
    //BOOL hasFailed = ![[suite run] hasSucceeded];
    
    [pool release];
    //return ((int) hasFailed);
    return 0;
}