/**
 *  @file O3CGProgram.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 1/6/07.
 *  @author Jonathan deWerd
 *  @todo Add error handling to CG variable setting
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3CGProgram.h"
#import "O3Texture.h"
#import "O3CGParameterSupport.h"
#import "O3CGParameter.h"
#import "O3CGAnnotation.h"
#import "O3KVCHelper.h"
using namespace std;

///Fill the parameter map the first time it is accessed rather than incrementally
//#define O3CGPROGRAM_FILL_PARAM_CACHE_AT_ONCE
///Fill the annotation map the first time it is accessed rather than incrementally
//#define O3CGPROGRAM_FILL_ANNO_CACHE_AT_ONCE

typedef map<string, O3CGParameter*> ParameterMap;
typedef map<string, O3CGAnnotation*> AnnotationMap;

const unsigned 	O3CGActionUndoableWhenPrecompiledError = 1;
CGcontext 		gCGContext;
const char**	gCGDefaultCompilerArguments;
BOOL gO3ShadersEnabled = YES; ///<Weather or not shaders are enabled. Don't access directly, use [[O3CGProgram class] shadersEnabled]. Does not affect O3Effect or other shading classes. Defaults to YES.


void O3CGProgram_cgErrorCallback() {
	O3CLogError(@"Cg error: %s\n", cgGetErrorString(cgGetError()));
}


@implementation O3CGProgram
inline void initializeP() {
	static bool shading_initialized = NO; //Make sure we are run once
	if (shading_initialized) return;
	shading_initialized = YES;
	
	//O3CGProgram_FlushParameterCache(self);
	gCGContext = cgCreateContext();
	cgGLSetManageTextureParameters(gCGContext, CG_TRUE);
	cgSetErrorCallback(O3CGProgram_cgErrorCallback);
	cgGLRegisterStates(gCGContext);
	cgGLSetOptimalOptions(CG_PROFILE_ARBVP1);
    cgGLSetOptimalOptions(CG_PROFILE_ARBFP1);
}

CGcontext O3GlobalCGContext() {
	initializeP();
	return gCGContext;
}

void O3CGProgram_setAutoSetParameters(O3CGProgram* self) {
	if (!self->mAutoSetParameters) return;
	vector<O3CGAutoSetParameter>::iterator it;
	for (it=self->mAutoSetParameters->begin();it!=self->mAutoSetParameters->end();++it)
		cgGLSetStateMatrixParameter((*it).param, (*it).matrix, (*it).transform);
}

void autoDetectAutoSetParametersP(O3CGProgram* self) {
	typedef struct {string name; CGGLenum matrix; CGGLenum transform;} O3CGProgramAutoSetTemplate;
	int i; for (i=0;i<gNumCGAutoSetParamaterTemplates;i++) {
		CGparameter param;
		if (param = cgGetNamedParameter(self->mProgram, gCGAutoSetParamaterTemplates[i].name)) {
			O3CGAutoSetParameter newAutoSetter = {param, gCGAutoSetParamaterTemplates[i].matrix, gCGAutoSetParamaterTemplates[i].transform};
			self->mAutoSetParameters->push_back(newAutoSetter);
		}
	}
}

ParameterMap* mParametersP(O3CGProgram* self) {
	if (self->mParameters) return self->mParameters;
	self->mParameters = new ParameterMap();
	#ifdef O3CGPROGRAM_FILL_PARAM_CACHE_AT_ONCE
	CGparameter parameter = cgGetFirstParameter(self->mProgram);
	do {
		string name = cgGetParameterName(parameter);
		O3CGParameter* newParam = [[O3CGParameter alloc] initWithParameter:parameter];
		(*self->mParameters)[name] = newParam;
	} while (parameter = cgGetNextParameter(parameter));
	#endif
	return self->mParameters;
}

AnnotationMap*	mAnnotationsP(O3CGProgram* self) {
	if (self->mAnnotations) return self->mAnnotations;
	self->mAnnotations = new AnnotationMap();
	#ifdef O3CGPROGRAM_FILL_ANNO_CACHE_AT_ONCE
	CGannotation anno = cgGetFirstProgramAnnotation(self->mProgram);
	do {
		string name = cgGetAnnotationName(anno);
		O3CGAnnotation* newAnno = [[O3CGAnnotation alloc] initWithAnnotation:anno];
		(*self->mAnnotations)[name] = newAnno;
	} while (anno = cgGetNextAnnotation(anno));
	#endif
	return self->mAnnotations;
}


/************************************/ #pragma mark Initialization /************************************/
///Instance initialization
inline void initP(O3CGProgram* self) {
	initializeP();
	self->mAutoSetParameters = new vector<O3CGAutoSetParameter>();
}

- (void)dealloc {
	cgDestroyProgram(mProgram);
	[super dealloc];
}

- (id)init {
	[self release];
	return nil;
}

- (id)initWithSource:(NSString*)source entryFunction:(NSString*)entryPoint type:(CGprofile)profile {
	O3SuperInitOrDie();
	initP(self);
	
	mProgram = cgCreateProgram(gCGContext, CG_SOURCE, [source UTF8String], profile, NSString_cString(entryPoint), gCGDefaultCompilerArguments);
	autoDetectAutoSetParametersP(self);
	
	return self;
}

- (id)initWithPrecompiledData:(NSData*)data entryFunction:(NSString*)entryPoint type:(CGprofile)profile {
	O3SuperInitOrDie();
	initP(self);
	
	mProgram = cgCreateProgram(gCGContext, CG_OBJECT, (char*)[data bytes], profile, (char*)[data bytes], gCGDefaultCompilerArguments);
	autoDetectAutoSetParametersP(self);
	
	return self;
}

/************************************/ #pragma mark Accessors /************************************/
- (NSString*)entryFunction {
	return [NSString stringWithUTF8String:cgGetProgramString(mProgram, CG_PROGRAM_ENTRY)];
}

- (CGprofile)type {
	O3AssertIvar(mProgram);
	return cgGetProgramProfile(mProgram);
}

- (NSString*)source {
	O3AssertIvar(mProgram);
	const char* source = cgGetProgramString(mProgram, CG_PROGRAM_SOURCE);
	return [[[NSString alloc] initWithBytes:source length:strlen(source) encoding:NSASCIIStringEncoding] autorelease];
}

- (NSData*)compiledData {
	O3AssertIvar(mProgram);
	const char* object = cgGetProgramString(mProgram, CG_COMPILED_PROGRAM);
	return [[[NSData alloc] initWithBytes:object length:strlen(object)] autorelease];
}

- (BOOL)needsCompiling {
	O3AssertIvar(mProgram);
	return !cgIsProgramCompiled(mProgram);
}

- (void)setType:(CGprofile)profile {
	O3AssertIvar(mProgram);
	cgSetProgramProfile(mProgram, profile);
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
	CGannotation anno = cgGetFirstProgramAnnotation(mProgram);
	do {
		[to_return addObject:[NSString stringWithUTF8String:cgGetAnnotationName(anno)]];
	} while (anno = cgGetNextAnnotation(anno));
	return to_return;
}

- (O3CGAnnotation*)annotationNamed:(NSString*)key {
	AnnotationMap* annos = mAnnotationsP(self);
	string name = NSString_cString(key);
	AnnotationMap::iterator anno_loc = annos->find(name);
	O3CGAnnotation* to_return = anno_loc->second;
	if (anno_loc==annos->end()) {
		CGannotation anno = cgGetNamedProgramAnnotation(mProgram, name.c_str());
		if (!anno) return nil;
		(*annos)[name] = to_return = [[O3CGAnnotation alloc] initWithAnnotation:anno];
	}
	return to_return;
}



/************************************/ #pragma mark Parameters /************************************/
- (id)parameters {
	if (!mParameterKVCHelper) mParameterKVCHelper = [[O3KVCHelper alloc] initWithTarget:self
                                                                      valueForKeyMethod:@selector(parameterNamed:)
                                                                   setValueForKeyMethod:@selector(setParameterValue:forKey:)
                                                                         listKeysMethod:@selector(parameterKeys)];
	return mParameterKVCHelper;	
}

- (NSArray*)parameterKeys {
	NSMutableArray* to_return = [NSMutableArray array];
	CGparameter param = cgGetFirstParameter(mProgram, CG_GLOBAL);
	do {
		[to_return addObject:[NSString stringWithUTF8String:cgGetParameterName(param)]];
	} while (param = cgGetNextParameter(param));
	param = cgGetFirstParameter(mProgram, CG_PROGRAM);
	do {
		[to_return addObject:[NSString stringWithUTF8String:cgGetParameterName(param)]];
	} while (param = cgGetNextParameter(param));
	return to_return;	
}

- (O3CGParameter*)parameterNamed:(NSString*)key {
	ParameterMap* params = mParametersP(self);
	string name = NSString_cString(key);
	ParameterMap::iterator param_loc = params->find(name);
	O3CGParameter* to_return = param_loc->second;
	if (param_loc==params->end()) {
		CGparameter param = cgGetNamedParameter(mProgram, name.c_str());
		if (!param) return nil;
		(*params)[name] = to_return = [[O3CGParameter alloc] initWithParameter:param];
	}
	return to_return;
}

- (void)setParameterValue:(NSValue*)value forKey:(NSString*)key {
	O3CGParameter* param = mParametersP(self)->find(NSString_cString(key))->second;
	if (!param) {
		O3ToImplement();
	}
	[param setValue:value];
}


/************************************/ #pragma mark Use /************************************/
- (int)renderPasses {
	return 1;
}

- (void)beginRendering {
	#ifdef O3DEBUG
	mRenderingBegun = YES;
	#endif
}

- (void)setRenderPass:(int)passnum {
	if (!gO3ShadersEnabled) return;
	#ifdef O3DEBUG
	O3AssertIvar(mRenderingBegun);
	#endif
	O3Assert(passnum==0,@"Plain CGPrograms are not multipass (tried to set pass %i)",passnum);
}

- (void)endRendering {
	if (!gO3ShadersEnabled) return;
	#ifdef O3DEBUG
	O3AssertIvar(mRenderingBegun);
	mRenderingBegun = NO;
	#endif
}



/************************************/ #pragma mark Memory management /************************************/
- (void)purgeCaches {
	O3DestroyCppMap(AnnotationMap, mAnnotations);
	O3DestroyCppMap(ParameterMap, mParameters);
}


/************************************/ #pragma mark Class Methods /************************************/
+ (BOOL)compiledLazily {
	 initializeP();
	return cgGetAutoCompile(gCGContext)==CG_COMPILE_LAZY;
}

+ (BOOL)compiledAutomatically {
	 initializeP();
	return cgGetAutoCompile(gCGContext)!=CG_COMPILE_MANUAL;
}

+ (void)setCompiledLazily:(BOOL)lazy {
	 initializeP();	
	cgSetAutoCompile(gCGContext, (lazy)? CG_COMPILE_LAZY : CG_COMPILE_IMMEDIATE);
}

+ (void)setCompiledAutomatically:(BOOL)compiledAutomatically {
	 initializeP();
	CGenum to_set = (compiledAutomatically)? CG_COMPILE_LAZY : CG_COMPILE_IMMEDIATE;
	if (compiledAutomatically) 
		if (cgGetAutoCompile(gCGContext)==CG_COMPILE_IMMEDIATE) 
			to_set = CG_COMPILE_IMMEDIATE;
	cgSetAutoCompile(gCGContext, to_set);
}

///@note Does not enable or disable \e effects, which are usually how shaders are used anyhow. Also does not prevent effects from using shaders.
+ (BOOL)shadersEnabled {
	return gO3ShadersEnabled;
}

///@todo Make it unbind any currently bound shaders
+ (NSError*)setShadersEnabled:(BOOL)enable {
	gO3ShadersEnabled = enable;
	return nil;
}

@end
