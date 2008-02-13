//
//  O32DStructArray.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 2/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import "O3StructArray.h"

@interface O32DStructArray : O3StructArray {
	UIntP mRows, mCols;
	BOOL mTranspose:1;
}
- (O32DStructArray*)rows:(UIntP)r cols:(UIntP)cols rowMajor:(BOOL)rm; ///<Initialize a O32DStructArray by calling a O3StructArray constructor, then this ([[[O32DStructArray alloc] initWithType:t rawData:d] rows:5 cols:5 rowMajor:YES])
- (UIntP)rows;
- (UIntP)cols;
- (id)objectAtRow:(UIntP)row col:(UIntP)col;
- (void)setObjectAtRow:(UIntP)row col:(UIntP)col to:(id)obj;
- (void)getStruct:(void*)str atRow:(UIntP)row col:(UIntP)col;
- (void)setStruct:(const void*)str atRow:(UIntP)row col:(UIntP)col;
- (void)transpose;
- (BOOL)isRowMajor; ///<True if subsequent linear indicies go across rows first, then down columns. NOTE: this changes if you call mTranspose, rather than the underlying data changing. It just appears to change from the POV of the accessor.
@end

//O32DStructArray* O32DStructArrayWithBytesTypeRowsCols(void* bytes, const char* octype, UIntP r, UIntP c, BOOL rm); //Used by O3Matrix.h
//void O32DStructArrayGetR_C_RowMajor_(O32DStructArray* self, UIntP* r, UIntP* c, BOOL* rm); //Used by O3Matrix.h