//
//  O3ResSource.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 9/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
@class O3ResManager;

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
}
- (double)searchPriorityForObjectNamed:(NSString*)key;
- (id)tryToLoadObjectNamed:(NSString*)key intoResManager:(O3ResManager*)manager sideEffects:(BOOL)loadSiblings;
- (NSArray*)allKeys; ///<Finds all keys in the source, but does not load them. This method may return old data, since it is allowed to cache. Try to reload some nonexsistant key with sideEffects:NO to update said (optional) cache.
- (id)tryToReloadObjectNamed:(NSString*)key intoResManager:(O3ResManager*)manager sideEffects:(BOOL)loadSiblings;
@end
