//
//  O3GPUData.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 11/24/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3GPUData.h"

NSString* gO3VertexDataTypeUnrecognizedException = @"O3VertexDataTypeUnrecognizedException";

O3GLBufferObj* O3GLBufferObjNew() {
	O3GLBufferObj* r = new O3GLBufferObj();
	r->references = 1;
	GLuint b;
	glGenBuffersARB(1, &b);
	r->id = b;
	return r;
}

O3GLBufferObj* O3GLBufferObjCopy(O3GLBufferObj* o) {
	o->references++;
	return o;
}

O3GLBufferObj* O3GLBufferObjDuplicate(O3GLBufferObj* o, GLenum* usage, UIntP extraBytes) {
	O3CLogInfo(@"Stall on buffer (%i) copy", o->id);
	O3GLBufferObj* r = O3GLBufferObjNew();

	//Get o's size, bytes, and usage
	GLsizeiptrARB s;
	glGetBufferParameterivARB(GL_ARRAY_BUFFER_ARB, GL_BUFFER_SIZE_ARB, (GLint*)&s);
	void* bytes = malloc(s+extraBytes);
	glGetBufferSubDataARB(GL_ARRAY_BUFFER_ARB, NULL, s, bytes);
	if (!usage) {
		GLenum u; usage=&u;
		glGetBufferParameterivARB(GL_ARRAY_BUFFER_ARB, GL_BUFFER_USAGE_ARB, (GLint*)&u);
	}
		
	//Now copy the data
	glBindBufferARB(GL_ARRAY_BUFFER_ARB, r->id); 
	glBufferDataARB(GL_ARRAY_BUFFER_ARB, s+extraBytes, bytes, *usage);

	//And release the data we got above
	free(bytes);
		
	return r;
}

///Copies a buffer to allow changes to it.
///@warning o should not be mapped
///@param usage nil means the usage is copied from the old buffer. Otherwise, *usage is used.
O3GLBufferObj* O3GLBufferObjPrepareForChanges(O3GLBufferObj* o, GLenum* usage) {
	if (o->references==1) return o;
	o->references--;
	return O3GLBufferObjDuplicate(o, usage, 0);
}

void O3GLBufferObjRelease(O3GLBufferObj* o) {
	o->references--;
	if (!o->references) {
		glDeleteBuffersARB(1, &(o->id));
		delete o;
	}
}



@implementation O3GPUData
O3DefaultO3InitializeImplementation

/************************************/ #pragma mark Inline Support /************************************/
inline BOOL isMappedP(O3GPUData* self) {
	glBindBufferARB(GL_ARRAY_BUFFER_ARB, self->mBuffer->id);
	GLboolean mapped; 
	glGetBufferParameterivARB(GL_ARRAY_BUFFER_ARB, GL_BUFFER_MAPPED_ARB, (GLint*)&mapped);
	return mapped;
}

//Possibly just call glUnmapBuffer and check the error?
inline void unmapP(O3GPUData* self) {
	glBindBufferARB(GL_ARRAY_BUFFER_ARB, self->mBuffer->id);
	glUnmapBufferARB(GL_ARRAY_BUFFER_ARB);
}

//Binds the receiver's buffer to GL_ARRAY_BUFFER_ARB, checks to see if it is mapped, and unmaps it if necessary
inline void prepareForUseP(O3GPUData* self) {
	if (isMappedP(self)) {
		O3LogInfo(@"You should call -relinquishBytes on all O3GPUData after you are done reading or writing the data. The buffer returned by -bytes or -mutableBytes has been invalidated to prepare for rendering.");
		unmapP(self);
	}
}

inline void willMutateP(O3GPUData* self) {
	self->mBuffer = O3GLBufferObjPrepareForChanges(self->mBuffer, NULL);
}

/************************************/ #pragma mark Init /************************************/ 
- (O3GPUData*)initWithBytes:(const void*)bytes length:(UIntP)len {
	return [self initWithBytesNoCopy:(void*)bytes length:len freeWhenDone:NO hint:GL_STATIC_DRAW_ARB];
}

- (O3GPUData*)initWithBytesNoCopy:(void*)bytes length:(UIntP)len freeWhenDone:(BOOL)fwd {
	return [self initWithBytesNoCopy:bytes length:len freeWhenDone:fwd hint:GL_STATIC_DRAW_ARB];
}

///This function uploads data asynchronously if %fwd is YES (ownership is transfered to the O3GPUData)
- (O3GPUData*)initWithBytesNoCopy:(void*)bytes length:(UIntP)len freeWhenDone:(BOOL)fwd hint:(GLenum)usageHint {
	O3SuperInitOrDie();
	mBuffer = O3GLBufferObjNew();
	glBindBufferARB(GL_ARRAY_BUFFER_ARB, mBuffer->id);
	mLength = len;
	glBufferDataARB(GL_ARRAY_BUFFER_ARB, len, bytes, usageHint);
	if (fwd) free(bytes);
	return self;
}

- (O3GPUData*)initWithCapacity:(UIntP)cap {
	return [self initWithCapacity:cap hint:GL_STATIC_DRAW_ARB];
}

- (O3GPUData*)initWithData:(NSData*)other {
	UIntP olen = [other length];
	if (![other isGPUData]) return [self initWithBytes:[other bytes] length:olen];
	O3SuperInitOrDie();
	mBuffer = O3GLBufferObjCopy(((O3GPUData*)other)->mBuffer);
	mLength = olen;
	return self;
}

- (O3GPUData*)initWithReader:(O3BufferedReader*)r length:(UIntP)len hint:(GLenum)usageHint {
	O3SuperInitOrDie();
	mBuffer = O3GLBufferObjNew();
	glBindBufferARB(GL_ARRAY_BUFFER_ARB, mBuffer->id);
	glBufferDataARB(GL_ARRAY_BUFFER_ARB, len, NULL, usageHint);
	void* b = glMapBufferARB(GL_ARRAY_BUFFER_ARB, GL_WRITE_ONLY);
	r->ReadBytesInto(b, len);
	glUnmapBufferARB(GL_ARRAY_BUFFER_ARB);
	mLength = len;
	return self;
}

- (O3GPUData*)initWithCapacity:(UIntP)cap hint:(GLenum)hint {
	O3SuperInitOrDie();
	mBuffer = O3GLBufferObjNew();
	glBindBufferARB(GL_ARRAY_BUFFER_ARB, mBuffer->id);
	glBufferDataARB(GL_ARRAY_BUFFER_ARB, cap, NULL, hint);
	return self;	
}

- (void)dealloc {
	O3GLBufferObjRelease(mBuffer);
	O3SuperDealloc();
}

/************************************/ #pragma mark Resizing /************************************/
- (void)increaseLengthBy:(UIntP)nlen {
	[self setLength:[self length]+nlen];
}

- (void)setLength:(UIntP)nlen {
	UIntP cap = [self capacity];
	if (nlen<cap) {
		mLength = nlen;
		return;
	}
	UIntP inc = nlen-cap;
	UIntP ncap = nlen+(mCapacityOverruns++)*inc;
	O3GLBufferObj* nbuf = O3GLBufferObjDuplicate(mBuffer, NULL, ncap-cap);
	O3GLBufferObjRelease(mBuffer);
	mBuffer = nbuf;
	mLength = nlen;
}

- (UIntP)length {
	return mLength;
}

- (UIntP)capacity {
	glBindBufferARB(GL_ARRAY_BUFFER_ARB, mBuffer->id);
	UIntP s; glGetBufferParameterivARB(GL_ARRAY_BUFFER_ARB, GL_BUFFER_SIZE_ARB, (GLint*)&s);
	return s;
}

/************************************/ #pragma mark Mapping /************************************/
- (const void*)bytes {
	if (isMappedP(self)) {
		GLenum access; glGetBufferParameterivARB(GL_ARRAY_BUFFER_ARB, GL_BUFFER_ACCESS_ARB, (GLint*)&access);
		if (access==GL_WRITE_ONLY_ARB) {
			O3LogWarn(@"O3GPUData %@ was mapped as write only when -bytes was called. Invalidating the write-only buffer and returning a read only one.");
			unmapP(self);
			return [self bytes];
		}
		void* ptr; glGetBufferPointervARB(GL_ARRAY_BUFFER_ARB, GL_BUFFER_MAP_POINTER_ARB, &ptr);
		return ptr;
	}
	//Buffer bound as side effect of isMapped
	return glMapBufferARB(GL_ARRAY_BUFFER_ARB, GL_READ_ONLY);
}

- (void*)mutableBytes {
	if (isMappedP(self)) {
		GLenum access; glGetBufferParameterivARB(GL_ARRAY_BUFFER_ARB, GL_BUFFER_ACCESS_ARB, (GLint*)&access);
		if (access==GL_WRITE_ONLY_ARB || access==GL_READ_ONLY_ARB) {
			O3LogWarn(@"O3GPUData %@ was mapped as write or read only when -mutableBytes was called. Invalidating the read-only (or write-only) buffer and returning a RW one.");
			unmapP(self);
			return [self mutableBytes];
		}
		void* ptr; glGetBufferPointervARB(GL_ARRAY_BUFFER_ARB, GL_BUFFER_MAP_POINTER_ARB, &ptr);
		return ptr;
	}
	//Buffer bound as side effect of isMapped
	return glMapBufferARB(GL_ARRAY_BUFFER_ARB, GL_READ_WRITE);
}

- (void*)writeOnlyBytes {
	if (isMappedP(self)) {
		GLenum access; glGetBufferParameterivARB(GL_ARRAY_BUFFER_ARB, GL_BUFFER_ACCESS_ARB, (GLint*)&access);
		if (access==GL_READ_ONLY) {
			O3LogWarn(@"O3GPUData %@ was mapped as read only when -writableBytes was called. Invalidating the read-only buffer and returning a write-only one.");
			unmapP(self);
			return [self writeOnlyBytes];
		}
		void* ptr; glGetBufferPointervARB(GL_ARRAY_BUFFER_ARB, GL_BUFFER_MAP_POINTER_ARB, &ptr);
		return ptr;
	}
	//Buffer bound as side effect of isMapped
	return glMapBufferARB(GL_ARRAY_BUFFER_ARB, GL_WRITE_ONLY);
}

- (void)getBytes:(void*)bytes {
	O3LogInfo(@"[O3GPUData getBytes: produces a stall]");
	glBindBufferARB(GL_ARRAY_BUFFER_ARB, mBuffer->id);
	glGetBufferSubDataARB(GL_ARRAY_BUFFER_ARB, NULL, mLength, bytes);
}

- (void)getBytes:(void*)bytes length:(UIntP)len {
	O3LogInfo(@"[O3GPUData getBytes:length: produces a stall]");
	O3Assert(len<=mLength, @"length cannot be greater than the length of the receiver");
	glBindBufferARB(GL_ARRAY_BUFFER_ARB, mBuffer->id);
	glGetBufferSubDataARB(GL_ARRAY_BUFFER_ARB, NULL, len, bytes);
}

- (void)getBytes:(void*)bytes range:(NSRange)r {
	O3LogInfo(@"[O3GPUData getBytes:range: produces a stall]");
	O3Assert(r.location+r.length<=mLength, @"range.location+range.length cannot be greater than the length of the receiver");
	glBindBufferARB(GL_ARRAY_BUFFER_ARB, mBuffer->id);
	glGetBufferSubDataARB(GL_ARRAY_BUFFER_ARB, (GLintptrARB)((UInt8*)NULL+r.location), r.length, bytes);	
}

- (NSData*)subdataWithRange:(NSRange)r {
	void* b = malloc(r.length);
	[self getBytes:b range:r];
	return [[[NSMutableData alloc] initWithBytesNoCopy:b length:r.length freeWhenDone:YES] autorelease];
}

- (NSData*)regularData {
	return [self subdataWithRange:NSMakeRange(0,mLength)];
}

/************************************/ #pragma mark Adding Data /************************************/
- (void)appendBytes:(const void*)b length:(UIntP)len {
	UIntP olen = mLength;
	[self setLength:olen+len];
	[self replaceBytesInRange:NSMakeRange(olen, len) withBytes:b];
}

- (void)appendData:(NSData*)dat {
	const void* b = [dat bytes];
	[self appendBytes:b length:[dat length]];
	[dat relinquishBytes];
}

/************************************/ #pragma mark Replacing Data /************************************/
- (void)replaceBytesInRange:(NSRange)r withBytes:(const void*)b {
	if (r.location+r.length > mLength) [NSException raise:NSRangeException format:@"[%@ %@] range %@ out of bounds (len=%i)", self, NSStringFromSelector(_cmd), NSStringFromRange(r), mLength];
	glMapBufferARB(GL_ARRAY_BUFFER_ARB, mBuffer->id);
	glBufferSubDataARB(GL_ARRAY_BUFFER_ARB, (GLintptrARB)((UInt8*)NULL+r.location), r.length, b);
}

- (void)replaceBytesInRange:(NSRange)r withBytes:(const void*)b length:(UIntP)len {
	if (r.location+r.length > mLength) [NSException raise:NSRangeException format:@"[%@ %@] range %@ out of bounds (len=%i)", self, NSStringFromSelector(_cmd), NSStringFromRange(r), mLength];
	IntP shift = len-r.length;
	if (!shift) {[self replaceBytesInRange:r withBytes:b]; return;}
	NSRange shiftrange = NSMakeRange(r.location+r.length, mLength-(r.location+r.length));
	[self setLength:mLength+shift];
	void* sb = malloc(shiftrange.length);
	[self getBytes:sb range:shiftrange];
	[self replaceBytesInRange:NSMakeRange(r.location, len) withBytes:b];
	[self replaceBytesInRange:NSMakeRange(r.location+len, shiftrange.length) withBytes:sb];
	free(sb);
}

/************************************/ #pragma mark Testing /************************************/
- (BOOL)isEqualToData:(NSData*)o {
	if (mLength!=[o length]) return NO;
	const void* a = [self bytes];
	const void* b = [self bytes];
	int c = memcmp(a,b,mLength);
	[self relinquishBytes];
	[o relinquishBytes];
	if (c) return NO;
	return YES;
}

/************************************/ #pragma mark NSCopying /************************************/
- (id)copyWithZone:(NSZone*)z {
	return [[O3GPUData allocWithZone:z] initWithData:self];
}

/************************************/ #pragma mark NSCoding /************************************/
///@todo make this more optimal (direct reading for O3 coders)
- (void)encodeWithCoder:(NSCoder*)c {
	[c encodeObject:[self subdataWithRange:NSMakeRange(0,mLength)] forKey:@"data"];
	[c encodeInt32:(Int32)[self usageHint] forKey:@"hint"];
}

- (id)initWithCoder:(NSCoder*)c {
	NSData* d = [c decodeObjectForKey:@"data"];
	return [[O3GPUData alloc] initWithBytesNoCopy:(void*)[d bytes]
	                                  length:[d length]
	                            freeWhenDone:NO
	                                    hint:(GLenum)[c decodeInt32ForKey:@"hint"]];
}

/************************************/ #pragma mark O3GPUDataAdditions Overrides /************************************/
- (void)relinquishBytes {
	unmapP(self);
}

- (BOOL)isGPUData {
	return YES;
}

- (O3GPUData*)gpuCopy {
	return [self copy];
}

/************************************/ #pragma mark Accessors /************************************/
- (GLenum)usageHint {
	GLenum h;
	glBindBufferARB(GL_ARRAY_BUFFER_ARB, mBuffer->id);
	glGetBufferParameterivARB(GL_ARRAY_BUFFER_ARB, GL_BUFFER_USAGE_ARB, (GLint*)&h);
	return h;
}

- (GLvoid*)glPtrForBindingArray {
	glBindBufferARB(GL_ARRAY_BUFFER_ARB, mBuffer->id);
	return NULL; //This works. It's not an error. Really.
}

- (GLvoid*)glPtrForBindingElements {
	glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, mBuffer->id);
	return NULL; //This works. It's not an error. Really.
}

@end

@implementation NSData (O3GPUDataAdditions)
- (void)relinquishBytes {}
- (BOOL)isGPUData {return NO;}
- (O3GPUData*)gpuCopy {return [[O3GPUData alloc] initWithData:self];}
- (GLvoid*)glPtrForBindingArray {
	glBindBufferARB(GL_ARRAY_BUFFER, GL_ZERO);
	return (GLvoid*)[self bytes];
}

- (GLvoid*)glPtrForBindingElements {
	glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER, GL_ZERO);
	return (GLvoid*)[self bytes];
}
@end