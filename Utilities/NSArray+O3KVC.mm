//
//  NSArray+O3KVC.m
//  ObjC3D
//
//  Created by Jonathan deWerd on 2/24/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import "NSArray+O3KVC.h"

@implementation NSArray (O3KVCAdditions)

- (id)valueForUndefinedKey:(NSString*)uk {
	if (!uk) return [super valueForUndefinedKey:uk];
	const char* uks = NSStringUTF8String(uk);
	if (uks[0]=='#' && uks[1]) return [self objectAtIndex:atoi(uks+1)];
	return [super valueForUndefinedKey:uk];
}

- (void)setValue:(id)val forKey:(NSString*)k {
	if (!k) {
		[super setValue:val forKey:k];
		return;
	}
	const char* uks = NSStringUTF8String(k);
	if (uks[0]!='#' || !uks[1]) {
		[super setValue:val forKey:k];
		return;
	}
	[(NSMutableArray*)self replaceObjectAtIndex:atoi(uks+1) withObject:val];
}

@end
