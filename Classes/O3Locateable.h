#import "O3Space.h"
@class O3TRSSpace;

@interface O3Locateable : NSObject <O3Spatial, NSCoding> {
	O3TRSSpace* mObjectSpace;
}
//Movement
- (void)recenter;
- (void)moveBy:(O3Vec3d)amount inPOVOf:(id<O3Spatial>)pov;
- (void)moveTo:(O3Vec3d)amount inPOVOf:(id<O3Spatial>)pov;
- (void)rotateBy:(angle)theta over:(O3Vec3d)axis inPOVOf:(id<O3Spatial>)pov;
- (void)resize:(O3Vec3d)amount inPOVOf:(id<O3Spatial>)pov;

//Changing the parent
- (void)setParentSpace:(id<O3Spatial>)s;
@end

typedef O3Locateable<O3Renderable> O3SceneObj;