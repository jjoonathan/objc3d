//
//  O3ResSource.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 9/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
@class O3ResManager;

enum O3ResManagerLaziness {
	O3ResManagerFileLazy=0,		///<Each file will be entirely loaded whenever any object is needed from it. Not lazy at all.
	O3ResManagerModerateLazy=1,	///<Small files will be loaded all at once, but big files will be loaded object-by-object. Lets each res source make its own decision.
	O3ResManagerObjectLazy=2,		///<Each object will be loaded only when needed. Forces laziness.
	O3ResManagerNoOpinionLazy=3	///<Passes control of laziness to next higher tier. This is the default for everything except the global lazy setting, which defaults to O3ResManagerModerateLazy. Only used internally, won't ever be returned by -laziness.
};

/** O3ResSource is an abstract class for all classes which provide ways of loading resources. 
 *  If a resource cannot be found, a O3ResManager will look through its list of O3ResSources
 *  , sort them based on their searchPriority: for the unknown key (based on the likelihood of 
 *  having the resource / the very rough approximate time to check/load), and ask each one with a nonzero
 *  search priority to load the key. This causes inteligent, lazy loading with fallback options (say,
 *  searching websites or something).
 * @note Always allow the load methods to load siblings if possible.
 * @warning All methods raise doesNotRespondToSelector exceptions, so do *not* call super.
 */
@interface O3ResSource : NSObject {
@private
	enum O3ResManagerLaziness mLaziness;
}
//To be implemented by subclass
- (id)initWithCoder:(NSCoder*)coder;
- (void)encodeWithCoder:(NSCoder*)coder;
- (double)searchPriorityForObjectNamed:(NSString*)key;
- (BOOL)handleLoadRequest:(NSString*)requestedObject fromManager:(O3ResManager*)rm tryAgain:(inout BOOL*)temporaryFailure;
- (BOOL)shouldLoadLazily; ///<Returns YES if the resource soure is over the critical limit under O3ResManagerModerateLazy between lazy and not-lazy loading
- (void)subresourceDied:(O3ResSource*)rs; ///<Default implementation does nothing

//Allows binding to a table or somesuch
- (NSString*)stringValue;
- (void)setStringValue:(NSString*)string;

- (enum O3ResManagerLaziness)laziness;
- (void)setLaziness:(enum O3ResManagerLaziness)newLazy;

+ (enum O3ResManagerLaziness)laziness;
+ (void)setLaziness:(enum O3ResManagerLaziness)newLazy;
@end
