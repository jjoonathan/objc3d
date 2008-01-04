//========================================================================
// GLFW - An OpenGL framework
// File:        macosx_init.c
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
// $Id: macosx_init.c,v 1.9 2005/03/19 19:09:41 marcus256 Exp $
//========================================================================

#include "internal.h"

//========================================================================
// _glfwInitThreads() - Initialize GLFW thread package
//========================================================================

static void _glfwInitThreads( void )
{
    // Initialize critical section handle
    (void) pthread_mutex_init( &_glfwThrd.CriticalSection, NULL );

    // The first thread (the main thread) has ID 0
    _glfwThrd.NextID = 0;

    // Fill out information about the main thread (this thread)
    _glfwThrd.First.ID       = _glfwThrd.NextID ++;
    _glfwThrd.First.Function = NULL;
    _glfwThrd.First.PosixID  = pthread_self();
    _glfwThrd.First.Previous = NULL;
    _glfwThrd.First.Next     = NULL;
}

int  _glfwChangeToResourcesDirectory( void )
{
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef resourcesURL = CFBundleCopyResourcesDirectoryURL( mainBundle );
    char resourcesPath[GLFW_MAX_PATH_LENGTH];

    if ( !CFURLGetFileSystemRepresentation( resourcesURL,
                                            TRUE,
                                            (UInt8*)resourcesPath,
                                            GLFW_MAX_PATH_LENGTH ) )
    {
        CFRelease( resourcesURL );
        return GL_FALSE;
    }

    CFRelease( resourcesURL );

    if ( chdir( resourcesPath ) != 0 )
    {
        return GL_FALSE;
    }

    return GL_TRUE;
}

int _glfwPlatformInit( void )
{
    _glfwWin.MacWindow = NULL;
    _glfwWin.AGLContext = NULL;
    _glfwWin.WindowFunctions = NULL;
    _glfwWin.MouseUPP = NULL;
    _glfwWin.CommandUPP = NULL;
    _glfwWin.KeyboardUPP = NULL;
    _glfwWin.WindowUPP = NULL;
    
    _glfwInput.Modifiers = 0;
    
    _glfwLibs.OpenGLFramework
        = CFBundleGetBundleWithIdentifier( CFSTR( "com.apple.opengl" ) );
    if ( _glfwLibs.OpenGLFramework == NULL )
    {
        return GL_FALSE;
    }

    _glfwDesktopVideoMode = CGDisplayCurrentMode( kCGDirectMainDisplay );
    if ( _glfwDesktopVideoMode == NULL )
    {
        return GL_FALSE;
    }

    _glfwInitThreads();

    if ( !_glfwChangeToResourcesDirectory() )
    {
        return GL_FALSE;
    }

    if ( !_glfwInstallEventHandlers() )
    {
    	_glfwPlatformTerminate();
        return GL_FALSE;
    }

    _glfwTimer.t0 = GetCurrentEventTime();

    return GL_TRUE;
}

int _glfwPlatformTerminate( void )
{
    if ( _glfwWin.MouseUPP != NULL )
    {
        DisposeEventHandlerUPP( _glfwWin.MouseUPP );
        _glfwWin.MouseUPP = NULL;
    }
    if ( _glfwWin.CommandUPP != NULL )
    {
        DisposeEventHandlerUPP( _glfwWin.CommandUPP );
        _glfwWin.CommandUPP = NULL;
    }
    if ( _glfwWin.KeyboardUPP != NULL )
    {
        DisposeEventHandlerUPP( _glfwWin.KeyboardUPP );
        _glfwWin.KeyboardUPP = NULL;
    }
    
    return GL_TRUE;
}
