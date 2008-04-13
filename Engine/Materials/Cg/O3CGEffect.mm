/**
 *  @file O3CGEffect.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 1/5/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3Material.h"
#import "O3CGEffect.h"
#import "O3CGProgram.h"
#import "O3CGAnnotation.h"
#import "O3CGParameter.h"
#import "O3CGTechnique.h"
#import "O3KVCHelper.h"

///Fill the parameter map the first time it is accessed rather than lazily
//#define O3CGEFFECT_FILL_PARAM_CACHE_AT_ONCE
///Fill the annotation map the first time it is accessed rather than lazily
//#define O3CGEFFECT_FILL_ANNO_CACHE_AT_ONCE
///Fill the technique map the first time it is accessed rather than lazily
//#define O3CGEFFECT_FILL_TECHNIQUE_CACHE_AT_ONCE

typedef map<string, O3CGTechnique*> TechniqueMap;
typedef map<string, O3CGParameter*> ParameterMap;
typedef map<string, O3CGAnnotation*> AnnotationMap;

const char** gDefaultCGEffectCompilerArguments = NULL;
BOOL gO3CGEffectsEnabled = YES;
ParameterMap gO3CGEffectGlobals;

@implementation O3CGEffect
O3DefaultO3InitializeImplementation

+ (void)o3init {
}

/************************************/ #pragma mark Inline C /************************************/
void O3CGEffect_setEffectP(O3CGEffect* self, CGeffect newEffect) {
	if (self->mEffect) cgDestroyEffect(self->mEffect);
	self->mEffect = newEffect;
	
	if (self->mTextureParams) {
		delete self->mTextureParams;
		self->mTextureParams = NULL;
	}
	[self purgeCaches];
}

void O3CGEffect_setAutoSetParameters(O3CGEffect* self) {
	O3AssertIvar(self->mAutoSetParameters);
	if (!self->mAutoSetParameters) return; //Why?
	vector<O3CGAutoSetParameter>::iterator it;
	for (it=self->mAutoSetParameters->begin();it!=self->mAutoSetParameters->end();++it) {
		CGparameter param = (*it).param;
		CGGLenum matrix = (*it).matrix;
		CGGLenum transform = (*it).transform;
		cgGLSetStateMatrixParameter(param, matrix, transform);
	}
}

void O3CGEffect_autoDetectAutoSetParameters(O3CGEffect* self, CGeffect effect) {
	if (self->mAutoSetParameters) delete self->mAutoSetParameters;
	self->mAutoSetParameters = new vector<O3CGAutoSetParameter>();
	typedef struct {string name; CGGLenum matrix; CGGLenum transform;} O3CGEffectAutoSetTemplate;
	int i; for (i=0;i<gNumCGAutoSetParamaterTemplates;i++) {
		CGparameter param;
		if (param = cgGetEffectParameterBySemantic(effect, gCGAutoSetParamaterTemplates[i].name)) {
			O3CGAutoSetParameter newAutoSetter = {param, gCGAutoSetParamaterTemplates[i].matrix, gCGAutoSetParamaterTemplates[i].transform};
			self->mAutoSetParameters->push_back(newAutoSetter);
		}
	}
}

inline void mConnectGlobalParamsP(O3CGEffect* self) {
	CGparameter eff_param = cgGetFirstEffectParameter(self->mEffect);
	do {
		string sem = cgGetParameterSemantic(eff_param);
		if (sem=="") continue;
		BOOL should_go_to_next_param = NO;
		for (UIntP i=0; i<gNumCGAutoSetParamaterTemplates; i++) {
			string template_binding = gCGAutoSetParamaterTemplates[i].name;
			if (sem==template_binding) {
				should_go_to_next_param = YES;
				break;
			}
		}
		if (should_go_to_next_param) continue;
		ParameterMap::iterator param = gO3CGEffectGlobals.find(sem);
		O3CGParameter* oc_param = param->second;
		BOOL made_param = NO; made_param;
		CGtype eff_param_type = cgGetParameterType(eff_param);
		if (param==gO3CGEffectGlobals.end()) {
			made_param = YES;
			oc_param = [(O3CGParameter*)[O3CGParameter alloc] initWithType:eff_param_type];
			param->second = oc_param;
		}
		CGparameter global_param = [oc_param rawParameter];
		#ifdef O3DEBUG
		const char* eff_tname = cgGetTypeString(eff_param_type); eff_tname;
		const char* glob_tname = cgGetTypeString(cgGetParameterType(global_param)); glob_tname;
		#endif
		cgConnectParameter(global_param, eff_param);
	} while (eff_param = cgGetNextParameter(eff_param));
}

inline O3CGTechnique* mPrincipalTechniqueP(O3CGEffect* self) {
	if (self->mPrincipalTechnique) return self->mPrincipalTechnique;
	CGtechnique tech = cgGetFirstTechnique(self->mEffect);
	do {
		bool valid = cgIsTechniqueValidated(tech);
		if (!valid) valid = cgValidateTechnique(tech)?YES:NO;
		if (valid) {
			NSString* name = [NSString stringWithUTF8String:cgGetTechniqueName(tech)];
			self->mPrincipalTechnique = [self techniqueNamed:name];
			return self->mPrincipalTechnique;
		}
	} while (tech = cgGetNextTechnique(tech));
	O3LogWarn(@"No valid technique found for effect \"%s\"", cgGetEffectName(self->mEffect));
	return nil;
}

inline set<CGparameter>* mTextureParamsP(O3CGEffect* self) {
	O3AssertIvar(self->mEffect);
	if (self->mTextureParams) return self->mTextureParams;
	self->mTextureParams = new set<CGparameter>();
	CGparameter param = cgGetFirstEffectParameter(self->mEffect);
	do {
		if (cgGetParameterClass(param)==CG_PARAMETERCLASS_SAMPLER) {
			self->mTextureParams->insert(param);
		}
	} while (param = cgGetNextParameter(param));
	return self->mTextureParams;
}

/************************************/ #pragma mark Initialization /************************************/
- (id)init {
	[self release];
	O3LogWarn(@"[O3CGEffect init] is invalid. Use initWithSoutce.");
	return nil;
}

- (id)initWithSource:(NSString*)source {
	O3SuperInitOrDie();
	[self setSource:source];
	if (!cgIsEffect(mEffect)) {
		[self release];
		return nil;
	}
	return self;
}

- (void)dealloc {
	if (mEffect) cgDestroyEffect(mEffect);
	if (mAutoSetParameters) delete mAutoSetParameters;
	if (mTextureParams) delete mTextureParams;
	[self purgeCaches];
	[mSource release];
	[super dealloc];
}

- (void)purgeCaches {
	O3Destroy(mAnnotations);
	O3Destroy(mTechniques);
	O3Destroy(mParameters);
}

- (id)initWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding]) {
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
		[self release];
		return nil;
	}
	NSString* src = [coder decodeObjectForKey:@"source"];
	if (!src) {
		O3LogWarn(@"O3CGEffect could not be created becaule there was no source key in archive");
		[self release];
		return nil;
	}
	return [self initWithSource:src];
}

- (void)encodeWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding])
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
	[coder encodeObject:mSource forKey:@"source"];
}

- (NSString*)source {
	return mSource;
}

- (void)setSource:(NSString*)source {
	const char* src = NSStringUTF8String(source);
	CGeffect newEffect = cgCreateEffect(O3GlobalCGContext(), src, gDefaultCGEffectCompilerArguments);
	if (!cgIsEffect(newEffect)) {
		O3LogWarn(@"Cg effect (re-)creation failed with error \"%s\"", cgGetLastListing(O3GlobalCGContext()));
		return;
	}
	O3Assign(source, mSource);
	O3CGEffect_autoDetectAutoSetParameters(self, newEffect);
	O3CGEffect_setEffectP(self, newEffect);	
	mConnectGlobalParamsP(self);
}



/************************************/ #pragma mark Annotations /************************************/
- (NSArray*)annotationNames {
	NSMutableArray* to_return = [NSMutableArray array];
	CGannotation anno = cgGetFirstEffectAnnotation(mEffect);
	do {
		[to_return addObject:[NSString stringWithUTF8String:cgGetAnnotationName(anno)]];
	} while (anno = cgGetNextAnnotation(anno));
	return to_return;
}

- (O3CGAnnotation*)annotationNamed:(NSString*)key {
	O3CGAnnotation* cga = [mAnnotations objectForKey:key];
	if (cga) return cga;
	CGannotation anno = cgGetNamedEffectAnnotation(mEffect, [key UTF8String]);
	if (!anno) return nil;
	cga = [[[O3CGAnnotation alloc] initWithAnnotation:anno] autorelease];
	if (!mAnnotations) mAnnotations = [[NSMutableDictionary alloc] init];
	[mAnnotations setObject:cga forKey:key];
	return cga;
}


/************************************/ #pragma mark Parameters /************************************/
- (NSDictionary*)paramValues {
	NSArray* keys = [self paramNames];
	UIntP ct = [keys count];
	NSMutableDictionary* md = [[NSMutableDictionary alloc] init];
	for (UIntP i=0; i<ct; i++) {
		NSString* str = [keys objectAtIndex:i];
		[md setObject:[[self param:str] value] forKey:str];
	}
	return [md autorelease];
}

- (id)valueForParam:(NSString*)pname {
	return [[self param:pname] value];
}

- (void)setValue:(id)val forParam:(NSString*)pname {
	[[self param:pname] setValue:val];
}

- (O3CGParameter*)param:(NSString*)pname {
	O3CGParameter* cp = [mParameters objectForKey:pname];
	if (cp) return cp;
	if (!mParameters) mParameters = [[NSMutableDictionary alloc] init];
	CGparameter prm = cgGetNamedEffectParameter(mEffect, [pname UTF8String]);
	cp = [[[O3CGParameter alloc] initWithParam:prm] autorelease];
	[mParameters setObject:cp forKey:pname];
	return cp;
}

- (NSArray*)paramNames {
	NSMutableArray* to_return = [NSMutableArray array];
	CGparameter parm = cgGetFirstEffectParameter(mEffect);
	do {
		[to_return addObject:[NSString stringWithUTF8String:cgGetParameterName(parm)]];
	} while (parm = cgGetNextParameter(parm));
	return to_return;
}

- (BOOL)paramsAreCGParams {return YES;}



/************************************/ #pragma mark Techniques /************************************/
- (NSArray*)techniqueNames {
	NSMutableArray* to_return = [NSMutableArray array];
	CGtechnique techn = cgGetFirstTechnique(mEffect);
	do {
		[to_return addObject:[NSString stringWithUTF8String:cgGetTechniqueName(techn)]];
	} while (techn = cgGetNextTechnique(techn));
	return to_return;	
}

- (O3CGTechnique*)techniqueNamed:(NSString*)key {
	O3CGTechnique* cgt = [mTechniques objectForKey:key];
	if (cgt) return cgt;
	CGtechnique techn = cgGetNamedTechnique(mEffect, [key UTF8String]);
	if (!techn) return nil;
	cgt = [[[O3CGTechnique alloc] initWithTechnique:techn fromEffect:self] autorelease];
	if (!mTechniques) mTechniques = [[NSMutableDictionary alloc] init];
	[mTechniques setObject:cgt forKey:key];
	return cgt;
}


/************************************/ #pragma mark Use /************************************/
- (void)beginRendering {
	[mPrincipalTechniqueP(self) beginRendering];
}

- (int)renderPasses {
	return [mPrincipalTechniqueP(self) renderPasses];
}

- (void)setRenderPass:(int)passnum {
	if (!gO3CGEffectsEnabled) return;
	O3AssertIvar(mRenderingBegun);
	[mPrincipalTechniqueP(self) setRenderPass:passnum];
}

- (void)endRendering {
	[mPrincipalTechniqueP(self) endRendering];
}

- (O3Material*)newMaterial {
	return [mPrincipalTechniqueP(self) newMaterial];
}

/************************************/ #pragma mark Class /************************************/
+ (BOOL)effectsEnabled {
	return gO3CGEffectsEnabled;
}

///@todo make enable/disable currently bound effects
///@note Defaults to YES (enabled)
+ (NSError*)setEffectsEnabled:(BOOL)enabled {
	gO3CGEffectsEnabled = enabled;
	return nil;
}

+ (O3CGParameter*)globalNamed:(NSString*)gpname {
	string name = NSStringUTF8String(gpname);
	ParameterMap::iterator param = gO3CGEffectGlobals.find(name);
	if (param==gO3CGEffectGlobals.end()) return nil;
	return param->second;
}

+ (void)setGlobalValue:(id)val forKey:(NSString*)k {
	string name = NSStringUTF8String(k);
	ParameterMap::iterator param = gO3CGEffectGlobals.find(name);
	if (param==gO3CGEffectGlobals.end()) {
		O3AssertArg(NO, @"Key \"%@\" (to be set to \"%@\") does not exist in the global effect parameter repository.", k, val);
		return;
	}
	[param->second setValue:val];	
}

///Adds a new key of name k and type t, if a global param by this name already exists it is left alone and no error is raised as long as the types are the same
+ (O3CGParameter*)createGlobalOfType:(CGtype)t forKey:(NSString*)k {
	O3Asrt(k);
	string name = NSStringUTF8String(k);
	ParameterMap::iterator param = gO3CGEffectGlobals.find(name);
	if (param==gO3CGEffectGlobals.end()) {
		O3CGParameter* nparam = [(O3CGParameter*)[O3CGParameter alloc] initWithType:t];
		gO3CGEffectGlobals[name] = nparam;
		return nparam;
	} else {
		CGtype ot = cgGetParameterType([param->second rawParameter]); ot;
		O3Assert(ot==t, @"A key of name \"%@\" already exists, but it has a different type (%s instead of %s)", k, cgGetTypeString(ot), cgGetTypeString(t));
		return param->second;
	}
}


@end


@implementation O3CGEffect (TechniquePrivateCallbacks)

- (void)beginTechniqueRendering {
	if (!gO3CGEffectsEnabled) return;
	set<CGparameter>::iterator it = mTextureParamsP(self)->begin();
	set<CGparameter>::iterator end = mTextureParamsP(self)->end();
	for (; it!=end; it++) {
		CGparameter effect_param = *it;
		int j = cgGetNumConnectedToParameters(effect_param);
		//GLuint texid = cgGLGetTextureParameter(effect_param);
		
		int i; for (i=0;i<j;i++) {
			CGparameter prog_param = cgGetConnectedToParameter(effect_param,i);
			cgGLEnableTextureParameter(prog_param);
			CGerror err = cgGetError();
			if (err) O3LogWarn(@"Error setting up sampler %s", cgGetParameterName(prog_param));
		}
		cgSetSamplerState(effect_param);
	}
	O3CGEffect_setAutoSetParameters(self);
	mRenderingBegun = YES;
}

- (void)endTechniqueRendering {
	if (!gO3CGEffectsEnabled) return;
	if (!mRenderingBegun) return;
	mRenderingBegun = NO;
	set<CGparameter>::iterator it = mTextureParams->begin();
	set<CGparameter>::iterator end = mTextureParams->end();
	CGparameter effect_param;
	for (; it!=end; it++) {
		effect_param = *it;
		int j = cgGetNumConnectedToParameters(effect_param);
		int i; for (i=0;i<j;i++) {
			CGparameter prog_param = cgGetConnectedToParameter(effect_param,i);
			cgGLDisableTextureParameter(prog_param);
		}
	}
}

@end
