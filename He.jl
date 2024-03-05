module He

using Graphs
using DataStructures
using Random

export adj, adjacency_set, descendants!, ancestors!, reachable, htail, sibanc, he, convert_admg_to_mag 

"""
   This module contains the implementation of the Hu-Evans Markov equivalence algorithm and the ADMG to MAG algorithm
   from the same authors.
   Authors: https://github.com/mwien/magequivalence
"""

"""
    Returns true if there is an edge between a and b in either graph D or B
"""
function adj(D, B, a, b)
    return has_edge(D, a, b) || has_edge(D, b, a) || has_edge(B, a, b)
end

"""
    Returns true if there is an edge between a and b in either graph D or B
"""
function adjacency_set(D)
    S = Set{Tuple{Int64, Int64}}()
    for v in vertices(D)
        for w in neighbors(D, v)
            if v < w
                push!(S, (v, w))
            end
        end
    end
    return S
end

"""
    Returns the set of descendants of v in D
"""
function descendants!(D, des, v)
    if !isempty(des[v])
        return des[v]
    end

    push!(des[v], v)
    
    for y in outneighbors(D, v)
        union!(des[v], descendants!(D, des, y))
    end

    return des[v]
end

"""
    Returns the set of ancestors of v in D
"""
function ancestors!(D, anc, v)
    if !isempty(anc[v])
        return anc[v]
    end

    push!(anc[v], v)
    
    for y in inneighbors(D, v)
        union!(anc[v], ancestors!(D, anc, y))
    end

    return anc[v]
end

"""
    Returns the set of vertices reachable from Z in B - A
"""
function reachable(B, Z, A)
    q = Queue{Int64}()
    for v in Z
        enqueue!(q, v)
    end

    R = Set{Integer}(Z)
    
    while !isempty(q)
        x = dequeue!(q)
        for y in neighbors(B, x)
            if !(y in R) && (y in A)
                push!(R, y)
                enqueue!(q, y)
            end
        end
    end

    return R
end

"""
    Returns the set of vertices in the head-to-tail path from Z in B - A using a breadth-first search
"""
function htail(D, B, anc, Z)
    A = Set{Int64}()
    for z in Z
        union!(A, anc[z])
    end
    R = reachable(B, Z, A)
    pa = Set{Int64}()
    for r in R
        for p in inneighbors(D, r)
            push!(pa, p)
        end
    end

    return setdiff(union(R, pa), Z)
end

"""
    Returns the set of vertices in the sibling-ancestor path from v to w in B - A using a breadth-first search
"""
function sibanc(D, B, anc, des, dis, C, v, w)
    A = union(anc[v], anc[w])
    DI = Set{Int64}(C[dis[v]])
    DE = union(des[v], des[w])
    SA = Set{Int64}()

    for a in A
        for b in neighbors(B, a)
            push!(SA, b)
        end
    end

    return setdiff(intersect(SA, DI), union(A, DE))
end

"""
    Hu-Evans Markov equivalence algorithm (Hu, Z., & Evans, R. (2020). Faster algorithms for Markov Equivalence. In Confer-
    ence on Uncertainty in Artificial Intelligence (pp. 739-748). PMLR).
    D: the directed graph representing the ADMG
    B: the bidirected graph representing the ADMG
"""
function he(D, B)
    S = Set{Set{Int64}}()
    anc = [Set{Int64}() for i = 1:nv(D)]
    des = [Set{Int64}() for i = 1:nv(D)]
    C = connected_components(B)
    dis = zeros(Int64, nv(D)) #districts of v

    for i = 1:length(C)
        for v in C[i]
            dis[v] = i
        end
    end
    
    for v in vertices(D)
        for w in inneighbors(D, v)
            push!(S, Set{Int64}([v,w]))
        end

        for w in inneighbors(D, v)
            for z in inneighbors(D, v)
                if z != w && !adj(D, B, z, w)
                    push!(S, Set{Int64}([v,w,z]))
                end
            end
        end

        ancestors!(D, anc, v)
        descendants!(D, des, v)
    end

    for v in vertices(B)
        for w in neighbors(B, v)
            if v > w
                continue
            end
            push!(S, Set{Int64}([v, w]))
            T = htail(D, B, anc, Set{Int64}([v, w]))
            for z in T
                if !(adj(D, B, v, z) && adj(D, B, w, z))
                    push!(S, Set{Int64}([v, w, z]))
                end
            end

            for z in sibanc(D, B, anc, des, dis, C, v, w)
                if !(adj(D, B, v, z) && adj(D, B, w, z))
                    if z in reachable(B, v, union(anc[v], union(anc[w], anc[z])))
                        push!(S, Set{Int64}([v, w, z]))
                    end
                end
            end
        end
    end
    return S
end

"""
    This function converts an ADMG to a MAG
    D: the directed graph representing the ADMG
    B: the bidirected graph representing the ADMG
"""
function convert_admg_to_mag(D, B)
    # Create new directed and undirected graphs to represent the MAG
    DM = SimpleDiGraph(nv(D))
    BM = SimpleGraph(nv(B))

    # Initialize a list of sets to store ancestors for each vertex in D
    anc = [Set{Int64}() for i = 1:nv(D)]

    # Compute ancestors for each vertex in D
    for y in vertices(D)
        ancestors!(D, anc, y)
    end
    
    # Add directed edges to DM based on the ancestral relations in D and B
    for y in vertices(D)
        for w in htail(D, B, anc, Set{Int64}(y))
            add_edge!(DM, w, y)
        end
    end
    
    # Add bidirected edges to BM based on connected components in B and ancestral relations
    for C in connected_components(B)
        for u in C
            for v in C
                # Skip self-loops and vertices with common ancestors
                if u == v || u in anc[v] || v in anc[u]
                    continue
                end
                # Check if there is a path from u to v through common ancestors
                if u in reachable(B, v, union(anc[u], anc[v]))
                    add_edge!(BM, u, v)
                end
            end
        end
    end

    # Return the resulting MAG
    return DM, BM
end


end
