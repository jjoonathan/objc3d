//
//  O32DStructArray.m
//  ObjC3D
//
//  Created by Jonathan deWerd on 2/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import "O32DStructArray.h"
#import "O3ScalarStructType.h"

#define INDEX_FOR_RC(rows, cols, row, col) (col*rows+row)

@implementation O32DStructArray
O3DefaultO3InitializeImplementation
/************************************/ #pragma mark Creation /************************************/
- (O32DStructArray*)rows:(UIntP)r cols:(UIntP)cols rowMajor:(BOOL)rm {
	O3Assert(!mRows && !mCols && r && cols, @"Call rows:cols: ONLY as the second part in an init sequence (like [[[O32DStructArray alloc] initWithType:t rawData:d] rows:5 cols:5 rowMajor:YES]). rows and cols must both be nonzero.");
	[super setCountLocked:YES];
	mRows = r;
	mCols = cols;
	O3Assert(mRows*mCols==[self count], @"O32DStructArray count==rows*columns mismatch");
	if ([self isRowMajor] != rm) [self transpose];
	return self;
}

/************************************/ #pragma mark Standard Protocols /************************************/
- (id)copyWithZone:(NSZone*)z {
	return [[super copyWithZone:z] rows:mRows cols:mCols rowMajor:[self isRowMajor]];
}

- (id)mutableCopyWithZone:(NSZone*)z {
	return [[super mutableCopyWithZone:z] rows:mRows cols:mCols rowMajor:[self isRowMajor]];
}

- (id)initWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding]) {
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
		[self release];
		return nil;
	}
	[super initWithCoder:coder];
	mRows = [coder decodeIntForKey:@"rows"];
	mCols = [coder decodeIntForKey:@"cols"];
	if ([coder decodeBoolForKey:@"rowMajor"]&&![self isRowMajor]) [self transpose];
	if (!mRows || !mCols || mRows*mCols!=[self count]) {
		O3LogWarn(@"No row or col key (or bad data) present for O32DStructArray");
		[self release];
		return nil;
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding])
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
	[super encodeWithCoder:coder];
	[coder encodeInt:mRows forKey:@"rows"];
	[coder encodeInt:mCols forKey:@"cols"];
	if ([self isRowMajor]) [coder encodeBool:YES forKey:@"rowMajor"];
}

/************************************/ #pragma mark Accessors /************************************/
- (UIntP)rows {
	return mRows;
}

- (UIntP)cols {
	return mCols;
}

- (id)objectAtRow:(UIntP)row col:(UIntP)col {
	O3Assert(mRows && mCols && mRows*mCols==[self count], @"You must call rows:cols: during the init sequence of a O32DStructArray, like O32DStructArray* a = [[[O32DStructArray alloc] initWithType:t rawData:d] rows:5 cols:5 rowMajor:YES].");
	if (mTranspose) O3Swap(row,col);
	return [super objectAtIndex:INDEX_FOR_RC(mRows, mCols, row, col)];
}

- (void)setObjectAtRow:(UIntP)row col:(UIntP)col to:(id)obj {
	O3Assert(mRows && mCols && mRows*mCols==[self count], @"You must call rows:cols: during the init sequence of a O32DStructArray, like O32DStructArray* a = [[[O32DStructArray alloc] initWithType:t rawData:d] rows:5 cols:5 rowMajor:YES].");
	if (mTranspose) O3Swap(row,col);
	[super replaceObjectAtIndex:INDEX_FOR_RC(mRows, mCols, row, col) withObject:obj];
}

- (void)getStruct:(void*)str atRow:(UIntP)row col:(UIntP)col {
	O3Assert(mRows && mCols && mRows*mCols==[self count], @"You must call rows:cols: during the init sequence of a O32DStructArray, like O32DStructArray* a = [[[O32DStructArray alloc] initWithType:t rawData:d] rows:5 cols:5 rowMajor:YES].");
	if (mTranspose) O3Swap(row,col);
	[super getStruct:str atIndex:INDEX_FOR_RC(mRows, mCols, row, col)];
}

- (void)setStruct:(const void*)str atRow:(UIntP)row col:(UIntP)col {
	O3Assert(mRows && mCols && mRows*mCols==[self count], @"You must call rows:cols: during the init sequence of a O32DStructArray, like O32DStructArray* a = [[[O32DStructArray alloc] initWithType:t rawData:d] rows:5 cols:5 rowMajor:YES].");
	if (mTranspose) O3Swap(row,col);
	[super setStruct:str atIndex:INDEX_FOR_RC(mRows, mCols, row, col)];
}

- (BOOL)isRowMajor {
	if (INDEX_FOR_RC(3,3,0,2)==2) return mTranspose?NO:YES;
	if (INDEX_FOR_RC(3,3,0,2)==6) return mTranspose?YES:NO;
	O3Asrt(NO);
	return YES;
}

- (void)transpose {
	mTranspose = !mTranspose;
}

void O32DStructArrayGetR_C_RowMajor_(O32DStructArray* self, UIntP* r, UIntP* c, BOOL* rm) {
	if (r) *r = self->mRows;
	if (c) *c = self->mCols;
	if (rm) *rm = [self isRowMajor];
}

@end

O32DStructArray* O32DStructArrayWithBytesTypeRowsCols(void* bytes, const char* octype, UIntP r, UIntP c, BOOL rm) {
	O3CType ct = O3CTypeEncoded(octype);
	O3StructType* t = [O3ScalarStructType scalarTypeWithCType:O3CTypeEncoded(octype)];
	return [[[[O32DStructArray alloc] initWithBytes:bytes type:t length:r*c*O3CTypeSize(ct)] rows:r cols:c rowMajor:rm] autorelease];
}