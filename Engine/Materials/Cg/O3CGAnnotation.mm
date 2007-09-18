/**
 *  @file O3CGAnnotation.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 2/25/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#include <map>
#import "O3CGAnnotation.h"
#import "O3CGParameterSupport.h"
using namespace std;

map<CGannotation, O3CGAnnotation*> gO3CGAnnotationMap;

@implementation O3CGAnnotation
inline O3CGAnnotation* O3CGAnnotation_init(O3CGAnnotation* self, CGannotation anno, BOOL freeWhenDone) {
	if (!self) return nil;
	self->mAnnotation = anno;
	self->mFreeAnnoWhenDone = freeWhenDone;
	gO3CGAnnotationMap[anno] = self; //Add us to the CGannotation->O3CGAnnotation* map
	return self;
}

- (void)dealloc {
	gO3CGAnnotationMap.erase(mAnnotation); //Remove us from the CGannotation->O3CGAnnotation* map
	[super dealloc];
}

/************************************/ #pragma mark Initialization /************************************/
- (id)init {
	[self release];
	return nil;
}

///@note You must pass in the type of CG object because the specs don't \e guarentee that cgIs* will not return true on something that isn't what they are testing for
///@warn Depricated
- (id)initWithType:(CGtype)type name:(NSString*)name forCGObject:(void*)cgObject ofType:(CGannotationType)cgAnnoType {
	O3SuperInitOrDie();
	const char* cname = NSString_cString(name);
	CGannotation anno = nil;
	switch (cgAnnoType) {
		case CGParameterAnnotationType:
			O3Assert(cgIsParameter((CGparameter)cgObject), @"Cannot create a parameter annotation for non-parameter object 0x%X",cgObject);
			anno = cgCreateParameterAnnotation((CGparameter)cgObject, cname, type);
			break;
		case CGEffectAnnotationType:
			O3Assert(cgIsEffect((CGeffect)cgObject), @"Cannot create an effect annotation for non-effect object 0x%X",cgObject);
			anno = cgCreateEffectAnnotation((CGeffect)cgObject, cname, type);
			break;
		case CGPassAnnotationType:
			O3Assert(cgIsPass((CGpass)cgObject), @"Cannot create a pass annotation for non-pass object 0x%X",cgObject);
			anno = cgCreatePassAnnotation((CGpass)cgObject, cname, type);
			break;
		case CGTechniqueAnnotationType:
			O3Assert(cgIsTechnique((CGtechnique)cgObject), @"Cannot create a technique annotation for non-technique object 0x%X",cgObject);
			anno = cgCreateTechniqueAnnotation((CGtechnique)cgObject, cname, type);
			break;
		case CGProgramAnnotationType:
			O3Assert(cgIsProgram((CGprogram)cgObject), @"Cannot create a program annotation for non-program object 0x%X",cgObject);
			anno = cgCreateProgramAnnotation((CGprogram)cgObject, cname, type);
			break;
		default:
			O3Assert(false , @"O3CGAnnotation didn't recognize the annotation type passed to it!");
	}
	return O3CGAnnotation_init(self, anno, YES);
}

- (id)initWithAnnotation:(CGannotation)anno {
	if (!anno) {
		[self release];
		return nil;
	}
	O3SuperInitOrDie();
	return O3CGAnnotation_init(self, anno, YES);
}

+ (id)annotationOfAnnotation:(CGannotation)anno {
	return gO3CGAnnotationMap[anno];
}



/************************************/ #pragma mark Inspectors /************************************/
- (NSString*)name {
	return [NSString stringWithUTF8String:cgGetAnnotationName(mAnnotation)];
}

- (CGannotation)rawAnnotation {
	return mAnnotation;
}

- (id)value {
	return O3GetCGAnnotationValue(mAnnotation);
}

///@note Raises if called on an array
- (int)intValue {
	return O3GetScalarAnnotationValue(mAnnotation, int);
}

///@note Raises if called on an array
- (float)floatValue {
	return O3GetScalarAnnotationValue(mAnnotation, float);
}

///@note Raises if called on an array
///@note Currently doubleValue only exists for compatibility: it only really returns things at float precision
- (double)doubleValue {
	return O3GetScalarAnnotationValue(mAnnotation, double);	
}

///@note Raises if called on an array
- (BOOL)boolValue {
	return O3GetScalarAnnotationValue(mAnnotation, BOOL);
}

///@note Works for all annotation types but is only more efficient than [[annotation value] stringValue] when the receiver is a string annotation
- (NSString*)stringValue {
	if (cgGetAnnotationType(mAnnotation)==CG_STRING)
		return [NSString stringWithUTF8String:cgGetStringAnnotationValue(mAnnotation)];
	return [[self value] stringValue];
}



/************************************/ #pragma mark Thin wrapper management /************************************/
- (BOOL)freeWhenDone {
	return mFreeAnnoWhenDone;
}

- (void)setFreeWhenDone:(BOOL)newOwns {
	mFreeAnnoWhenDone = newOwns;
}



/************************************/ #pragma mark Mutators /************************************/
- (void)setBoolValue:(BOOL)val {
	cgSetBoolAnnotation(mAnnotation, val);
}

- (void)setIntValue:(int)val {
	cgSetIntAnnotation(mAnnotation, val);
}

- (void)setFloatValue:(float)val {
	cgSetFloatAnnotation(mAnnotation, val);
}

- (void)setDoubleValue:(double)val {
	cgSetFloatAnnotation(mAnnotation, val);
}

- (void)setValue:(NSObject*)newValue {
	O3SetCGAnnotationToValue(mAnnotation, newValue);
}


@end
