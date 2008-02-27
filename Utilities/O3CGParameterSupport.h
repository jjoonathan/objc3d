/**
 *  @file O3CGParameterSupport.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 1/13/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import <Cg/cg.h>
#import <Cg/cgGL.h>

typedef enum {
	CGParameterAnnotationType,
	CGEffectAnnotationType,
	CGPassAnnotationType,
	CGTechniqueAnnotationType,
	CGProgramAnnotationType	
} CGannotationType;

void O3SetCGParameterToValue(CGparameter param, id newValue, CGhandle typeContext);
id   O3GetCGParameterValue(CGparameter param);
void O3SetCGAnnotationToValue(CGannotation anno, id value);
id   O3GetCGAnnotationValue(CGannotation anno);

#ifdef __cplusplus
#define O3GetScalarAnnotationValue(annotation, scalar_type) O3GetScalarAnnotationValueSupport<scalar_type>::getValue(annotation)
template <typename TYPE>
struct O3GetScalarAnnotationValueSupport {
	static TYPE getValue(CGannotation anno) {
		int val_count;
		CGtype annotation_type = cgGetAnnotationType(anno);
		O3AssertArg(cgIsAnnotation(anno), @"Argument to O3GetScalarAnnotationValue must be an annotation");
		O3Assert(annotation_type!=CG_STRUCT && annotation_type!=CG_ARRAY, @"This would be ambiguous so it isn't implemented in O3CGAnnotation's scalar inspector methods");
		switch(annotation_type) {
			case CG_BOOL: {
				const CGbool* vals = cgGetBoolAnnotationValues(anno, &val_count);
				return vals[0];
			}
			case CG_FLOAT: {
				const float* vals = cgGetFloatAnnotationValues(anno, &val_count);
				return vals[0];
			}
			case CG_INT: {
				const int* vals = cgGetIntAnnotationValues(anno, &val_count);
				return vals[0];
			}
			default:
				O3CLogError(@"CG type %s not recognized in O3GetScalarAnnotationValue.", cgGetTypeString(annotation_type));
				O3Assert(false , @"O3CGAnnotation's scalar inspector methods (-intValue floatValue etc) do not work on vector annotations.");
		}
		return 0;
	}
};
#endif /*defined(__cplusplus)*/
