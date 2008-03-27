/**
 *  @file O3CGParameter.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 2/20/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3CGParameter.h"
#import "O3KVCHelper.h"
#import "O3CGAnnotation.h"
#import "O3CGParameterSupport.h"
#import <Cg/cg.h>
#import <Cg/cgGL.h>

//#define O3CGPARAMETER_FILL_ANNO_CACHE_AT_ONCE
typedef map<string, O3CGAnnotation*> AnnotationMap;

@implementation O3CGParameter

+ (void)initialize {
	O3Init();
	[self exposeBinding:@"value"];
}

- (id)init {
	[self release];
	O3Assert(false , @"O3CGParameter cannot be default initialized!");
	return nil;
}

- (void)dealloc {
	O3Destroy(mSubParams);
	O3Destroy(mAnnotations);
	if (mParam) O3CGParameterUnbindValue(self);
	if (mFreeParamWhenDone) cgDestroyParameter(mParam);
	O3SuperDealloc();
}

- (id)initWithType:(CGtype)type {
	O3SuperInitOrDie();
	mParam = cgCreateParameter(O3GlobalCGContext(), type);
	mFreeParamWhenDone = YES;
	return self;
}

- (id)initWithType:(CGtype)type count:(int)array_size {
	O3SuperInitOrDie();
	mParam = cgCreateParameterArray(O3GlobalCGContext(), type, array_size);
	mFreeParamWhenDone = YES;
	return self;
}

- (id)initWithType:(CGtype)type dimensions:(int*)array_size dimensionCount:(unsigned)dim_count {
	O3SuperInitOrDie();
	mParam = cgCreateParameterMultiDimArray(O3GlobalCGContext(), type, dim_count, array_size);
	mFreeParamWhenDone = YES;
	return self;
}

- (id)initWithParam:(CGparameter)param {
	if (!param) {
		[self release];
		return nil;
	}
	O3SuperInitOrDie();
	mParam = param;
	//mFreeParamWhenDone = NO;
	return self;
}

- (id)initWithTypeFromParam:(CGparameter)param {
	O3SuperInitOrDie();
	CGtype otype = cgGetParameterNamedType(param);
	if (otype==CG_ARRAY) {
		CGtype base_type = cgGetArrayType(param);
		int dims = cgGetArrayDimension(param);
		if (dims==1) self = [self initWithType:base_type count:cgGetArraySize(param, 0)];
		else {
			int* dim_arr = (int*)malloc(sizeof(int)*dims);
			for (int i=0; i<dims; i++) dim_arr[i] = cgGetArraySize(param, i);
			self = [self initWithType:base_type dimensions:dim_arr dimensionCount:dims];
			free(dim_arr);
		}
	} else {
		self = [self initWithType:otype];
	}
	return self;
}

- (id)initByCopying:(O3CGParameter*)other {
	if (![self initWithTypeFromParam:[other rawParameter]]) return nil;
	O3Assign([other name], mName);
	[self setValue:[other value]];
	return self;
}

/************************************/ #pragma mark Mutators /************************************/
- (void)setIntValue:(int)val {
	O3Assert(cgGetParameterClass(mParam)==CG_PARAMETERCLASS_SCALAR, @"Cannot setIntValue to %i of non-scalar parameter \"%@\".", val, [self name]);
	cgSetParameter1i(mParam, val);
}

- (void)setIntArrayValue:(int*)val count:(unsigned)count {
	cgSetParameterValueic(mParam, count, val);
}

- (void)setIntMatrixValue:(int*)val rows:(unsigned)rows columns:(unsigned)cols {
	cgSetParameterValueic(mParam, rows*cols, val);	
}

- (void)setIntMatrixValue:(int*)val rows:(unsigned)rows columns:(unsigned)cols rowMajor:(BOOL)rowMajor {
	if (rowMajor) cgSetParameterValueir(mParam, rows*cols, val);	
	else          cgSetParameterValueic(mParam, rows*cols, val);	
}


- (void)setFloatValue:(float)val {
	O3Assert(cgGetParameterClass(mParam)==CG_PARAMETERCLASS_SCALAR, @"Cannot setFloatValue to %f of non-scalar parameter \"%@\".", val, [self name]);
	cgSetParameter1f(mParam, val);	
}

- (void)setFloatArrayValue:(const float*)val count:(unsigned)count {
	cgSetParameterValuefc(mParam, count, val);
}

- (void)setFloatMatrixValue:(const float*)val rows:(unsigned)rows columns:(unsigned)cols {
	cgSetParameterValuefc(mParam, rows*cols, val);	
}

- (void)setFloatMatrixValue:(const float*)val rows:(unsigned)rows columns:(unsigned)cols rowMajor:(BOOL)rowMajor {
	if (rowMajor) cgSetParameterValuefr(mParam, rows*cols, val);	
	else          cgSetParameterValuefc(mParam, rows*cols, val);	
}


- (void)setDoubleValue:(double)val {
	O3Assert(cgGetParameterClass(mParam)==CG_PARAMETERCLASS_SCALAR, @"Cannot setDoubleValue to %f of non-scalar parameter \"%@\".", val, [self name]);
	cgSetParameter1d(mParam, val);
}

- (void)setDoubleArrayValue:(const double*)val count:(unsigned)count {
	cgSetParameterValuedc(mParam, count, val);		
}

- (void)setDoubleMatrixValue:(const double*)val rows:(unsigned)rows columns:(unsigned)cols {
	cgSetParameterValuedc(mParam, rows*cols, val);		
}

- (void)setDoubleMatrixValue:(const double*)val rows:(unsigned)rows columns:(unsigned)cols rowMajor:(BOOL)rowMajor {
	if (rowMajor) cgSetParameterValuedr(mParam, rows*cols, val);	
	else          cgSetParameterValuedc(mParam, rows*cols, val);	
	
}

- (void)setValue:(id)newValue {
	O3SetCGParameterToValue(mParam, newValue, O3GlobalCGContext());
}

/************************************/ #pragma mark Thin Wrapper Management /************************************/
- (BOOL)freeWhenDone {
	return mFreeParamWhenDone;
}

- (void)setFreeWhenDone:(BOOL)newOwns {
	mFreeParamWhenDone = newOwns;
}

/************************************/ #pragma mark Inspectors /************************************/
- (NSString*)name {
	return mName ?: [NSString stringWithCString:cgGetParameterName(mParam)];
}

///@warn Does not turn off freeWhenDone if it is on, you must do that manually if you want to customize the behavior.
- (CGparameter)rawParameter {
	return mParam;
}

- (CGtype)type {
	return cgGetParameterType(mParam);
}

- (id)value {
	return O3GetCGParameterValue(mParam);
}

- (int)intValue {
	int to_return;
	cgGetParameterValueir(mParam, 1, &to_return);
	return to_return;
}

- (float)floatValue {
	float to_return;
	cgGetParameterValuefr(mParam, 1, &to_return);
	return to_return;	
}

- (double)doubleValue {
	double to_return;
	cgGetParameterValuedr(mParam, 1, &to_return);
	return to_return;	
}

- (NSString*)stringValue {
	return [[self value] stringValue];
}

- (O3CGParameter*)structField:(NSString*)name {
	O3CGParameter* cval = [mSubParams objectForKey:name];
	if (cval) return cval;
	CGparameter member = cgGetNamedStructParameter(mParam, NSStringUTF8String(name));
	cval = [[O3CGParameter alloc] initWithParam:member];
	if (!mSubParams) mSubParams = [[[NSMutableDictionary alloc] init] autorelease];
	if (cval) [mSubParams setObject:cval forKey:name];
	return cval;
}

- (id)valueForKey:(NSString*)key {
	return [self structField:key];
}

/************************************/ #pragma mark Annotations /************************************/
- (NSArray*)annotationNames {
	NSMutableArray* to_return = [NSMutableArray array];
	CGannotation anno = cgGetFirstParameterAnnotation(mParam);
	do {
		[to_return addObject:[NSString stringWithUTF8String:cgGetAnnotationName(anno)]];
	} while (anno = cgGetNextAnnotation(anno));
	return to_return;
}

- (O3CGAnnotation*)annotationNamed:(NSString*)key {
	O3CGAnnotation* an = [mAnnotations objectForKey:key];
	if (an) return an;
	if (!mAnnotations) mAnnotations = [[NSMutableDictionary alloc] init];
	CGannotation anno = cgGetNamedParameterAnnotation(mParam, [key UTF8String]);
	if (!anno) return nil;
	an = [[O3CGAnnotation alloc] initWithAnnotation:anno];
	[mAnnotations setObject:an forKey:key];
	return [an autorelease];
}

///@note To get Cg acceleration, \e binding and \e keyPath must be @"value" (it is best but not necessary that the constant string is used) and options must be null. Otherwise plain Objective C bindings are used.
///@note \eto is the destination and \e from is the place the value is gotten from. The ordering is to maintain consistency with KVB (PLS).
O3EXTERN_C void O3CGParameterBindValueFrom_to_(O3CGParameter* from, O3CGParameter* to) {
	#ifdef O3DEBUG
	static Class O3CGParameter_class = nil;
		if (!O3CGParameter_class) O3CGParameter_class = [O3CGParameter class];
	O3AssertArg(from->isa == O3CGParameter_class, @"O3CGParameterBindValue_to_ cannot be called with from as an object of class \"%@\"", [from className]);
	O3AssertArg(to->isa == O3CGParameter_class, @"O3CGParameterBindValue_to_ cannot be called with to as an object of class \"%@\"", [from className]);
	#endif
	cgConnectParameter(from->mParam, to->mParam);
}

///@note To get Cg acceleration, \e binding and \e keyPath must be @"value" and options must be null. Otherwise plain Objective C bindings are used.
- (void)bind:(NSString *)binding toObject:(id)observableController withKeyPath:(NSString *)keyPath options:(NSDictionary *)options {
	BOOL thisKeyIsValue = (binding==@"value")? YES : [binding isEqualToString:@"value"];
	BOOL thatKeyIsValue = (keyPath==@"value")? YES : [keyPath isEqualToString:@"value"];
	BOOL isPlainValueValueBinding = thisKeyIsValue & thatKeyIsValue & !options;
	static Class O3CGParameter_class = nil;
		if (!O3CGParameter_class) O3CGParameter_class = [O3CGParameter class];
	BOOL isCGValueValueBinding = isPlainValueValueBinding & (observableController->isa == O3CGParameter_class);
	
	if (isCGValueValueBinding) {
		cgConnectParameter(((O3CGParameter*)observableController)->mParam, self->mParam);
		return;
	}
	
	//We cannot use accelerated Cg binding if we are binding a key other than value or we are doing a special binding or the target isn't another O3CGParameter	
	if (options && thisKeyIsValue)
		O3LogInfo(@"Calling [O3CGParameter bind:@\"value\" toObject:withKeyPath:options:] with non-nil options will be much slower than with nil options (options force it to use the ObjC rather than Cg runtime).");
	if ((thisKeyIsValue && binding!=@"value") || (thatKeyIsValue && keyPath!=@"value"))
		O3LogInfo(@"Calling [O3CGParameter bind:x toObject:withKeyPath:x options:] with non constant x strings is slower than it would otherwise be.");
	[super bind:binding toObject:observableController withKeyPath:keyPath options:options];
}

- (void)unbind:(NSString*)binding {
	BOOL bindingIsValue = (binding==@"value")? YES : [binding isEqualToString:@"value"];
	if (bindingIsValue)
		if (O3CGParameterUnbindValue(self)) return;
	[super unbind:binding];
}

///@returns YES if there was a value to unbind (that was unbound, but this shouldn't fail), NO if there wasn't.
O3EXTERN_C BOOL O3CGParameterUnbindValue(O3CGParameter* self) {
	if (cgGetConnectedParameter(self->mParam)) {
		cgDisconnectParameter(self->mParam);
		return YES;
	}
	return NO;
}


@end
