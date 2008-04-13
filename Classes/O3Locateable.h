#import "O3Space.h"
@class O3TRSSpace;

@interface O3Locateable : NSObject <O3Spatial, NSCoding> {
	O3TRSSpace* mObjectSpace;
}
//Movement
- (void)recenter;
- (void)moveTo:(O3Vec3d)amount inPOVOf:(id<O3Spatial>)pov;
- (void)rotateBy:(angle)theta over:(O3Vec3d)axis inPOVOf:(id<O3Spatial>)pov;
- (void)resize:(O3Vec3d)amount inPOVOf:(id<O3Spatial>)pov;

- (void)setParentSpace:(id<O3Spatial>)s; ///<Change the parent, keeping the object's position the same with respect to the world
- (void)setParentSpaceWithoutAdjusting:(id<O3Spatial>)s; ///<Sets the parent, keeping the transformation with respect to the parent the same
@end

typedef O3Locateable<O3Renderable> O3SceneObj;