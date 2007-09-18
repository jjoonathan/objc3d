// tri_stripper.cpp: implementation of the Tri Stripper class.
//
// Copyright (C) 2002 Tanguy Fautr�.
// For conditions of distribution and use,
// see copyright notice in tri_stripper.h
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "tri_stripper.h"




// namespace triangle_stripper
namespace triangle_stripper {




//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////
// Members Functions
//////////////////////////////////////////////////////////////////////

void tri_stripper::Strip(primitives_vector * out_pPrimitivesVector)
{
	// verify that the number of indices is correct
	if (m_TriIndices.size() % 3 != 0)
		throw triangles_indices_error();

	// clear possible garbage
	m_PrimitivesVector.clear();
	out_pPrimitivesVector->clear();

	// Initialize the triangle graph
	InitTriGraph();

	// Initialize the triangle priority queue
	InitTriHeap();

	// Reset the cache simulator
	InitCache();

	// Launch the triangle strip generator
	Stripify();

	// Add the triangles that couldn't be stripped
	AddLeftTriangles();

	// Free ressources
	m_Triangles.clear();
	
	// Put the results into the user's vector
	std::swap(m_PrimitivesVector, (* out_pPrimitivesVector));
}



void tri_stripper::InitTriGraph()
{
	// Set up the graph size and complete the triangles data
	// note: setsize() completely resets the graph as well as the node markers
	m_Triangles.setsize(m_TriIndices.size() / 3);

	for (size_t i = 0; i < m_Triangles.size(); ++i)
		m_Triangles[i] = triangle(m_TriIndices[i * 3 + 0], m_TriIndices[i * 3 + 1], m_TriIndices[i * 3 + 2]);

	// Build the edges lookup table
	triangle_edges TriInterface;
	TriInterface.reserve(m_Triangles.size() * 3);

	for (size_t i = 0; i < m_Triangles.size(); ++i) {
		TriInterface.push_back(triangle_edge(m_Triangles[i]->A(), m_Triangles[i]->B(), i)); 
		TriInterface.push_back(triangle_edge(m_Triangles[i]->B(), m_Triangles[i]->C(), i)); 
		TriInterface.push_back(triangle_edge(m_Triangles[i]->C(), m_Triangles[i]->A(), i)); 
	}

	// Sort the lookup table for faster searches
	std::sort(TriInterface.begin(), TriInterface.end(), _cmp_tri_interface_lt());

	// Link neighbour triangles together using the edges lookup table
	for (size_t i = 0; i < m_Triangles.size(); ++i) {

		const triangle_edge EdgeBA(m_Triangles[i]->B(), m_Triangles[i]->A(), i);
		const triangle_edge EdgeCB(m_Triangles[i]->C(), m_Triangles[i]->B(), i);
		const triangle_edge EdgeAC(m_Triangles[i]->A(), m_Triangles[i]->C(), i);

		LinkNeighboursTri(TriInterface, EdgeBA);
		LinkNeighboursTri(TriInterface, EdgeCB);
		LinkNeighboursTri(TriInterface, EdgeAC);
	}
}



void tri_stripper::LinkNeighboursTri(const triangle_edges & TriInterface, const triangle_edge Edge)
{
	typedef triangle_edges::const_iterator edge_const_it;

	// Find the first edge equal to Edge
	edge_const_it It = std::lower_bound(TriInterface.begin(), TriInterface.end(), Edge, _cmp_tri_interface_lt());

	// See if there are any other edges that are equal
	// (if so, it means that more than 2 triangles are sharing the same edge,
	//  which is unlikely but not impossible)
	for (; (It != TriInterface.end()) && ((It->A() == Edge.A()) && (It->B() == Edge.B())); ++It)
		m_Triangles.insert(Edge.TriPos(), It->TriPos());

	// Note: degenerated triangles will also point themselves as neighbour triangles
}



void tri_stripper::InitTriHeap()
{
	m_TriHeap.clear();
	m_TriHeap.reserve(m_Triangles.size());

	// Set up the triangles priority queue
	// The lower the number of available neighbour triangles, the higher the priority.
	for (size_t i = 0; i < m_Triangles.size(); ++i)
		m_TriHeap.push(triangle_degree(i, m_Triangles[i].number_of_out_arcs()));

	// Remove useless triangles
	// (Note: we had to put all of them into the heap before to ensure coherency of the heap_array object)
	while ((! m_TriHeap.empty()) && (m_TriHeap.top().Degree() == 0))
		m_TriHeap.pop();
}



void tri_stripper::InitCache()
{
	m_Cache.reset();
}



void tri_stripper::Stripify()
{
	// Reset the triangle strip id selector
	m_StripID = 0;

	// Reset the candidate list
	m_NextCandidates.clear();

	// Loop untill there is no available candidate triangle left
	while (! m_TriHeap.empty()) {

		// There is no triangle in the candidates list, refill it with the loneliest triangle
		const size_t HeapTop = m_TriHeap.top().TriPos();
		m_NextCandidates.push_back(HeapTop);

		// Loop while BuildStrip can find good candidates for us
		while (! m_NextCandidates.empty()) {

			// Choose the best strip containing that triangle
			// Note: FindBestStrip empties m_NextCandidates
			const triangle_strip TriStrip = FindBestStrip();

			// Build it if it's long enough, otherwise discard it
			// Note: BuildStrip refills m_NextCandidates
			if (TriStrip.Size() >= m_MinStripSize)
				BuildStrip(TriStrip);
		}

		// We must discard the triangle we inserted in the candidate list from the heap
		// if it led to nothing. (We simply removed it if it hasn't been removed by BuildStrip() yet)
		if (! m_TriHeap.removed(HeapTop))
			m_TriHeap.erase(HeapTop);

		// Eliminate all the triangles that have now become useless
		while ((! m_TriHeap.empty()) && (m_TriHeap.top().Degree() == 0))
			m_TriHeap.pop();
	}
}



inline tri_stripper::triangle_strip tri_stripper::FindBestStrip()
{
	triangle_strip BestStrip;
	size_t BestStripDegree = 0;
	size_t BestStripCacheHits = 0;

	// Backup the cache, because it'll be erased during the simulations
	const cache_simulator CacheBackup = m_Cache;

	while (! m_NextCandidates.empty()) {

		// Discard useless triangles from the candidates list
		if ((m_Triangles[m_NextCandidates.back()].marked()) || (m_TriHeap[m_NextCandidates.back()].Degree() == 0)) {
			m_NextCandidates.pop_back();

			// "continue" is evil! But it really makes things easier here.
			// The useless triangle is discarded, and the "while" just rebegins again
			continue;
		}

		// Invariant: (CandidateTri's Degree() >= 1) && (CandidateTri is not marked).
		// So it can directly be used.
		const size_t CandidateTri = m_NextCandidates.back();
		m_NextCandidates.pop_back();

		// Try to extend the triangle in the 3 possible directions
		for (size_t i = 0; i < 3; ++i) {

			// Try a new strip with that triangle in a particular direction
			const triangle_strip TempStrip = ExtendTriToStrip(CandidateTri, triangle_strip::start_order(i));

			// We want to keep the best strip
			// Discard strips that don't match the minimum required size
			if (TempStrip.Size() >= m_MinStripSize) {

				// Cache simulator disabled?
				if (m_Cache.size() == 0) {

					// Cache is disabled, take the longest strip
					if (TempStrip.Size() > BestStrip.Size())
						BestStrip = TempStrip;

				// Cache simulator enabled
				// Use other criteria to find the "best" strip
				} else {

					// Priority 1: Keep the strip with the best cache hit count
					if (m_Cache.HitCount() > BestStripCacheHits) {
						BestStrip = TempStrip;
						BestStripDegree = m_TriHeap[TempStrip.StartTriPos()].Degree();
						BestStripCacheHits = m_Cache.HitCount();

					} else if (m_Cache.HitCount() == BestStripCacheHits) {

						// Priority 2: Keep the strip with the loneliest start triangle
						if ((BestStrip.Size() != 0) && (m_TriHeap[TempStrip.StartTriPos()].Degree() < BestStripDegree)) {
							BestStrip = TempStrip;
							BestStripDegree = m_TriHeap[TempStrip.StartTriPos()].Degree();

						// Priority 3: Keep the longest strip 
						} else if (TempStrip.Size() > BestStrip.Size()) {
							BestStrip = TempStrip;
							BestStripDegree = m_TriHeap[TempStrip.StartTriPos()].Degree();
						}
					}
				}
			}

			// Restore the cache (modified by ExtendTriToStrip) and implicitly reset the cache hit count
			m_Cache = CacheBackup;
		}

	}

	return BestStrip;
}



tri_stripper::triangle_strip tri_stripper::ExtendTriToStrip(const size_t StartTriPos, const triangle_strip::start_order StartOrder)
{
	typedef triangles_graph::const_out_arc_iterator const_tri_link_iter;
	typedef triangles_graph::node_iterator tri_node_iter;

	size_t Size = 1;
	bool ClockWise = false;
	triangle_strip::start_order Order = StartOrder;

	// Begin a new strip
	++m_StripID;

	// Mark the first triangle as used for this strip
	m_Triangles[StartTriPos]->SetStripID(m_StripID);

	// Update the cache
	AddTriToCache((* m_Triangles[StartTriPos]), Order);


	// Loop while we can further extend the strip
	for (tri_node_iter TriNodeIt = (m_Triangles.begin() + StartTriPos); 
		(TriNodeIt != m_Triangles.end()) && ((m_Cache.size() == 0) || ((Size + 2) < m_Cache.size()));
		++Size) {

		// Get the triangle edge that would lead to the next triangle
		const triangle_edge Edge = GetLatestEdge(** TriNodeIt, Order);

		// Link to a neighbour triangle
		const_tri_link_iter LinkIt;
		for (LinkIt = TriNodeIt->out_begin(); LinkIt != TriNodeIt->out_end(); ++LinkIt) {

			// Get the reference to the possible next triangle
			const triangle & Tri = (** (LinkIt->terminal()));

			// Check whether it's already been used
			if ((Tri.StripID() != m_StripID) && (! (LinkIt->terminal()->marked()))) {

				// Does the current candidate triangle match the required for the strip?

				if ((Edge.B() == Tri.A()) && (Edge.A() == Tri.B())) {
					Order = (ClockWise) ? triangle_strip::ABC : triangle_strip::BCA;
					AddIndexToCache(Tri.C(), true);
					break;
				}

				else if ((Edge.B() == Tri.B()) && (Edge.A() == Tri.C())) {
					Order = (ClockWise) ? triangle_strip::BCA : triangle_strip::CAB;
					AddIndexToCache(Tri.A(), true);
					break;
				}

				else if ((Edge.B() == Tri.C()) && (Edge.A() == Tri.A())) {
					Order = (ClockWise) ? triangle_strip::CAB : triangle_strip::ABC;
					AddIndexToCache(Tri.B(), true);
					break;
				}
			}
		}

		// Is it the end of the strip?
		if (LinkIt == TriNodeIt->out_end()) {
			TriNodeIt = m_Triangles.end();
			--Size;
		} else {
			TriNodeIt = LinkIt->terminal();
    
			// Setup for the next triangle
			(* TriNodeIt)->SetStripID(m_StripID);
			ClockWise = ! ClockWise;
		}
	}


	return triangle_strip(StartTriPos, StartOrder, Size);
}



inline tri_stripper::triangle_edge tri_stripper::GetLatestEdge(const triangle & Triangle, const triangle_strip::start_order Order) const
{
	switch (Order) {
	case triangle_strip::ABC:
		return triangle_edge(Triangle.B(), Triangle.C(), 0);
	case triangle_strip::BCA:
		return triangle_edge(Triangle.C(), Triangle.A(), 0);
	case triangle_strip::CAB:
		return triangle_edge(Triangle.A(), Triangle.B(), 0);
	default:
		return triangle_edge(0, 0, 0);
	}
}



void tri_stripper::BuildStrip(const triangle_strip TriStrip)
{
	typedef triangles_graph::const_out_arc_iterator const_tri_link_iter;
	typedef triangles_graph::node_iterator tri_node_iter;

	const size_t StartTriPos = TriStrip.StartTriPos();

	bool ClockWise = false;
	triangle_strip::start_order Order = TriStrip.StartOrder();

	// Create a new strip
	m_PrimitivesVector.push_back(primitives());
	m_PrimitivesVector.back().m_Type = PT_Triangle_Strip;

	// Put the first triangle into the strip
	AddTriToIndices((* m_Triangles[StartTriPos]), Order);

	// Mark the first triangle as used
	MarkTriAsTaken(StartTriPos);


	// Loop while we can further extend the strip
	tri_node_iter TriNodeIt = (m_Triangles.begin() + StartTriPos);

	for (size_t Size = 1; Size < TriStrip.Size(); ++Size) {

		// Get the triangle edge that would lead to the next triangle
		const triangle_edge Edge = GetLatestEdge(** TriNodeIt, Order);

		// Link to a neighbour triangle
		const_tri_link_iter LinkIt;
		for (LinkIt = TriNodeIt->out_begin(); LinkIt != TriNodeIt->out_end(); ++LinkIt) {

			// Get the reference to the possible next triangle
			const triangle & Tri = (** (LinkIt->terminal()));

			// Check whether it's already been used
			if (! (LinkIt->terminal()->marked())) {

				// Does the current candidate triangle match the required for the strip?
				// If it does, then add it to the Indices
				if ((Edge.B() == Tri.A()) && (Edge.A() == Tri.B())) {
					Order = (ClockWise) ? triangle_strip::ABC : triangle_strip::BCA;
					AddIndex(Tri.C());
					break;
				}

				else if ((Edge.B() == Tri.B()) && (Edge.A() == Tri.C())) {
					Order = (ClockWise) ? triangle_strip::BCA : triangle_strip::CAB;
					AddIndex(Tri.A());
					break;
				}

				else if ((Edge.B() == Tri.C()) && (Edge.A() == Tri.A())) {
					Order = (ClockWise) ? triangle_strip::CAB : triangle_strip::ABC;
					AddIndex(Tri.B());
					break;
				}
			}
		}

		// Debug check: we must have found the next triangle
		assert(LinkIt != TriNodeIt->out_end());

		// Go to the next triangle
		TriNodeIt = LinkIt->terminal();
		MarkTriAsTaken(TriNodeIt - m_Triangles.begin());
        
		// Setup for the next triangle
		ClockWise = ! ClockWise;
	}
}



void tri_stripper::MarkTriAsTaken(const size_t i)
{
	typedef triangles_graph::node_iterator tri_node_iter;
	typedef triangles_graph::out_arc_iterator tri_link_iter;

	// Mark the triangle node
	m_Triangles[i].mark();

	// Remove triangle from priority queue if it isn't yet
	if (! m_TriHeap.removed(i))
		m_TriHeap.erase(i);

	// Adjust the degree of available neighbour triangles
	for (tri_link_iter LinkIt = m_Triangles[i].out_begin(); LinkIt != m_Triangles[i].out_end(); ++LinkIt) {

		const size_t j = LinkIt->terminal() - m_Triangles.begin();

		if ((! m_Triangles[j].marked()) && (! m_TriHeap.removed(j))) {
			triangle_degree NewDegree = m_TriHeap.peek(j);
			NewDegree.SetDegree(NewDegree.Degree() - 1);
			m_TriHeap.update(j, NewDegree);

			// Update the candidate list if cache is enabled
			if ((m_Cache.size() > 0) && (NewDegree.Degree() > 0))
				m_NextCandidates.push_back(j);
		}
	}
}



inline void tri_stripper::AddIndexToCache(const index i, bool CacheHitCount)
{
	// Cache simulator enabled?
	if (m_Cache.size() > 0)
		m_Cache.push(i, CacheHitCount);
}



inline void tri_stripper::AddIndex(const index i)
{
	// Add the index to the current indices array
	m_PrimitivesVector.back().m_Indices.push_back(i);

	// Run cache simulator
	AddIndexToCache(i);
}



inline void tri_stripper::AddTriToCache(const triangle & Tri, const triangle_strip::start_order Order)
{
	// Add Tri indices in the right order into the indices cache simulator.
	// And enable the cache hit count
	switch (Order) {
	case triangle_strip::ABC:
		AddIndexToCache(Tri.A(), true);
		AddIndexToCache(Tri.B(), true);
		AddIndexToCache(Tri.C(), true);
		return;
	case triangle_strip::BCA:
		AddIndexToCache(Tri.B(), true);
		AddIndexToCache(Tri.C(), true);
		AddIndexToCache(Tri.A(), true);
		return;
	case triangle_strip::CAB:
		AddIndexToCache(Tri.C(), true);
		AddIndexToCache(Tri.A(), true);
		AddIndexToCache(Tri.B(), true);
		return;
	}
}



inline void tri_stripper::AddTriToIndices(const triangle & Tri, const triangle_strip::start_order Order)
{
	// Add Tri indices in the right order into the latest Indices vector.
	switch (Order) {
	case triangle_strip::ABC:
		AddIndex(Tri.A());
		AddIndex(Tri.B());
		AddIndex(Tri.C());
		return;
	case triangle_strip::BCA:
		AddIndex(Tri.B());
		AddIndex(Tri.C());
		AddIndex(Tri.A());
		return;
	case triangle_strip::CAB:
		AddIndex(Tri.C());
		AddIndex(Tri.A());
		AddIndex(Tri.B());
		return;
	}
}



void tri_stripper::AddLeftTriangles()
{
	// Create the latest indices array
	// and fill it with all the triangles that couldn't be stripped
	primitives Primitives;
	Primitives.m_Type = PT_Triangles;
	m_PrimitivesVector.push_back(Primitives);
	indices & Indices = m_PrimitivesVector.back().m_Indices;

	for (size_t i = 0; i < m_Triangles.size(); ++i)
		if (! m_Triangles[i].marked()) {
			Indices.push_back(m_Triangles[i]->A());
			Indices.push_back(m_Triangles[i]->B());
			Indices.push_back(m_Triangles[i]->C());
		}

	// Undo if useless
	if (Indices.size() == 0)
		m_PrimitivesVector.pop_back();
}




} // namespace triangle_stripper
