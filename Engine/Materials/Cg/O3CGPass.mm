/**
 *  @file O3CGPass.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 3/15/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3CGPass.h"
#import "O3KVCHelper.h"
#import "O3CGAnnotation.h"

//#define O3CGPASS_FILL_ANNO_CACHE_AT_ONCE

@implementation O3CGPass
O3DefaultO3InitializeImplementation
/************************************/ #pragma mark Init /************************************/
- (void)dealloc {
	[self purgeCaches];
	[super dealloc];
}

- (id)init {
	[self release];
	return nil;
}

- (O3CGPass*)initWithPass:(CGpass)pass {
	O3SuperInitOrDie();
	mPass = pass;
	return self;
}



/************************************/ #pragma mark Inspectors /************************************/
- (NSString*)name {
	return [NSString stringWithUTF8String:cgGetPassName(mPass)];
}



/************************************/ #pragma mark Annotations /************************************/
typedef map<string, O3CGAnnotation*> AnnotationMap;

AnnotationMap*	mAnnotationsP(O3CGPass* self) {
	if (self->mAnnotations) return self->mAnnotations;
	self->mAnnotations = new AnnotationMap();
	#ifdef O3CGPASS_FILL_ANNO_CACHE_AT_ONCE
	CGannotation anno = cgGetFirstPassAnnotation(self->mPass);
	do {
		string name = cgGetAnnotationName(anno);
		O3CGAnnotation* newAnno = [[O3CGAnnotation alloc] initWithAnnotation:anno];
		(*self->mAnnotations)[name] = newAnno;
	} while (anno = cgGetNextAnnotation(anno));
	#endif
	return self->mAnnotations;
}

- (id)annotations {
	if (!mAnnotationKVCHelper) mAnnotationKVCHelper = [[O3KVCHelper alloc] initWithTarget:self
                                                                        valueForKeyMethod:@selector(annotationNamed:)
                                                                     setValueForKeyMethod:nil
                                                                           listKeysMethod:@selector(annotationKeys)];
	return mAnnotationKVCHelper;
}

- (NSArray*)annotationKeys {
	NSMutableArray* to_return = [NSMutableArray array];
	CGannotation anno = cgGetFirstPassAnnotation(mPass);
	do {
		[to_return addObject:[NSString stringWithUTF8String:cgGetAnnotationName(anno)]];
	} while (anno = cgGetNextAnnotation(anno));
	return to_return;
}

- (O3CGAnnotation*)annotationNamed:(NSString*)key {
	AnnotationMap* annos = mAnnotationsP(self);
	string name = NSStringUTF8String(key);
	AnnotationMap::iterator anno_loc = annos->find(name);
	O3CGAnnotation* to_return = anno_loc->second;
	if (anno_loc==annos->end()) {
		CGannotation anno = cgGetNamedPassAnnotation(mPass, name.c_str());
		if (!anno) return nil;
		(*annos)[name] = to_return = [[O3CGAnnotation alloc] initWithAnnotation:anno];
	}
	return to_return;
}



- (void)purgeCaches {
	O3DestroyCppMap(AnnotationMap, mAnnotations);
}

@end
