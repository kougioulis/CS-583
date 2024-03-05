module Graph_generators

using Graphs
using DataStructures
using Random
using Statistics

export generate_graph, generate_erdos_renyi_mag, generate_barabasi_albert_graph

"""
    This function generates a random MAG according to Wienöbst et al.
    n: number of vertices
    d: average degree
    p: probability of a bidirected edge
    Authors: https://github.com/mwien/magequivalence
"""

function generate_graph(n, d, p)
    # Create a directed graph to represent the directed edges
    D = SimpleDiGraph(n)
    # Create an undirected graph to represent the bidirected edges
    B = SimpleGraph(n)

    # Counter for the total number of edges to add
    ecount = 0

    # Continue adding edges until the total number of edges reaches d*n
    while ecount < d*n
        # Randomly choose two vertices
        a = rand(1:n)
        b = rand(1:n)

        # Ensure a <= b by swapping if necessary
        if b < a
            tmp = a
            a = b
            b = tmp
        end

        # Check if the edge does not already exist in either graph
        if a != b && !has_edge(D, a, b) && !has_edge(B, a, b)
            # Randomly decide whether to add a directed or bidirected edge
            #if rand(1:2) == 1
            #randomly decide according to a probability value p 
            if rand() < p #rand(1:2) == 1 or p = 0.5
                add_edge!(D, a, b)  # add a directed edge
            else
                add_edge!(B, a, b)  # add a bidirected edge
            end
            ecount += 1
        end
    end

    # Randomly permute the vertices
    perm = randperm(n)

    # Return the permuted directed and bidirected graphs
    return D[perm], B[perm]
end

"""
    This function generates a random Erdos-Renyi MAG
    n: number of vertices
    d: average degree
    p: probability of a bidirected edge
"""
function generate_erdos_renyi_mag(n, d, p)
    # create a directed graph to represent the directed edges
    D = SimpleDiGraph(n)
    # create an undirected graph to represent the bidirected edges
    B = SimpleGraph(n)

    ecount = 0

    # Continue adding edges until the total number of edges reaches d
    while ecount < d*n
        # Randomly choose two vertices
        a = rand(1:n)
        b = rand(1:n)

        # Ensure a <= b by swapping if necessary
        if b < a
            tmp = a
            a = b
            b = tmp
        end

        # Check if the edge does not already exist in either graph
        if a != b && !has_edge(D, a, b) && !has_edge(B, a, b)
            # Randomly decide whether to add a directed or bidirected edge
            if rand() < p
                add_edge!(D, a, b)  # add a directed edge
            else
                add_edge!(B, a, b)  # add a bidirected edge
            end
            ecount += 1
        end
    end

    # randomly permute the vertices
    perm = randperm(n)

    # return the permuted directed and bidirected graphs
    return D[perm], B[perm]
end

"""
    This function generates a random Barabasi-Albert MAG
    n: number of vertices
    d: average degree
    p: probability of a bidirected edge

"""
function generate_barabasi_albert_graph(n, d, p)
    # start with a complete graph on m vertices (initial cluster)
    m = 3

    # generate the directed Barabasi-Albert graph
    D = barabasi_albert(n, m, is_directed=true)

    # create an undirected graph to represent the bidirected edges of the PDMG
    B = SimpleGraph(n)

    ecount = 0

    # Continue adding bidirected edges until the total number of edges reaches d * n
    while ecount < d * n
        # Randomly choose two vertices
        a = rand(1:n)
        b = rand(1:n)

        # Ensure a <= b by swapping if necessary
        if b < a
            a, b = b, a
        end
        # Check if the edge does not already exist in either graph
        if a != b && !has_edge(D, a, b) && !has_edge(B, a, b)
            # Randomly decide whether to add a directed or bidirected edge
            if rand() < p
                add_edge!(D, a, b)  # add a directed edge
            else
                add_edge!(B, a, b)  # add a bidirected edge
            end
            ecount += 1
        end
        ##############
        # Check if the edge doesn't already exist in the undirected graph
        #if a != b && !has_edge(B, a, b)
        #    # If the random number is less than or equal to p, add a bidirectional edge
        #    if rand() <= p
        #        add_edge!(B, a, b)
        #        ecount += 1
        #    end
        #end
    end

    return D, B
end

end 
