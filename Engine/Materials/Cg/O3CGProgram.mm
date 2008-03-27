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
const char**	gCGDefaultCompilerArguments;
BOOL gO3ShadersEnabled = YES; ///<Weather or not shaders are enabled. Don't access directly, use [[O3CGProgram class] shadersEnabled]. Does not affect O3Effect or other shading classes. Defaults to YES.


@implementation O3CGProgram
O3DefaultO3InitializeImplementation

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

NSMutableDictionary* mParametersP(O3CGProgram* self) {
	if (self->mParameters) return self->mParameters;
	NSMutableDictionary* mdct = [[NSMutableDictionary alloc] init];
	O3Assign(mdct, self->mParameters);
	[mdct release];
	return self->mParameters;
}

NSMutableDictionary* mAnnotationsP(O3CGProgram* self) {
	if (self->mAnnotations) return self->mAnnotations;
	NSMutableDictionary* mdct = [[NSMutableDictionary alloc] init];
	O3Assign(mdct, self->mAnnotations);
	[mdct release];
	return self->mAnnotations;
}


/************************************/ #pragma mark Initialization /************************************/
///Instance initialization
inline void initP(O3CGProgram* self) {
	self->mAutoSetParameters = new vector<O3CGAutoSetParameter>();
}

- (void)dealloc {
	cgDestroyProgram(mProgram);
	[mUnusedSource release];
	[mParameters release];
	[mAnnotations release];
	[super dealloc];
}

- (id)init {
	[self release];
	return nil;
}

- (id)initWithSource:(NSString*)source entryFunction:(NSString*)entryPoint profile:(CGprofile)profile {
	O3SuperInitOrDie();
	initP(self);
	
	if (!cgGLIsProfileSupported(profile)) {
		O3LogWarn(@"Unsupported profile %s", cgGetProfileString(profile));
		[self release];
		return nil;
	}	
	mProgram = cgCreateProgram(O3GlobalCGContext(), CG_SOURCE, [source UTF8String], profile, NSStringUTF8String(entryPoint), gCGDefaultCompilerArguments);
	autoDetectAutoSetParametersP(self);
	
	return self;
}

- (id)initWithPrecompiledData:(NSData*)data entryFunction:(NSString*)entryPoint profile:(CGprofile)profile {
	O3SuperInitOrDie();
	initP(self);
	if (!cgGLIsProfileSupported(profile)) {
		O3LogWarn(@"Unsupported profile %s", cgGetProfileString(profile));
		[self release];
		return nil;
	}
	mProgram = cgCreateProgram(O3GlobalCGContext(), CG_OBJECT, (char*)[data bytes], profile, (char*)[data bytes], gCGDefaultCompilerArguments);
	autoDetectAutoSetParametersP(self);
	return self;
}

- (id)initWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding]) {
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
		[self release];
		return nil;
	}
	NSData* dat = [coder decodeObjectForKey:@"compiledData"];
	NSString* src = [coder decodeObjectForKey:@"source"];
	NSString* profileName = [coder decodeObjectForKey:@"profile"];
	NSString* entryPoint = [coder decodeObjectForKey:@"entryPoint"];
	if (!profileName || !entryPoint) goto die;
	if (dat) {
		O3Assign(src,mUnusedSource);
		return [self initWithPrecompiledData:dat entryFunction:entryPoint profile:cgGetProfile(NSStringUTF8String(profileName))];
	}
	if (src) return [self initWithSource:src entryFunction:entryPoint profile:cgGetProfile(NSStringUTF8String(profileName))];
	
	die:
	O3LogWarn(@"Could not init coder due to missing keys");
	[self release];
	return nil;
}

- (void)encodeWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding])
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
	[coder encodeObject:[self profileName] forKey:@"profile"];
	[coder encodeObject:[self entryFunction] forKey:@"entryPoint"];
	NSString* src = [self source] ?: mUnusedSource;
	NSData* dat = [self compiledData];
	if (src) [coder encodeObject:src forKey:@"source"];
	if (dat) [coder encodeObject:dat forKey:@"compiledData"];
}

/************************************/ #pragma mark Accessors /************************************/
- (NSString*)entryFunction {
	return [NSString stringWithUTF8String:cgGetProgramString(mProgram, CG_PROGRAM_ENTRY)];
}

- (CGprofile)profile {
	O3AssertIvar(mProgram);
	return cgGetProgramProfile(mProgram);
}

- (void)setProfile:(CGprofile)profile {
	O3AssertIvar(mProgram);
	if (!cgGLIsProfileSupported(profile))
		O3LogWarn(@"Unsupported profile %s", cgGetProfileString(profile));
	else
		cgSetProgramProfile(mProgram, profile);
}

- (NSString*)profileName {
	return [NSString stringWithUTF8String:cgGetProfileString([self profile])];
}

- (void)setProfileName:(NSString*)newName {
	[self setProfile:cgGetProfile([newName UTF8String])];
}

- (NSString*)source {
	O3AssertIvar(mProgram);
	const char* source = cgGetProgramString(mProgram, CG_PROGRAM_SOURCE);
	if (!source) return nil;
	return [[[NSString alloc] initWithBytes:source length:strlen(source) encoding:NSASCIIStringEncoding] autorelease];
}

- (NSData*)compiledData {
	O3AssertIvar(mProgram);
	const char* object = cgGetProgramString(mProgram, CG_COMPILED_PROGRAM);
	if (!object) return nil;
	return [[[NSData alloc] initWithBytes:object length:strlen(object)] autorelease];
}

- (BOOL)needsCompiling {
	O3AssertIvar(mProgram);
	return !cgIsProgramCompiled(mProgram);
}



/************************************/ #pragma mark Annotations /************************************/
- (NSArray*)annotationNames {
	NSMutableArray* to_return = [NSMutableArray array];
	CGannotation anno = cgGetFirstProgramAnnotation(mProgram);
	do {
		[to_return addObject:[NSString stringWithUTF8String:cgGetAnnotationName(anno)]];
	} while (anno = cgGetNextAnnotation(anno));
	return to_return;
}

- (O3CGAnnotation*)annotation:(NSString*)key {
	O3CGAnnotation* cga = [mAnnotationsP(self) objectForKey:key];
	if (cga) return cga;
	cga = [[[O3CGAnnotation alloc] initWithAnnotation:cgGetNamedProgramAnnotation(mProgram, [key UTF8String])] autorelease];
	[mAnnotationsP(self) setObject:cga forKey:key];
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
	O3CGParameter* cp = [mParametersP(self) objectForKey:pname];
	if (cp) return cp;
	CGparameter prm = cgGetNamedParameter(mProgram, [pname UTF8String]);
	cp = [[[O3CGParameter alloc] initWithParam:prm] autorelease];
	[mParametersP(self) setObject:cp forKey:pname];
	return cp;
}

- (NSArray*)paramNames {
	NSMutableArray* to_return = [NSMutableArray array];
	CGparameter parm = cgGetFirstParameter(mProgram, CG_PROGRAM);
	do {
		[to_return addObject:[NSString stringWithUTF8String:cgGetParameterName(parm)]];
	} while (parm = cgGetNextParameter(parm));
	parm = cgGetFirstParameter(mProgram, CG_GLOBAL);
	do {
		[to_return addObject:[NSString stringWithUTF8String:cgGetParameterName(parm)]];
	} while (parm = cgGetNextParameter(parm));
	return to_return;
}

- (BOOL)paramsAreCGParams {return YES;}


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
	O3Destroy(mAnnotations);
	O3Destroy(mParameters);
}


/************************************/ #pragma mark Class Methods /************************************/
+ (BOOL)compiledLazily {
	return cgGetAutoCompile(O3GlobalCGContext())==CG_COMPILE_LAZY;
}

+ (BOOL)compiledAutomatically {
	return cgGetAutoCompile(O3GlobalCGContext())!=CG_COMPILE_MANUAL;
}

+ (void)setCompiledLazily:(BOOL)lazy {
	cgSetAutoCompile(O3GlobalCGContext(), (lazy)? CG_COMPILE_LAZY : CG_COMPILE_IMMEDIATE);
}

+ (void)setCompiledAutomatically:(BOOL)compiledAutomatically {
	CGenum to_set = (compiledAutomatically)? CG_COMPILE_LAZY : CG_COMPILE_IMMEDIATE;
	if (compiledAutomatically) 
		if (cgGetAutoCompile(O3GlobalCGContext())==CG_COMPILE_IMMEDIATE) 
			to_set = CG_COMPILE_IMMEDIATE;
	cgSetAutoCompile(O3GlobalCGContext(), to_set);
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
