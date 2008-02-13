/**
 *  @file O3CGParameterSupport.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 1/13/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3CGParameterSupport.h"
#import "NSValueO3CGShaderAdditions.h"
#import "O3Texture.h"
#import "O3EncodingInterpretation.h"
#import "O32DStructArray.h"
#import "O3ScalarStructType.h"
#import <Cg/cg.h>
#import <Cg/cgGL.h>

void O3SetCGAnnotationToValue(CGannotation anno, id value) {
	O3AssertArg(cgIsAnnotation(anno), @"Annotation argument of O3GetCGAnnotationValue must be a real annotation");
	CGtype anno_type = cgGetAnnotationType(anno);
	int rows, cols; cgGetTypeSizes(anno_type, &rows, &cols); rows;
	O3Asrt(rows==0);
	O3Asrt(cols /*This could be 0 if the annotation has struct/other values in it*/);
	if (cols>1) { //Array
		//CGtype ele_type = cgGetTypeBase(anno_type);
		O3Asrt(false /*Fixme: array annotations aren't supported]*/);
	} else if (cols==1) {
		switch (anno_type) {
			case CG_BOOL:
				cgSetBoolAnnotation(anno, [value boolValue]?CG_TRUE:CG_FALSE);
				return;
			case CG_INT:
				cgSetIntAnnotation(anno, [value intValue]);
				return;
			case CG_FLOAT:
				cgSetFloatAnnotation(anno, [value floatValue]);
				return;
			case CG_STRING:
				cgSetStringAnnotation(anno, NSStringUTF8String([value stringValue]));
				return;
			default:
				O3CLogError(@"Unknown CG type (annotation \"%s\")", cgGetAnnotationName(anno));
				O3Assert(false , @"See error log");
		}		
	} else O3Asrt(false);
}

id O3GetCGAnnotationValue(CGannotation anno) {
	O3AssertArg(cgIsAnnotation(anno), @"Annotation argument of O3GetCGAnnotationValue must be a real annotation");
	CGtype anno_type = cgGetAnnotationType(anno);
	CGparameterclass anno_class = cgGetTypeClass(anno_type);	
	switch (anno_class) {
		case CG_PARAMETERCLASS_SCALAR:
		case CG_PARAMETERCLASS_VECTOR:
		case CG_PARAMETERCLASS_MATRIX: {
			int rows, cols; cgGetTypeSizes(anno_type, &rows, &cols);
			CGtype element_type = (rows==0&&cols==1)? anno_type : cgGetTypeBase(anno_type);
			switch (element_type) {
				case CG_FLOAT:
				case CG_HALF: {
					int count; const float* values = cgGetFloatAnnotationValues(anno, &count);
					if (rows==0 && cols==1) return [NSNumber numberWithFloat:values[0]];
					UIntP len = sizeof(float)*count;
					if (rows==0) return [[O3StructArray alloc] initWithBytes:O3MemDup(values,len) type:O3FloatType() length:len];
					O3CLogWarn(@"Row or column major?");
					return [[[O32DStructArray alloc] initWithBytes:O3MemDup(values,len) type:O3FloatType() length:len] rows:rows cols:cols rowMajor:YES];
				}
				case CG_INT:
				case CG_BOOL: {
					int count; const int* values = cgGetIntAnnotationValues(anno, &count);
					if (rows==0 && cols==1) return [NSNumber numberWithFloat:values[0]];
					UIntP len = sizeof(int)*count;
					O3CompileAssert(sizeof(int)==4,"");
					if (rows==0) return [[O3StructArray alloc] initWithBytes:O3MemDup(values,len) type:O3Int32Type() length:len];
					O3CLogWarn(@"Row or column major?");
					return [[[O32DStructArray alloc] initWithBytes:O3MemDup(values,len) type:O3Int32Type() length:len] rows:rows cols:cols rowMajor:YES];
				}
				default:
					O3Assert(false , @"O3GetCGAnnotationValue/CG_PARAMETERCLASS_(SCALAR|VECTOR|MATRIX) base type wasn't recognized");
			}
			return nil;
		}
		case CG_PARAMETERCLASS_ARRAY: {
			O3Asrt(cgGetTypeClass(cgGetTypeBase(anno_type))==CG_PARAMETERCLASS_ARRAY);
			int count; const char* const* vals = cgGetStringAnnotationValues(anno, &count);
			NSMutableArray* to_return = [NSMutableArray array];
			for (UIntP i=0; i<count; i++) {
				[to_return addObject:[NSString stringWithUTF8String:vals[i]]];
			}
			return to_return;
		}
		case CG_PARAMETERCLASS_OBJECT: {
			return [NSString stringWithUTF8String:cgGetStringAnnotationValue(anno)];
		}
		case CG_PARAMETERCLASS_UNKNOWN:
		default:
			O3Assert(false , @"O3GetCGAnnotationValue/(CG_PARAMETERCLASS_UNKNOWN|*) parameter class unknown or not recognized");
	}
	O3AssertFalse();
	return nil;
}

id O3GetCGParameterValue(CGparameter param) {
	O3AssertArg(param && cgIsParameter(param), @"Parameter argument of O3GetCGParameterValue must be a non-null annotation");
	CGtype param_type = cgGetParameterType(param);
	CGparameterclass param_class = cgGetParameterClass(param);	
	switch (param_class) {
		case CG_PARAMETERCLASS_SCALAR:
		case CG_PARAMETERCLASS_VECTOR:
		case CG_PARAMETERCLASS_MATRIX: {
			int rows, cols; cgGetTypeSizes(param_type, &rows, &cols);
			CGtype element_type = cgGetTypeBase(param_type);
			int param_component_count = rows? rows*cols : cols;
			switch (element_type) {
				case CG_FLOAT:
				case CG_HALF: {
					UIntP len = sizeof(float)*param_component_count;
					float* values = (float*)malloc(len);
					cgGetParameterValuefc(param, param_component_count, values);
					if (rows==0 && cols==1) {
						id to_return = [NSNumber numberWithFloat:values[0]];
						free(values);
						return to_return;
					}
					if (!rows) return [[O3StructArray alloc] initWithBytes:values type:O3FloatType() length:len];
					return [[[O32DStructArray alloc] initWithBytes:values type:O3FloatType() length:len] rows:rows cols:cols rowMajor:NO];
				}
				case CG_INT:
				case CG_BOOL: {
					UIntP len = sizeof(int)*param_component_count;
					int* values = (int*)malloc(len);
					cgGetParameterValueic(param, param_component_count, values);
					if (rows==0 && cols==1) {
						id to_return = [NSNumber numberWithInt:values[0]];
						free(values);
						return to_return;
					}
					O3CompileAssert(sizeof(int)==4,"");
					if (!rows) return [[O3StructArray alloc] initWithBytes:values type:O3Int32Type() length:len];
					return [[[O32DStructArray alloc] initWithBytes:values type:O3Int32Type() length:len] rows:rows cols:cols rowMajor:NO];
				}
				default:
					O3Assert(false , @"O3CGShader/valueForKey/CG_PARAMETERCLASS_(SCALAR|VECTOR|MATRIX) base type wasn't recognized");
			}
			return nil;
		}
		case CG_PARAMETERCLASS_ARRAY: {
			NSMutableArray* to_return = [NSMutableArray array];
			int count = cgGetArrayTotalSize(param);
			for (UIntP i=0; i<count; i++) [to_return addObject:O3GetCGParameterValue(cgGetArrayParameter(param, i))];
			return to_return;
		}
		case CG_PARAMETERCLASS_SAMPLER: {
			return [O3Texture textureForID:cgGLGetTextureParameter(param)];
		}
		case CG_PARAMETERCLASS_OBJECT: {
			return [NSString stringWithUTF8String:cgGetStringParameterValue(param)];
		}
		case CG_PARAMETERCLASS_STRUCT: {
			NSMutableDictionary* to_return = [NSMutableDictionary dictionary];
			CGparameter sparam = cgGetFirstStructParameter(param);
			do {
				[to_return setObject:O3GetCGParameterValue(sparam) forKey:[NSString stringWithUTF8String:cgGetParameterName(sparam)]];
			} while (sparam = cgGetNextParameter(sparam)); //? should be cgGetNextStructParameter
		}
		case CG_PARAMETERCLASS_UNKNOWN:
		default:
			O3Assert(false , @"O3CGShader/valueForKey/(CG_PARAMETERCLASS_UNKNOWN|*) parameter class unknown or not recognized");
	}
	O3AssertFalse();
	return nil;
}

void O3SetCGParameterToValue(CGparameter param, id newValue) {
	O3AssertArg(cgIsParameter(param), @"Parameter argument of O3CGSetParameterToValue must be a non-null parameter");
	CGtype param_type = cgGetParameterType(param);
	CGparameterclass param_class = cgGetParameterClass(param);	
	switch (param_class) {
		case CG_PARAMETERCLASS_SCALAR: {
			if (param_type==CG_FLOAT) cgSetParameter1f(param, [newValue floatValue]);
			//if (param_type==CG_DOUBLE) cgSetParameter1f(param, [key floatValue]);
			if (param_type==CG_INT) cgSetParameter1i(param, [newValue intValue]);
			if (param_type==CG_BOOL) cgSetParameter1i(param, [newValue intValue]);
			return;
		}
		case CG_PARAMETERCLASS_VECTOR:
		case CG_PARAMETERCLASS_MATRIX: {
			int rows, cols; cgGetTypeSizes(param_type, &rows, &cols);
			UIntP newValueCount = [newValue count];
			if (newValueCount!=(rows?:1)*cols) O3CLogWarn(@"Count mismatch (actual=%i!=%i)",newValueCount,(rows?:1)*cols);
			O3AssertArg([newValue respondsToSelector:@selector(bytesOfType:)] /*&& [newValues respondsToSelector:@selector(isRowMajor:)] && [newValues respondsToSelector:@selector(count)]*/, @"newValue must respond to bytesOfType:");
			double* bytes = (double*)[(NSArray*)newValue bytesOfType:O3DoubleType()];
			if ([(NSArray*)newValue isRowMajor])
				cgSetParameterValuedr(param, [(NSArray*)newValue count], (const double*)bytes);
			else
				cgSetParameterValuedc(param, [(NSArray*)newValue count], (const double*)bytes);
			free(bytes);
			return;
		}
		case CG_PARAMETERCLASS_STRUCT: {
			NSEnumerator* keyEnum = [newValue keyEnumerator];
			id key;
			while (key = [keyEnum nextObject]) {
				CGparameter sparam = cgGetNamedStructParameter(param, NSStringUTF8String(key));
				if (!sparam) {
					O3CLogWarn(@"Parameter \"%s\" not found in struct \"%s\". Ignoring.",NSStringUTF8String(key), cgGetParameterName(param));
					continue;
				}
				O3Assert(cgIsParameter(sparam), @"");
				O3SetCGParameterToValue(sparam, [newValue objectForKey:key]);
			}
			return;
		}
		case CG_PARAMETERCLASS_ARRAY: {
			int count = cgGetArrayTotalSize(param);
			UIntP ncount = [newValue count];
			if (count!=ncount) cgSetArraySize(param, ncount);
			for (UIntP i=0; i<ncount; i++) {
				O3SetCGParameterToValue(cgGetArrayParameter(param, i), [newValue objectAtIndex:i]);
			}
			return;
		}
		case CG_PARAMETERCLASS_SAMPLER: {
			cgGLSetTextureParameter(param, [newValue textureID]); 
			//cgGLSetupSampler(param, [newValue textureID]);
			return;
		}
	}
	O3Assert(false , @"CG parameter type not recognized!");
}
