//
//  O3GLView.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 10/18/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
@class O3ResManager, O3Camera, O3Scene;

@interface O3GLView : NSView {
	NSOpenGLContext* mContext;
	NSColor* mBackgroundColor;
	O3ResManager* mResManager;
	NSString* mSceneName;
	O3Scene* mScene;
	O3Camera* mCamera;
	
	//Pixel format attribs
	NSOpenGLPixelFormatAttribute mMultisampleStyle;
	NSOpenGLPixelFormatAttribute mRenderer;
	NSOpenGLPixelFormatAttribute mPolicy;
	UInt16 mColorBits;
	UInt16 mDepthBits;
	UInt16 mStencilBits;
	UInt16 mAccumBits;
	UInt8 mAuxBuffers;
	UInt8 mSampleCount;
	BOOL mFloatingColor:1;
	BOOL mAuxDepthStencil:1;
	BOOL mDoubleBuffer:1;
	BOOL mStereoBuffer:1;
	BOOL mNoRecovery:1;
	BOOL mContextNeedsUpdate:1;
}
//Init
- (O3GLView*)initWithFrame:(NSRect)frameRect;

//Attributes
- (O3ResManager*)resourceManager;
- (void)setResourceManager:(O3ResManager*)manager;
- (NSString*)sceneName;
- (void)setSceneName:(NSString*)name;
- (O3Scene*)scene;
- (void)setScene:(O3Scene*)scene;
- (O3Camera*)camera;
- (void)setCamera:(O3Camera*)newCamera;
- (NSOpenGLContext*)context;
- (NSColor*)backgroundColor;
- (void)setBackgroundColor:(NSColor*)color;

//Rendering
- (void)drawBlackScreenOfDeath:(NSString*)message;

//Pixel format attributes
- (NSOpenGLContext*)generateContext; ///<Generates a context based on the parameters stored in the receiver and transfers textures, etc. This is called if no context exists when one is needed.
- (long)colorBits;
- (void)setColorBits:(long)bits;
- (BOOL)floatingPointColor;
- (void)setFloatingPointColor:(BOOL)fp;
- (long)depthBits;
- (void)setDepthBits:(long)bits;
- (long)stencilBits;
- (void)setStencilBits:(long)newStencilBits;
- (long)accumBits;
- (void)setAccumBits:(long)accumBits;
- (long)auxBuffers;
- (void)setAuxBuffers:(long)buffers;
- (BOOL)auxDepthStencil;
- (void)setAuxDepthStencil:(BOOL)ads;
- (BOOL)doubleBuffer;
- (void)setDoubleBuffer:(BOOL)db;
- (BOOL)stereoBuffer;
- (void)setStereoBuffer:(BOOL)sb;
- (long)numberOfSamples;
- (void)setNumberOfSamples:(long)numberOfSamples;
- (NSOpenGLPixelFormatAttribute)multisampleStyle;
- (void)setMultisampleStyle:(NSOpenGLPixelFormatAttribute)style;
- (NSOpenGLPixelFormatAttribute)renderer;
- (void)setRenderer:(NSOpenGLPixelFormatAttribute)rend;
- (BOOL)noRecovery;
- (void)setNoRecovery:(BOOL)nr;
- (NSOpenGLPixelFormatAttribute)policy;
- (void)setPolicy:(NSOpenGLPixelFormatAttribute)newPolicy;

//OpenGL props
- (NSString*)colorString;
- (void)setColorString:(NSString*)str;
- (NSString*)depthString;
- (void)setDepthString:(NSString*)depthStr;
- (NSString*)stencilString;
- (void)setStencilString:(NSString*)newStr;
- (NSString*)accumString;
- (void)setAccumString:(NSString*)accumString;
- (NSString*)auxBuffersString;
- (void)setAuxBuffersString:(NSString*)abstr;
- (NSString*)samplingString;
- (void)setSamplingString:(NSString*)abstr;
- (NSString*)antiAliasingStyleString;
- (void)setAntiAliasingStyleString:(NSString*)abstr;
- (NSString*)rendererString;
- (void)setRendererString:(NSString*)abstr;
- (NSString*)policyString;
- (void)setPolicyString:(NSString*)abstr;

//Private
- (void)setContext:(NSOpenGLContext*)context;

@end
