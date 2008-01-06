//
//  O3GLView.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 10/18/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3GLView.h"
#import "O3ResManager.h"
#import "O3Camera.h"
#import "O3Scene.h"
#import "O3GLViewController.h"
#import <ApplicationServices/ApplicationServices.h>

CGDirectDisplayID NSViewDisplayID(NSView* self) {
	return (CGDirectDisplayID)[[[[[self window] screen] deviceDescription] objectForKey:@"NSScreenNumber"] unsignedIntValue];
}

void O3SetMouseLocation(CGPoint pt) {
	CGWarpMouseCursorPosition(pt);
}

inline CGPoint O3TranslatePointNSToCGScreen(NSPoint pt, NSView* view) {
	NSRect sf = [[[view window] screen] frame];
	float h = sf.size.height;
	return CGPointMake(pt.x, h-pt.y);
}

inline NSPoint O3TranslatePointCGToNSScreen(CGPoint pt, NSView* view) {
	NSRect sf = [[[view window] screen] frame];
	float h = sf.size.height;
	return NSMakePoint(pt.x, h-pt.y);
}

CGPoint O3ScreenCenterOfView(NSView* view) {
	NSPoint centerInSelfCoords = O3CenterOfNSRect([view bounds]);
	NSPoint c = [[view window] convertBaseToScreen:[view convertPoint:centerInSelfCoords toView:nil]];
	return O3TranslatePointNSToCGScreen(c,view);
}

O3Vec2d O3CenterMouse(NSView* view, NSEvent* e) {
	CGPoint pt = !e? O3TranslatePointNSToCGScreen([NSEvent mouseLocation], view) : CGPointMake(0,0);
	CGPoint center = O3ScreenCenterOfView(view);
	O3SetMouseLocation(center);
	return e? O3Vec2d([e deltaX], [e deltaY]) : O3Vec2d(pt.x-center.x, pt.y-center.y);
}

@implementation O3GLView

inline void updateContextIfNecessary(O3GLView* self) {
	if (self->mContextNeedsUpdate) {
		[self setContext:[self generateContext]];
		self->mContextNeedsUpdate = NO;
	}
}

/************************************/ #pragma mark Init&Destruction /************************************/
+ (void)initialize {
	[self setKeys:[NSArray arrayWithObjects:@"colorBits", @"floatingPointColor", nil] triggerChangeNotificationsForDependentKey:@"colorString"];
	[self setKeys:[NSArray arrayWithObject:@"depthBits"] triggerChangeNotificationsForDependentKey:@"depthString"];
	[self setKeys:[NSArray arrayWithObject:@"stencilBits"] triggerChangeNotificationsForDependentKey:@"stencilString"];
	[self setKeys:[NSArray arrayWithObject:@"accumBits"] triggerChangeNotificationsForDependentKey:@"accumString"];
	[self setKeys:[NSArray arrayWithObject:@"auxBuffers"] triggerChangeNotificationsForDependentKey:@"auxBuffersString"];
	[self setKeys:[NSArray arrayWithObject:@"numberOfSamples"] triggerChangeNotificationsForDependentKey:@"samplingString"];
	[self setKeys:[NSArray arrayWithObject:@"multisampleStyle"] triggerChangeNotificationsForDependentKey:@"aaStyleString"];
	[self setKeys:[NSArray arrayWithObject:@"renderer"] triggerChangeNotificationsForDependentKey:@"rendererString"];
	[self setKeys:[NSArray arrayWithObject:@"policy"] triggerChangeNotificationsForDependentKey:@"policyString"];
}

inline void initP(O3GLView* self) {
	self->mMultisampleStyle = NSOpenGLPFAMultisample;
	self->mRenderer = NSOpenGLPFAAccelerated;
	self->mPolicy = NSOpenGLPFAMaximumPolicy;
	self->mColorBits = 32;
	self->mDepthBits = 32;
	self->mStencilBits = 8;
	self->mAccumBits = 0;
	self->mAuxBuffers = 0;
	self->mSampleCount = 4;
	self->mFloatingColor = NO;
	self->mAuxDepthStencil = NO;
	self->mDoubleBuffer = YES;
	self->mStereoBuffer = NO;
	self->mNoRecovery = NO;
	self->mContextNeedsUpdate = YES;
	self->mViewState = [[NSMutableDictionary alloc] init];
	[self setSceneName:@"defaultScene"];
	[self setUpdateInterval:1/35];
	[[self window] setAcceptsMouseMovedEvents:YES];
}

- (O3GLView*)initWithFrame:(NSRect)frameRect {
	[super initWithFrame:frameRect];
	initP(self);
	return self;
}

- (void)dealloc {
	[mViewState release];
	[mCamera release];
	[mSceneName release];
	[mScene release];
	[mContext release];
	[self unlockMouse];
	O3SuperDealloc();
}

- (void)encodeWithCoder:(NSCoder*)coder {
	O3Assert([coder allowsKeyedCoding], @"Cannot encode an O3GLView into a non-keyed coder");
	[super encodeWithCoder:coder];
	[coder encodeObject:mSceneName forKey:@"sceneName"];
	[coder encodeObject:mCamera forKey:@"camera"];
	[coder encodeObject:mBackgroundColor forKey:@"background"];
	
	static NSDictionary* msMap = nil;
	if (!msMap) msMap = [[NSDictionary alloc] initWithObjectsAndKeys:@"MSAA", @"Multisampling", @"SSAA", @"Supersampling", @"AAA", @"Alpha Sampling", nil];
	NSString* msStr = [self antiAliasingStyleString];
	NSString* encMSStr = [msMap objectForKey:msStr];
	[coder encodeObject:encMSStr?:@"?" forKey:@"AA"];
	
	static NSDictionary* rendMap = nil;
	if (!rendMap) rendMap = [[NSDictionary alloc] initWithObjectsAndKeys:@"software", @"Force Software Renderer", @"hardware", @"Accelerated Renderer", @"any", @"Default Renderer", nil];
	NSString* rendStr = [self rendererString];
	NSString* encRendStr = [rendMap objectForKey:rendStr];
	[coder encodeObject:encRendStr?:@"?" forKey:@"renderer"];
	
	static NSDictionary* policyMap = nil;
	if (!policyMap) policyMap = [[NSDictionary alloc] initWithObjectsAndKeys:@"closest", @"Closest", @"max", @"Maximum", @"min", @"Minimum", nil];
	NSString* policyStr = [self policyString];
	NSString* encPolicyStr = [policyMap objectForKey:policyStr];
	[coder encodeObject:encPolicyStr?:@"?" forKey:@"policy"];
	
	[coder encodeBool:YES forKey:@"settingsValid"];
	[coder encodeInt:mColorBits forKey:@"colorBits"];
	[coder encodeInt:mDepthBits forKey:@"depthBits"];
	[coder encodeInt:mStencilBits forKey:@"stencilBits"];
	[coder encodeInt:mAccumBits forKey:@"accumBits"];
	[coder encodeInt:mAuxBuffers forKey:@"auxBuffers"];
	[coder encodeInt:mSampleCount forKey:@"samples"];
	[coder encodeInt:mAuxDepthStencil forKey:@"auxDepthStencil"];
	[coder encodeInt:mDoubleBuffer forKey:@"doubleBuffer"];
	[coder encodeInt:mStereoBuffer forKey:@"stereoBuffer"];
	[coder encodeInt:mNoRecovery forKey:@"noRecovery"];
}

- (O3GLView*)initWithCoder:(NSCoder*)coder {
	O3Assert([coder allowsKeyedCoding], @"Cannot create an O3GLView from a non-keyed coder");
	[super initWithCoder:coder];
	initP(self);
	[self setSceneName:[coder decodeObjectForKey:@"sceneName"]];
	[self setCamera:[coder decodeObjectForKey:@"camera"]];
	[self setBackgroundColor:[coder decodeObjectForKey:@"background"]];
	
	NSString* msStr = [coder decodeObjectForKey:@"AA"];
	if ([msStr isEqualToString:@"AAA"])
		[self setMultisampleStyle:NSOpenGLPFASampleAlpha];
	else if ([msStr isEqualToString:@"SSAA"])
		[self setMultisampleStyle:NSOpenGLPFASupersample];
	else if ([msStr isEqualToString:@"MSAA"])
		[self setMultisampleStyle:NSOpenGLPFAMultisample];
	else
		[self setMultisampleStyle:(NSOpenGLPixelFormatAttribute)0];
	
	NSString* rendStr = [coder decodeObjectForKey:@"renderer"];
	if ([rendStr isEqualToString:@"software"])
		[self setRenderer:NSOpenGLPFARendererID];
	else if ([rendStr isEqualToString:@"hardware"])
		[self setRenderer:NSOpenGLPFAAccelerated];
	else
		[self setRenderer:(NSOpenGLPixelFormatAttribute)0];

	NSString* policyStr = [coder decodeObjectForKey:@"policy"];
	if ([policyStr isEqualToString:@"closest"])
		[self setPolicy:NSOpenGLPFAClosestPolicy];
	else if ([policyStr isEqualToString:@"min"])
		[self setPolicy:NSOpenGLPFAMinimumPolicy];
	else
		[self setPolicy:NSOpenGLPFAMaximumPolicy];

	if ([coder decodeBoolForKey:@"settingsValid"]) {
		[self setColorBits:[coder decodeIntForKey:@"colorBits"]];
		[self setDepthBits:[coder decodeIntForKey:@"depthBits"]];
		[self setStencilBits:[coder decodeIntForKey:@"stencilBits"]];
		[self setAccumBits:[coder decodeIntForKey:@"accumBits"]];
		[self setAuxBuffers:[coder decodeIntForKey:@"auxBuffers"]];
		[self setNumberOfSamples:[coder decodeIntForKey:@"samples"]];
		[self setAuxDepthStencil:[coder decodeIntForKey:@"auxDepthStencil"]];
		[self setDoubleBuffer:[coder decodeIntForKey:@"doubleBuffer"]];
		[self setStereoBuffer:[coder decodeIntForKey:@"stereoBuffer"]];
		[self setNoRecovery:[coder decodeIntForKey:@"noRecovery"]];
	}
	return self;
}

/************************************/ #pragma mark Mouse /************************************/
- (void)lockMouse {
	if (mOwnsMouse) return;
	mOwnsMouse = YES;
	CGDisplayHideCursor(NSViewDisplayID(self));
	O3CenterMouse(self,nil);
	mIgnoreNextRot = YES;
}

- (void)unlockMouse {
	if (!mOwnsMouse) return;
	mOwnsMouse = NO;
	CGDisplayShowCursor(NSViewDisplayID(self));
	O3CenterMouse(self,nil);
}

- (void)lockedMouseMoved:(O3Vec2d)amount {
	NSResponder* nr = [self nextResponder];
	if (!mIgnoreNextRot && [nr respondsToSelector:@selector(lockedMouseMoved:)])
		[(O3GLView*)nr lockedMouseMoved:amount];
	mIgnoreNextRot = NO;
}

inline void mouseMoved(O3GLView* self, NSEvent* e) {
	if (self->mOwnsMouse) {
		[self lockedMouseMoved:O3CenterMouse(self,e)];
	}
}

- (void)mouseMoved:(NSEvent*)e {
	mouseMoved(self, e);
	[super mouseMoved:e];
}

- (void)mouseDragged:(NSEvent*)e {
	mouseMoved(self, e);
	[super mouseDragged:e];
}

- (BOOL)mouseLocked {
	return mOwnsMouse;
}

- (void)toggleMouseLock {
	if (mOwnsMouse) [self unlockMouse];
	else            [self lockMouse];
}

- (void)viewDidMoveToWindow {
	[[self window] setAcceptsMouseMovedEvents:YES];
}

/************************************/ #pragma mark Accessors /************************************/
- (void)installDefaultViewController {
	O3LogWarn(@"This method causes a leak. Don't use in real code.");
	O3GLViewController* cont = [[O3GLViewController alloc] init];
	[cont setRepresentedView:self];
}

- (NSMutableDictionary*)viewState {
	return mViewState;
}

- (O3ResManager*)resourceManager {
	return mResManager?:[O3ResManager sharedManager];
}

- (void)setResourceManager:(O3ResManager*)manager {
	mResManager = manager;
}

- (NSString*)sceneName {
	return mSceneName;
}

- (void)setSceneName:(NSString*)name {
	O3Assign(name, mSceneName);
	[self unbind:@"scene"];
	if (mResManager&&name) [self bind:@"scene" toObject:mResManager withKeyPath:name options:nil];
} 

- (O3Scene*)scene {
	return mScene;
}

- (O3Scene*)setDefaultScene {
	O3Scene* s = [[O3Scene alloc] init];
	[self setScene:s];
	return s;
}

- (void)setScene:(O3Scene*)scene {
	O3Assert([scene conformsToProtocol:@protocol(O3Renderable)], @"Scene %@ (possibly named \"%@\") doesn't implement O3Renderable.", scene, mSceneName); 
	O3Assign(scene, mScene);
	[self setNeedsDisplay:YES];
}

- (O3Camera*)camera {
	if (!mCamera) mCamera = [O3Camera new];
	return mCamera;
}

- (void)setCamera:(O3Camera*)newCamera {
	O3Assign(newCamera, mCamera);
	[self setNeedsDisplay:YES];
}

- (NSOpenGLContext*)context {
	updateContextIfNecessary(self);
	return mContext;
}

- (void)setContext:(NSOpenGLContext*)context {
	if (mContext) [mContext clearDrawable];
	O3Assign(context, mContext);
	[context setView:self];
	[self setNeedsDisplay:YES];
}

- (NSColor*)backgroundColor {
	return mBackgroundColor;
}

- (void)setBackgroundColor:(NSColor*)color {
	O3Assign(color, mBackgroundColor);
}

- (O3GLViewController*)controller {
	if ([[self nextResponder] isKindOfClass:[O3GLViewController class]]) return (O3GLViewController*)[self nextResponder];
	return nil;
}


/************************************/ #pragma mark Drawing /************************************/
- (void)drawRect:(NSRect)rect {
	if (mScene) {
		O3RenderContext ctx;
		ctx.objCCompatibility = [NSNull class];
		ctx.view = self;
		ctx.camera = [self camera];
		ctx.cameraSpace = [ctx.camera space];
		if (mNotFirstFrame) {
			ctx.elapsedTime = 0;
			mNotFirstFrame = YES;
			O3StartTimer(mFrameTimer);
		} else {
			ctx.elapsedTime = O3ElapsedTime(mFrameTimer);
			O3StartTimer(mFrameTimer);
		}
		[mCamera setProjectionMatrix];
		[[self context] makeCurrentContext];

		[mCamera tickWithContext:&ctx];
		[mScene tickWithContext:&ctx];

		float r=0.; float g=0.; float b=0.; float a=1.;
		[mBackgroundColor getRed:&r green:&g blue:&b alpha:&a];
		glClearColor(r,g,b,a);
		glEnable(GL_DEPTH_TEST);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_ACCUM_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
		
		[mScene renderWithContext:&ctx];
		
		[mContext flushBuffer];
		[self setNeedsDisplay:YES];
	} else {
		[self lockFocus];
		[self drawBlackScreenOfDeath:@"No Scene"];
		[self unlockFocus];
	}
}

- (void)lazyUpdate {
	updateContextIfNecessary(self);
	[mContext update];
	[self setNeedsDisplay:YES];
}

- (void)update {
	updateContextIfNecessary(self);
	[mContext update];
	[self drawRect:[self frame]];
}

- (void)drawBlackScreenOfDeath:(NSString*)message {
	NSRect bounds = [self bounds];
	NSSize s = bounds.size;
	[[NSColor blackColor] set];
	[NSBezierPath fillRect:bounds];
	NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont boldSystemFontOfSize:18], NSFontAttributeName, [NSColor darkGrayColor], NSForegroundColorAttributeName, nil];
	NSSize nss = [message sizeWithAttributes:attrs];
	[message drawInRect:O3CenterSizeInRect(nss, bounds) withAttributes:attrs];	
}

/************************************/ #pragma mark Pixel Format /************************************/
- (long)colorBits {
	return mColorBits;
}

- (void)setColorBits:(long)bits {
	if (mColorBits==bits) return;
	mColorBits=bits;
	mContextNeedsUpdate=YES;
}

- (BOOL)floatingPointColor {
	return mFloatingColor;
}

- (void)setFloatingPointColor:(BOOL)fp {
	if (mFloatingColor==fp) return;
	mFloatingColor=fp;
	mContextNeedsUpdate=YES;
}

- (long)depthBits {
	return mDepthBits;
}

- (void)setDepthBits:(long)bits {
	if (mDepthBits==bits) return;
	mDepthBits=bits;
	mContextNeedsUpdate=YES;
}

- (long)stencilBits {
	return mStencilBits;
}

- (void)setStencilBits:(long)newStencilBits {
	if (mStencilBits==newStencilBits) return;
	mStencilBits=newStencilBits;
	mContextNeedsUpdate=YES;
}

- (long)accumBits {
	return mAccumBits;
}

- (void)setAccumBits:(long)accumBits {
	if (mAccumBits==accumBits) return;
	mAccumBits=accumBits;
	mContextNeedsUpdate=YES;
}

- (long)auxBuffers {
	return mAuxBuffers;
}

- (void)setAuxBuffers:(long)buffers {
	if (mAuxBuffers==buffers) return;
	mAuxBuffers=buffers;
	mContextNeedsUpdate=YES;
}

- (BOOL)auxDepthStencil {
	return mAuxDepthStencil;
}

- (void)setAuxDepthStencil:(BOOL)ads {
	if (mAuxDepthStencil==ads) return;
	mAuxDepthStencil=ads;
	mContextNeedsUpdate=YES;
}

- (BOOL)doubleBuffer {
	return mDoubleBuffer;
}

- (void)setDoubleBuffer:(BOOL)db {
	if (db==mDoubleBuffer) return;
	mDoubleBuffer=db;
	mContextNeedsUpdate=YES;
}

- (BOOL)stereoBuffer {
	return mStereoBuffer;
}

- (void)setStereoBuffer:(BOOL)sb {
	if (mStereoBuffer==sb) return;
	mStereoBuffer=sb;
	mContextNeedsUpdate=YES;
}

- (long)numberOfSamples {
	return mSampleCount;
}

- (void)setNumberOfSamples:(long)numberOfSamples {
	if (numberOfSamples==mSampleCount) return;
	mSampleCount=numberOfSamples;
	mContextNeedsUpdate=YES;
}

- (NSOpenGLPixelFormatAttribute)multisampleStyle {
	return mMultisampleStyle;
}

- (void)setMultisampleStyle:(NSOpenGLPixelFormatAttribute)style {
	if (style==mMultisampleStyle) return;
	mMultisampleStyle=style;
	mContextNeedsUpdate=YES;
}

- (NSOpenGLPixelFormatAttribute)renderer {
	return mRenderer;
}

- (void)setRenderer:(NSOpenGLPixelFormatAttribute)rend {
	if (rend==mRenderer) return;
	mRenderer=rend;
	mContextNeedsUpdate=YES;
}

- (BOOL)noRecovery {
	return mNoRecovery;
}

- (void)setNoRecovery:(BOOL)nr {
	if (nr==mNoRecovery) return;
	mNoRecovery=nr;
	mContextNeedsUpdate=YES;
}

- (NSOpenGLPixelFormatAttribute)policy {
	return mPolicy;
}

- (void)setPolicy:(NSOpenGLPixelFormatAttribute)newPolicy {
	if (newPolicy==mPolicy) return;
	mPolicy=newPolicy;
	mContextNeedsUpdate=YES;
}

- (NSOpenGLContext*)generateContext {
	NSOpenGLPixelFormatAttribute* attrs = (NSOpenGLPixelFormatAttribute*)malloc(100*sizeof(NSOpenGLPixelFormatAttribute));
	int i=0;
	
	attrs[i++] = NSOpenGLPFAColorSize;
	attrs[i++] = (NSOpenGLPixelFormatAttribute)mColorBits;
	attrs[i++] = NSOpenGLPFADepthSize;
	attrs[i++] = (NSOpenGLPixelFormatAttribute)mDepthBits;
	attrs[i++] = NSOpenGLPFAStencilSize;
	attrs[i++] = (NSOpenGLPixelFormatAttribute)mStencilBits;
	attrs[i++] = NSOpenGLPFAAccumSize;
	attrs[i++] = (NSOpenGLPixelFormatAttribute)mAccumBits;
	attrs[i++] = NSOpenGLPFAAuxBuffers;
	attrs[i++] = (NSOpenGLPixelFormatAttribute)mAuxBuffers;
	attrs[i++] = NSOpenGLPFASamples;
	attrs[i++] = (NSOpenGLPixelFormatAttribute)mSampleCount;
	if (mMultisampleStyle==NSOpenGLPFAMultisample && mSampleCount>1) {
		attrs[i++] = NSOpenGLPFASampleBuffers;
		attrs[i++] = (NSOpenGLPixelFormatAttribute)1;
	}
	if (mFloatingColor) {attrs[i++] = NSOpenGLPFAColorFloat;  attrs[i++] = (NSOpenGLPixelFormatAttribute)1;}
	if (mAuxDepthStencil) {attrs[i++] = NSOpenGLPFAAuxDepthStencil;  attrs[i++] = (NSOpenGLPixelFormatAttribute)1;}
	if (mDoubleBuffer) {attrs[i++] = NSOpenGLPFADoubleBuffer;  attrs[i++] = (NSOpenGLPixelFormatAttribute)1;}
	if (mStereoBuffer) {attrs[i++] = NSOpenGLPFAStereo;  attrs[i++] = (NSOpenGLPixelFormatAttribute)1;}
	if (mNoRecovery) {attrs[i++] = NSOpenGLPFANoRecovery;  attrs[i++] = (NSOpenGLPixelFormatAttribute)1;}
	attrs[i++] = mPolicy;  attrs[i++] = (NSOpenGLPixelFormatAttribute)1;
	attrs[i++] = mMultisampleStyle;  attrs[i++] = (NSOpenGLPixelFormatAttribute)1;
	if (mRenderer==NSOpenGLPFAAccelerated)
		{attrs[i++] = NSOpenGLPFAAccelerated;  attrs[i++] = (NSOpenGLPixelFormatAttribute)1;}
	else if (mRenderer==NSOpenGLPFARendererID)
		{attrs[i++] = NSOpenGLPFARendererID;  attrs[i++] = (NSOpenGLPixelFormatAttribute)0x00020400;}
	
	attrs[i] = (NSOpenGLPixelFormatAttribute)0;
	NSOpenGLPixelFormat* format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
	NSOpenGLContext* newContext = [[NSOpenGLContext alloc] initWithFormat:format shareContext:mContext];
	[self setContext:newContext];
	[format release];
	free(attrs);
	return newContext;
}

/************************************/ #pragma mark OpenGL props /************************************/
- (NSString*)colorString {
	switch ([self colorBits]) {
		case 15: return @"15 bit RGB (5 5 5)";
		case 24: return @"24 bit RGB (8 8 8)";
		case 48: return [self floatingPointColor]? @"48 bit RGB Float (16 16 16)" : @"48 bit RGB (16 16 16)";
		case 96: return @"96 bit RGB Float (32 32 32)";
		case 16: return @"16 bit RGBA (5 5 5 1)";
		case 32: return @"32 bit RGBA (8 8 8 8) (Default)";
		case 64: return [self floatingPointColor]? @"64 bit RGBA Float (16 16 16 16)" : @"64 bit RGBA (16 16 16 16)";
		case 128: return @"128 bit RGBA Float (32 32 32 32)";
	}
	return [NSString stringWithFormat:@"Unknown (%i bits%@)", [self colorBits], [self floatingPointColor]?@", floating point":@""];
}

- (void)setColorString:(NSString*)str {
	int bits = [str intValue];
	[self setColorBits:(bits?:32)];
	BOOL fp = [str isCaseInsensitiveLike:@"*float*"];
	[self setFloatingPointColor:fp];
}

- (NSString*)depthString {
	int dbits = [self depthBits];
	if (!dbits) return @"None";
	return [NSString stringWithFormat:@"%i bit", dbits];
}

- (void)setDepthString:(NSString*)depthStr {
	int bits = [depthStr intValue];
	[self setDepthBits:bits];
}

- (NSString*)stencilString {
	int bits = [self stencilBits];
	return bits? [NSString stringWithFormat:@"%i bit", bits] : @"None";
}

- (void)setStencilString:(NSString*)newStr {
	[self setStencilBits:[newStr intValue]];
}

- (NSString*)accumString {
	switch ([self accumBits]) {
		case 0: return @"None";
		case 24: return @"24 bit RGB (8 8 8)";
		case 48: return @"48 bit RGB (16 16 16)";
		case 96: return @"96 bit RGB (32 32 32)";
		case 192: return @"192 bit RGB (64 64 64)";
		case 32: return @"32 bit RGBA (8 8 8 8)";
		case 64: return @"64 bit RGBA (16 16 16 16)";
		case 128: return @"128 bit RGBA (32 32 32 32)";
		case 256: return @"256 bit RGBA (64 64 64 64)";
	}
	return [NSString stringWithFormat:@"Unknown (%i bits)", [self accumBits]];
}

- (void)setAccumString:(NSString*)accumString {
	[self setAccumBits:[accumString intValue]];
}

- (NSString*)auxBuffersString {
	int b = [self auxBuffers];
	if (!b) return @"None";
	return [NSString stringWithFormat:@"%i", b];
}

- (void)setAuxBuffersString:(NSString*)abstr {
	[self setAuxBuffers:[abstr intValue]];
}

- (NSString*)samplingString {
	int s = [self numberOfSamples];
	if (!s) return @"None";
	return [NSString stringWithFormat:@"%i Sample%@", s, (s>1)?@"s":@""];
}

- (void)setSamplingString:(NSString*)abstr {
	[self setNumberOfSamples:[abstr intValue]];
}

- (NSString*)antiAliasingStyleString {
	switch ([self multisampleStyle]) {
		case NSOpenGLPFAMultisample: return @"Multisampling";
		case NSOpenGLPFASupersample: return @"Supersampling";
		case NSOpenGLPFASampleAlpha: return @"Alpha Sampling";
	}
	return @"Default anti-aliasing";
}

- (void)setAntiAliasingStyleString:(NSString*)abstr {
	if ([abstr isEqualToString:@"Supersampling"]) [self setMultisampleStyle:NSOpenGLPFASupersample];
	else if ([abstr isEqualToString:@"Multisampling"]) [self setMultisampleStyle:NSOpenGLPFAMultisample];
	else if ([abstr isEqualToString:@"Alpha Sampling"]) [self setMultisampleStyle:NSOpenGLPFASampleAlpha];
	else [self setMultisampleStyle:(NSOpenGLPixelFormatAttribute)0];
}

- (NSString*)rendererString {
	switch ([self renderer]) {
		case NSOpenGLPFARendererID: return @"Force Software Renderer";
		case NSOpenGLPFAAccelerated: return @"Accelerated Renderer";
	}
	return @"Default Renderer";	
}

- (void)setRendererString:(NSString*)abstr {
	if ([abstr isEqualToString:@"Force Software Renderer"]) [self setRenderer:NSOpenGLPFARendererID];
	else if ([abstr isEqualToString:@"Accelerated Renderer"]) [self setRenderer:NSOpenGLPFAAccelerated];
	else [self setRenderer:(NSOpenGLPixelFormatAttribute)0];	
}

- (NSString*)policyString {
	switch ([self policy]) {
		case NSOpenGLPFAClosestPolicy: return @"Closest";
		case NSOpenGLPFAMaximumPolicy: return @"Maximum";
		case NSOpenGLPFAMinimumPolicy: return @"Minimum";
	}
	return @"Unknown";	
}

- (void)setPolicyString:(NSString*)abstr {
	if ([abstr isEqualToString:@"Closest"]) [self setPolicy:NSOpenGLPFAClosestPolicy];
	else if ([abstr isEqualToString:@"Maximum"]) [self setPolicy:NSOpenGLPFAMaximumPolicy];
	else if ([abstr isEqualToString:@"Minimum"]) [self setPolicy:NSOpenGLPFAMinimumPolicy];
	else [self setPolicy:NSOpenGLPFAMaximumPolicy];	
}

/************************************/ #pragma mark Events /************************************/
- (double)updateInterval {
	if (!mUpdateTimer) return -1.0;
	return [mUpdateTimer timeInterval];
}

- (void)setUpdateInterval:(double)newInt {
	NSTimer* t = [NSTimer scheduledTimerWithTimeInterval:newInt target:self selector:@selector(update) userInfo:nil repeats:YES];
	O3Assign(t, mUpdateTimer);
}

- (BOOL)acceptsFirstResponder {
	return YES;
}


@end
