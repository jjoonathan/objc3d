//
//  O3ResSource.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 9/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3ResSource.h"

enum O3ResManagerLaziness gResManagerLaziness = O3ResManagerModerateLazy;

@implementation O3ResSource
O3DefaultO3InitializeImplementation
inline enum O3ResManagerLaziness mLazinessP(O3ResSource* self) {
	return self->mLaziness==O3ResManagerNoOpinionLazy ? gResManagerLaziness : self->mLaziness;
}

- (id)init {
	O3SuperInitOrDie();
	mLaziness = O3ResManagerNoOpinionLazy;
	return self;
}

- (id)initWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding]) {
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
		[self release];
		return nil;
	}
	O3SuperInitOrDie();
	mLaziness = (O3ResManagerLaziness)[coder decodeIntForKey:@"laziness"];
	return self;
}

 - (void)encodeWithCoder:(NSCoder*)coder {
 	//[super encodeWithCoder:coder];
 	if (![coder allowsKeyedCoding])
 		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
 	[coder encodeInt:(int)mLaziness forKey:@"Laziness"];
 }

/************************************/ #pragma mark Abstract methods /************************************/
- (double)searchPriorityForObjectNamed:(NSString*)key {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)loadObjectNamed:(NSString*)name {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (void)loadAllObjectsInto:(O3ResManager*)manager {
	[self doesNotRecognizeSelector:_cmd];
}

- (BOOL)isBig {
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

- (NSString*)stringValue {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (void)setStringValue:(NSString*)string {
	[self doesNotRecognizeSelector:_cmd];
}



///Non-abstract method method. Override -(id)loadObjectNamed and -(void)loadAllObjectsIntoManager.
///Keys that cannot be loaded are ignored (nil is returned on failure).
- (id)loadObjectNamed:(NSString*)key intoResManager:(O3ResManager*)manager {
	switch (mLazinessP(self)) {
		case O3ResManagerNoOpinionLazy:
			O3AssertFalse(@"mLazinessP should never return O3ResManagerNoOpinionLazy.");
		case O3ResManagerFileLazy: {
			[self loadAllObjectsInto:manager];
			return [manager valueForKey:key];
		}
		case O3ResManagerModerateLazy: {
			if ([self isBig]) {
				[self loadAllObjectsInto:manager];
				return [manager valueForKey:key];			
			} else {
				id obj = [self loadObjectNamed:key];
				if (obj) [manager setValue:obj forKey:key];
				return obj;
			}
		}
		case O3ResManagerObjectLazy: {
			id obj = [self loadObjectNamed:key];
			if (obj) [manager setValue:obj forKey:key];
			return obj;			
		}
		default:
			O3AssertFalse(@"Improper laziness: %i", mLazinessP(self));
	}
	return nil;
}


///Returns the laziness of the receiver or the global laziness if the receiver has no opinion
- (enum O3ResManagerLaziness)laziness {return mLazinessP(self);}
///Sets the receiver's laziness. O3ResManagerNoOpinionLazy will make the receiver return the global laziness for 
- (void)setLaziness:(enum O3ResManagerLaziness)newLazy {mLaziness = newLazy;}

+ (enum O3ResManagerLaziness)laziness {return gResManagerLaziness==O3ResManagerNoOpinionLazy?gResManagerLaziness:O3ResManagerModerateLazy;}
///Sets global laziness to anything but O3ResManagerNoOpinionLazy (attempting this will reset the global laziness to the default)
+ (void)setLaziness:(enum O3ResManagerLaziness)newLazy {gResManagerLaziness = newLazy;}

@end
