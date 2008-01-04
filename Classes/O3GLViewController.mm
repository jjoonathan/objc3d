//
//  O3GLViewController.mm
//  ObjC3D
//
//  Created by Jonathan deWerd on 12/27/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "O3GLViewController.h"
#import "O3GLViewActionCollection.h"
#import "O3GLView.h"

@implementation O3GLViewController
/************************************/ #pragma mark Init and Dealloc /************************************/
inline void initP(O3GLViewController* self) {
	self->mKeyDownActions = [[NSMutableDictionary alloc] init];
	self->mKeyUpActions = [[NSMutableDictionary alloc] init];
	self->mTarget = [O3GLViewActionCollection class];
}

- (id)init {
	O3SuperInitOrDie(); initP(self);
	[self setDefaultActions];
	return self;
}

- (void)dealloc {
	[mKeyUpActions release];
	[mKeyDownActions release];
	[mView setNextResponder:[self nextResponder]];
	O3LogDebug(@"Controller detaching from view hierarchy at %@.", mView);
	O3SuperDealloc();
}

- (id)initWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding]) {
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
		[self release];
		return nil;
	}
	[super initWithCoder:coder];
	mKeyUpActions = [[coder decodeObjectForKey:@"keyUpActions"] mutableCopy];
	mKeyDownActions = [[coder decodeObjectForKey:@"keyDownActions"] mutableCopy];
	O3Assign([coder decodeObjectForKey:@"target"], mTarget);
	if (!mTarget) mTarget = self;
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
	if (![coder allowsKeyedCoding])
		[NSException raise:NSInvalidArgumentException format:@"Object %@ cannot be encoded with a non-keyed archiver", self];
	[coder encodeObject:mKeyUpActions forKey:@"keyUpActions"];
	[coder encodeObject:mKeyDownActions forKey:@"keyDownActions"];
	if (mTarget!=self) [coder encodeObject:mTarget forKey:@"target"];
}

/************************************/ #pragma mark Accessors /************************************/
- (O3GLView*)representedView {
	return mView;
}

///Removes itself from its old place in the responder chain and inserts itself above view
- (void)setRepresentedView:(O3GLView*)view {
	if (mView) [mView setNextResponder:[self nextResponder]];
	mView = view;
	[self setNextResponder:[view nextResponder]];
	[view setNextResponder:self];
}

- (NSMutableDictionary*)keyDownActions {
	return mKeyDownActions;
}

- (NSMutableDictionary*)keyUpActions {
	return mKeyUpActions;
}

///Defaults to O3GLViewActionCollection
- (id)target {
	return mTarget;
}


/************************************/ #pragma mark Events /************************************/
static BOOL lookupAndSend(O3GLViewController* self, NSDictionary* dict, id target, NSString* name) {
	NSString* actionStr = [dict objectForKey:name];
	O3LogDebug(@"Dispatching method %@ from dict %@ to %@ for event named %@", actionStr, self->mKeyDownActions==dict?@"mKeyDownActions":(self->mKeyUpActions==dict?@"mKeyUpActions":dict), target, name);
	if (!actionStr) return NO;
	SEL action = NSSelectorFromString(actionStr);
	[target performSelector:action withObject:self->mView];
	return YES;
}

static NSString* nameForEvent(NSEvent* event) {
	NSString* charStr = [event charactersIgnoringModifiers];
	O3Assert([charStr length]==1, @"Not programmed to handle more than 1 char per event!");
	UInt32 theChar = [charStr characterAtIndex:0];
	if (theChar<256) return charStr;
	switch (theChar) {
		case 0xF700: return @"NSUpArrowFunctionKey";
		case 0xF701: return @"NSDownArrowFunctionKey";
		case 0xF702: return @"NSLeftArrowFunctionKey";
		case 0xF703: return @"NSRightArrowFunctionKey";
		case 0xF704: return @"NSF1FunctionKey";
		case 0xF705: return @"NSF2FunctionKey";
		case 0xF706: return @"NSF3FunctionKey";
		case 0xF707: return @"NSF4FunctionKey";
		case 0xF708: return @"NSF5FunctionKey";
		case 0xF709: return @"NSF6FunctionKey";
		case 0xF70A: return @"NSF7FunctionKey";
		case 0xF70B: return @"NSF8FunctionKey";
		case 0xF70C: return @"NSF9FunctionKey";
		case 0xF70D: return @"NSF10FunctionKey";
		case 0xF70E: return @"NSF11FunctionKey";
		case 0xF70F: return @"NSF12FunctionKey";
		case 0xF710: return @"NSF13FunctionKey";
		case 0xF711: return @"NSF14FunctionKey";
		case 0xF712: return @"NSF15FunctionKey";
		case 0xF713: return @"NSF16FunctionKey";
		case 0xF714: return @"NSF17FunctionKey";
		case 0xF715: return @"NSF18FunctionKey";
		case 0xF716: return @"NSF19FunctionKey";
		case 0xF717: return @"NSF20FunctionKey";
		case 0xF718: return @"NSF21FunctionKey";
		case 0xF719: return @"NSF22FunctionKey";
		case 0xF71A: return @"NSF23FunctionKey";
		case 0xF71B: return @"NSF24FunctionKey";
		case 0xF71C: return @"NSF25FunctionKey";
		case 0xF71D: return @"NSF26FunctionKey";
		case 0xF71E: return @"NSF27FunctionKey";
		case 0xF71F: return @"NSF28FunctionKey";
		case 0xF720: return @"NSF29FunctionKey";
		case 0xF721: return @"NSF30FunctionKey";
		case 0xF722: return @"NSF31FunctionKey";
		case 0xF723: return @"NSF32FunctionKey";
		case 0xF724: return @"NSF33FunctionKey";
		case 0xF725: return @"NSF34FunctionKey";
		case 0xF726: return @"NSF35FunctionKey";
		case 0xF727: return @"NSInsertFunctionKey";
		case 0xF728: return @"NSDeleteFunctionKey";
		case 0xF729: return @"NSHomeFunctionKey";
		case 0xF72A: return @"NSBeginFunctionKey";
		case 0xF72B: return @"NSEndFunctionKey";
		case 0xF72C: return @"NSPageUpFunctionKey";
		case 0xF72D: return @"NSPageDownFunctionKey";
		case 0xF72E: return @"NSPrintScreenFunctionKey";
		case 0xF72F: return @"NSScrollLockFunctionKey";
		case 0xF730: return @"NSPauseFunctionKey";
		case 0xF731: return @"NSSysReqFunctionKey";
		case 0xF732: return @"NSBreakFunctionKey";
		case 0xF733: return @"NSResetFunctionKey";
		case 0xF734: return @"NSStopFunctionKey";
		case 0xF735: return @"NSMenuFunctionKey";
		case 0xF736: return @"NSUserFunctionKey";
		case 0xF737: return @"NSSystemFunctionKey";
		case 0xF738: return @"NSPrintFunctionKey";
		case 0xF739: return @"NSClearLineFunctionKey";
		case 0xF73A: return @"NSClearDisplayFunctionKey";
		case 0xF73B: return @"NSInsertLineFunctionKey";
		case 0xF73C: return @"NSDeleteLineFunctionKey";
		case 0xF73D: return @"NSInsertCharFunctionKey";
		case 0xF73E: return @"NSDeleteCharFunctionKey";
		case 0xF73F: return @"NSPrevFunctionKey";
		case 0xF740: return @"NSNextFunctionKey";
		case 0xF741: return @"NSSelectFunctionKey";
		case 0xF742: return @"NSExecuteFunctionKey";
		case 0xF743: return @"NSUndoFunctionKey";
		case 0xF744: return @"NSRedoFunctionKey";
		case 0xF745: return @"NSFindFunctionKey";
		case 0xF746: return @"NSHelpFunctionKey";
		case 0xF747: return @"NSModeSwitchFunctionKey";
	}
	return @"UnknownKey";
}

- (void)setDefaultActions {
	[mKeyDownActions setObject:@"startFlyingLeft:" forKey:@"a"];
	[mKeyUpActions setObject:@"stopFlyingLeft:" forKey:@"a"];
	[mKeyDownActions setObject:@"startFlyingRight:" forKey:@"e"];
	[mKeyUpActions setObject:@"stopFlyingRight:" forKey:@"e"];
	[mKeyDownActions setObject:@"startFlyingForward:" forKey:@","];
	[mKeyUpActions setObject:@"stopFlyingForward:" forKey:@","];
	[mKeyDownActions setObject:@"startFlyingBackward:" forKey:@"o"];
	[mKeyUpActions setObject:@"stopFlyingBackward:" forKey:@"o"];
	[mKeyDownActions setObject:@"startFlyingUp:" forKey:@"p"];
	[mKeyUpActions setObject:@"stopFlyingUp:" forKey:@"p"];
	[mKeyDownActions setObject:@"startFlyingDown:" forKey:@"u"];
	[mKeyUpActions setObject:@"stopFlyingDown:" forKey:@"u"];
	[mKeyDownActions setObject:@"startFlyingFast:" forKey:@"NSShiftKey"];
	[mKeyUpActions setObject:@"stopFlyingFast:" forKey:@"NSShiftKey"];
}

#define luas(dict, name) lookupAndSend(self, dict, mTarget, name)

///Forwards the action up the responder chain if no action is defined, but otherwise calls the selector it found on %target. The sender argument is the view, not the controller.
- (void)keyDown:(NSEvent*)event {
	if ([event isARepeat]) return;
	if (!luas(mKeyDownActions, nameForEvent(event))); // [super keyDown:event];
}

///Forwards the action up the responder chain if no action is defined, but otherwise calls the selector it found on %target. The sender argument is the view, not the controller.
- (void)keyUp:(NSEvent*)event {
	if ([event isARepeat]) return;
	if (!luas(mKeyUpActions, nameForEvent(event))); // [super keyDown:event];
}

- (void)mouseDown:(NSEvent*)e {
	[mView toggleMouseLock];
}

- (void)flagsChanged:(NSEvent *)theEvent {
	UInt32 diFlags = [theEvent modifierFlags]&NSDeviceIndependentModifierFlagsMask;
	UInt32 flagDelta = diFlags^mFlags;
	#define CHECK_FLAG(f, name) if (flagDelta&f) luas(diFlags&f? mKeyDownActions : mKeyUpActions, name);
	CHECK_FLAG(NSAlphaShiftKeyMask, @"NSAlphaShiftKey");
	CHECK_FLAG(NSShiftKeyMask, @"NSShiftKey");
	CHECK_FLAG(NSControlKeyMask, @"NSControlKey");
	CHECK_FLAG(NSAlternateKeyMask, @"NSAlternateKey");
	CHECK_FLAG(NSCommandKeyMask, @"NSCommandKey");
	//CHECK_FLAG(NSNumericPadKeyMask, @"NSNumericPadKey");
	CHECK_FLAG(NSHelpKeyMask, @"NSHelpKey");
	CHECK_FLAG(NSFunctionKeyMask, @"NSFunctionKey");	
	#undef CHECK_FLAG
	mFlags = diFlags;
}

#undef luas


@end
