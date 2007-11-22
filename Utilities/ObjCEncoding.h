/**
 *  @file ObjCEncoding.h
 *  @license MIT License (see LICENSE.txt)
 *  @author Jonathan deWerd
 *  @copyright Copyright (c) 2007 Jonathan deWerd. All rights reserved, except those explicitly granted by the MIT license in LICENSE.txt.
 */
#pragma once
//This is more because gen_bridge_metadata has issue with this file than because it requires C++
#ifdef __cplusplus
#include <ctype.h>

#define OCTYPE_CONST    'r'
#define OCTYPE_IN       'n'
#define OCTYPE_INOUT    'N'
#define OCTYPE_OUT      'o'
#define OCTYPE_BYCOPY   'O'
#define OCTYPE_BYREF    'R'
#define OCTYPE_ONEWAY   'V'
#define OCTYPE_GCINVISIBLE  '!'

#define OCTYPE_ID       '@'
#define OCTYPE_CLASS    '#'
#define OCTYPE_SEL      ':'
#define OCTYPE_CHR      'c'
#define OCTYPE_UCHR     'C'
#define OCTYPE_SHT      's'
#define OCTYPE_USHT     'S'
#define OCTYPE_INT      'i'
#define OCTYPE_UINT     'I'
#define OCTYPE_LNG      'l'
#define OCTYPE_ULNG     'L'
#define OCTYPE_LNG_LNG  'q'
#define OCTYPE_ULNG_LNG 'Q'
#define OCTYPE_FLT      'f'
#define OCTYPE_DBL      'd'
#define OCTYPE_BFLD     'b'
#define OCTYPE_VOID     'v'
#define OCTYPE_UNDEF    '?'
#define OCTYPE_PTR      '^'
#define OCTYPE_CHARPTR  '*'
#define OCTYPE_ATOM     '%'
#define OCTYPE_ARY_B    '['
#define OCTYPE_ARY_E    ']'
#define OCTYPE_UNION_B  '('
#define OCTYPE_UNION_E  ')'
#define OCTYPE_STRUCT_B '{'
#define OCTYPE_STRUCT_E '}'
#define OCTYPE_VECTOR   '!'

#define OCARG_CONST    0x01
#define OCARG_IN       0x01
#define OCARG_OUT      0x02
#define OCARG_INOUT    0x03
#define OCARG_BYCOPY   0x04
#define OCARG_BYREF    0x08
#define OCARG_ONEWAY   0x10
#define OCARG_GCINVISIBLE  0x20
#endif /*defined(__cplusplus)*/