/**
 *  @file O3CGMaterial.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 4/4/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3CGMaterial.h"
#import "O3KVCHelper.h"
#import "O3CGParameter.h"

typedef map<string, O3CGMaterialParameterPair> mParameters_t;

@implementation O3CGMaterial
/************************************/ #pragma mark Private /************************************/
inline void unbindParamsP(O3CGMaterial* self) {
	if (!self->mParamsToUnbind) return;
	vector<O3CGParameter*>::iterator it =  self->mParamsToUnbind->begin();
	vector<O3CGParameter*>::iterator end = self->mParamsToUnbind->end();
	for (; it!=end; it++)
		O3CGParameterUnbindValue(*it);
	delete self->mParamsToUnbind;
	self->mParamsToUnbind = NULL;
}



/************************************/ #pragma mark Construction and Destruction /************************************/
- (id)init {
	[self release];
	O3LogWarn(@"Cannot default initialize O3CGMaterial");
	return nil;
}

- (id)initWithMaterialType:(NSObject<O3MultipassDirector, O3HasCGParameters>*)materialType {
	O3SuperInitOrDie();
	O3Assign(materialType, mMaterialType);
	return self;
}

- (void)dealloc {
	unbindParamsP(self);
	O3Destroy(mParameterKVCHelper);
	O3Destroy(mMaterialType);
	O3DestroyCppContainer(mParameters_t, mParameters, , ->second.value);
	O3SuperDealloc();
}



/************************************/ #pragma mark Material type /************************************/
- (NSObject<O3MultipassDirector, O3HasCGParameters>*)materialType {
	return mMaterialType;
}

- (void)setMaterialType:(NSObject<O3MultipassDirector, O3HasCGParameters>*)materialType {
	O3Assign(materialType, mMaterialType);
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

///@note if \e param isn't a valid parameter name, \e value is completely ignored and not kept in the list of parameters. This behavior differs from that of O3Material.
///@note if setValue:forParameter: is called in the middle of a rendering pass, results take effect immediately.  This behavior differs from that of O3Material.
- (void)setValue:(NSObject*)value forParameter:(NSString*)param {
	if (!mParameters) mParameters = new mParameters_t();
	mParameters_t::iterator location = mParameters->find(NSString_cString(param));
	if (location==mParameters->end()) {
		if (!value) return;
		O3CGParameter* targ = [mMaterialType parameterNamed:param];
		if (!targ) {
			O3LogWarn(@"Tried to set value for CG parameter %s that doesn't exist in material type %s", [param UTF8String], [[mMaterialType description] UTF8String]);
			return;
		}
		O3CGMaterialParameterPair& val = (*mParameters)[NSString_cString(param)];
		val.target = targ;
		O3Assign([[O3CGParameter alloc] initWithType:[targ type]], val.value);
	} else {
		O3CGMaterialParameterPair& val = location->second;
		if (!value) {
			if (mParamsToUnbind) {
				vector<O3CGParameter*>::iterator it =  self->mParamsToUnbind->begin();
				vector<O3CGParameter*>::iterator end = self->mParamsToUnbind->end();
				O3CGParameter* valTarget = val.target;
				for (; it!=end; it++) {
					if (*it==valTarget) {
						O3CGParameterUnbindValue(*it);
						mParamsToUnbind->erase(it);
						break;
					}
				}
			}
			O3Destroy(val.value);
			mParameters->erase(location);
			return;
		}
		[val.value setValue:value];
	}
}

- (NSObject*)valueForParameter:(NSString*)param {
	if (!mParameters) return nil;
	const char* cname = NSString_cString(param);
	mParameters_t::iterator loc = mParameters->find(cname);
	if (loc==mParameters->end()) return nil;
	return (O3CGParameter*)[loc->second.value value]; //Return the parameter's value, not the parameter (it is an internal trick)
}



/************************************/ #pragma mark O3MultipassDirector /************************************/
- (int)renderPasses {
	return [mMaterialType renderPasses];
}

- (void)beginRendering {
	O3Assert(!mParamsToUnbind , @"Didn't call endRendering on O3CGMaterial that beginRendering was called on");
	if (mParameters) {
		mParameters_t::iterator it = mParameters->begin();
		mParameters_t::iterator end = mParameters->end();
		mParamsToUnbind = new vector<O3CGParameter*>(mParameters->size());
		int i=0; for (; it!=end; it++) {
			O3CGMaterialParameterPair& pair = it->second;
			O3CGParameterBindValue_to_(pair.target, pair.value);
			(*mParamsToUnbind)[i++] = pair.target;
		}
	}
	[mMaterialType beginRendering];
}

- (void)setRenderPass:(int)passnum {
	[mMaterialType setRenderPass:passnum];
}

- (void)endRendering {
	unbindParamsP(self);
	[mMaterialType endRendering];
}



@end

