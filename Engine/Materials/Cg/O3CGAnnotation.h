/**
 *  @file O3CGAnnotation.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 2/25/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import <Cg/cg.h>
#import <Cg/cgGL.h>

/**
 * A CG annotation is basically metadata that can be associated with another CG* object (programatically or in the CG file itself).
 * This class is a thin wrapper around CGannotation. This means that it is perfectly acceptable to ask an O3CGAnnotation for the rawAnnotation and operate on it.
 * The CG runtime takes care of freeing CGannotations that it created, but O3CGAnnotations that you create must be freed explicitly. O3CGAnnotation takes care of this for you.
 */
@interface O3CGAnnotation : NSObject {
	CGannotation mAnnotation;
	BOOL mFreeAnnoWhenDone;
}
//Initialization
- (id)initWithAnnotation:(CGannotation)anno;
+ (id)annotationOfAnnotation:(CGannotation)anno; ///<Returns the O3CGAnnotation for a CGannotation that already has a O3CGAnnotation.

//Inspectors
- (NSString*)name;
- (CGannotation)rawAnnotation; ///<Returns the CGannotation wrapped by the receiver. @note This method is perfectly safe to use since O3CGAnnotation is a thin wrapper. Feel free to do whatever you want with the returned object (except destroy it :) )
- (id)value; ///<Returns an ObjC-ized value of the receiver
- (int)intValue;	///<The receiver's value as an integer
- (float)floatValue;	///<The receiver's value as a float
- (double)doubleValue;	///<The receiver's value as a double (not any more precise than floatValue in the current CG implementation)
- (BOOL)boolValue;	///<The receiver's value as a boolean value
- (NSString*)stringValue;	///<The receiver's value as a string

//Thin wrapper management
- (BOOL)freeWhenDone; ///<Weather or not the receiver is responsible for destroying mParam when it is done with it
- (void)setFreeWhenDone:(BOOL)newOwns; ///<Sets weather or not the receiver frees its parameter when it is done with it

//Mutators
- (void)setIntValue:(int)val;
- (void)setFloatValue:(float)val;
- (void)setDoubleValue:(double)val;
- (void)setBoolValue:(BOOL)val;
- (void)setValue:(NSObject*)newValue; ///<Sets the value of the receiver to newValue without changing the receiver's type

@end
