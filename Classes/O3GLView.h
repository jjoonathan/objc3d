//
//  O3GLView.h
//  ObjC3D
//
//  Created by Jonathan deWerd on 10/18/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3Timer.h"
@class O3ResManager, O3Camera, O3Scene, O3GLViewController;

@interface O3GLView : NSView {
	NSOpenGLContext* mContext;
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
	BOOL mOwnsMouse:1; ///<YES if the receiver has made the mouse invisible and centered it
	BOOL mIgnoreNextRot:1; //If the mouse appears to "jump," so does the view, so the jumps need to be ignored
	BOOL mRenderingDisabled:1;
	BOOL mLogFPS:1; //More of a debug thing for the scripting layer (not public)
	
	NSTimer* mUpdateTimer;
	NSMutableDictionary* mViewState; ///<A scratch dictionary
}
//Init
- (O3GLView*)initWithFrame:(NSRect)frameRect;

//Convenience
- (void)installDefaultViewController;
- (O3GLViewController*)controller;
- (void)toggleMouseLock;

//Mouse
- (void)lockMouse;
- (void)unlockMouse;
- (BOOL)mouseLocked;

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
- (NSColor*)backgroundColor; ///<For convenience only, actually just calls through to the scene
- (void)setBackgroundColor:(NSColor*)color;
- (O3Scene*)setDefaultScene;
- (double)updateInterval; ///<-1 if automatic updates are disabled
- (void)setUpdateInterval:(double)newInt;
- (NSMutableDictionary*)viewState; ///<The receiver's scratch dictionary

//Rendering
- (void)update;
- (void)drawBlackScreenOfDeath:(NSString*)message;
- (BOOL)paused;
- (void)setPaused:(BOOL)paused;

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
