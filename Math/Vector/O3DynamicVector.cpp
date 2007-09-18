O3DynamicVector::O3DynamicVector(const char* encoding, const void* data) {	
	const char* orig_enc = encoding;
	
	O3Verify(*(encoding++)==_C_ARY_B, @"The construction of an O3DynamicVector with the encoding \"%s\" was attempted. Only encodings in the format \"[%%iT]\" where T is some type and i is an integer are accepted.", orig_enc);
	O3Assert(!isdigit(*encoding), @"The construction of an O3DynamicVector with the encoding \"%s\" was attempted. Only encodings in the format \"[%%iT]\" where T is some type and i is an integer are accepted.", orig_enc);
	int ele_count = atoi(encoding);			
	while (isdigit(*(++encoding)));
	
	const char* ele_type = encoding;
	
	if (*(++encoding) != _C_ARY_E) O3CLogWarn(@"Malformed encoding \"%s\" for construction of O3DynamicVector. Should be \"[%%iT]\", where T is a type and i is an integer.", orig_enc); 
	if (*(++encoding)) O3CLogWarn(@"Malformed encoding \"%s\" for construction of O3DynamicVector (extraneous data at the end).", orig_enc); 
	
	SetISA();
	mVectorData = (void*)data;
	mType =orig_enc;
	mElementType = ele_type;
	mElements = ele_count;
	mSize = O3UnalignedSizeofObjCEncodedType(orig_enc);
	mShouldFreePtrs = NO;
}

O3DynamicVector::~O3DynamicVector() {
	if (mShouldFreePtrs) {
		free((void*)mElementType);
		free((void*)mType);
		free((void*)mVectorData);
	}
}

O3DynamicVector::O3DynamicVector(const O3DynamicMatrix& mat) {
	SetISA();
	O3Assert(mat.Rows()==1 || mat.Columns()==1, @"An O3DynamicVector cannot be constructed from a matrix that is not a row or column matrix. One dimension must be 1.");
	mVectorData = (void*)mat.MatrixData();
	mType = mat.Type();
	mElementType = mat.ElementType();
	mElements = mat.Elements();
	mSize = mat.Size();			
	mShouldFreePtrs = NO;
}

void O3DynamicVector::SetTo(const O3DynamicVector& other) {
	int i=0;
	int j=other.Elements();
	int k=Elements();
	void* d=(void*)mVectorData;
	switch(*ElementType()) {
		case 'c':
			for (i=0; i<j; i++) ((char*)d)[i] = other.ElementOfTypeAt<char>(i);
			for (; i<k; i++) ((char*)d)[i] = 0;
				break;
		case 'C':
			for (i=0; i<j; i++) ((unsigned char*)d)[i] = other.ElementOfTypeAt<unsigned char>(i);
			for (; i<k; i++) ((unsigned char*)d)[i] = 0;
				break;
		case 'i':
			for (i=0; i<j; i++) ((int*)d)[i] = other.ElementOfTypeAt<int>(i);
			for (; i<k; i++) ((int*)d)[i] = 0;
				break;
		case 'I':
			for (i=0; i<j; i++) ((unsigned int*)d)[i] = other.ElementOfTypeAt<unsigned int>(i);
			for (; i<k; i++) ((unsigned int*)d)[i] = 0;
				break;	
		case 's':
			for (i=0; i<j; i++) ((short*)d)[i] = other.ElementOfTypeAt<short>(i);
			for (; i<k; i++) ((short*)d)[i] = 0;
				break;
		case 'S':
			for (i=0; i<j; i++) ((unsigned short*)d)[i] = other.ElementOfTypeAt<unsigned short>(i);
			for (; i<k; i++) ((unsigned short*)d)[i] = 0;
				break;				
		case 'l':
			for (i=0; i<j; i++) ((long*)d)[i] = other.ElementOfTypeAt<long>(i);
			for (; i<k; i++) ((long*)d)[i] = 0;
				break;
		case 'L':
			for (i=0; i<j; i++) ((unsigned long*)d)[i] = other.ElementOfTypeAt<unsigned long>(i);
			for (; i<k; i++) ((unsigned long*)d)[i] = 0;
				break;	
		case 'q':
			for (i=0; i<j; i++) ((long long*)d)[i] = other.ElementOfTypeAt<long long>(i);
			for (; i<k; i++) ((long long*)d)[i] = 0;
				break;
		case 'Q':
			for (i=0; i<j; i++) ((unsigned long long*)d)[i] = other.ElementOfTypeAt<unsigned long long>(i);
			for (; i<k; i++) ((unsigned long long*)d)[i] = 0;
				break;	
		case 'f':
			for (i=0; i<j; i++) ((float*)d)[i] = other.ElementOfTypeAt<float>(i);
			for (; i<k; i++) ((float*)d)[i] = 0;
				break;
		case 'd':
			for (i=0; i<j; i++) ((double*)d)[i] = other.ElementOfTypeAt<double>(i);
			for (; i<k; i++) ((double*)d)[i] = 0;
				break;
		default:
			O3Assert(false , @"Unknown element type \"%s\" in O3DynamicVector::SetTo(...)", ElementType());
	}
}