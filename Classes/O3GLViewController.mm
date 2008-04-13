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
#import "O3Camera.h"

@implementation O3GLViewController
O3DefaultO3InitializeImplementation
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
	unsigned keyCode = [event keyCode];
	switch (keyCode) {
		case 12: return @"q";
		case 13: return @"w";
		case 14: return @"e";
		case 15: return @"r";
		case 17: return @"t";
		case 16: return @"y";
		case 32: return @"u";
		case 34: return @"i";
		case 31: return @"o";
		case 35: return @"p";
		case 33: return @"[";
		case 30: return @"]";
		case 42: return @"\\";
		case 0 : return @"a";
		case 1 : return @"s";
		case 2 : return @"d";
		case 3 : return @"f";
		case 5 : return @"g";
		case 4 : return @"h";
		case 38: return @"j";
		case 40: return @"k";
		case 37: return @"l";
		case 41: return @";";
		case 39: return @"'";
		case 6 : return @"z";
		case 7 : return @"x";
		case 8 : return @"c";
		case 9 : return @"v";
		case 11: return @"b";
		case 45: return @"n";
		case 46: return @"m";
		case 43: return @",";
		case 47: return @".";
		case 44: return @"/";
		case 0x31: return @"Space";
		case 0x24: return @"Return";
		case 0x30: return @"Tab";
		case 0x33: return @"Backspace";
		case 0x35: return @"Escape";
		case 0x7A: return @"F1";
		case 0x78: return @"F2";
		case 0x63: return @"F3";
		case 0x76: return @"F4";
		case 0x60: return @"F5";
		case 0x61: return @"F6";
		case 0x62: return @"F7";
		case 0x64: return @"F8";
		case 0x65: return @"F9";
		case 0x6D: return @"F10";
		case 0x67: return @"F11";
		case 0x6F: return @"F12";
		case 0x69: return @"F13";
		case 0x6B: return @"F14";
		case 0x71: return @"F15";
		case 0x7B: return @"Left Arrow";
		case 0x7D: return @"Down Arrow";
		case 0x7C: return @"Right Arrow";
		case 0x7E: return @"Up Arrow";
		case 0x72: return @"Help";
		case 0x75: return @"Delete";
		case 0x73: return @"Home";
		case 0x77: return @"End";
		case 0x74: return @"Page Up";
		case 0x79: return @"Page Down";
		case 0x52: return @"Keypad 0";
		case 0x41: return @"Keypad .";
		case 0x4C: return @"Keypad Enter";
		case 0x53: return @"Keypad 1";
		case 0x54: return @"Keypad 2";
		case 0x55: return @"Keypad 3";
		case 0x56: return @"Keypad 4";
		case 0x57: return @"Keypad 5";
		case 0x58: return @"Keypad 6";
		case 0x45: return @"Keypad +";
		case 0x59: return @"Keypad 7";
		case 0x5B: return @"Keypad 8";
		case 0x5C: return @"Keypad 9";
		case 0x4E: return @"Keypad -";
		case 0x47: return @"Keypad Clear";
		case 0x51: return @"Keypad =";
		case 0x4B: return @"Keypad /";
		case 0x43: return @"Keypad *";
		case 0x0A: return @"Tilde";
		case 0x36: return @"Control";
		case 0x3A: return @"Option";
		case 0x37: return @"Command";
		case 0x38: return @"Shift";
		case 0x39: return @"Caps Lock";
	}
	return @"UnknownKey";
}

- (void)setDefaultActions {
	[mKeyDownActions setObject:@"startFlyingLeft:" forKey:@"a"];
	[mKeyUpActions setObject:@"stopFlyingLeft:" forKey:@"a"];
	[mKeyDownActions setObject:@"startFlyingRight:" forKey:@"d"];
	[mKeyUpActions setObject:@"stopFlyingRight:" forKey:@"d"];
	[mKeyDownActions setObject:@"startFlyingForward:" forKey:@"w"];
	[mKeyUpActions setObject:@"stopFlyingForward:" forKey:@"w"];
	[mKeyDownActions setObject:@"startFlyingBackward:" forKey:@"s"];
	[mKeyUpActions setObject:@"stopFlyingBackward:" forKey:@"s"];
	[mKeyDownActions setObject:@"startFlyingUp:" forKey:@"r"];
	[mKeyUpActions setObject:@"stopFlyingUp:" forKey:@"r"];
	[mKeyDownActions setObject:@"startFlyingDown:" forKey:@"f"];
	[mKeyUpActions setObject:@"stopFlyingDown:" forKey:@"f"];
	[mKeyDownActions setObject:@"startFlyingFast:" forKey:@"Shift"];
	[mKeyUpActions setObject:@"stopFlyingFast:" forKey:@"Shift"];
	[mKeyDownActions setObject:@"startBarrelingLeft:" forKey:@"q"];
	[mKeyUpActions setObject:@"stopBarrelingLeft:" forKey:@"q"];
	[mKeyDownActions setObject:@"startBarrelingRight:" forKey:@"e"];
	[mKeyUpActions setObject:@"stopBarrelingRight:" forKey:@"e"];
}

//Mouse motion action
- (void)lockedMouseMoved:(O3Vec2d)amount {
	[[mView camera] rotateForMouseMoved:amount];
}

#define luas(dict, name) lookupAndSend(self, dict, mTarget, name)

///Forwards the action up the responder chain if no action is defined, but otherwise calls the selector it found on %target. The sender argument is the view, not the controller.
- (void)keyDown:(NSEvent*)event {
	O3LogDebug(@"Key down: %@", event);
	if ([event isARepeat]) return;
	if (!luas(mKeyDownActions, nameForEvent(event))); // [super keyDown:event];
}

///Forwards the action up the responder chain if no action is defined, but otherwise calls the selector it found on %target. The sender argument is the view, not the controller.
- (void)keyUp:(NSEvent*)event {
	O3LogDebug(@"Key up: %@", event);
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
	CHECK_FLAG(NSAlphaShiftKeyMask, @"Caps Lock");
	CHECK_FLAG(NSShiftKeyMask, @"Shift");
	CHECK_FLAG(NSControlKeyMask, @"Control");
	CHECK_FLAG(NSAlternateKeyMask, @"Option");
	CHECK_FLAG(NSCommandKeyMask, @"Command");
	//CHECK_FLAG(NSNumericPadKeyMask, @"NSNumericPadKey");
	CHECK_FLAG(NSHelpKeyMask, @"Help");
	CHECK_FLAG(NSFunctionKeyMask, @"Function");	
	#undef CHECK_FLAG
	mFlags = diFlags;
}

#undef luas


@end

