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
#import "O3KVCHelper.h"
#import "O3CGPass.h"

///Fill the annotation map the first time it is accessed rather than incrementally
//#define O3CGPROGRAM_FILL_ANNO_CACHE_AT_ONCE
//#define O3CGPROGRAM_FILL_PASS_CACHE_AT_ONCE

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
- (NSArray*)annotationNames {
	NSMutableArray* to_return = [NSMutableArray array];
	CGannotation anno = cgGetFirstTechniqueAnnotation(mTechnique);
	do {
		[to_return addObject:[NSString stringWithUTF8String:cgGetAnnotationName(anno)]];
	} while (anno = cgGetNextAnnotation(anno));
	return to_return;
}

- (O3CGAnnotation*)annotation:(NSString*)key {
	O3CGAnnotation* tr = [mAnnotations objectForKey:key];
	if (tr) return tr;
	if (!mAnnotations) mAnnotations = [[NSMutableDictionary alloc] init];
	CGannotation anno = cgGetNamedTechniqueAnnotation(mTechnique, [key UTF8String]);
	if (!anno) return nil;
	tr = [[O3CGAnnotation alloc] initWithAnnotation:anno];
	[mAnnotations setObject:tr forKey:key];
	return [tr autorelease];
}



/************************************/ #pragma mark Passes /************************************/
- (NSArray*)passNames {
	NSMutableArray* to_return = [NSMutableArray array];
	CGpass pass = cgGetFirstPass(mTechnique);
	do {
		[to_return addObject:[NSString stringWithUTF8String:cgGetPassName(pass)]];
	} while (pass = cgGetNextPass(pass));
	return to_return;	
}

- (O3CGPass*)passNamed:(NSString*)key {
	O3CGPass* p = [mPassMap objectForKey:key];
	if (p) return p;
	CGpass pass = cgGetNamedPass(mTechnique, [key UTF8String]);
	if (!pass) return nil;
	p = [[O3CGPass alloc] initWithPass:pass];
	[mPassMap setObject:p forKey:key];
	return [p autorelease];	
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
	O3Destroy(mAnnotations);
	O3Destroy(mPassMap);
	delete mPasses;
}

///Returns a new material with default parameters for the receiver with a  retain count of 1
- (O3Material*)newMaterial {
	return [[O3Material alloc] initWithMaterialType:self];
}

/************************************/ #pragma mark Params /************************************/
- (BOOL)paramsAreCGParams {return YES;}
- (NSDictionary*)paramValues {return [mEffect paramValues];}
- (id)valueForParam:(NSString*)pname {return [mEffect valueForParam:pname];}
- (void)setValue:(id)val forParam:(NSString*)pname {[mEffect setValue:val forParam:pname];}
- (O3Parameter*)param:(NSString*)pname {return [mEffect param:pname];}


@end
