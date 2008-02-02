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
		case CG_PARAMETERCLASS_VECTOR: //Probably not in an annotation, but oh well
		case CG_PARAMETERCLASS_MATRIX: { //^x2
			CGtype element_type = cgGetTypeBase(anno_type);
			switch (element_type) {
				case CG_FLOAT:
				case CG_HALF: {
					int count;
					const float* values = cgGetFloatAnnotationValues(anno, &count);
					NSValue* to_return;
					int rows, cols; cgGetTypeSizes(anno_type, &rows, &cols);
					if (rows==1 && cols==1) to_return = [NSNumber numberWithFloat:values[0]];
					else to_return = [NSValue valueWithBytes:values cgType:anno_type];
					return to_return;
				}
				case CG_INT:
				case CG_BOOL: {
					int count;
					const int* values = cgGetIntAnnotationValues(anno, &count);
					NSValue* to_return;
					int rows, cols; cgGetTypeSizes(anno_type, &rows, &cols);
					if (rows==1 && cols==1) to_return = [NSNumber numberWithInt:values[0]];
					else to_return = [NSValue valueWithBytes:values cgType:anno_type];
					return to_return;
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
					int count;
					const float* values = cgGetFloatAnnotationValues(anno, &count);
					NSMutableArray* to_return = [NSMutableArray array];
					int i; for (i=0;i<count;i++) [to_return addObject:[NSNumber numberWithFloat:values[i]]];
					return to_return;
				}
				case CG_INT:
				case CG_BOOL: {
					int count;
					const int* values = cgGetIntAnnotationValues(anno, &count);
					NSMutableArray* to_return = [NSMutableArray array];
					int i; for (i=0;i<count;i++) [to_return addObject:[NSNumber numberWithInt:values[i]]];
					return to_return;
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
			int rows, cols; cgGetTypeSizes(param_type, &rows, &cols);
			CGtype element_type = cgGetTypeBase(param_type);
			int param_component_count = rows*cols;
			switch (element_type) {
				case CG_FLOAT:
				case CG_HALF: {
					float* values = new float[param_component_count];
					cgGetParameterValuefc(param, param_component_count, values);
					NSValue* to_return;
					if (rows==1 && cols==1) to_return = [NSNumber numberWithFloat:values[0]];
					else to_return = [NSValue valueWithBytes:values cgType:param_type];
					delete[] values; //Can we do this?
					return to_return;
				}
				case CG_INT:
				case CG_BOOL: {
					int* values = new int[param_component_count];
					cgGetParameterValueic(param, param_component_count, values);
					NSValue* to_return;
					if (rows==1 && cols==1) to_return = [NSNumber numberWithInt:values[0]];
					else to_return = [NSValue valueWithBytes:values cgType:param_type];
					delete[] values; //Can we do this?
					return to_return;
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
			int rows, cols; cgGetTypeSizes(member_type, &rows, &cols);
			int atoms_per_element = rows*cols;
			int total_atoms = atoms_per_element*members;
			switch (element_type) {
				case CG_FLOAT:
				case CG_HALF: {
					float* values = new float[total_atoms];
					float* values_itr = values;
					cgGetParameterValuefc(param, total_atoms, values);
					NSMutableArray* to_return = [NSMutableArray array];
					int i; for (i=0;i<members;i++) {
						[to_return addObject:[NSValue valueWithBytes:values_itr cgType:param_type]];
						values_itr += atoms_per_element;
					}
					delete[] values; //Can we do this?
					return to_return;
				}
				case CG_INT:
				case CG_BOOL: {
					int* values = new int[total_atoms];
					int* values_itr = values;
					cgGetParameterValueic(param, total_atoms, values);
					NSMutableArray* to_return = [NSMutableArray array];
					int i; for (i=0;i<members;i++) {
						[to_return addObject:[NSValue valueWithBytes:values_itr cgType:param_type]];
						values_itr += atoms_per_element;
					}
					delete[] values; //Can we do this?
					return to_return;
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
			if (param_type==CG_BOOL) cgSetParameter1i(param, [newValue intValue]);
			return;
		}
		case CG_PARAMETERCLASS_VECTOR:
		case CG_PARAMETERCLASS_MATRIX: {
			const char* type_encoding = [newValue objCType];
			char atom_type; //First char that is 'f', 'i', or 'd' (no l because Cg doesn't really support it)
			const char* type_encoding_search = type_encoding;
			while (atom_type=(*(type_encoding_search++)))
				if (atom_type=='f' || atom_type=='i' || atom_type=='d') break;
			if (!atom_type) {
				O3CLogWarn(@"O3CGShader setValue:forKey: unrecognized atom type (not int, double, or float)!");
				return;
			}
			unsigned atom_count = O3CountObjCEncodedElementsOfType(atom_type, type_encoding);
			void* bytes = malloc(O3UnalignedSizeofObjCEncodedType(type_encoding));
			[newValue getValue:bytes];
			switch (atom_type) {
				case 'f':
					cgSetParameterValuefc(param, atom_count, (const float*)bytes);
					break;
				case 'd':
					cgSetParameterValuedc(param, atom_count, (const double*)bytes);
					break;
				case 'i':
					cgSetParameterValueic(param, atom_count, (const int*)bytes);
					break;
			}	
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
		case CG_PARAMETERCLASS_SAMPLER: {
			cgGLSetTextureParameter(param, [newValue textureID]); 
			//cgGLSetupSampler(param, [newValue textureID]);
			return;
		}
	}
	O3Assert(false , @"CG parameter type not recognized!");
}
