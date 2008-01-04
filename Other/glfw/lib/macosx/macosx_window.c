//========================================================================
// GLFW - An OpenGL framework
// File:        macosx_window.c
// Platform:    Mac OS X
// API Version: 2.5
// Authors:     Keith Bauer (onesadcookie at hotmail.com)
//              Camilla Berglund (elmindreda at users.sourceforge.net)
//              Marcus Geelnard (marcus.geelnard at home.se)
// WWW:         http://glfw.sourceforge.net
//------------------------------------------------------------------------
// Copyright (c) 2002-2005 Marcus Geelnard
//
// This software is provided 'as-is', without any express or implied
// warranty. In no event will the authors be held liable for any damages
// arising from the use of this software.
//
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it
// freely, subject to the following restrictions:
//
// 1. The origin of this software must not be misrepresented; you must not
//    claim that you wrote the original software. If you use this software
//    in a product, an acknowledgment in the product documentation would
//    be appreciated but is not required.
//
// 2. Altered source versions must be plainly marked as such, and must not
//    be misrepresented as being the original software.
//
// 3. This notice may not be removed or altered from any source
//    distribution.
//
// Marcus Geelnard
// marcus.geelnard at home.se
//------------------------------------------------------------------------
// $Id: macosx_window.c,v 1.16 2005/03/19 19:09:41 marcus256 Exp $
//========================================================================

#include "internal.h"

static _GLFWmacwindowfunctions _glfwMacFSWindowFunctions =
{
    _glfwMacFSOpenWindow,
    _glfwMacFSCloseWindow,
    _glfwMacFSSetWindowTitle,
    _glfwMacFSSetWindowSize,
    _glfwMacFSSetWindowPos,
    _glfwMacFSIconifyWindow,
    _glfwMacFSRestoreWindow,
    _glfwMacFSRefreshWindowParams,
    _glfwMacFSSetMouseCursorPos
};

static _GLFWmacwindowfunctions _glfwMacDWWindowFunctions =
{
    _glfwMacDWOpenWindow,
    _glfwMacDWCloseWindow,
    _glfwMacDWSetWindowTitle,
    _glfwMacDWSetWindowSize,
    _glfwMacDWSetWindowPos,
    _glfwMacDWIconifyWindow,
    _glfwMacDWRestoreWindow,
    _glfwMacDWRefreshWindowParams,
    _glfwMacDWSetMouseCursorPos
};

#define _glfwTestModifier( modifierMask, glfwKey ) \
if ( changed & modifierMask ) \
{ \
    _glfwInputKey( glfwKey, (modifiers & modifierMask ? GLFW_PRESS : GLFW_RELEASE) ); \
}

void _glfwHandleMacModifierChange( UInt32 modifiers )
{
    UInt32 changed = modifiers ^ _glfwInput.Modifiers;

    _glfwTestModifier( shiftKey,        GLFW_KEY_LSHIFT );
    _glfwTestModifier( rightShiftKey,   GLFW_KEY_RSHIFT );
    _glfwTestModifier( controlKey,      GLFW_KEY_LCTRL );
    _glfwTestModifier( rightControlKey, GLFW_KEY_RCTRL );
    _glfwTestModifier( optionKey,       GLFW_KEY_LALT );
    _glfwTestModifier( rightOptionKey,  GLFW_KEY_RALT );

    _glfwInput.Modifiers = modifiers;
}

void _glfwHandleMacKeyChange( UInt32 keyCode, int action )
{
    switch ( keyCode )
    {
        case MAC_KEY_ESC:         _glfwInputKey( GLFW_KEY_ESC,         action); break;
        case MAC_KEY_F1:          _glfwInputKey( GLFW_KEY_F1,          action); break;
        case MAC_KEY_F2:          _glfwInputKey( GLFW_KEY_F2,          action); break;
        case MAC_KEY_F3:          _glfwInputKey( GLFW_KEY_F3,          action); break;
        case MAC_KEY_F4:          _glfwInputKey( GLFW_KEY_F4,          action); break;
        case MAC_KEY_F5:          _glfwInputKey( GLFW_KEY_F5,          action); break;
        case MAC_KEY_F6:          _glfwInputKey( GLFW_KEY_F6,          action); break;
        case MAC_KEY_F7:          _glfwInputKey( GLFW_KEY_F7,          action); break;
        case MAC_KEY_F8:          _glfwInputKey( GLFW_KEY_F8,          action); break;
        case MAC_KEY_F9:          _glfwInputKey( GLFW_KEY_F9,          action); break;
        case MAC_KEY_F10:         _glfwInputKey( GLFW_KEY_F10,         action); break;
        case MAC_KEY_F11:         _glfwInputKey( GLFW_KEY_F11,         action); break;
        case MAC_KEY_F12:         _glfwInputKey( GLFW_KEY_F12,         action); break;
        case MAC_KEY_F13:         _glfwInputKey( GLFW_KEY_F13,         action); break;
        case MAC_KEY_F14:         _glfwInputKey( GLFW_KEY_F14,         action); break;
        case MAC_KEY_F15:         _glfwInputKey( GLFW_KEY_F15,         action); break;
        case MAC_KEY_UP:          _glfwInputKey( GLFW_KEY_UP,          action); break;
        case MAC_KEY_DOWN:        _glfwInputKey( GLFW_KEY_DOWN,        action); break;
        case MAC_KEY_LEFT:        _glfwInputKey( GLFW_KEY_LEFT,        action); break;
        case MAC_KEY_RIGHT:       _glfwInputKey( GLFW_KEY_RIGHT,       action); break;
        case MAC_KEY_TAB:         _glfwInputKey( GLFW_KEY_TAB,         action); break;
        case MAC_KEY_BACKSPACE:   _glfwInputKey( GLFW_KEY_BACKSPACE,   action); break;
        case MAC_KEY_HELP:        _glfwInputKey( GLFW_KEY_INSERT,      action); break;
        case MAC_KEY_DEL:         _glfwInputKey( GLFW_KEY_DEL,         action); break;
        case MAC_KEY_PAGEUP:      _glfwInputKey( GLFW_KEY_PAGEUP,      action); break;
        case MAC_KEY_PAGEDOWN:    _glfwInputKey( GLFW_KEY_PAGEDOWN,    action); break;
        case MAC_KEY_HOME:        _glfwInputKey( GLFW_KEY_HOME,        action); break;
        case MAC_KEY_END:         _glfwInputKey( GLFW_KEY_END,         action); break;
        case MAC_KEY_KP_0:        _glfwInputKey( GLFW_KEY_KP_0,        action); break;
        case MAC_KEY_KP_1:        _glfwInputKey( GLFW_KEY_KP_1,        action); break;
        case MAC_KEY_KP_2:        _glfwInputKey( GLFW_KEY_KP_2,        action); break;
        case MAC_KEY_KP_3:        _glfwInputKey( GLFW_KEY_KP_3,        action); break;
        case MAC_KEY_KP_4:        _glfwInputKey( GLFW_KEY_KP_4,        action); break;
        case MAC_KEY_KP_5:        _glfwInputKey( GLFW_KEY_KP_5,        action); break;
        case MAC_KEY_KP_6:        _glfwInputKey( GLFW_KEY_KP_6,        action); break;
        case MAC_KEY_KP_7:        _glfwInputKey( GLFW_KEY_KP_7,        action); break;
        case MAC_KEY_KP_8:        _glfwInputKey( GLFW_KEY_KP_8,        action); break;
        case MAC_KEY_KP_9:        _glfwInputKey( GLFW_KEY_KP_9,        action); break;
        case MAC_KEY_KP_DIVIDE:   _glfwInputKey( GLFW_KEY_KP_DIVIDE,   action); break;
        case MAC_KEY_KP_MULTIPLY: _glfwInputKey( GLFW_KEY_KP_MULTIPLY, action); break;
        case MAC_KEY_KP_SUBTRACT: _glfwInputKey( GLFW_KEY_KP_SUBTRACT, action); break;
        case MAC_KEY_KP_ADD:      _glfwInputKey( GLFW_KEY_KP_ADD,      action); break;
        case MAC_KEY_KP_DECIMAL:  _glfwInputKey( GLFW_KEY_KP_DECIMAL,  action); break;
        case MAC_KEY_KP_EQUAL:    _glfwInputKey( GLFW_KEY_KP_EQUAL,    action); break;
        case MAC_KEY_KP_ENTER:    _glfwInputKey( GLFW_KEY_KP_ENTER,    action); break;
        default:
            {
                UInt32 state = 0;
                const void *KCHR = (const void *)GetScriptVariable(smCurrentScript, smKCHRCache);
                char charCode = (char)KeyTranslate( KCHR, keyCode, &state );
                UppercaseText( &charCode, 1, smSystemScript );
                _glfwInputKey( charCode, action );
            }
            break;
    }
}

EventTypeSpec GLFW_KEY_EVENT_TYPES[] =
{
    { kEventClassKeyboard, kEventRawKeyDown },
    { kEventClassKeyboard, kEventRawKeyUp },
    { kEventClassKeyboard, kEventRawKeyModifiersChanged }
};

OSStatus _glfwKeyEventHandler( EventHandlerCallRef handlerCallRef,
                               EventRef event,
                               void *userData )
{
    switch ( GetEventKind( event ) )
    {
        case kEventRawKeyDown:
            {
                UInt32 keyCode;
                short int keyChar;
               if ( GetEventParameter( event,
                                        kEventParamKeyCode,
                                        typeUInt32,
                                        NULL,
                                        sizeof( UInt32 ),
                                        NULL,
                                        &keyCode ) == noErr )
                {
                    _glfwHandleMacKeyChange( keyCode, GLFW_PRESS );
                }
                if( GetEventParameter( event,
                                       kEventParamKeyUnicodes,
                                       typeUnicodeText,
                                       NULL,
                                       sizeof(keyChar),
                                       NULL,
                                       &keyChar) == noErr )
                {
                	_glfwInputChar( keyChar, GLFW_PRESS );
                }
                return noErr;
            }
            break;
        case kEventRawKeyUp:
            {
                UInt32 keyCode;
                short int keyChar;
                if ( GetEventParameter( event,
                                        kEventParamKeyCode,
                                        typeUInt32,
                                        NULL,
                                        sizeof( UInt32 ),
                                        NULL,
                                        &keyCode ) == noErr )
                {
                    _glfwHandleMacKeyChange( keyCode, GLFW_RELEASE );
                }
                if( GetEventParameter( event,
                                       kEventParamKeyUnicodes,
                                       typeUnicodeText,
                                       NULL,
                                       sizeof(keyChar),
                                       NULL,
                                       &keyChar) == noErr )
                {
                	_glfwInputChar( keyChar, GLFW_RELEASE );
                }
                return noErr;
            }
            break;
        case kEventRawKeyModifiersChanged:
            {
                UInt32 modifiers;
                if ( GetEventParameter( event,
                                        kEventParamKeyModifiers,
                                        typeUInt32,
                                        NULL,
                                        sizeof( UInt32 ),
                                        NULL,
                                        &modifiers ) == noErr )
                {
                    _glfwHandleMacModifierChange( modifiers );
                    return noErr;
                }
            }
            break;
    }

    return eventNotHandledErr;
}

EventTypeSpec GLFW_MOUSE_EVENT_TYPES[] =
{
    { kEventClassMouse, kEventMouseDown },
    { kEventClassMouse, kEventMouseUp },
    { kEventClassMouse, kEventMouseMoved },
    { kEventClassMouse, kEventMouseDragged },
    { kEventClassMouse, kEventMouseWheelMoved },
};

OSStatus _glfwMouseEventHandler( EventHandlerCallRef handlerCallRef,
                                 EventRef event,
                                 void *userData )
{
    // TO DO: this is probably completely broken for full-screen
    switch ( GetEventKind( event ) )
    {
        case kEventMouseDown:
            {
                WindowRef window;
                EventRecord oldStyleMacEvent;
                ConvertEventRefToEventRecord( event, &oldStyleMacEvent );
                if ( FindWindow ( oldStyleMacEvent.where, &window ) == inMenuBar )
                {
                    MenuSelect( oldStyleMacEvent.where );
                    HiliteMenu(0);
                    return noErr;
                }
                else
                {
                    HIPoint mouseLocation;
                    if ( !_glfwWin.Fullscreen )
                    {
                        if ( GetEventParameter( event,
                                                kEventParamWindowMouseLocation,
                                                typeHIPoint,
                                                NULL,
                                                sizeof( HIPoint ),
                                                NULL,
                                                &mouseLocation ) != noErr )
                            break;
                    }

                    EventMouseButton button;
                    if ( GetEventParameter( event,
                                            kEventParamMouseButton,
                                            typeMouseButton,
                                            NULL,
                                            sizeof( EventMouseButton ),
                                            NULL,
                                            &button ) == noErr )
                    {
                        button -= kEventMouseButtonPrimary;
                        if ( button <= GLFW_MOUSE_BUTTON_LAST )
                        {
                            _glfwInputMouseClick( button
                                                  + GLFW_MOUSE_BUTTON_LEFT,
                                                  GLFW_PRESS );
                        }
                        return noErr;
                    }
                }
            }
            break;
        case kEventMouseUp:
            {
                HIPoint mouseLocation;

                if ( !_glfwWin.Fullscreen )
                {
                    if ( GetEventParameter( event,
                                            kEventParamWindowMouseLocation,
                                            typeHIPoint,
                                            NULL,
                                            sizeof( HIPoint ),
                                            NULL,
                                            &mouseLocation ) != noErr )
                        break;
                }

                EventMouseButton button;
                if ( GetEventParameter( event,
                                        kEventParamMouseButton,
                                        typeMouseButton,
                                        NULL,
                                        sizeof( EventMouseButton ),
                                        NULL,
                                        &button ) == noErr )
                {
                  button -= kEventMouseButtonPrimary;
                  if ( button <= GLFW_MOUSE_BUTTON_LAST )
                  {
                    _glfwInputMouseClick( button
                                          + GLFW_MOUSE_BUTTON_LEFT,
                                          GLFW_RELEASE );
                  }
                  return noErr;
                }
            }
            break;
        case kEventMouseMoved:
        case kEventMouseDragged:
            {
                HIPoint mouseLocation;
                if ( _glfwWin.Fullscreen )
                {
                    if ( GetEventParameter( event,
                                            kEventParamMouseLocation,
                                            typeHIPoint,
                                            NULL,
                                            sizeof( HIPoint ),
                                            NULL,
                                            &mouseLocation ) == noErr )
                    {
                        _glfwInput.MousePosX = mouseLocation.x;
                        _glfwInput.MousePosY = mouseLocation.y;
                        if( _glfwWin.MousePosCallback )
                        {
                            _glfwWin.MousePosCallback( _glfwInput.MousePosX,
                                                       _glfwInput.MousePosY );
                        }
                        return noErr;
                    }
                }
                else
                {
                    if ( GetEventParameter( event,
                                            kEventParamWindowMouseLocation,
                                            typeHIPoint,
                                            NULL,
                                            sizeof( HIPoint ),
                                            NULL,
                                            &mouseLocation ) == noErr )
                    {
                        Rect structure, content;
                        GetWindowBounds(_glfwWin.MacWindow, kWindowStructureRgn, &structure);
                        GetWindowBounds(_glfwWin.MacWindow, kWindowContentRgn, &content);
                        _glfwInput.MousePosX = mouseLocation.x - content.left + structure.left;
                        _glfwInput.MousePosY = mouseLocation.y - content.top + structure.top;
                        if( _glfwWin.MousePosCallback )
                        {
                            _glfwWin.MousePosCallback( _glfwInput.MousePosX,
                                                       _glfwInput.MousePosY );
                        }
                        return noErr;
                    }
                }
            }
            break;
        case kEventMouseWheelMoved:
            {
                EventMouseWheelAxis axis;
                if ( GetEventParameter( event,
                                        kEventParamMouseWheelAxis,
                                        typeMouseWheelAxis,
                                        NULL,
                                        sizeof( EventMouseWheelAxis ),
                                        NULL,
                                        &axis) == noErr )
                {
                    long wheelDelta;
                    if ( axis == kEventMouseWheelAxisY &&
                         GetEventParameter( event,
                                            kEventParamMouseWheelDelta,
                                            typeLongInteger,
                                            NULL,
                                            sizeof( long ),
                                            NULL,
                                            &wheelDelta ) == noErr )
                    {
                        _glfwInput.WheelPos += wheelDelta;
                        if( _glfwWin.MouseWheelCallback )
                        {
                            _glfwWin.MouseWheelCallback( _glfwInput.WheelPos );
                        }
                        return noErr;
                    }
                }
            }
            break;
    }

    return eventNotHandledErr;
}

EventTypeSpec GLFW_COMMAND_EVENT_TYPES[] =
{
    { kEventClassCommand, kEventCommandProcess }
};

OSStatus _glfwCommandHandler( EventHandlerCallRef handlerCallRef,
                                 EventRef event,
                                 void *userData )
{
    if ( _glfwWin.SysKeysDisabled )
    {
        // TO DO: give adequate UI feedback that this is the case
        return eventNotHandledErr;
    }

    HICommand command;
    if ( GetEventParameter( event,
                            kEventParamDirectObject,
                            typeHICommand,
                            NULL,
                            sizeof( HICommand ),
                            NULL,
                            &command ) == noErr )
    {
        switch ( command.commandID )
        {
            case kHICommandClose:
            case kHICommandQuit:
            {
                // Check if the program wants us to close the window
                if( _glfwWin.WindowCloseCallback )
                {
                    if( _glfwWin.WindowCloseCallback() )
                    {
                        glfwCloseWindow();
                    }
                }
                else
                {
                    glfwCloseWindow();
                }
                return noErr;
            }
        }
    }

    return eventNotHandledErr;
}

EventTypeSpec GLFW_WINDOW_EVENT_TYPES[] =
{
  { kEventClassWindow, kEventWindowBoundsChanged },
  { kEventClassWindow, kEventWindowClose },
  { kEventClassWindow, kEventWindowDrawContent },
};

OSStatus _glfwWindowEventHandler( EventHandlerCallRef handlerCallRef,
                              EventRef event,
                              void *userData )
{
	switch (GetEventKind(event))
 	{
    	case kEventWindowBoundsChanged:
    	{
      		WindowRef window;
      		GetEventParameter(event, kEventParamDirectObject, typeWindowRef, NULL,
			                  sizeof(WindowRef), NULL, &window);

      		Rect rect;
      		GetWindowPortBounds(window, &rect);

      		if ( _glfwWin.Width != rect.right ||
           	    _glfwWin.Height != rect.bottom)
      		{
        		aglUpdateContext(_glfwWin.AGLContext);

        		_glfwWin.Width  = rect.right;
        		_glfwWin.Height = rect.bottom;
        		if( _glfwWin.WindowSizeCallback )
        		{
          			_glfwWin.WindowSizeCallback( _glfwWin.Width,
                                                _glfwWin.Height );
        		}
        		// Emulate (force) content invalidation
        		if( _glfwWin.WindowRefreshCallback )
        		{
                    _glfwWin.WindowRefreshCallback();
        		}
      		}
      		break;
    	}

    	case kEventWindowClose:
    	{
      		// Check if the program wants us to close the window
      		if( _glfwWin.WindowCloseCallback )
      		{
          		if( _glfwWin.WindowCloseCallback() )
          		{
              		glfwCloseWindow();
          		}
     	 	}
      		else
      		{
          		glfwCloseWindow();
      		}
      		return noErr;
    	}

    	case kEventWindowDrawContent:
    	{
			// Call user callback function
            if( _glfwWin.WindowRefreshCallback )
	        {
				_glfwWin.WindowRefreshCallback();
			}
			break;
      }
  	}

  	return eventNotHandledErr;
}

int  _glfwInstallEventHandlers( void )
{
    OSStatus error;

    _glfwWin.MouseUPP = NewEventHandlerUPP( _glfwMouseEventHandler );

    error = InstallEventHandler( GetApplicationEventTarget(),
                                 _glfwWin.MouseUPP,
                                 GetEventTypeCount( GLFW_MOUSE_EVENT_TYPES ),
                                 GLFW_MOUSE_EVENT_TYPES,
                                 NULL,
                                 NULL );
    if ( error != noErr )
    {
        return GL_FALSE;
    }

    _glfwWin.CommandUPP = NewEventHandlerUPP( _glfwCommandHandler );

    error = InstallEventHandler( GetApplicationEventTarget(),
                                 _glfwWin.CommandUPP,
                                 GetEventTypeCount( GLFW_COMMAND_EVENT_TYPES ),
                                 GLFW_COMMAND_EVENT_TYPES,
                                 NULL,
                                 NULL );
    if ( error != noErr )
    {
      return GL_FALSE;
    }

    _glfwWin.KeyboardUPP = NewEventHandlerUPP( _glfwKeyEventHandler );

    error = InstallEventHandler( GetApplicationEventTarget(),
                                 _glfwWin.KeyboardUPP,
                                 GetEventTypeCount( GLFW_KEY_EVENT_TYPES ),
                                 GLFW_KEY_EVENT_TYPES,
                                 NULL,
                                 NULL );
    if ( error != noErr )
    {
        return GL_FALSE;
    }

    return GL_TRUE;
}

#define _setAGLAttribute( aglAttributeName, parameter ) \
if ( parameter != 0 ) { \
    pixelFormatAttributes[numAttrs++] = aglAttributeName; \
    pixelFormatAttributes[numAttrs++] = parameter; \
}

#define _getAGLAttribute( aglAttributeName, variableName ) \
{ \
    GLint value; \
    (void)aglDescribePixelFormat( pixelFormat, aglAttributeName, &value ); \
    variableName = value; \
}

int  _glfwPlatformOpenWindow( int width,
                              int height,
                              int redbits,
                              int greenbits,
                              int bluebits,
                              int alphabits,
                              int depthbits,
                              int stencilbits,
                              int mode,
                              int accumredbits,
                              int accumgreenbits,
                              int accumbluebits,
                              int accumalphabits,
                              int auxbuffers,
                              int stereo,
                              int refreshrate )
{
    OSStatus error;

    // TO DO: Refactor this function!

    _glfwWin.WindowFunctions = (mode == GLFW_FULLSCREEN ? &_glfwMacFSWindowFunctions : &_glfwMacDWWindowFunctions);

    // create pixel format attribute list

    GLint pixelFormatAttributes[256];
    int numAttrs = 0;

    pixelFormatAttributes[numAttrs++] = AGL_RGBA;
    pixelFormatAttributes[numAttrs++] = AGL_DOUBLEBUFFER;

    if ( mode == GLFW_FULLSCREEN )
    {
        pixelFormatAttributes[numAttrs++] = AGL_FULLSCREEN;
    }

    if ( stereo )
    {
        pixelFormatAttributes[numAttrs++] = AGL_STEREO;
    }

    _setAGLAttribute( AGL_AUX_BUFFERS,      auxbuffers);

    _setAGLAttribute( AGL_RED_SIZE,         redbits );
    _setAGLAttribute( AGL_GREEN_SIZE,       greenbits );
    _setAGLAttribute( AGL_BLUE_SIZE,        bluebits );
    _setAGLAttribute( AGL_ALPHA_SIZE,       alphabits );
    _setAGLAttribute( AGL_DEPTH_SIZE,       depthbits );
    _setAGLAttribute( AGL_STENCIL_SIZE,     stencilbits );
    _setAGLAttribute( AGL_ACCUM_RED_SIZE,   accumredbits );
    _setAGLAttribute( AGL_ACCUM_GREEN_SIZE, accumgreenbits );
    _setAGLAttribute( AGL_ACCUM_BLUE_SIZE,  accumbluebits );
    _setAGLAttribute( AGL_ACCUM_ALPHA_SIZE, accumalphabits );

    pixelFormatAttributes[numAttrs++] = AGL_NONE;

    // create pixel format.

    AGLDevice mainMonitor = GetMainDevice();
    AGLPixelFormat pixelFormat = aglChoosePixelFormat( &mainMonitor,
                                                       1,
                                                       pixelFormatAttributes );
    if ( pixelFormat == NULL )
    {
        return GL_FALSE;
    }

    // store pixel format's values for _glfwPlatformGetWindowParam's use

    _getAGLAttribute( AGL_ACCELERATED,      _glfwWin.Accelerated );
    _getAGLAttribute( AGL_RED_SIZE,         _glfwWin.RedBits );
    _getAGLAttribute( AGL_GREEN_SIZE,       _glfwWin.GreenBits );
    _getAGLAttribute( AGL_BLUE_SIZE,        _glfwWin.BlueBits );
    _getAGLAttribute( AGL_ALPHA_SIZE,       _glfwWin.AlphaBits );
    _getAGLAttribute( AGL_DEPTH_SIZE,       _glfwWin.DepthBits );
    _getAGLAttribute( AGL_STENCIL_SIZE,     _glfwWin.StencilBits );
    _getAGLAttribute( AGL_ACCUM_RED_SIZE,   _glfwWin.AccumRedBits );
    _getAGLAttribute( AGL_ACCUM_GREEN_SIZE, _glfwWin.AccumGreenBits );
    _getAGLAttribute( AGL_ACCUM_BLUE_SIZE,  _glfwWin.AccumBlueBits );
    _getAGLAttribute( AGL_ACCUM_ALPHA_SIZE, _glfwWin.AccumAlphaBits );
    _getAGLAttribute( AGL_AUX_BUFFERS,      _glfwWin.AuxBuffers );
    _getAGLAttribute( AGL_STEREO,           _glfwWin.Stereo );
    _glfwWin.RefreshRate = refreshrate;

    // create AGL context

    _glfwWin.AGLContext = aglCreateContext( pixelFormat, NULL );

    aglDestroyPixelFormat( pixelFormat );

    if ( _glfwWin.AGLContext == NULL )
    {
        _glfwPlatformCloseWindow();
        return GL_FALSE;
    }

    // create window

    Rect windowContentBounds;
    windowContentBounds.left = 0;
    windowContentBounds.top = 0;
    windowContentBounds.right = width;
    windowContentBounds.bottom = height;

    error = CreateNewWindow( kDocumentWindowClass,
                             GLFW_WINDOW_ATTRIBUTES,
                             &windowContentBounds,
                             &( _glfwWin.MacWindow ) );
    if ( ( error != noErr ) || ( _glfwWin.MacWindow == NULL ) )
    {
        _glfwPlatformCloseWindow();
        return GL_FALSE;
    }

    if ( !_glfwWin.Fullscreen )
    {
      _glfwWin.WindowUPP = NewEventHandlerUPP( _glfwWindowEventHandler );

      error = InstallWindowEventHandler( _glfwWin.MacWindow,
                                         _glfwWin.WindowUPP,
                                         GetEventTypeCount( GLFW_WINDOW_EVENT_TYPES ),
                                         GLFW_WINDOW_EVENT_TYPES,
                                         NULL,
                                         NULL );
      if ( error != noErr )
      {
        _glfwPlatformCloseWindow();
        return GL_FALSE;
      }
    }

    // Don't care if we fail here
    (void)SetWindowTitleWithCFString( _glfwWin.MacWindow, CFSTR( "GLFW Window" ) );
    (void)RepositionWindow( _glfwWin.MacWindow,
                            NULL,
                            kWindowCenterOnMainScreen );

    // TO DO: put this somewhere else; this is a bit too soon
    ShowWindow( _glfwWin.MacWindow );

    // show window, attach OpenGL context, &c

    if ( mode == GLFW_FULLSCREEN )
    {
        CGDisplayErr cgError;

        cgError = CGCaptureAllDisplays();
        if ( cgError != CGDisplayNoErr )
        {
            _glfwPlatformCloseWindow();
            return GL_FALSE;
        }

        HideMenuBar();

        // I have no idea if this will work at all, particularly on
        // multi-monitor systems.  Might need to use CGL for full-screen
        // setup and AGL for windowed (ugh!).
        if ( !aglSetFullScreen( _glfwWin.AGLContext,
                                width,
                                height,
                                refreshrate,
                                0 ) )
        {
            _glfwPlatformCloseWindow();
            return GL_FALSE;
        }
    }
    else
    {
        if ( !aglSetDrawable( _glfwWin.AGLContext,
                              GetWindowPort( _glfwWin.MacWindow ) ) )
        {
            _glfwPlatformCloseWindow();
            return GL_FALSE;
        }
    }

    // Make OpenGL context current;

    if ( !aglSetCurrentContext( _glfwWin.AGLContext ) )
    {
        _glfwPlatformCloseWindow();
        return GL_FALSE;
    }

    return GL_TRUE;
}

void _glfwPlatformCloseWindow( void )
{
    if( _glfwWin.WindowFunctions != NULL )
    {
	    if( _glfwWin.WindowUPP != NULL )
	    {
	        DisposeEventHandlerUPP( _glfwWin.WindowUPP );
	        _glfwWin.WindowUPP = NULL;
	    }

	    _glfwWin.WindowFunctions->CloseWindow();

	    if( _glfwWin.AGLContext != NULL )
	    {
		    aglSetCurrentContext( NULL );
		    aglSetDrawable( _glfwWin.AGLContext, NULL );
		    aglDestroyContext( _glfwWin.AGLContext );
		    _glfwWin.AGLContext = NULL;
		}

    	if( _glfwWin.MacWindow != NULL )
    	{
		    ReleaseWindow( _glfwWin.MacWindow );
		    _glfwWin.MacWindow = NULL;
	    }

	    _glfwWin.WindowFunctions = NULL;
    }
}

void _glfwPlatformSetWindowTitle( const char *title )
{
    _glfwWin.WindowFunctions->SetWindowTitle( title );
}

void _glfwPlatformSetWindowSize( int width, int height )
{
    _glfwWin.WindowFunctions->SetWindowSize( width, height );
}

void _glfwPlatformSetWindowPos( int x, int y )
{
    _glfwWin.WindowFunctions->SetWindowPos( x, y );
}

void _glfwPlatformIconifyWindow( void )
{
    _glfwWin.WindowFunctions->IconifyWindow();
}

void _glfwPlatformRestoreWindow( void )
{
    _glfwWin.WindowFunctions->RestoreWindow();
}

void _glfwPlatformSwapBuffers( void )
{
    aglSwapBuffers( _glfwWin.AGLContext );
}

void _glfwPlatformSwapInterval( int interval )
{
    GLint parameter = interval;
    // Don't care if we fail here
    (void)aglSetInteger( _glfwWin.AGLContext,
                         AGL_SWAP_INTERVAL,
                         &parameter );
}

void _glfwPlatformRefreshWindowParams( void )
{
    _glfwWin.WindowFunctions->RefreshWindowParams();
}

int  _glfwPlatformGetWindowParam( int param )
{
    switch ( param )
    {
        case GLFW_ACCELERATED:      return _glfwWin.Accelerated;    break;
        case GLFW_RED_BITS:         return _glfwWin.RedBits;        break;
        case GLFW_GREEN_BITS:       return _glfwWin.GreenBits;      break;
        case GLFW_BLUE_BITS:        return _glfwWin.BlueBits;       break;
        case GLFW_ALPHA_BITS:       return _glfwWin.AlphaBits;      break;
        case GLFW_DEPTH_BITS:       return _glfwWin.DepthBits;      break;
        case GLFW_STENCIL_BITS:     return _glfwWin.StencilBits;    break;
        case GLFW_ACCUM_RED_BITS:   return _glfwWin.AccumRedBits;   break;
        case GLFW_ACCUM_GREEN_BITS: return _glfwWin.AccumGreenBits; break;
        case GLFW_ACCUM_BLUE_BITS:  return _glfwWin.AccumBlueBits;  break;
        case GLFW_ACCUM_ALPHA_BITS: return _glfwWin.AccumAlphaBits; break;
        case GLFW_AUX_BUFFERS:      return _glfwWin.AuxBuffers;     break;
        case GLFW_STEREO:           return _glfwWin.Stereo;         break;
        case GLFW_REFRESH_RATE:     return _glfwWin.RefreshRate;    break;
        default:                    return GL_FALSE;
    }
}

void _glfwPlatformPollEvents( void )
{
    EventRef event;
    EventTargetRef eventDispatcher = GetEventDispatcherTarget();

    while ( ReceiveNextEvent( 0, NULL, 0.0, TRUE, &event ) == noErr )
    {
        SendEventToEventTarget( event, eventDispatcher );
        ReleaseEvent( event );
    }
}

void _glfwPlatformWaitEvents( void )
{
    EventRef event;

    // Wait for new events
    ReceiveNextEvent( 0, NULL, kEventDurationForever, FALSE, &event );

    // Poll new events
    _glfwPlatformPollEvents();
}

void _glfwPlatformHideMouseCursor( void )
{
    // TO DO: What if we fail here?
    (void)CGDisplayHideCursor( kCGDirectMainDisplay );
}

void _glfwPlatformShowMouseCursor( void )
{
    // TO DO: What if we fail here?
    (void)CGDisplayShowCursor( kCGDirectMainDisplay );
}

void _glfwPlatformSetMouseCursorPos( int x, int y )
{
    _glfwWin.WindowFunctions->SetMouseCursorPos( x, y );
}


int  _glfwMacFSOpenWindow( int width, int height, int redbits, int greenbits, int bluebits, int alphabits, int depthbits, int stencilbits, int accumredbits, int accumgreenbits, int accumbluebits, int accumalphabits, int auxbuffers, int stereo, int refreshrate )
{
    return GL_FALSE;
}

void _glfwMacFSCloseWindow( void )
{
    // TO DO: un-capture displays, &c.
}

void _glfwMacFSSetWindowTitle( const char *title )
{
    // no-op really, change "fake" mini-window title
    _glfwMacDWSetWindowTitle( title );
}

void _glfwMacFSSetWindowSize( int width, int height )
{
    // TO DO: something funky for full-screen
    _glfwMacDWSetWindowSize( width, height );
}

void _glfwMacFSSetWindowPos( int x, int y )
{
    // no-op really, change "fake" mini-window position
    _glfwMacDWSetWindowPos( x, y );
}

void _glfwMacFSIconifyWindow( void )
{
    // TO DO: Something funky for full-screen
    _glfwMacDWIconifyWindow();
}

void _glfwMacFSRestoreWindow( void )
{
    _glfwMacDWRestoreWindow();
    // TO DO: Something funky for full-screen
}

void _glfwMacFSRefreshWindowParams( void )
{
    // TO DO: implement this!
}

void _glfwMacFSSetMouseCursorPos( int x, int y )
{
    // TO DO: play with event suppression interval.  Ugh.
    // TO DO: what if we fail here?
    (void)CGDisplayMoveCursorToPoint( kCGDirectMainDisplay,
                                      CGPointMake( x, y ) );
}

int  _glfwMacDWOpenWindow( int width, int height, int redbits, int greenbits, int bluebits, int alphabits, int depthbits, int stencilbits, int accumredbits, int accumgreenbits, int accumbluebits, int accumalphabits, int auxbuffers, int stereo, int refreshrate )
{
    return GL_FALSE;
}

void _glfwMacDWCloseWindow( void )
{
}

void _glfwMacDWSetWindowTitle( const char *title )
{
    CFStringRef windowTitle = CFStringCreateWithCString( kCFAllocatorDefault,
                                                         title,
                                                         kCFStringEncodingISOLatin1 );

    // Don't care if we fail
    (void)SetWindowTitleWithCFString( _glfwWin.MacWindow, windowTitle );

    CFRelease( windowTitle );
}

void _glfwMacDWSetWindowSize( int width, int height )
{
    SizeWindow( _glfwWin.MacWindow,
                width,
                height,
                TRUE );
}

void _glfwMacDWSetWindowPos( int x, int y )
{
    // TO DO: take main monitor bounds into account
    MoveWindow( _glfwWin.MacWindow,
                x,
                y,
                FALSE );
}

void _glfwMacDWIconifyWindow( void )
{
    // TO DO: What if we fail here?
    (void)CollapseWindow( _glfwWin.MacWindow,
                          TRUE );
}

void _glfwMacDWRestoreWindow( void )
{
    // TO DO: What if we fail here?
    (void)CollapseWindow( _glfwWin.MacWindow,
                          FALSE );
}

void _glfwMacDWRefreshWindowParams( void )
{
    // TO DO: implement this!
}

void _glfwMacDWSetMouseCursorPos( int x, int y )
{
    // TO DO: handle window position
    _glfwMacFSSetMouseCursorPos( x, y );
}
