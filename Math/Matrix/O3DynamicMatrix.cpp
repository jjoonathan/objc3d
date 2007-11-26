#include "ObjCEncoding.h"
#include "O3BufferedReader.h"

void O3DynamicMatrix::SetTo(const O3DynamicMatrix& other) {
	switch(*ElementType()) {
		case 'c': SetToType<char>(other); 				break;
		case 'C': SetToType<unsigned char>(other); 		break;
		case 'i': SetToType<int>(other); 				break;
		case 'I': SetToType<unsigned int>(other); 		break;	
		case 's': SetToType<short>(other); 				break;
		case 'S': SetToType<unsigned short>(other); 	break;				
		case 'l': SetToType<long>(other); 				break;
		case 'L': SetToType<unsigned long>(other); 		break;	
		case 'q': SetToType<long long>(other); 			break;
		case 'Q': SetToType<unsigned long long>(other); break;	
		case 'f': SetToType<float>(other); 				break;
		case 'd': SetToType<double>(other); 			break;
		default: O3Assert(false , @"Unknown element type \"%s\" in O3DynamicVector::SetTo(...)", ElementType());
	}
}

O3DynamicMatrix::O3DynamicMatrix(const O3DynamicVector& vec) {
	SetISA();
	mMatrixData = vec.VectorData();
	mType = vec.Type();
	mElementType = vec.ElementType();
	mRows = vec.Rows();
	mColumns = vec.Columns();
	mSize = vec.Size();			
	mShouldFreeMatrixDat =  NO;
	mShouldFreeType      =  NO;
	mShouldFreeEleType   =  NO;
}

///Create a dynamic matrix using an encode type and a pointer. The encoding MUST be in the format "[%i[%i]]".
O3DynamicMatrix::O3DynamicMatrix(const char* encoding, const void* data, BOOL freeWhenDone) {
	initWithEncoding_data_(encoding, data, freeWhenDone);
}

///@param freeWhenDone dictates weather ele_type and data should be freed when the receiver is done with them
void O3DynamicMatrix::initWithRows_Cols_ElementType_data_(int rows, int cols, const char* ele_type, const void* data, BOOL freeMatWhenDone, BOOL freeEleTypeWhenDone) {
	SetISA();
	mMatrixData = data;
	mElementType = ele_type;
	mType = NULL;
	mRows = rows;
	mColumns = cols;
	mSize = (rows*cols?:1)*O3UnalignedSizeofObjCEncodedType(ele_type);
	mShouldFreeMatrixDat =  freeMatWhenDone;
	mShouldFreeType      =  NO;
	mShouldFreeEleType   =  freeEleTypeWhenDone;
}

///@param freeWhenDone dictates weather %encoding and %data should be freed when the receiver is done with them
void O3DynamicMatrix::initWithEncoding_data_(const char* encoding, const void* data, BOOL freeWhenDone) {
	SetISA();
	const char* orig_enc = encoding;
	
	O3Verify(*(encoding++)==OCTYPE_ARY_B, @"The construction of an O3DynamicMatrix with the encoding \"%s\" was attempted. Only encodings in the format \"[%%i[%%iT]]\" where T is some type are accepted.", orig_enc);
	O3Assert(!isdigit(*encoding), @"The construction of an O3DynamicMatrix with the encoding \"%s\" was attempted. Only encodings in the format \"[%%i[%%iT]]\" where T is some type are accepted.", orig_enc);
	int rows = atoi(encoding);			
	while (isdigit(*(++encoding)));
	
	O3Verify(*(encoding++)==OCTYPE_ARY_B, @"The construction of an O3DynamicMatrix with the encoding \"%s\" was attempted. Only encodings in the format \"[%%i[%%iT]]\" where T is some type and i is an integer are accepted.", orig_enc);
	O3Assert(!isdigit(*encoding), @"The construction of an O3DynamicMatrix with the encoding \"%s\" was attempted. Only encodings in the format \"[%%i[%%iT]]\" where T is some type and i is an integer are accepted.", orig_enc);
	int cols = atoi(encoding);			
	while (isdigit(*(++encoding)));
	
	const char* ele_type = encoding;
	
	if (*(++encoding) != OCTYPE_ARY_E) O3CLogWarn(@"Malformed encoding \"%s\" for construction of O3DynamicMatrix.", orig_enc); 
	if (*(++encoding) != OCTYPE_ARY_E) O3CLogWarn(@"Malformed encoding \"%s\" for construction of O3DynamicMatrix.", orig_enc); 
	if (*(++encoding)) O3CLogWarn(@"Malformed encoding \"%s\" for construction of O3DynamicMatrix (extraneous data at the end).", orig_enc); 
	
	mMatrixData = data;
	mElementType = ele_type;
	mType = orig_enc;
	mRows = rows;
	mColumns = cols;
	mSize = O3UnalignedSizeofObjCEncodedType(orig_enc);
	mShouldFreeMatrixDat =  freeWhenDone;
	mShouldFreeType      =  freeWhenDone;
	mShouldFreeEleType   =  NO;
}

O3DynamicMatrix::O3DynamicMatrix(O3BufferedReader* r) {
	UInt8 b = r->ReadByte();
	unsigned rows = (b>>3)&0x7; if (rows==0x7) rows = r->ReadUCIntAsUInt32();
	unsigned cols = b&0x7;  if (cols==0x7) cols = r->ReadUCIntAsUInt32();
	BOOL free_ele = NO;
	UInt8 type = b>>6; //Element type
	const char* enc;
		if (type==0) enc="d";
		if (type==1) enc="f";
		if (type==2) enc="i";
		if (type==3) {enc = strdup([r->ReadCCString(O3CCSStringTable) UTF8String]); free_ele=YES;}
	initWithRows_Cols_ElementType_data_(rows, cols, enc, O3DeserializedBytesOfType(enc, r, rows*cols?:1), YES, free_ele);
}

O3DynamicMatrix::~O3DynamicMatrix() {
	if (mShouldFreeMatrixDat) free((void*)mMatrixData);
	if (mShouldFreeType)      free((void*)mType);
	if (mShouldFreeEleType)   free((void*)mElementType);
}

///Transfers ownership of the matrix to the receiver by copying it.
void O3DynamicMatrix::CopyData() {
	mShouldFreeMatrixDat =  YES;
	mShouldFreeType      =  YES;
	mShouldFreeEleType   =  YES;
	mElementType = strdup(mElementType);
	mType = strdup(mType);
	void* newMatData = malloc(mSize);
	memcpy(newMatData, mMatrixData, mSize);
	mMatrixData = newMatData;
}

///Only copies other's references, not its data. Use CopyData() for that.
O3DynamicMatrix::O3DynamicMatrix(const O3DynamicMatrix& other) {
	mMatrixData = other.MatrixData();
	mType = other.Type();
	mElementType = other.ElementType();
	mRows = other.Rows();
	mColumns = other.Columns();
	mSize = other.Size();
	mShouldFreeMatrixDat =  NO;
	mShouldFreeType      =  NO;
	mShouldFreeEleType   =  NO;
}

///@warning This format cannot change without changing the format in O3Value.mm for -portableData in the NSValue category (some types are stored as "0x0" matricies)
NSData* O3DynamicMatrix::PortableData() const {
	NSMutableData* dat = [NSMutableData dataWithCapacity:32];
	O3BufferedWriter w(dat);
	UInt8 byte;
	UIntP rows = Rows();
	UIntP cols = Columns();
	byte = (rows<6)? rows<<3 : 7;
	byte |= (cols<6)? cols : 7;
	if (!strcmp(mElementType, "d")) byte |= 0<<6;
	else if (!strcmp(mElementType, "f")) byte |= 1<<6;
	else if (!strcmp(mElementType, "i")) byte |= 2<<6;
	else byte |= 3<<6;
	w.WriteByte(byte);
	if (rows>6) w.WriteUCInt(Rows());
	if (cols>6) w.WriteUCInt(Columns());
	if (byte&0xC0==3) w.WriteCCString(mElementType);
	O3SerializeDataOfType(mMatrixData, mElementType, &w, Rows()*Columns());
	return dat;
}

///@note Tests byte equality, so as far as this is concerned -0 != 0 and nan==nan!=(other nan). Turn into a matrix if you want numerical equality.
const BOOL O3DynamicMatrix::IsEqual(const O3DynamicMatrix* other) {
	if (!other) return false;
	if (mSize!=other->mSize) return false;
	if (strcmp(mElementType, other->mElementType)) return false;
	if (mRows!=other->mRows || mColumns!=other->mColumns) return false;
	return !memcmp(other->mMatrixData, mMatrixData, mSize);
}
