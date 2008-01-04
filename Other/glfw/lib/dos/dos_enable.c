//========================================================================
// GLFW - An OpenGL framework
// File:        dos_enable.c
// Platform:    DOS
// API version: 2.5
// Author:      Marcus Geelnard (marcus.geelnard at home.se)
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
// $Id: dos_enable.c,v 1.4 2005/03/14 20:22:30 marcus256 Exp $
//========================================================================

#include "internal.h"


//************************************************************************
//****               Platform implementation functions                ****
//************************************************************************

//========================================================================
// _glfwPlatformEnableSystemKeys() - Enable system keys
// _glfwPlatformDisableSystemKeys() - Disable system keys
//========================================================================

void _glfwPlatformEnableSystemKeys( void )
{
    // Not supported under DOS (yet)
}

void _glfwPlatformDisableSystemKeys( void )
{
    // Not supported under DOS (yet)
}
