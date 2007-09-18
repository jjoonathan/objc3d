// tri_stripper.h: interface for the tri_stripper class.
//
//////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2002 Tanguy Fautr�.
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.
//
//  Tanguy Fautr�
//  softdev@pandora.be
//
//////////////////////////////////////////////////////////////////////
//
//							Tri Stripper
//							************
//
// Current version: 1.00 Final (23/04/2003)
//
// Comment: Triangle stripper in O(n.log(n)).
//          
//          Currently there are no protection against crazy values
//          given via SetMinStripSize() and SetCacheSize().
//          So be careful. (Min. strip size should be equal or greater
//          than 2, cache size should be about 10 for GeForce 256/2
//          and about 10-16 for GeForce 3/4.) 
//          
// History: - 1.00 FINAL  (23/04/2003) - Separated cache simulator into another class
//                                     - Fixed English: "indice" -> "index"
//                                     - Fixed one or two points for better compatibility
//                                       with newer compilers (VC++ .NET 2003)
//          - 1.00 BETA 5 (10/12/2002) - Fixed a bug in Stripify() that could sometimes
//                                       cause it to go into an infinite loop.
//                                       (thanks to Remy for the bug report)
//          - 1.00 BETA 4 (18/11/2002) - Removed the dependency on OpenGL:
//                                       modified gl_primitives to primitives,
//                                       and gl_primitives_vector to primitives_vector;
//                                       and added primitive_type.
//                                       (thanks to Patrik for noticing this useless dependency)
//          - 1.00 BETA 3 (18/11/2002) - Fixed a bug in LinkNeightboursTri() that could cause a crash
//                                       (thanks to Nicolas for finding it)
//          - 1.00 BETA 2 (16/11/2002) - Improved portability
//          - 1.00 BETA 1 (27/10/2002) - First public release
//
//////////////////////////////////////////////////////////////////////

#pragma once




#include "cache_simulator.h"




// namespace triangle_stripper
namespace triangle_stripper {




#include "graph_array.h"
#include "heap_array.h"



class tri_stripper
{
public:

	// New Public types
	typedef unsigned int index;
	typedef std::vector<index> indices;

	enum primitive_type {
		PT_Triangles		= 0x0004,	// = GL_TRIANGLES
		PT_Triangle_Strip	= 0x0005	// = GL_TRIANGLE_STRIP
	};

	struct primitives
	{
		indices			m_Indices;
		primitive_type	m_Type;
	};

	typedef std::vector<primitives> primitives_vector;

	struct triangles_indices_error { };


	// constructor/initializer
	tri_stripper(const indices & TriIndices);
	
	// Settings functions
	void SetCacheSize(const size_t CacheSize = 16);			// = 0 will disable the cache optimizer
	void SetMinStripSize(const size_t MinStripSize = 2);

	// Stripper
	void Strip(primitives_vector * out_pPrimitivesVector);	// throw triangles_indices_error();

private:

	friend struct _cmp_tri_interface_lt;


	class triangle
	{
	public:
		triangle();
		triangle(const index A, const index B, const index C);

		void SetStripID(const size_t StripID);

		index A() const;
		index B() const;
		index C() const;
		size_t StripID() const;

	private:
		index m_A;
		index m_B;
		index m_C;
		size_t m_StripID;
	};


	class triangle_edge
	{
	public:
		triangle_edge(const index A, const index B, const size_t TriPos);

		index A() const;
		index B() const;
		size_t TriPos() const;

	private:
		index m_A;
		index m_B;
		size_t m_TriPos;
	};


	class triangle_degree
	{
	public:
		triangle_degree();
		triangle_degree(const size_t TriPos, const size_t Degree);

		size_t Degree() const;
		size_t TriPos() const;

		void SetDegree(const size_t Degree);

	private:
		size_t m_TriPos;
		size_t m_Degree;
	};


	class triangle_strip
	{
	public:
		enum start_order { ABC = 0, BCA = 1, CAB = 2 };

		triangle_strip();
		triangle_strip(size_t StartTriPos, start_order StartOrder, size_t Size);

		size_t StartTriPos() const;
		start_order StartOrder() const;
		size_t Size() const;

	private:
		size_t		m_StartTriPos;
		start_order	m_StartOrder;
		size_t		m_Size;
	};


	struct _cmp_tri_interface_lt
	{
		bool operator() (const triangle_edge & a, const triangle_edge & b) const;
	};


	struct _cmp_tri_degree_gt
	{
		bool operator () (const triangle_degree & a, const triangle_degree & b) const;
	};


	typedef common_structures::graph_array<triangle, char> triangles_graph;
	typedef common_structures::heap_array<triangle_degree, _cmp_tri_degree_gt> triangles_heap;
	typedef std::vector<triangle_edge> triangle_edges;
	typedef std::vector<size_t> triangle_indices;
	typedef std::deque<index> indices_cache; 


	void InitCache();
	void InitTriGraph();
	void InitTriHeap();
	void Stripify();
	void AddLeftTriangles();

	void LinkNeighboursTri(const triangle_edges & TriInterface, const triangle_edge Edge);
	void MarkTriAsTaken(const size_t i);

	triangle_edge GetLatestEdge(const triangle & Triangle, const triangle_strip::start_order Order) const;

	triangle_strip FindBestStrip();
	triangle_strip ExtendTriToStrip(const size_t StartTriPos, const triangle_strip::start_order StartOrder);
	void BuildStrip(const triangle_strip TriStrip);
	void AddIndex(const index i);
	void AddIndexToCache(const index i, bool CacheHitCount = false);
	void AddTriToCache(const triangle & Tri, const triangle_strip::start_order Order);
	void AddTriToIndices(const triangle & Tri, const triangle_strip::start_order Order);

	const indices &		m_TriIndices;

	size_t				m_MinStripSize;
//	size_t				m_CacheSize;

	primitives_vector	m_PrimitivesVector;
	triangles_graph		m_Triangles;
	triangles_heap		m_TriHeap;
	triangle_indices	m_NextCandidates;
	cache_simulator		m_Cache;
//	indices_cache		m_IndicesCache;
	size_t				m_StripID;
//	size_t				m_CacheHits;
};




//////////////////////////////////////////////////////////////////////////
// tri_stripper Inline functions
//////////////////////////////////////////////////////////////////////////

inline tri_stripper::tri_stripper(const indices & TriIndices) : m_TriIndices(TriIndices) {
	SetCacheSize();
	SetMinStripSize();
}


inline void tri_stripper::SetCacheSize(const size_t CacheSize) {
//	m_CacheSize = CacheSize;
	m_Cache.resize(CacheSize);
}


inline void tri_stripper::SetMinStripSize(const size_t MinStripSize) {
	m_MinStripSize = MinStripSize;
}


inline tri_stripper::triangle::triangle() { }


inline tri_stripper::triangle::triangle(const index A, const index B, const index C) : m_A(A), m_B(B), m_C(C), m_StripID(0) { }


inline void tri_stripper::triangle::SetStripID(const size_t StripID) {
	m_StripID = StripID;
}


inline tri_stripper::index tri_stripper::triangle::A() const {
	return m_A;
}


inline tri_stripper::index tri_stripper::triangle::B() const {
	return m_B;
}


inline tri_stripper::index tri_stripper::triangle::C() const {
	return m_C;
}


inline size_t tri_stripper::triangle::StripID() const {
	return m_StripID;
}


inline tri_stripper::triangle_edge::triangle_edge(const index A, const index B, const size_t TriPos) : m_A(A), m_B(B), m_TriPos(TriPos) { }


inline tri_stripper::index tri_stripper::triangle_edge::A() const {
	return m_A;
}


inline tri_stripper::index tri_stripper::triangle_edge::B() const {
	return m_B;
}


inline size_t tri_stripper::triangle_edge::TriPos() const {
	return m_TriPos;
}


inline tri_stripper::triangle_degree::triangle_degree() { }


inline tri_stripper::triangle_degree::triangle_degree(const size_t TriPos, const size_t Degree) : m_TriPos(TriPos), m_Degree(Degree) { }


inline size_t tri_stripper::triangle_degree::Degree() const {
	return m_Degree;
}


inline size_t tri_stripper::triangle_degree::TriPos() const {
	return m_TriPos;
}


inline void tri_stripper::triangle_degree::SetDegree(const size_t Degree) {
	m_Degree = Degree;
}


inline tri_stripper::triangle_strip::triangle_strip() : m_StartTriPos(0), m_StartOrder(ABC), m_Size(0) { }


inline tri_stripper::triangle_strip::triangle_strip(const size_t StartTriPos, const start_order StartOrder, const size_t Size)
	: m_StartTriPos(StartTriPos), m_StartOrder(StartOrder), m_Size(Size) { }


inline size_t tri_stripper::triangle_strip::StartTriPos() const {
	return m_StartTriPos;
}


inline tri_stripper::triangle_strip::start_order tri_stripper::triangle_strip::StartOrder() const {
	return m_StartOrder;
}


inline size_t tri_stripper::triangle_strip::Size() const {
	return m_Size;
}


inline bool tri_stripper::_cmp_tri_interface_lt::operator() (const triangle_edge & a, const triangle_edge & b) const {
	const tri_stripper::index A1 = a.A();
	const tri_stripper::index B1 = a.B();
	const tri_stripper::index A2 = b.A();
	const tri_stripper::index B2 = b.B();

	if ((A1 < A2) || ((A1 == A2) && (B1 < B2)))
		return true;
	else
		return false;
}


inline bool tri_stripper::_cmp_tri_degree_gt::operator () (const triangle_degree & a, const triangle_degree & b) const {
	// the triangle with a smaller degree has more priority 
	return a.Degree() > b.Degree();
}




} // namespace triangle_stripper


