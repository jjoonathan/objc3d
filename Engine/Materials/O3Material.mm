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
#import "O3Parameter.h"

typedef map<string, O3MaterialParameterPair> mParameters_t;

#ifdef __cplusplus
O3Parameter* O3MaterialParameterPair::Param(O3Material* pt) {
	if (cg_value) return cg_value;
	return [[[O3Parameter alloc] initWithName:paramName parent:pt] autorelease];
}

void O3MaterialParameterPair::Set(O3Material* parentMaterial) {
		if (cg_value && cg_to) {
			O3CGParameterBindValueFrom_to_(cg_value, cg_to);
		} else {
			[parentMaterial setValue:value forParam:paramName];
		}
	}
#endif

@implementation O3Material
O3DefaultO3InitializeImplementation
/************************************/ #pragma mark Private /************************************/
inline void setMaterialTypeP(O3Material* self, NSObject<O3MultipassDirector, O3HasParameters>* matType) {
	O3Assign(matType, self->mMaterialType);
	if (!self->mParameters) return;
	mParameters_t::iterator it=self->mParameters->begin(), e=self->mParameters->end();
	do {
		it->second.SetTarget(matType);
	} while ((++it)!=e);
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
	O3SuperInitOrDie();
	[self setMaterialTypeName:matTypeName];		
	NSMutableDictionary* pdict = [coder decodeObjectForKey:@"params"];
	NSEnumerator* pdictEnumerator = [pdict keyEnumerator];
	while (NSString* o = [pdictEnumerator nextObject]) {
		[self setValue:[pdict objectForKey:o] forParam:o];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding])
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
	NSArray* pnames = [self paramNames];
	NSEnumerator* pnamesEnumerator = [pnames objectEnumerator];
	NSMutableDictionary* pdict = [[NSMutableDictionary alloc] init];
	while (NSString* o = [pnamesEnumerator nextObject])
		[pdict setObject:[[self param:o] value] forKey:o];
	[coder encodeObject:pdict forKey:@"params"];
	if (mMaterialTypeName) [coder encodeObject:mMaterialTypeName forKey:@"materialType"];
	[pdict release];
}

- (void)dealloc {
	O3Destroy(mMaterialType);
	delete mParameters;
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
- (NSDictionary*)paramValues {
	NSMutableDictionary* md = [[[NSMutableDictionary alloc] init] autorelease];
	mParameters_t::iterator it = mParameters->begin();
	mParameters_t::iterator e = mParameters->end();
	do {
		[md setObject:it->second.Value() forKey:it->second.Name()];
	} while (it++ != e);
	return md;
}

- (NSArray*)paramNames {
	NSMutableArray* nms = [NSMutableArray array];
	mParameters_t::iterator it = mParameters->begin();
	mParameters_t::iterator e = mParameters->end();
	do {
		[nms addObject:it->second.Name()];
	} while (it++ != e);
	return nms;
}

- (id)valueForParam:(NSString*)pname {
	string k = [pname UTF8String];
	mParameters_t::iterator it = mParameters->find(k);
	if (it==mParameters->end()) return nil;
	return it->second.Value();
}

- (void)setValue:(id)val forParam:(NSString*)pname {
	string k = [pname UTF8String];
	if (!mParameters) mParameters = new mParameters_t();
	mParameters_t::iterator it = mParameters->find(k);
	if (it==mParameters->end()) {
		O3MaterialParameterPair& newPair = (*mParameters)[k];
		newPair.SetName(pname);
		newPair.SetTarget(mMaterialType);
		newPair.SetValue(val);
	} else {
		it->second.SetValue(val);
	}
}

- (O3Parameter*)param:(NSString*)pname {
	string k = [pname UTF8String];
	if (!mParameters) mParameters = new mParameters_t();
	mParameters_t::iterator it = mParameters->find(k);
	if (it==mParameters->end()) {
		O3MaterialParameterPair& newPair = (*mParameters)[k];
		newPair.SetName(pname);
		newPair.SetTarget(mMaterialType);
		return newPair.Param(self);
	} else {
		return it->second.Param(self);
	}
	return nil;
}



/************************************/ #pragma mark O3MultipassDirector /************************************/
- (int)renderPasses {
	return [mMaterialType renderPasses];
}
	
- (void)beginRendering {
	if (mParameters) {
		mParameters_t::iterator it = mParameters->begin();
		mParameters_t::iterator end = mParameters->end();
		for (; it!=end; it++) it->second.Set(self);
	}
	[mMaterialType beginRendering];
}
	
- (void)setRenderPass:(int)passnum {
	[mMaterialType setRenderPass:passnum];
}
	
- (void)endRendering {
	[mMaterialType endRendering];
}
	
- (BOOL)paramsAreCGParams {
	return NO;
}

@end

