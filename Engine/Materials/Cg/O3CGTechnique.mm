/**
 *  @file O3CGTechnique.mm
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3CGTechnique.h"
#import "O3CGEffect.h"
#import "O3CGAnnotation.h"
#import "O3CGParameterSupport.h"
#import "O3CGMaterial.h"
#import "O3KVCHelper.h"
#import "O3CGPass.h"

///Fill the annotation map the first time it is accessed rather than incrementally
//#define O3CGPROGRAM_FILL_ANNO_CACHE_AT_ONCE
//#define O3CGPROGRAM_FILL_PASS_CACHE_AT_ONCE

typedef map<string, O3CGAnnotation*> AnnotationMap;
typedef map<string, O3CGPass*> PassMap;

@implementation O3CGTechnique
O3DefaultO3InitializeImplementation
inline vector<CGpass>* mPassesP(O3CGTechnique* self) {
	if (self->mPasses) return self->mPasses;
	self->mPasses = new vector<CGpass>();
	CGpass current_pass = cgGetFirstPass(self->mTechnique);
	do {
		self->mPasses->push_back(current_pass);
	} while (current_pass = cgGetNextPass(current_pass));
	return self->mPasses;
}

AnnotationMap*	mAnnotationsP(O3CGTechnique* self) {
	if (self->mAnnotations) return self->mAnnotations;
	self->mAnnotations = new AnnotationMap();
	#ifdef O3CGEFFECT_FILL_ANNO_CACHE_AT_ONCE
	CGannotation anno = cgGetFirstTechniqueAnnotation(self->mTechnique);
	do {
		string name = cgGetAnnotationName(anno);
		O3CGAnnotation* newAnno = [[O3CGAnnotation alloc] initWithAnnotation:anno];
		(*self->mAnnotations)[name] = newAnno;
	} while (anno = cgGetNextAnnotation(anno));
	#endif
	return self->mAnnotations;
}

PassMap* mPassMapP(O3CGTechnique* self) {
	if (self->mPassMap) return self->mPassMap;
	self->mPassMap = new PassMap();
	#ifdef O3CGPROGRAM_FILL_PASS_CACHE_AT_ONCE
	CGpass pass = cgGetFirstPass(self->mTechnique);
	do {
		string name = cgGetPassName(pass);
		O3CGPass* newPass = [[O3CGPass alloc] initWithPass:pass];
		(*self->mPassMap)[name] = newPass;
	} while (pass = cgGetNextPass(pass));
	#endif
	return self->mPassMap;
}

- (id)initWithTechnique:(CGtechnique)technique fromEffect:(O3CGEffect*)effect {
	if (!technique) {
		[self release];
		return nil;
	}
	O3SuperInitOrDie();
	if (!self) return nil;
	mTechnique = technique;
	mEffect = effect;
	return self;
}

- (void)dealloc {
	if (mPasses) delete mPasses;
	[self purgeCaches];
	[super dealloc];
}

///@note O3CGTechnique uses its own test for isValid
- (BOOL)isValid {
	if (!mTechnique) return nil;
	if (cgIsTechniqueValidated(mTechnique)) return YES;
	return cgValidateTechnique(mTechnique)?YES:NO;
}

- (NSString*)name {
	if (!mTechnique) return nil;
	return [NSString stringWithUTF8String:cgGetTechniqueName(mTechnique)];
}

- (O3CGEffect*)effect {
	return mEffect;
}



/************************************/ #pragma mark Annotations /************************************/
- (id)annotations {
	if (!mAnnotationKVCHelper) mAnnotationKVCHelper = [[O3KVCHelper alloc] initWithTarget:self
                                                                        valueForKeyMethod:@selector(annotationNamed:)
                                                                     setValueForKeyMethod:nil
                                                                           listKeysMethod:@selector(annotationKeys)];
	return mAnnotationKVCHelper;
}

- (NSArray*)annotationKeys {
	NSMutableArray* to_return = [NSMutableArray array];
	CGannotation anno = cgGetFirstTechniqueAnnotation(mTechnique);
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
		CGannotation anno = cgGetNamedTechniqueAnnotation(mTechnique, name.c_str());
		if (!anno) return nil;
		(*annos)[name] = to_return = [[O3CGAnnotation alloc] initWithAnnotation:anno];
	}
	return to_return;
}



/************************************/ #pragma mark Passes /************************************/
- (id)passes {
	if (!mPassesKVCHelper) mPassesKVCHelper = [[O3KVCHelper alloc] initWithTarget:self
                                                                valueForKeyMethod:@selector(passNamed:)
                                                             setValueForKeyMethod:nil
                                                                   listKeysMethod:@selector(passKeys)];
	return mAnnotationKVCHelper;	
}

- (NSArray*)passKeys {
	NSMutableArray* to_return = [NSMutableArray array];
	CGpass pass = cgGetFirstPass(mTechnique);
	do {
		[to_return addObject:[NSString stringWithUTF8String:cgGetPassName(pass)]];
	} while (pass = cgGetNextPass(pass));
	return to_return;	
}

- (O3CGPass*)passNamed:(NSString*)key {
	PassMap* passes = mPassMapP(self);
	string name = NSStringUTF8String(key);
	PassMap::iterator pass_loc = passes->find(name);
	O3CGPass* to_return = pass_loc->second;
	if (pass_loc==passes->end()) {
		CGpass pass = cgGetNamedPass(mTechnique, name.c_str());
		if (!pass) return nil;
		(*passes)[name] = to_return = [[O3CGPass alloc] initWithPass:pass];
	}
	return to_return;	
}



/************************************/ #pragma mark Use /************************************/
- (int)renderPasses {
	return mPassesP(self)->size();
}

- (void)beginRendering {
	O3Assert([self isValid], @"Cannot call beginRendering (or any other render method for that matter) on an invalid technique");
	[mEffect beginTechniqueRendering];
}

- (void)setRenderPass:(int)passnum {
	vector<CGpass>* passes = mPassesP(self);
	O3Assert(passnum<passes->size(), @"Attempt to access pass index %i of %i", passnum, passes->size());
	if (passnum>0) cgResetPassState(passes->at(passnum-1));
	CGpass thepass = passes->at(passnum);
	cgSetPassState(thepass);
	O3GLBreak();
}

- (void)endRendering {
	vector<CGpass>* passes = mPassesP(self);
	int size = passes->size();
	if (size>0) cgResetPassState(passes->at(size-1));
	[mEffect endTechniqueRendering];
}

- (void)purgeCaches {
	O3DestroyCppMap(AnnotationMap, mAnnotations);
}

///Returns a new material with default parameters for the receiver with a  retain count of 1
- (O3CGMaterial*)newMaterial {
	return [[O3CGMaterial alloc] initWithMaterialType:self];
}

/************************************/ #pragma mark Params /************************************/
- (id)parameters {
	return [mEffect parameters];
}

- (NSArray*)parameterKeys {
	return [mEffect parameterKeys];
}

- (O3CGParameter*)parameterNamed:(NSString*)key {
	return [mEffect parameterNamed:key];
}

- (void)setParameterValue:(id)value forKey:(NSString*)key {
	[mEffect setParameterValue:value forKey:key];
}

- (CGtype)typeNamed:(NSString*)tname {
	return [mEffect typeNamed:tname];
}


@end
