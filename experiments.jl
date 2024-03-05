#==========================
######CS-583 Project########
######Graph Algorithms######
==========================#
 
using Graphs
using DataStructures
using Random
using Statistics

using ProgressBars
using Dates

#import project modules 
include("He.jl")
include("Csrc.jl")
include("Asr.jl")
include("Graph_utils.jl")
include("Graph_generators.jl")

#main simulation function
function simulate_experiments()
    Random.seed!(1)

    log_folder = "log"
    if !isdir(log_folder)
        mkpath(log_folder)
    end

    log_file = joinpath(log_folder, Dates.format(now(), "yyyy-mm-dd HH:MM:SS") * ".log")

    outfile = open(log_file, "a")

    # print current date
    println(outfile, Dates.format(now(), "yyyy-mm-dd HH:MM:SS"))

    for d in ["1","3","5", "10", "15", "30"]
        n_values = get_n_values(d)

        for n in n_values
            hetime = []
            csrctime = []
            dirprev = []
            bidirprev = []
            ratprev = []
            dir = []
            bidir = []
            rat = []
            asrtime = []
            
            p_values = [0.2, 0.5, 0.8]

            println("n = $n, d = $d")

            for p in p_values
                D, B = Graph_generators.generate_erdos_renyi_mag(n, parse(Int, d), p)
                method = "Erdos-Renyi"
                #D, B = Graph_generators.generate_barabasi_albert_graph(n, parse(Int, d), p)
                #method = "Barabasi-Albert"
                for rep in tqdm(1:100)
                    push!(dirprev, ne(D))
                    push!(bidirprev, ne(B))
                    push!(ratprev, ne(D) / ne(B))
   
                    D, B = He.convert_admg_to_mag(D, B) 
   
                    push!(dir, ne(D))
                    push!(bidir, ne(B))
                    push!(rat, ne(D) / ne(B))
                    push!(hetime, @elapsed(He.he(D, B)))
                    push!(csrctime, @elapsed(Csrc.csrc(D, B)))
                    push!(asrtime, @elapsed(Asr.equivalent(D, B)))
                end
                println(outfile, "Number of vertices: $n, d: $d")
                println(outfile, "p: ", p)
                println(outfile, "Graph Generation Method: $method")
                println(outfile, "Average number of directed edges in ADMG: $(mean(dirprev)), Average number of bidirected edges in ADMG: $(mean(bidirprev)), ADMG #RATIO: $(mean(ratprev))")
                println(outfile, "Average number of directed edges in MAG: $(mean(dir)), Average number of bidirected edges in MAG: $(mean(bidir)), MAG #RATIO: $(mean(rat))")
                println(outfile, "HE avg time (sec): $(mean(hetime)), HE std dev: $(std(hetime))")
                println(outfile, "C-SRC avg time (sec): $(mean(csrctime)), C-SRC std (sec): $(std(csrctime))")
                println(outfile, "ASR avg time (sec): $(mean(asrtime)), ASR std (sec): $(std(asrtime))")
                flush(outfile)

            end
        end
    end

    println(outfile, Dates.format(now(), "yyyy-mm-dd HH:MM:SS"))
    close(outfile)
    println("Experiments completed successfully. See results in $log_file.")
end

function get_n_values(d)
    if d == "1"
        return [5, 10, 15, 25, 50, 75, 100, 125, 150, 175, 200, 250, 300, 350, 400, 500, 1000]
    elseif d == "3"
        return [10, 15, 25, 50, 75, 100, 125, 150, 175, 200, 250, 300, 350, 400, 450, 500, 1000]
    elseif d == "5"
        return [25, 50, 75,500, 100, 125, 150, 175, 200, 250, 300, 350, 400, 450, 500]
    elseif d == "10"
        return [30, 50,500, 50, 100, 125, 150, 175, 200, 250, 300, 350, 400, 450, 500]
    elseif d == "15"
        return [100,500, 150, 175, 200, 250, 300, 350, 400, 450, 500]
    else
        return [100,500, 150, 175, 200, 250, 300, 350, 400, 450, 500]
    end
end

simulate_experiments()