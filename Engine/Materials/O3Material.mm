/**
 *  @file O3Material.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 1/4/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3Material.h"
#import "O3KVCHelper.h"
#import "O3ResManager.h"
#import "O3CGMaterial.h"

typedef map<string, O3MaterialParameterPair> mParameters_t;

@implementation O3Material
O3DefaultO3InitializeImplementation
/************************************/ #pragma mark Private /************************************/
inline void setMaterialTypeP(O3Material* self, NSObject<O3MultipassDirector, O3HasParameters>* matType) {
	O3Assign(matType, self->mMaterialType);
}

/************************************/ #pragma mark Construction and Destruction /************************************/
- (id)init {
	[self release];
	O3LogWarn(@"Cannot default initialize O3Material");
	return nil;
}

- (id)initWithMaterialType:(NSObject<O3MultipassDirector, O3HasParameters>*)materialType {
	O3SuperInitOrDie();
	setMaterialTypeP(self, materialType);
	return self;
}

- (id)initWithMaterialTypeNamed:(NSString*)name {
	O3SuperInitOrDie();
	[self setMaterialTypeName:name];
	return self;
}

- (id)initWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding]) {
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be decoded with a non-keyed archiver", self];
		[self release];
		return nil;
	}
	NSString* matTypeName = [coder decodeObjectForKey:@"materialType"];
	if ([[O3RMGM() valueForKey:matTypeName] conformsToProtocol:@protocol(O3HasCGParameters)]) {
		[self release];
		self = [[O3CGMaterial alloc] initWithMaterialTypeNamed:matTypeName];
	} else {
		O3SuperInitOrDie();
		[self setMaterialTypeName:matTypeName];		
	}
	NSMutableDictionary* pdict = [coder decodeObjectForKey:@"params"];
	NSEnumerator* pdictEnumerator = [pdict keyEnumerator];
	while (NSString* o = [pdictEnumerator nextObject]) {
		[self setValue:[pdict objectForKey:o] forParameter:o];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding])
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
	NSArray* pnames = [self parameterNames];
	NSEnumerator* pnamesEnumerator = [pnames objectEnumerator];
	NSMutableDictionary* pdict = [[NSMutableDictionary alloc] init];
	while (NSString* o = [pnamesEnumerator nextObject])
		[pdict setObject:[self valueForParameter:o] forKey:o];
	[coder encodeObject:pdict forKey:@"params"];
	if (mMaterialTypeName) [coder encodeObject:mMaterialTypeName forKey:@"materialType"];
	[pdict release];
}

- (void)dealloc {
	O3Destroy(mParameterKVCHelper);
	O3Destroy(mMaterialType);
	O3DestroyCppContainer(mParameters_t, mParameters, , ->second.value);
	O3Destroy(mMaterialTypeName);
	[self unbind:@"materialType"];
	O3SuperDealloc();
}

/************************************/ #pragma mark Material type /************************************/
- (NSObject<O3MultipassDirector, O3HasParameters>*)materialType {
	return mMaterialType;
}

- (void)setMaterialType:(NSObject<O3MultipassDirector, O3HasParameters>*)materialType {
	setMaterialTypeP(self, materialType);
}

- (NSString*)materialTypeName {
	return mMaterialTypeName;
}

- (void)setMaterialTypeName:(NSString*)newName {
	[self unbind:@"materialType"];
	O3Assign(newName,mMaterialTypeName);
	if (newName) {
		[self bind:@"materialType" toObject:gO3ResManagerSharedInstance withKeyPath:newName options:nil];
	}
}



/************************************/ #pragma mark mParameters /************************************/
- (id)parameters {
	if (!mParameterKVCHelper) mParameterKVCHelper = [[O3KVCHelper alloc] initWithTarget:self
                                                                        valueForKeyMethod:@selector(valueForParameter:)
                                                                     setValueForKeyMethod:@selector(setValue:forParameter:)
                                                                           listKeysMethod:@selector(parameterNames)];
	return mParameterKVCHelper;
}

- (NSArray*)parameterNames {
	if (!mParameters) return [NSArray array];
	mParameters_t::iterator it = mParameters->begin();
	mParameters_t::iterator end = mParameters->end();
	NSMutableArray* to_return = [NSMutableArray array];
	for (; it!=end; it++) {
		const char* cstr = it->first.c_str();
		[to_return addObject:[NSString stringWithUTF8String:cstr]];
	}
	return to_return;
}

///@note if \e param isn't a valid parameter name, \e value is kept in the list of parameters anyways (and ignored). This behavior differs from that of O3CGMaterial.
///@note if setValue:forParameter: is called in the middle of a rendering pass, results take effect on the next pass. This behavior differs from that of O3CGMaterial.
- (void)setValue:(NSObject*)value forParameter:(NSString*)param {
	value = O3Descriptify(value);
	if (!mParameters) mParameters = new mParameters_t();
	mParameters_t::iterator location = mParameters->find(NSStringUTF8String(param));
	if (location==mParameters->end()) {
		if (!value) return;
		O3MaterialParameterPair& val = (*mParameters)[NSStringUTF8String(param)];
		O3Assign(value, val.value);
	} else {
		O3MaterialParameterPair& val = location->second;
		if (!value) {
			O3Destroy(val.value);
			mParameters->erase(location);
			return;
		}
		O3Assign(value, val.value);
	}
}

- (NSObject*)valueForParameter:(NSString*)param {
	if (!mParameters) return nil;
	const char* cname = NSStringUTF8String(param);
	mParameters_t::iterator loc = mParameters->find(cname);
	if (loc==mParameters->end()) return nil;
	return loc->second.value;
}


/************************************/ #pragma mark O3MultipassDirector /************************************/
- (int)renderPasses {
	return [mMaterialType renderPasses];
}
	
- (void)beginRendering {
	if (mParameters) {
		mParameters_t::iterator it = mParameters->begin();
		mParameters_t::iterator end = mParameters->end();
		for (; it!=end; it++) {
			O3MaterialParameterPair& pair = it->second;
			[pair.target setValue:pair.value];
		}
	}
	[mMaterialType beginRendering];
}
	
- (void)setRenderPass:(int)passnum {
	[mMaterialType setRenderPass:passnum];
}
	
- (void)endRendering {
	[mMaterialType endRendering];
}
	


@end

