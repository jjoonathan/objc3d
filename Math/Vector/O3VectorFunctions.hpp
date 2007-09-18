/**
 *  @file O3VectorFunctions.hpp
 *  @license MIT License (see LICENSE.txt)
 *  @date 2/3/07.
 *  @author Jonathan deWerd
 *  @copyright Copyright 2007 Jonathan deWerd. This file is distributed under the MIT license (see accompanying file for details).
 */
template <typename TYPE, int NUMBER, typename INTERP_TYPE> 
O3Vec<TYPE, NUMBER> lerp(const O3Vec<TYPE, NUMBER>& v, const O3Vec<TYPE, NUMBER>& v2, const INTERP_TYPE interpolant) {
	O3Vec<TYPE, NUMBER> to_return; 
	int i; for (i=0;i<NUMBER;i++) {
		to_return[i] = (1.0 - interpolant)*(v[i]) + v2[i]*interpolant;
	}
	return to_return;
}

O3Vec_TT
std::ostream& operator<<(std::ostream &stream, const O3Vec_T& v) {
	stream<<"O3Vec<?,"<<NUMBER<<">(";
	int i; for (i=0;i<NUMBER;i++) stream<<v[i]<<((i<(NUMBER-1))?", ":")");
	return stream;
}
