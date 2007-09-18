/**
 *  @file O3Material.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 1/4/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3Material.h"
#import "O3KVCHelper.h"

typedef map<string, O3MaterialParameterPair> mParameters_t;

@implementation O3Material
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

- (void)dealloc {
	O3Destroy(mParameterKVCHelper);
	O3Destroy(mMaterialType);
	O3DestroyCppContainer(mParameters_t, mParameters, , ->second.value);
	O3SuperDealloc();
}

/************************************/ #pragma mark Material type /************************************/
- (NSObject<O3MultipassDirector, O3HasParameters>*)materialType {
	return mMaterialType;
}

- (void)setMaterialType:(NSObject<O3MultipassDirector, O3HasParameters>*)materialType {
	setMaterialTypeP(self, materialType);
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
	if (!mParameters) mParameters = new mParameters_t();
	mParameters_t::iterator location = mParameters->find(NSString_cString(param));
	if (location==mParameters->end()) {
		if (!value) return;
		O3MaterialParameterPair& val = (*mParameters)[NSString_cString(param)];
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
	const char* cname = NSString_cString(param);
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

