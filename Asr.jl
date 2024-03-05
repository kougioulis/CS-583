module Asr

using Graphs
using DataStructures
using Random
using Statistics

export equivalent, dag_reachable, Col, sp, pa, Triples

"""
    Returns the adjacency set of a directed graph D.
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
    Returns the set of vertices reachable from w in the directed graph D.

"""
function dag_reachable(D, w)
    q = Queue{Int64}()
    S = Set{Int64}()

    enqueue!(q, w)
    push!(S, w)
    
    while !isempty(q)
        x = dequeue!(q)
        for y in neighbors(D, x)
            if !(y in S)
                push!(S, y)
                enqueue!(q, y)
            end
        end
    end

    return S
end


"""
    Returns the set of colliders in G
"""
function Col(G)
    colliders = Set{Tuple{Int, Int, Int}}()

    for v in vertices(G)
        #obtain the parents of v
        parents = Set{Int}([u for u in inneighbors(G, v)])
        for u in parents
            for w in parents
                if !has_edge(G, u, w) && u < w
                    push!(colliders, (u, v, w))
                end
            end
        end
    end
    return colliders
end

"""
    Returns the set of spouses of b in G
"""
function sp(G, b)
    return Set{Int}([v for (v, c) in edges(adjacency_set(G)) if b == c])
end

"""
    Returns the set of parents of c in G
"""
function pa(G, c)
    return Set{Int}([v for (v, d) in edges(adjacency_set(G)) if d == c])
end

"""
    Returns the set of triples in G (Algorithm A.2 in Ali-Spirtes-Richardson paper)
    R Ayesha Ali, Richardson T., & Spirtes, P. (2009). Markov equivalence for Ancestral Graphs. The Annals of Statistics, 37(5B):2808–2837.
"""
function Triples(G)
    T0 = Set{Tuple{Int, Int, Int}}((a, b, c) for (a, b, c) in Col(G) if (a, c) ∉ adjacency_set(G))
    Tk = Set(T0)
    k = 0

    while true
        k += 1
        Tk_prev = Set(Tk)

        for (a, b, c) in setdiff(Col(G), Tk_prev)
            if a in intersect(sp(G, b), pa(G, c))
                V = Set{Tuple{Int, Int}}(union([(t, u) for t in pa(G, c) for u in pa(G, c) if t != u in G], [(b, a)]))
                E = Set{Tuple{Int, Int}}(union([(t, u) for (t, u, v) in Tk_prev], [(u, v) for (t, u, v) in V]))

                S = dag_reachable((V, E), b, a)
                X = Set{Int}([x for (y, z, x) in Tk_prev if (z, y) in S])

                if isempty(setdiff(X, [v for (v, c) in Adj(G)]))
                    Tk = union(Tk, Set{Tuple{Int, Int, Int}}([(a, b, c), (c, b, a)]))
                end
            end
        end
        if issetequal(Tk, Tk_prev)
            break
        end
    end
    return Tk
end

"""
    Returns true if the MAGs G1 and G2 are Markov equivalent, false otherwise.
    (Algorithm A.3 in Ali-Spirtes-Richardson paper)
"""
function equivalent(G1, G2)
    # Check if the adjacency sets are not equal
    if !issetequal(adjacency_set(G1), adjacency_set(G2))
        return false
    end

    # Compute the triples and colliders for G1 and G2
    T1 = Triples(G1)
    C2 = Col(G2)
    T2 = Triples(G2)
    C1 = Col(G1)

    # Check if Triples(G1) \ Col(G2) is not empty
    if !isempty(setdiff(T1, C2))
        return false
    end

    # Check if Triples(G2) \ Col(G1) is empty
    if !isempty(setdiff(T2, C1))
        return false
    end

    return true
end


end