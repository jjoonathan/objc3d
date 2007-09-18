/**
 *  @file ObjC3D.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 6/2/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
#if !defined(__OBJC__) || !defined(__cplusplus)
#error ObjC3D requires ObjectiveC++ (different from plain ObjectiveC) to compile.
#error Since the ObjC3D headers are expensive to process, you probably want to #include <ObjC3D/ObjC3D.h> in your precompiled header (.pch) file, and if you have ObjC++ in your pch file you need to allow it in your whole project.
#error Fix this by making all your .m files into .mm files or by getting info on all your .m source files and setting their "File Type" to sourcecode.cpp.objcpp
#endif

#include "O3Global.h"
#include "O3Math.h"
#include "O3Color.h"
