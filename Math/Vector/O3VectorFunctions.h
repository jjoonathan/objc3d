#ifdef __cplusplus
#ifndef O3TEMPLATE_FILE_VECTOR_FUNCTIONS_H
#error This is a template file, not a regular cpp file, so it cannot be used as one.
#endif
/**
 *  @file O3VectorFunctions.h
 *  @license MIT License (see LICENSE.txt)
 *  @date 2/3/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
O3Vec_TT  TYPE dot(const O3Vec_T& v, const O3Vec<TYPE, NUMBER>& v2) {return v|v2;}
O3Vec_TT  TYPE length(const O3Vec_T& v) {return v.Length();}
O3Vec_TT  O3Vec<TYPE, NUMBER> normalize(const O3Vec<TYPE, NUMBER>& v) {return v.GetNormalized();}
O3Vec_TT  O3Vec<TYPE, NUMBER> abs(const O3Vec<TYPE, NUMBER>& v) {return v.GetAbs();}
O3Vec_TT  O3Vec<TYPE, NUMBER> floor(const O3Vec<TYPE, NUMBER>& v) {return v.GetFloored();}
O3Vec_TT  O3Vec<TYPE, NUMBER> ceil(const O3Vec<TYPE, NUMBER>& v) {return v.GetCeiled();}
O3Vec_TT  O3Vec<TYPE, NUMBER> round(const O3Vec<TYPE, NUMBER>& v) {return v.GetRounded();}
O3Vec_TT  O3Vec<TYPE, NUMBER> clamp(const O3Vec<TYPE, NUMBER>& v, TYPE min, TYPE max) {return v.GetClamped(min, max);}
template <typename TYPE, int NUMBER, typename INTERP_TYPE> O3Vec<TYPE, NUMBER> lerp(const O3Vec<TYPE, NUMBER>& v, const O3Vec<TYPE, NUMBER>& v2, const INTERP_TYPE interpolant);

O3Vec_TT  std::ostream& operator<<(std::ostream& stream, const O3Vec_T& v);
#endif /*defined(__cplusplus)*/