/**
 *  @file O3RawVertexData.mm
 *  @license MIT License (see LICENSE.txt)
 *  @date 12/27/06.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2006 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#import "O3RawVertexData.h"
#import "O3VertexFormats.h"
#include <map>

const NSString* O3RawVertexDataDoublyMappedException  = @"O3RawVertexDataDoublyMappedException";
const NSString* O3VertexDataTypeUnrecognizedException = @"O3VertexDataTypeUnrecognizedException";
//std::map<O3VertexDataType, O3RawVertexData*> gBoundVertexDataObjectsForTypes();
BOOL gVertexDataClassInitialized = NO;
GLint gMaximumVertexAttributes;
O3SupportLevel gVertexDataBufferSupport;

@interface O3RawVertexData (Private)
- (void)setAccessHint:(GLenum)accessHint;
- (void)setSize:(GLsizeiptr)size;
@end

@implementation O3RawVertexData (Private)
- (void)setAccessHint:(GLenum)accessHint	{mAccessHint=accessHint;}
- (void)setSize:(GLsizeiptr)size	{mSize=size;}
@end

@implementation O3RawVertexData
O3DefaultO3InitializeImplementation

inline void O3RawVertexData_InitVertexData() {
	if (gVertexDataClassInitialized) return;
	gVertexDataClassInitialized = YES;
	if (!gMaximumVertexAttributes) glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &gMaximumVertexAttributes);
	
	if (GLEW_ARB_vertex_buffer_object) gVertexDataBufferSupport = O3FullySupported;
	else if (GL_VERSION_1_1) gVertexDataBufferSupport = O3FallbackSupported; //Support for glVertexPointer and friends (vertex arrays)
	else gVertexDataBufferSupport = O3NotSupported;
}

inline void O3RawVertexData_Init(O3RawVertexData* self) {
	O3RawVertexData_InitVertexData(); //Checks if it's necessary
	O3AssertIvar(gVertexDataBufferSupport);
	if (gVertexDataBufferSupport==O3FullySupported) glGenBuffersARB(1, &(self->mVertexBufferID));
	else self->mVertexArray = (void*)0x1; //Bogus but flags that we are in face a vertex array
	self->mAccessHint = GL_STATIC_DRAW;
}

inline void O3RawVertexData_QuickBind(O3RawVertexData* self, BOOL isElementArray = NO) {
	if (self->mVertexArray) return; //No need to bind if we are in fallback mode
	if (!self) {
		if (isElementArray) glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, GL_ZERO);
		else				glBindBufferARB(GL_ARRAY_BUFFER_ARB, GL_ZERO);
	}
	glBindBufferARB((isElementArray)?GL_ELEMENT_ARRAY_BUFFER_ARB:GL_ARRAY_BUFFER_ARB,
					self->mVertexBufferID);
}
void O3RawVertexData_Bind(O3RawVertexData* self) {O3RawVertexData_QuickBind(self);}

inline void O3RawVertexData_AssertRangeValid(O3RawVertexData* self, NSRange range) {
	O3Assert(range.location<=(self->mSize) , @"O3RawVertexData_AssertRangeValid()");
	O3Assert((range.location+range.length)<=(self->mSize) , @"O3RawVertexData_AssertRangeValid()");
}

inline void O3RawVertexData_Unbind(O3RawVertexData* self, BOOL isElementArray = NO) {
	if (self->mVertexArray) return; //No need to unbind if we are in fallback mode
	glBindBufferARB((isElementArray)?GL_ELEMENT_ARRAY_BUFFER_ARB:GL_ARRAY_BUFFER_ARB,
					GL_ZERO);
}	

- (id)init {
	O3SuperInitOrDie();
	O3RawVertexData_Init(self);
	return self;
}

- (void)dealloc {
	[self unbind];
	if (mBoundTypes) delete mBoundTypes; /*mBoundTypes = NULL;*/
	O3SuperDealloc();
}

- (id)initWithBytes:(UInt8*)bytes size:(GLsizeiptr)size accessHint:(GLenum)accessHint {
	O3SuperInitOrDie();
	O3RawVertexData_Init(self);
	[self setSize:size];
	
	O3RawVertexData_QuickBind(self);
	if (accessHint) mAccessHint = accessHint;
	if (mVertexArray) {
		mVertexArray = malloc(size);
		memcpy(mVertexArray, (void*)bytes, size);
	} else 
		glBufferDataARB(GL_ARRAY_BUFFER_ARB, size, bytes, mAccessHint);
	return self;
}

- (void)setBytes:(UInt8*)bytes size:(GLsizeiptr)size accessHint:(GLenum)accessHint {
	[self setAccessHint:accessHint];
	[self setSize:size];

	O3RawVertexData_QuickBind(self);
	if (mVertexArray) {
		if (mVertexArray!=(void*)0x1) free(mVertexArray);
		mVertexArray = malloc(size);
		memcpy(mVertexArray, (void*)bytes, size);
	} else
		glBufferDataARB(GL_ARRAY_BUFFER_ARB,
						 size,
						 bytes,
						 mAccessHint);
}

- (void)replaceDataInRange:(NSRange)range withBytes:(UInt8*)bytes {	
	O3RawVertexData_AssertRangeValid(self, range);
	
	O3RawVertexData_QuickBind(self);
	if (mVertexArray)	memcpy((UInt8*)mVertexArray+range.location, bytes, range.length);
	else glBufferSubDataARB(GL_ARRAY_BUFFER_ARB, range.location, range.length, (const void*)bytes);
}

- (NSData*)data {
	return [self dataInRange:NSMakeRange(0, mSize)];
}

- (NSData*)dataInRange:(NSRange)range {
	O3RawVertexData_AssertRangeValid(self, range);
	
	void* bytes = malloc(range.length);
	O3RawVertexData_QuickBind(self);
	if (mVertexArray)	memcpy(bytes, (void*)((UInt8*)mVertexArray+range.location), range.length);
	else				glGetBufferSubDataARB(GL_ARRAY_BUFFER_ARB, range.location, range.length, bytes);
	return [NSData dataWithBytesNoCopy:bytes length:range.length freeWhenDone:YES];
}

- (UInt8*)dataPointerWithAccess:(GLenum)access {
	if (mTimesMapped) O3LogWarn(@"[O3RawVertexData dataPointerWithAccess:] was called twice in a row without calling releaseDataPointer. While this is legal and will probably work as expected, you shouldn't do it because access conflicts can occur. For instance, if the first call maps the buffer as GL_READ_ONLY and the second call maps it as GL_WRITE_ONLY, the buffer will still only be GL_READ_ONLY.");

	if (mVertexArray) return (UInt8*)mVertexArray;
	mTimesMapped++;
	if (mMappedBuffer) return (UInt8*)mMappedBuffer;
	O3RawVertexData_QuickBind(self);
	mMappedBuffer = glMapBufferARB(GL_ARRAY_BUFFER_ARB, access);
	O3Assert(!glGetError() && mMappedBuffer , @"Attempt to map (obtain pointer to data of) O3RawVertexData %@ while bound for rendering (probably. It is possible that something else happened. Set a breakpoint to find out.)", self);
	return (UInt8*)mMappedBuffer;
}

- (void)releaseDataPointer {
	//if (mVertexArray) return; //All cases caught by line below
	if (!mMappedBuffer) return;
	if (--mTimesMapped) return; //Allows map, map then release, release to work as expected
	O3RawVertexData_QuickBind(self);
	mMappedBuffer = NULL;
	glUnmapBufferARB(GL_ARRAY_BUFFER_ARB);
}

- (GLvoid*)indicies {return O3RawVertexData_indicies(self);}
GLvoid* O3RawVertexData_indicies(O3RawVertexData* self) {
	static Class O3RawVertexDataClass = nil;
		if (!O3RawVertexDataClass) O3RawVertexDataClass = [O3RawVertexData class];
	if (self->isa!=O3RawVertexDataClass) return [self indicies];
	return (GLvoid*)self->mVertexArray; //NULL if N/A
}

- (void)bindAsSourceForVertexDataType:(O3VertexDataType)type format:(GLenum)format componentCount:(GLint)components {
	[self bindAsSourceForVertexDataType:type format:format componentCount:components offset:0 stride:0];}
///Binds the receiver to a certain vertex data attribute if nothing has already been bound for that type.
///@warn If the receiver stores indicies, be sure to pass [obj indicies] in the index parameter of glDrawElements, etc. This can be counted on to be NULL on architectures where gVertexDataBufferSupport==O3FullySupported, but not on other architectures. 
- (void)bindAsSourceForVertexDataType:(O3VertexDataType)type format:(GLenum)format componentCount:(GLint)components offset:(GLsizeiptr)offset stride:(GLsizei)stride {
	O3AssertArg(offset<mSize,@"Offset %i is greater than size %i", offset, mSize);
	O3Assert(!mMappedBuffer, @"Cannot call bindAsSourceForVertexAttributeNumber:... with that data mapped for editing.");
	if (O3VertexDataTypeIsVertexAttribute(type)) {
		O3LogInfo(@"Calling [O3RawVertexData bindAsSourceForVertexDataType...] with a vertex attribute parameter is slow. Instead, call one of the bindAsSourceForVertexAttribute methods.");
		[self bindAsSourceForVertexAttributeNumber: (unsigned)O3VertexAttributeNumberForForDataType(type)
											format: format
									componentCount: components
										normalized: NO
											offset: offset
											stride: stride];
		return;
	}
	
	/*std::map<O3VertexDataType, O3RawVertexData*>::iterator loc = gBoundVertexDataObjectsForTypes->find(type);
	if (loc!=gBoundVertexDataObjectsForTypes.end()) return;
	gBoundVertexDataObjectsForTypes.insert(type, self);*/
	
	if (!mBoundTypes) mBoundTypes = new std::set<O3VertexDataType>();
	if (!mBoundTypes->insert(type).second) return; //If we are already bound, early out
	
	if (type!=O3VertexLocationIndexDataType) O3RawVertexData_QuickBind(self);
	GLvoid* data = (GLvoid*)((UInt8*)mVertexArray + offset);
	switch (type) {
		case O3VertexLocationDataType:
			if (glIsEnabled(GL_VERTEX_ARRAY)) break;
			glEnableClientState(GL_VERTEX_ARRAY);
			glVertexPointer(components, format, stride, data);
			break;
		case O3NormalDataType:
			if (glIsEnabled(GL_NORMAL_ARRAY)) break;
			glEnableClientState(GL_NORMAL_ARRAY);
			O3AssertArg(components==3, @"components must be 3 for a normal array.");
			glNormalPointer(format, stride, data);	
			break;	
		case O3ColorDataType:
			if (glIsEnabled(GL_COLOR_ARRAY)) break;
			glEnableClientState(GL_COLOR_ARRAY);
			glColorPointer(components, format, stride, data);
			break;
		case O3ColorIndexDataType:
			if (glIsEnabled(GL_INDEX_ARRAY)) break;
			glEnableClientState(GL_INDEX_ARRAY);
			O3AssertArg(components<2, @"Index arrays can only have one component.");
			if (format==GL_UNSIGNED_SHORT) format = GL_SHORT; //An idiosyncrasy of the OSX implementation. Luckily, short actually means unsigned short in this case :)
			glIndexPointer(format, stride, data);
			break;
		case O3VertexLocationIndexDataType:
			if (mVertexArray) break; //If buffers aren't supported, don't use them.
			GLint element_binding; glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING_ARB, &element_binding);
			if (element_binding) break;
			O3RawVertexData_QuickBind(self, YES);
			break;
		case O3TexCoordDataType:
			glClientActiveTexture(GL_TEXTURE0);
			if (glIsEnabled(GL_TEXTURE_COORD_ARRAY)) break;
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
			glTexCoordPointer(components, format, stride, data);
			//glClientActiveTexture(GL_TEXTURE0);	//Enable if things go bad
			break;
		case O3EdgeFlagDataType:
			if (glIsEnabled(GL_EDGE_FLAG_ARRAY)) break;
			O3AssertArg(components<2, @"Edge flag arrays can only have one component.");
			O3AssertArg(format==GL_BOOL, @"Edge flag format must be GL_BOOL.");
			glEnableClientState(GL_EDGE_FLAG_ARRAY);
			glEdgeFlagPointer(stride, data);
			break;
		case O3SecondaryColorDataType:
			if (glIsEnabled(GL_SECONDARY_COLOR_ARRAY)) break;
			glEnableClientState(GL_SECONDARY_COLOR_ARRAY);
			glSecondaryColorPointer(components, format, stride, data);
			break;
		case O3FogCoordDataType:
			if (glIsEnabled(GL_FOG_COORD_ARRAY)) break;
			glEnableClientState(GL_FOG_COORD_ARRAY);
			O3AssertArg(components<2, @"Fog coord arrays can only have one element in them.");
			glFogCoordPointer(format, stride, data);
			break;
		default:
			/*if (type>=O3VertexAttribute0DataType && type<O3TexCoord0DataType) {
				int index = O3VertexAttributeNumberForForDataType(type);
				glEnableVertexAttribArray(index);
				glVertexAttribPointer(index, components, format, normalized, stride, data);
				break;
			}*/ //VAs are handled separately
			if (type>=O3TexCoord0DataType) {
				glClientActiveTexture(type);
				if (glIsEnabled(GL_TEXTURE_COORD_ARRAY)) break;
				glEnableClientState(GL_TEXTURE_COORD_ARRAY);
				glTexCoordPointer(components, format, stride, data);
				//glClientActiveTexture(GL_TEXTURE0);	//Enable if things go bad
				break;
			}
			[NSException raise:O3VertexDataTypeUnrecognizedException
                        format:@"[O3RawVertexData bindAsSourceForVertexDataType...] does not recognize %i as a valid vertex data type. Note that for vertex attributes, you should use the bindAsSourceForVertexAttribute methods."];
	}
}

- (void)bindAsSourceForVertexAttributeNumber:(GLuint)attrib format:(GLenum)format componentCount:(GLint)components {
	[self bindAsSourceForVertexAttributeNumber:attrib format:format componentCount:components normalized:NO offset:0 stride:0];}
- (void)bindAsSourceForVertexAttributeNumber:(GLuint)attrib format:(GLenum)format componentCount:(GLint)components normalized:(BOOL)normalized offset:(GLsizeiptr)offset stride:(GLsizei)stride {
	O3AssertArg(offset<mSize,@"Offset %i is greater than size %i", offset, mSize);
	O3Assert(!mMappedBuffer, @"Cannot call bindAsSourceForVertexAttributeNumber:... with that data mapped for editing.");
	O3RawVertexData_QuickBind(self);
	glEnableVertexAttribArray(attrib);
	GLvoid* data = (GLvoid*)((UInt8*)mVertexArray + offset);
	glVertexAttribPointer(attrib, components, format, normalized, stride, data);
	
	/*std::map<O3VertexDataType, O3RawVertexData*>::iterator loc = gBoundVertexDataObjectsForTypes.find(O3VertexAttributeDataType(type));
	if (loc!=gBoundVertexDataObjectsForTypes.end()) return;
	gBoundVertexDataObjectsForTypes.insert(O3VertexAttributeDataType(type), self);*/
	
	if (!mBoundTypes) mBoundTypes = new std::set<O3VertexDataType>();
	mBoundTypes->insert(O3VertexAttributeDataType(attrib));
}

- (void)unbind {
	if (!mBoundTypes) return;
	std::set<O3VertexDataType>::iterator it = mBoundTypes->begin();
	std::set<O3VertexDataType>::iterator end = mBoundTypes->end();
	IMP self_unbindAsSource = [self methodForSelector:@selector(unbindAsSourceForVertexDataTypeOrAttribute:)];
	for (; it!=end; it++) self_unbindAsSource(self, @selector(unbindAsSourceForVertexDataTypeOrAttribute:), *it);
	delete mBoundTypes; mBoundTypes = NULL;
}

///Unbinds the receiver for \e type. If the reciever wasn't bound to \e type, whatever was bound to \e type is unbound.
- (void)unbindAsSourceForVertexDataTypeOrAttribute:(O3VertexDataType)type {
	/*std::map<O3VertexDataType, O3RawVertexData*>::iterator loc = gBoundVertexDataObjectsForTypes.find(O3VertexAttributeDataType(type));
	if (loc!=gBoundVertexDataObjectsForTypes.end()) return;
	if (loc->second != self) return;
	gBoundVertexDataObjectsForTypes.erase(loc);*/
	
	if (mBoundTypes) { //Check to erase us from the set of bound types if applicable
		std::set<O3VertexDataType>::iterator it = mBoundTypes->find(type);
		if (it!=mBoundTypes->end()) mBoundTypes->erase(it);
	}
	
	switch (type) {
		case O3VertexLocationDataType:	
			glDisableClientState(GL_VERTEX_ARRAY);
			break;
		case O3VertexLocationIndexDataType:	
			O3RawVertexData_Unbind(self, YES);
			break;
		case O3NormalDataType:			
			glDisableClientState(GL_NORMAL_ARRAY);
			break;
		case O3ColorDataType:			
			glDisableClientState(GL_COLOR_ARRAY);
			break;
		case O3ColorIndexDataType:			
			glDisableClientState(GL_INDEX_ARRAY);
			break;
		case O3TexCoordDataType:		
			glClientActiveTexture(GL_TEXTURE0);
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
			break;
		case O3EdgeFlagDataType:		
			glDisableClientState(GL_EDGE_FLAG_ARRAY);
			break;
		case O3SecondaryColorDataType:	
			glDisableClientState(GL_SECONDARY_COLOR_ARRAY);
			break;
		case O3FogCoordDataType:		
			glDisableClientState(GL_FOG_COORD_ARRAY);
			break;
		default:
			if (type>=O3VertexAttribute0DataType && type<O3TexCoord0DataType) {
				int index = O3VertexAttributeNumberForForDataType(type);
				glDisableVertexAttribArray(index);
				break;
			}
			if (type>=O3TexCoord0DataType) {
				glClientActiveTexture(type);
				glDisableClientState(GL_TEXTURE_COORD_ARRAY);
				//glClientActiveTexture(GL_TEXTURE0);	//Enable if things go bad
				break;
			}
			[NSException raise:O3VertexDataTypeUnrecognizedException
                        format:@"[O3RawVertexData unbindAsSourceForVertexDataTypeOrAttribute...] does not recognize %i as a valid vertex data type. Note that for vertex attributes, you should use the bindAsSourceForVertexAttribute methods."];
	}
}

- (BOOL)isMapped {return (mMappedBuffer)?YES:NO;}
- (GLenum)accessHint {return mAccessHint;}
- (GLsizeiptr)size	{return mSize;}
@end
