//========================================================================
// GLFW - An OpenGL framework
// File:        macosx_time.c
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
// $Id: macosx_time.c,v 1.6 2005/03/19 19:09:41 marcus256 Exp $
//========================================================================

#include "internal.h"

double _glfwPlatformGetTime( void )
{
    return GetCurrentEventTime() - _glfwTimer.t0;
}

void   _glfwPlatformSetTime( double time )
{
    _glfwTimer.t0 = GetCurrentEventTime() - time;
}

void   _glfwPlatformSleep( double time )
{
    struct timeval  currenttime;
    struct timespec wait;
    pthread_mutex_t mutex;
    pthread_cond_t  cond;
    long dt_sec, dt_usec;

    // Not all pthread implementations have a pthread_sleep() function. We
    // do it the portable way, using a timed wait for a condition that we
    // will never signal. NOTE: The unistd functions sleep/usleep suspends
    // the entire PROCESS, not a signle thread, which is why we can not
    // use them to implement glfwSleep.

    // Set timeout time, relatvie to current time
    gettimeofday( &currenttime, NULL );
    dt_sec  = (long) time;
    dt_usec = (long) ((time - (double)dt_sec) * 1000000.0);
    wait.tv_nsec = (currenttime.tv_usec + dt_usec) * 1000L;
    if( wait.tv_nsec > 1000000000L )
    {
        wait.tv_nsec -= 1000000000L;
        dt_sec ++;
    }
    wait.tv_sec  = currenttime.tv_sec + dt_sec;

    // Initialize condition and mutex objects
    pthread_mutex_init( &mutex, NULL );
    pthread_cond_init( &cond, NULL );

    // Do a timed wait
    pthread_mutex_lock( &mutex );
    pthread_cond_timedwait( &cond, &mutex, &wait );
    pthread_mutex_unlock( &mutex );

    // Destroy condition and mutex objects
    pthread_mutex_destroy( &mutex );
    pthread_cond_destroy( &cond );
}
