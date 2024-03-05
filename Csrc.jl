module Csrc

using Graphs
using DataStructures
using Random

export csrc

""" 
    Returns true if there is an edge (directed or bidirected) between a and b (either in graph D or B)
""" 
function adj(D, B, a, b)
  
    return has_edge(D, a, b) || has_edge(D, b, a) || has_edge(B, a, b)
end

"""
    The constructive SRC algorithm of Wienöbst, Bannach & Liśkiewicz (Wienöbst, M., Bannach, M., & Liśkiewicz, M. (2022). A new constructive criterion
for Markov equivalence of MAGs. In Uncertainty in Artificial Intelligence (pp. 2107-2116). PMLR.)
    D: The directed graph
    B: The bidirected graph
"""
function csrc(D, B)
    A = Set{Tuple{Int64, Int64}}()
    VS = Set{Tuple{Int64, Int64, Int64}}()
    K = Set{Tuple{Int64, Int64}}()
    N = Set{Tuple{Int64, Int64}}()

    for y in vertices(D)
        for x in vcat(inneighbors(D, y), outneighbors(D, y), neighbors(B, y))
            if x < y
                push!(A, (x,y))
            end
        end
    end

    for y in vertices(D)
        for x in vcat(neighbors(B, y), inneighbors(D, y))
            for z in vcat(neighbors(B, y), inneighbors(D, y))
                if x < z && !adj(D, B, x, z)
                    push!(VS, (x, y, z))
                end
            end
        end
    end
    
    for y in vertices(D)
        S, mp = induced_subgraph(B, inneighbors(D, y))
        for C in connected_components(S)
            pa = Set{Int64}()
            sib = Set{Int64}()
            neigh = Set{Int64}(vcat(inneighbors(D, y), outneighbors(D, y), neighbors(B, y)))
            
            for vv in C
                d = mp[vv]
                for e in inneighbors(D, d)
                    push!(pa, e)
                end
                for e in neighbors(B, d)
                    push!(sib, e)
                end
            end

            if !isempty(setdiff(union(pa, sib), neigh))
                for b in intersect(sib, Set{Int64}(neighbors(B,y)))
                    push!(K, (b, y))
                end
            end
        end
    end

    for y in vertices(D)
        for b in inneighbors(D, y)
            push!(N, (b, y))
        end
    end
        
    return (A, VS, K, N)
end


end