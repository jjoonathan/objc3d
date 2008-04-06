//
//  O3ResSource.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 9/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3ResSource.h"
#import "O3ResManager.h"

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

- (void)subresourceDied:(O3ResSource*)rs {
}

/************************************/ #pragma mark Abstract methods /************************************/
- (double)searchPriorityForObjectNamed:(NSString*)key {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

///@param temporaryFailure is set to YES if the failure to load was just due to a lock not being acquired or something. If YES is passed to begin with, the receiver will try again on its own, and will always return NO in temporaryFailure.
- (BOOL)handleLoadRequest:(NSString*)requestedObject fromManager:(O3ResManager*)rm tryAgain:(inout BOOL*)temporaryFailure {
	[self doesNotRecognizeSelector:_cmd];
	if (temporaryFailure) *temporaryFailure = NO;
	return NO;
}

- (BOOL)shouldLoadLazily {
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


///Returns the laziness of the receiver or the global laziness if the receiver has no opinion
- (enum O3ResManagerLaziness)laziness {return mLazinessP(self);}
///Sets the receiver's laziness. O3ResManagerNoOpinionLazy will make the receiver return the global laziness for 
- (void)setLaziness:(enum O3ResManagerLaziness)newLazy {mLaziness = newLazy;}

+ (enum O3ResManagerLaziness)laziness {return gResManagerLaziness==O3ResManagerNoOpinionLazy?gResManagerLaziness:O3ResManagerModerateLazy;}
///Sets global laziness to anything but O3ResManagerNoOpinionLazy (attempting this will reset the global laziness to the default)
+ (void)setLaziness:(enum O3ResManagerLaziness)newLazy {gResManagerLaziness = newLazy;}

@end
