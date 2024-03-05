module Graph_utils

using Graphs
using DataStructures
using Random
using Statistics

export readgraph

"""
    This function reads a graph from a file
    file: the file to read from
    Authors: https://github.com/mwien/magequivalence
"""
function readgraph(file = stdin)

    if file != stdin
        infile = open(file, "r")
    else
        infile = stdin
    end

    (n, d, b) = parse.(Int, split(readline(infile)))
    readline(infile)
    D = SimpleDiGraph(n)

    for i = 1:d
        (x, y) = parse.(Int, split(readline(infile)))
        add_edge!(D, x, y)
    end

    B = SimpleGraph(n)

    for i = 1:b
        (x, y) = parse.(Int, split(readline(infile)))
        add_edge!(B, x, y)
    end

    if file != stdin
        close(infile)
    end

    return (D, B)

end

end 