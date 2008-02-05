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
#import "O3GPUData.h"
#import <Cg/cg.h>
#import <Cg/cgGL.h>

void O3SetCGAnnotationToValue(CGannotation anno, id value) {
	CGtype anno_type = cgGetAnnotationType(anno);
	if (anno_type==CG_STRUCT || anno_type==CG_ARRAY) {
 		O3CLogError(@"Setting CG_STRUCT and CG_ARRAY annotations is not supported (annotation \"%s\")", cgGetAnnotationName(anno));
	}
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
}

id O3GetCGAnnotationValue(CGannotation anno) {
	O3AssertArg(anno && cgIsAnnotation(anno), @"Annotation argument of O3GetCGAnnotationValue must be a non-null annotation");
	CGtype anno_type = cgGetAnnotationType(anno);
	CGparameterclass anno_class = cgGetTypeClass(anno_type);	
	switch (anno_class) {
		case CG_PARAMETERCLASS_SCALAR:
		case CG_PARAMETERCLASS_VECTOR:
		case CG_PARAMETERCLASS_MATRIX: {
			if (anno_class==CG_PARAMETERCLASS_MATRIX) O3CLogWarn(@"Matrix annotations are a bit sketchy: it is unknown if they are row major, column major, of if they even exist at all.");
			CGtype element_type = cgGetTypeBase(anno_type);
			switch (element_type) {
				case CG_FLOAT:
				case CG_HALF: {
					int count; const float* values = cgGetFloatAnnotationValues(anno, &count);
					int rows, cols; cgGetTypeSizes(anno_type, &rows, &cols);
					UIntP len = sizeof(float)*rows*cols;
					if (rows==1 && cols==1) return [NSNumber numberWithFloat:*(float*)values];
					else return [[[[O32DStructArray alloc] initWithBytes:O3MemDup(values, len) type:O3FloatType() length:len] rows:rows cols:cols rowMajor:YES] autorelease];
					O3Asrt(NO); return nil;
				}
				case CG_INT:
				case CG_BOOL: {
					int count; const int* values = cgGetIntAnnotationValues(anno, &count);
					int rows, cols; BOOL is_mat = cgGetTypeSizes(anno_type, &rows, &cols);
					UIntP len = sizeof(float)*rows*cols;
					O3Asrt(sizeof(int)!=8 /*If so, it is wrong to assume that those are Int32s! (two lines below)*/);
					if (rows==1 && cols==1) return [NSNumber numberWithInt:*(int*)values];
					if (cols==1) return [[[O3StructArray alloc] initWithCopiedBytes:values type:O3Int32Type() length:len] autorelease];
					if (is_mat) return [[[[O32DStructArray alloc] initWithBytes:O3MemDup(values, len) type:O3Int32Type() length:len] rows:rows cols:cols rowMajor:YES] autorelease];
					O3Asrt(NO); return nil;
				}
				default:
					O3Assert(false , @"O3GetCGAnnotationValue/CG_PARAMETERCLASS_(SCALAR|VECTOR|MATRIX) base type wasn't recognized");
			}
			return nil;
		}
		case CG_PARAMETERCLASS_ARRAY: {
			CGtype element_type = cgGetTypeBase(anno_type);
			switch (element_type) {
				case CG_FLOAT:
				case CG_HALF: {
					int count; const float* values = cgGetFloatAnnotationValues(anno, &count);
					return [[[O3StructArray alloc] initWithCopiedBytes:values type:O3FloatType() length:sizeof(float)*count] autorelease];
				}
				case CG_INT:
				case CG_BOOL: {
					O3Asrt(sizeof(int)!=8 /*If so, it is wrong to assume that those are Int32s! (two lines below)*/);
					int count; const int* values = cgGetIntAnnotationValues(anno, &count);
					return [[[O3StructArray alloc] initWithCopiedBytes:values type:O3Int32Type() length:sizeof(int)*count] autorelease];
				}
				default:
					O3Assert(false , @"O3GetCGAnnotationValue/CG_PARAMETERCLASS_ARRAY base type wasn't recognized");
			}
			return nil;
		}
		case CG_PARAMETERCLASS_OBJECT: {
			case CG_PARAMETERCLASS_UNKNOWN:
			default: {
				O3Assert(false , @"O3GetCGAnnotationValue/(CG_PARAMETERCLASS_UNKNOWN|*) parameter class unknown or not recognized");
			}
		}
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
			int rows, cols; BOOL is_mat = cgGetTypeSizes(param_type, &rows, &cols);
			CGtype element_type = cgGetTypeBase(param_type);
			int param_component_count = rows*cols;
			O3Asrt(sizeof(int)!=8 /*If so, it is wrong to assume that those are Int32s! (several lines below)*/);
			switch (element_type) {
				case CG_FLOAT:
				case CG_HALF: {
					UIntP len = (param_component_count*sizeof(float));
					float* values = (float*)malloc(len);
					cgGetParameterValuefr(param, param_component_count, values);
					if (rows==1 && cols==1) {
						id ret = [NSNumber numberWithFloat:*(float*)values];
						free(values);
						return ret;
					} else if (cols==1) {
						return [[[O3StructArray alloc] initWithBytes:values type:O3FloatType() length:len] autorelease];
					} else if (is_mat) {
						return [[[[O32DStructArray alloc] initWithBytes:values type:O3FloatType() length:len] rows:rows cols:cols rowMajor:YES] autorelease];
					}
				}
				case CG_INT:
				case CG_BOOL: {
					UIntP len = (param_component_count*sizeof(int));
					int* values = (int*)malloc(len);
					cgGetParameterValueir(param, param_component_count, values);
					if (rows==1 && cols==1) {
						id ret = [NSNumber numberWithInt:*(int*)values];
						free(values);
						return ret;
					} else if (cols==1) {
						return [[[O3StructArray alloc] initWithBytes:values type:O3Int32Type() length:len] autorelease];
					} else if (is_mat) {
						return [[[[O32DStructArray alloc] initWithBytes:values type:O3Int32Type() length:len] rows:rows cols:cols rowMajor:YES] autorelease];
					}
				}
				default:
					O3Assert(false , @"O3CGShader/valueForKey/CG_PARAMETERCLASS_(SCALAR|VECTOR|MATRIX) base type wasn't recognized");
			}
			return nil;
		}
		case CG_PARAMETERCLASS_ARRAY: {
			CGtype member_type = cgGetArrayType(param);	//The type of the members of the array (FLOAT4x4, etc)
			CGtype element_type = cgGetTypeBase(member_type); //The atomic type in the array (INT, FLOAT, etc)
			int members = cgGetArrayTotalSize(param);
			int rows, cols; BOOL is_mat = cgGetTypeSizes(member_type, &rows, &cols);
			int atoms_per_element = rows*cols;
			int total_atoms = atoms_per_element*members;
			O3Asrt(sizeof(int)!=8 /*If so, it is wrong to assume that those are Int32s! (several lines below)*/);
			switch (element_type) {
				case CG_FLOAT:
				case CG_HALF: {
					UIntP len = total_atoms*sizeof(float);
					float* values = (float*)malloc(len);
					cgGetParameterValuefr(param, total_atoms, values);
					if (rows==1 && cols==1) {
						return [[[O3StructArray alloc] initWithBytes:values type:O3FloatType() length:len] autorelease];
					} else if (cols==1) {
						return [[[O3StructArray alloc] initWithBytes:values type:O3FloatType() length:len] autorelease];
					} else if (is_mat) {
						return [[[[O32DStructArray alloc] initWithBytes:values type:O3FloatType() length:len] rows:rows cols:cols rowMajor:YES] autorelease];
					}
				}
				case CG_INT:
				case CG_BOOL: {
					UIntP len = total_atoms*sizeof(int);
					int* values = (int*)malloc(len);
					cgGetParameterValueir(param, total_atoms, values);
					if (rows==1 && cols==1) {
						return [[[O3StructArray alloc] initWithBytes:values type:O3Int32Type() length:len] autorelease];
					} else if (cols==1) {
						return [[[O3StructArray alloc] initWithBytes:values type:O3Int32Type() length:len] autorelease];
					} else if (is_mat) {
						return [[[[O32DStructArray alloc] initWithBytes:values type:O3Int32Type() length:len] rows:rows cols:cols rowMajor:YES] autorelease];
					}
				}
				default:
					O3Assert(false , @"O3CGShader/valueForKey/CG_PARAMETERCLASS_ARRAY base type wasn't recognized");
			}
			return nil;
		}
		case CG_PARAMETERCLASS_SAMPLER: {
			return [O3Texture textureForID:cgGLGetTextureParameter(param)];
		}
		case CG_PARAMETERCLASS_OBJECT: {
			switch (param_type) {
				case CG_STRING:
					return [NSString stringWithUTF8String:cgGetStringParameterValue(param)];
				default:
					O3Assert(false , @"O3CGShader/valueForKey/CG_PARAMETERCLASS_OBJECT base type wasn't recognized (not CG_STRING)");
			}
			return nil;
		}
		case CG_PARAMETERCLASS_STRUCT: {
			NSMutableDictionary* to_return = [NSMutableDictionary dictionary];
			CGparameter sparam = cgGetFirstStructParameter(param);
			do {
				[to_return setObject:O3GetCGParameterValue(sparam) forKey:[NSString stringWithUTF8String:cgGetParameterName(sparam)]];
			} while (sparam = cgGetNextParameter(sparam)); //? should be cgGetNextStructParameter
		}
		case CG_PARAMETERCLASS_UNKNOWN:
		default: {
			O3Assert(false , @"O3CGShader/valueForKey/(CG_PARAMETERCLASS_UNKNOWN|*) parameter class unknown or not recognized");
		}
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
			if (param_type==CG_BOOL) cgSetParameter1i(param, [newValue boolValue]);
			return;
		}
		case CG_PARAMETERCLASS_VECTOR:
		case CG_PARAMETERCLASS_MATRIX: {
			BOOL release_newValue = NO;
			if (![newValue isKindOfClass:[O3StructArray class]]) {
				O3Asrt([newValue respondsToSelector:@selector(objectAtIndex:)]);
				O3Asrt([newValue respondsToSelector:@selector(count:)]);
				newValue = [[O3StructArray alloc] initWithArray:newValue];
				release_newValue = YES;
			}
			O3ScalarStructType* struct_t = (O3ScalarStructType*)[(O3StructArray*)newValue structType];
			O3Assert([struct_t isKindOfClass:[O3ScalarStructType class]],@"%@ is not a scalar type!", struct_t);
			O3CType atom_type = [struct_t type];
			UIntP atom_count = [(O3StructArray*)newValue count];
			NSData* rd = [(O3StructArray*)newValue rawData];
			const void* bytes = [rd bytes];
			O3Asrt(sizeof(int)==4);
			switch (atom_type) {
				case O3FloatCType:
					cgSetParameterValuefc(param, atom_count, (const float*)bytes);
					break;
				case O3DoubleCType:
					cgSetParameterValuedc(param, atom_count, (const double*)bytes);
					break;
				case O3Int32CType:
				case O3Int8CType:
				case O3Int16CType:
				case O3Int64CType:
				case O3UInt32CType:
				case O3UInt8CType:
				case O3UInt16CType:
				case O3UInt64CType:
					cgSetParameterValueic(param, atom_count, (const int*)bytes);
					break;
				default:
					O3Asrt(NO);
			}	
			[rd relinquishBytes];
			if (release_newValue) [newValue release];
			return;
		}
		case CG_PARAMETERCLASS_STRUCT: {
			NSEnumerator* keyEnum = [newValue keyEnumerator];
			while (id key = [keyEnum nextObject]) {
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
		case CG_PARAMETERCLASS_SAMPLER: {
			cgGLSetTextureParameter(param, [newValue textureID]); 
			//cgGLSetupSampler(param, [newValue textureID]);
			return;
		}
	}
	O3Assert(false , @"CG parameter type not recognized!");
}
