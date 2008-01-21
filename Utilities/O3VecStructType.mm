//
//  O3VecStructType.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3FaceStructType.h"
#import "O3VecStructType.h"
#import "O3ScalarStructType.h"
#import "O3GPUData.h"

O3EXTERN_C_BLOCK

#define DefType(NAME, TYPE, ETYPE, CT) O3VecStructType* g ## NAME;   O3VecStructType* NAME () {return g ## NAME;}
O3VecStructTypeDefines
#undef DefType

#define DefType(NAME, TYPE, ETYPE, CT) int NAME ## Comparator (void* a, void* b, void* ctx) {\
	TYPE* aa = (TYPE*)a;\
	TYPE* bb = (TYPE*)b;\
	UIntP i; for(i=0; i<CT; i++) {\
		if (aa[i]<bb[i]) return NSOrderedAscending;\
		if (aa[i]>bb[i]) return NSOrderedDescending;\
	}\
	return NSOrderedSame;\
}
O3VecStructTypeDefines
#undef DefType

O3END_EXTERN_C_BLOCK



@implementation O3VecStructType
O3DefaultO3InitializeImplementation

O3EXTERN_C_BLOCK
UIntP* O3VecStructTypePermsAndMultiplier(O3VecStructType* self, double* multiplier) {
	*multiplier = self->mMultiplier;
	return self->mPermutations;
}

void O3VecStructTypeGetType_count_specificType_(O3VecStructType* self, O3CType* type, short* count, O3VecStructSpecificType* stype) {
	if (type) *type = self->mElementType;
	if (count) *count = self->mElementCount;
	if (stype) *stype = self->mSpecificType;
}

UIntP O3VecStructSize(O3VecStructType* type) {
	return O3CTypeSize(type->mElementType)*type->mElementCount;
}
O3END_EXTERN_C_BLOCK

/************************************/ #pragma mark Class Methods /************************************/
+ (void)o3init {
	O3CompileAssert(*@encode(real)=='f' || *@encode(real)=='d', @"O3VecStructType assumes that real is eather float or double");
	O3CType rtype = *@encode(real)=='f'? O3FloatCType : O3DoubleCType;
	gO3Vec3rType = [[O3VecStructType alloc] initWithElementType:rtype                     specificType:O3VecStructVec count:3 name:@"vec3r" comparator:O3Vec3rTypeComparator];
	gO3Vec3fType = [[O3VecStructType alloc] initWithElementType:O3FloatCType   specificType:O3VecStructVec count:3 name:@"vec3f" comparator:O3Vec3fTypeComparator];
	gO3Vec3dType = [[O3VecStructType alloc] initWithElementType:O3DoubleCType  specificType:O3VecStructVec count:3 name:@"vec3d" comparator:O3Vec3dTypeComparator];
	gO3Vec4rType = [[O3VecStructType alloc] initWithElementType:rtype                     specificType:O3VecStructVec count:4 name:@"vec4r" comparator:O3Vec4rTypeComparator];
	gO3Vec4fType = [[O3VecStructType alloc] initWithElementType:O3FloatCType   specificType:O3VecStructVec count:4 name:@"vec4f" comparator:O3Vec4fTypeComparator];
	gO3Vec4dType = [[O3VecStructType alloc] initWithElementType:O3DoubleCType  specificType:O3VecStructVec count:4 name:@"vec4d" comparator:O3Vec4dTypeComparator];
	gO3RGBA8Type = [[O3VecStructType alloc] initWithElementType:O3UInt8CType  specificType:O3VecStructVec count:4 name:@"RGBA8" comparator:O3RGBA8TypeComparator];
		[gO3RGBA8Type setMultiplier:1./255];
	gO3RGB8Type    = [[O3VecStructType alloc] initWithElementType:O3UInt8CType  specificType:O3VecStructVec count:3 name:@"RGB8" comparator:O3RGB8TypeComparator];
		[gO3RGB8Type setMultiplier:1./255];
	gO3Rot3dType     = [[O3VecStructType alloc] initWithElementType:O3DoubleCType  specificType:O3VecStructRotation count:3 name:@"rot3d" comparator:O3Rot3dTypeComparator];
	//gO3Point3d   = [[O3VecStructType alloc] initWithElementType:O3DoubleCType  specificType:O3VecStructPoint count:3 name:@"point3d"];
	gO3Point3fType   = [[O3VecStructType alloc] initWithElementType:O3FloatCType   specificType:O3VecStructPoint count:3 name:@"point3f" comparator:O3Point3fTypeComparator];
	//gO3Point4d   = [[O3VecStructType alloc] initWithElementType:O3DoubleCType  specificType:O3VecStructPoint count:4 name:@"point4d"];
	gO3Scale3dType   = [[O3VecStructType alloc] initWithElementType:O3DoubleCType  specificType:O3VecStructScale count:3 name:@"scale3d" comparator:O3Scale3dTypeComparator];
	gO3Index3x8Type  = [[O3VecStructType alloc] initWithElementType:O3UInt8CType   specificType:O3VecStructIndex count:3 name:@"idx3x8" comparator:O3Index3x8TypeComparator];
	gO3Index3x16Type = [[O3VecStructType alloc] initWithElementType:O3UInt16CType  specificType:O3VecStructIndex count:3 name:@"idx3x16" comparator:O3Index3x16TypeComparator];
	gO3Index3x32Type = [[O3VecStructType alloc] initWithElementType:O3UInt32CType  specificType:O3VecStructIndex count:3 name:@"idx3x32" comparator:O3Index3x32TypeComparator];
	gO3Index3x64Type = [[O3VecStructType alloc] initWithElementType:O3UInt64CType  specificType:O3VecStructIndex count:3 name:@"idx3x64" comparator:O3Index3x64TypeComparator];
	gO3Index4x8Type  = [[O3VecStructType alloc] initWithElementType:O3UInt8CType   specificType:O3VecStructIndex count:4 name:@"idx4x8" comparator:O3Index4x8TypeComparator];
	gO3Index4x16Type = [[O3VecStructType alloc] initWithElementType:O3UInt16CType  specificType:O3VecStructIndex count:4 name:@"idx4x16" comparator:O3Index4x16TypeComparator];
	gO3Index4x32Type = [[O3VecStructType alloc] initWithElementType:O3UInt32CType  specificType:O3VecStructIndex count:4 name:@"idx4x32" comparator:O3Index4x32TypeComparator];
	gO3Index4x64Type = [[O3VecStructType alloc] initWithElementType:O3UInt64CType  specificType:O3VecStructIndex count:4 name:@"idx4x64" comparator:O3Index4x64TypeComparator];
}

+ (O3VecStructType*)vec3fType {return O3Vec3fType();}
+ (O3VecStructType*)vec3dType {return O3Vec3dType();}
+ (O3VecStructType*)vec3rType {return O3Vec3rType();}
+ (O3VecStructType*)vec4fType {return O3Vec4fType();}
+ (O3VecStructType*)vec4dType {return O3Vec4dType();}
+ (O3VecStructType*)vec4rType {return O3Vec4rType();}
+ (O3VecStructType*)rot3dType     {return O3Rot3dType();    }
//+ (O3VecStructType*)point3dType  {return O3Point3dType();  }
+ (O3VecStructType*)point3fType  {return O3Point3fType();  }
//+ (O3VecStructType*)point4dType  {return O3Point4dType();  }
+ (O3VecStructType*)scale3dType   {return O3Scale3dType();  }
+ (O3VecStructType*)index3x8Type  {return O3Index3x8Type(); }
+ (O3VecStructType*)index3x16Type {return O3Index3x16Type();}
+ (O3VecStructType*)index3x32Type {return O3Index3x32Type();}
+ (O3VecStructType*)index3x64Type {return O3Index3x64Type();}
+ (O3VecStructType*)index4x8Type  {return O3Index4x8Type(); }
+ (O3VecStructType*)index4x16Type {return O3Index4x16Type();}
+ (O3VecStructType*)index4x32Type {return O3Index4x32Type();}
+ (O3VecStructType*)index4x64Type {return O3Index4x64Type();}

///@returns a new autoreleased vector 
+ (O3VecStructType*)vecStructTypeWithElementType:(O3CType)type
                                    specificType:(O3VecStructSpecificType)stype
                                           count:(int)count
                                            name:(NSString*)name 
                                      comparator:(O3StructArrayComparator)comp {
	O3StructType* existingType = name? O3StructTypeForName(name) : nil;
	if (existingType) return (O3VecStructType*)existingType;
	return [[[self alloc] initWithElementType:type specificType:stype count:count name:name comparator:comp] autorelease];
}

/************************************/ #pragma mark Init /************************************/
- (O3VecStructType*)initWithElementType:(O3CType)type specificType:(O3VecStructSpecificType)stype count:(int)count name:(NSString*)name comparator:(O3StructArrayComparator)comp {
	[super initWithName:name];
	mMultiplier = 1;
	mElementType = type;
	mElementCount = count;
	mSpecificType = stype;
	mComp = comp;
	return self;
}

- (void)dealloc {
	if (mFreePermsWhenDone) free(mPermutations);
	O3SuperDealloc();
}

/************************************/ #pragma mark Custom Accessors /************************************/
- (O3CType)elementType {
	return mElementType;
}

- (O3VecStructSpecificType)specificType {
	return mSpecificType;
}

- (short)elementCount {
	return mElementCount;
}

/************************************/ #pragma mark O3StructType /************************************/
- (UIntP)structSize {return O3VecStructSize(self);}

- (id)objectWithBytes:(const void*)bytes {
	NSMutableArray* to_return = [[[NSMutableArray alloc] initWithCapacity:mElementCount] autorelease];
	int j = mElementCount;
	UIntP ele_size = O3CTypeSize(mElementType);
	if (mPermutations) {
		for (int i=0; i<j; i++) {
			void* val = (UInt8*)bytes + mPermutations[i]*ele_size;
			[to_return addObject:O3CTypeNSValueWithMult(mElementType, val, mMultiplier)];
		}
	} else {
		for (int i=0; i<j; i++) {
			void* val = (UInt8*)bytes + i*ele_size;
			[to_return addObject:O3CTypeNSValueWithMult(mElementType, val, mMultiplier)];
		}		
	}
	return to_return;
}

- (void)writeObject:(id)dict toBytes:(void*)bytes {
	O3Assert([dict respondsToSelector:@selector(objectAtIndex:)], @"Invalid conversion (%@ is not a valid struct of type %@)", dict, [self className]);
	int j = mElementCount;
	double rmul = 1./mMultiplier;
	UIntP ele_size = O3CTypeSize(mElementType);
	if (mPermutations) {
		for (int i=0; i<j; i++) {
			void* val = (UInt8*)bytes + mPermutations[i]*ele_size;
			O3CTypeSetNSValueWithMult(mElementType, val, [(NSArray*)dict objectAtIndex:i], rmul);
		}
	} else {
		for (int i=0; i<j; i++) {
			void* val = (UInt8*)bytes + i*ele_size;
			O3CTypeSetNSValueWithMult(mElementType, val, [(NSArray*)dict objectAtIndex:i], rmul);
		}		
	}
}

- (NSData*)portabalizeStructsAt:(const void*)at count:(UIntP)count stride:(UIntP)s {
	O3RawData rd = O3CTypePortabalize(mElementType, at, s, 1, count*mElementCount);
	return [NSData dataWithBytesNoCopy:rd.bytes length:rd.length freeWhenDone:YES];
}

- (NSData*)deportabalizeStructs:(NSData*)indata to:(void*)target stride:(UIntP)s {
	if (!O3NeedByteswapToLittle && !target) return indata;
	UIntP size = [indata length];
	O3RawData rd = O3CTypeDeportabalize(mElementType, [indata bytes], target, s, size/O3CTypeSize(mElementType), mElementCount);
	[indata relinquishBytes];
	return rd.length? [NSData dataWithBytesNoCopy:target length:rd.length freeWhenDone:YES] : nil;
}

- (NSMutableData*)translateStructs:(NSData*)instructs stride:(UIntP)s toFormat:(O3StructType*)oformat {
	BOOL other_is_vec = [oformat isKindOfClass:[O3VecStructType class]];
	BOOL other_is_scalar = [oformat isKindOfClass:[O3ScalarStructType class]];
	if (!(other_is_vec ^ other_is_scalar)) return [super translateStructs:instructs stride:s toFormat:oformat];
	UIntP o_elementCount = other_is_scalar? 1 : [(O3VecStructType*)oformat elementCount];
	UIntP* o_perms = other_is_vec? [(O3VecStructType*)oformat permutations] : nil;
	UIntP o_stride = [oformat structSize];
	O3CType o_eleType = other_is_scalar? [(O3ScalarStructType*)oformat type] : [(O3VecStructType*)oformat elementType];
	UIntP o_eleStride = O3CTypeSize(o_eleType);
	O3CType in_eleType = mElementType;
	UIntP in_eleStride = O3CTypeSize(in_eleType);
	UIntP in_stride = s ?: [self structSize];
	UIntP in_count = [instructs length]/s;
	//UIntP in_ele_count = in_count * mElementCount;
	//UIntP o_count = in_ele_count / o_elementCount; O3Asrt(!(in_ele_count%o_elementCount));
	
	const UInt8* fbytes = (const UInt8*)[instructs bytes];
	NSMutableData* ret = [NSMutableData dataWithLength:o_stride*in_count];
	UInt8* tbytes = (UInt8*)[ret mutableBytes];
	
	UIntP i,j; for(i=0; i<in_count; i++) for (j=0; j<o_elementCount; j++) {
		UIntP tidx = o_perms? o_perms[j] : j;
		UInt8* tloc = tbytes + o_stride*i + tidx*o_eleStride;
		if (j>=mElementCount) {O3CTypeSetDoubleValue(o_eleType, tloc, 0); continue;}
		UIntP fidx = mPermutations? mPermutations[j] : j;
		const UInt8* floc = fbytes + i*in_stride + fidx*in_eleStride;
		O3CTypeTranslateFromTo(in_eleType, o_eleType, floc, tloc);
	}
	
	return ret;
}

/************************************/ #pragma mark Special info /************************************/
- (double)multiplier {
	return mMultiplier;
}

- (void)setMultiplier:(double)newMult {
	mMultiplier = newMult;
}

///Overrides ignored
- (UIntP*)permutations {
	return mPermutations;
}

- (void)setPermutations:(UIntP*)newPerms freeWhenDone:(BOOL)fwd {
	if (mFreePermsWhenDone) free(mPermutations);
	mPermutations = newPerms;
	mFreePermsWhenDone = fwd;
}

- (void)getFormat:(out GLenum*)format components:(out GLsizeiptr*)components offset:(out GLint*)offset stride:(out GLint*)stride normed:(out GLboolean*)normed vertsPerStruct:(out int*)vps forType:(in O3VertexDataType)type {
	if (format) {
	   switch (mElementType) {
	   	case O3FloatCType:  *format = GL_FLOAT; break;
	   	case O3DoubleCType: *format = GL_DOUBLE; break;
	   	case O3Int8CType:   *format = GL_BYTE; break;
	   	case O3Int16CType:  *format = GL_SHORT; break;
	   	case O3Int32CType:  *format = GL_INT; break;
	   	//case O3Int64CType:  return 0;
	   	case O3UInt8CType:  *format = GL_UNSIGNED_BYTE; break;
	   	case O3UInt16CType: *format = GL_UNSIGNED_SHORT; break;
		case O3UInt32CType: *format = GL_UNSIGNED_INT; break;
	   	//case O3UInt64CType: return 0;
		default: O3AssertFalse(@"Unknown GL type for type \"%c\" in vec struct %@", mElementType, self);
	   }
	   
	}
	if (components) *components = mElementCount;
	if (offset) *offset = 0;
	if (stride) *stride = O3VecStructSize(self);
	if (normed) *normed = (mMultiplier<.5)? GL_TRUE : GL_FALSE;
	if (vps) *vps = 1;
}

- (O3StructArrayComparator)defaultComparator {
	return mComp;
}

@end
