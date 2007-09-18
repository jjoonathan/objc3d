/**
 *  @file O3Value.mm
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#import "O3Vector.h"
#import "O3Value.h"
#import "O3DynamicMatrix.h"
#include <iostream>

@implementation O3Value

/************************************/ #pragma mark Creation & Destruction /************************************/
+ (O3Value*)valueWithMatrix:(O3DynamicMatrix)mat {
	O3Value* to_return = [[[self alloc] init] autorelease];
	to_return->mDynamicMatrix = new O3DynamicMatrix(mat);
	to_return->mDynamicMatrix->CopyData();
	return to_return;
}

+ (O3Value*)valueWithVector:(O3DynamicVector)vec {
	O3Value* to_return = [[[self alloc] init] autorelease];
	to_return->mDynamicMatrix = new O3DynamicMatrix(vec);
	to_return->mDynamicMatrix->CopyData();
	return to_return;
}

///Same as valueWithPortableData, but with a reader
+ (NSValue*)valueByReadingFrom:(O3BufferedReader*)br {
	return (O3Value*)[[[self alloc] initByReadingFrom:br] autorelease];
}

///@returns an O3Value if dat contains an encoded O3Value or an NSValue if it contains a specially coded "0x0" matrix
+ (NSValue*)valueWithPortableData:(NSData*)dat {
	return [[[self alloc] initWithPortableData:dat] autorelease];
}

- (id)initByReadingFrom:(O3BufferedReader*)br {
	O3SuperInitOrDie();
	mDynamicMatrix = new O3DynamicMatrix(br);
	if (mDynamicMatrix->Rows()==0 && mDynamicMatrix->Columns()==0) {
		NSValue* realVal = [[NSValue alloc] initWithBytes:mDynamicMatrix->MatrixData() objCType:mDynamicMatrix->ElementType()];
		[self release];
		return realVal;
	}
	return self;
}

- (id)initWithPortableData:(NSData*)dat {
	O3SuperInitOrDie();
	O3BufferedReader b(dat);
	mDynamicMatrix = new O3DynamicMatrix(&b);
	return self;
}

- (void)dealloc {
	if (mDynamicMatrix) delete mDynamicMatrix; /*mDynamicMatrix = NULL;*/
	[super dealloc];
}

- (id)copyWithZone:(NSZone*)zone {
	O3Value* copy = (O3Value*)NSCopyObject(self, 0, zone);
	copy->mDynamicMatrix->CopyData();
	return copy;
}

/************************************/ #pragma mark Compatibility constructors /************************************/
- (NSData*)portableData {
	return mDynamicMatrix->PortableData();
}

+ (O3Value*)valueWithPoint:(NSPoint)pt {
	O3Vec2d vec(pt.x, pt.y);
	return [self valueWithVector:vec];	
}

///@note The components are stored in the vector in the order rect.location.x, rect.location.y, rect.size.width, rect.size.height
+ (O3Value*)valueWithRect:(NSRect)rect {
	O3Vec4d vec(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
	return [self valueWithVector:vec];	
}

+ (O3Value*)valueWithSize:(NSSize)size {
	O3Vec2d vec(size.width, size.height);
	return [self valueWithVector:vec];
}



/************************************/ #pragma mark Inspectors /************************************/
- (O3DynamicMatrix)matrixValue {
	return *mDynamicMatrix;
}

- (O3DynamicVector)vectorValue {
	return O3DynamicVector(*mDynamicMatrix);
}

- (const char*)objCType {
	return mDynamicMatrix->Type();
}

/************************************/ #pragma mark Compatibility Inspectors /************************************/
- (NSPoint)pointValue {
	O3Vec2d pt([self vectorValue]);
	return NSMakePoint(pt[0], pt[1]);
}

- (NSRect)rectValue {
	O3Vec4d rect([self vectorValue]);
	return NSMakeRect(rect[0], rect[1], rect[2], rect[3]);	
}

- (NSSize)sizeValue {
	O3Vec2d size([self vectorValue]);
	return NSMakeSize(size[0], size[1]);	
}

/************************************/ #pragma mark NSValue Overriding /************************************/
- (id)initWithBytes:(void*)bytes objCType:(const char*)encode {
	O3LogWarn(@"Cannot use NSValue constructor %s on an O3Value.", [NSStringFromSelector(_cmd) UTF8String]);
	[self release];
	return self;
}

+ (id)valueWithBytes:(void*)bytes objCType:(const char*)encode {
	O3LogWarn(@"Cannot use NSValue constructor %s on an O3Value.", [NSStringFromSelector(_cmd) UTF8String]);
	return nil;
}

+ (id)value:(void*)bytes objCType:(const char*)encode {
	O3LogWarn(@"Cannot use NSValue constructor %s on an O3Value.", [NSStringFromSelector(_cmd) UTF8String]);
	return nil;
}

+ (id)valueWithNonretainedObject:(id)object {
	O3LogWarn(@"Cannot use NSValue constructor %s on an O3Value.", [NSStringFromSelector(_cmd) UTF8String]);
	return nil;
}

- (void)getValue:(void*)buffer {
	O3LogWarn(@"Cannot use NSValue inspector %s on an O3Value.", [NSStringFromSelector(_cmd) UTF8String]);
}

- (id)nonretainedObjectValue {
	O3LogWarn(@"Cannot use NSValue inspector %s on an O3Value.", [NSStringFromSelector(_cmd) UTF8String]);
	return nil;	
}

- (void*)pointerValue {
	O3LogWarn(@"Cannot use NSValue inspector %s on an O3Value.", [NSStringFromSelector(_cmd) UTF8String]);
	return nil;
}

/************************************/ #pragma mark Description, other protocols /************************************/
- (NSString*)description {
	int w = 5; //Width of elements
	if (!mDynamicMatrix) return @"<O3Value>null";
	std::ostringstream to_return;
	O3DynamicMatrix* mat = mDynamicMatrix;
	to_return<<"<O3Value "<<mat->Rows()<<"x"<<mat->Columns()<<mat->ElementType()<<">{\n";
	int i,j;
	for (i=0; i<mat->Rows(); i++) {
		to_return<<"{";
		for (j=0; j<mat->Columns(); j++) {
			int p = to_return.precision(w);
			int w2 = to_return.width(w);
			to_return<<mat->ElementOfTypeAt<double>(i,j);
			to_return.precision(p);
			to_return.width(w2);
			if (j!=(mat->Columns()-1)) to_return<<", ";
		}
		if (i!=(mat->Rows()-1))	to_return<<"}\n  ";
		else					to_return<<"}}\n";
	}
	return [NSString stringWithUTF8String:to_return.str().c_str()];
}

- (NSString*)stringValue {
	return [self description];
}

- (BOOL)isEqual:(id)other {
	if (![other isKindOfClass:[O3Value class]]) return NO;
	return mDynamicMatrix->IsEqual(((O3Value*)other)->mDynamicMatrix);
}

@end



@implementation NSValue (O3ValueAdditions)

- (NSData*)portableData {
	NSMutableData* dat = [NSMutableData dataWithCapacity:32];
	O3BufferedWriter w(dat);
	const char* type = [self objCType];
	w.WriteByte(3<<6); //A "0x0" matrix with a custom format
	w.WriteCCString(type);
	void* buffer = malloc(O3AlignedSizeofObjCEncodedType(type));
	[self getValue:buffer];
	O3SerializeDataOfType(buffer, type, &w, 1);
	free(buffer);
	return dat;
}
	
@end
