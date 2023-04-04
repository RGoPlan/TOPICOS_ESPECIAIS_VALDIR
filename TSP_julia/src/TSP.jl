push!(LOAD_PATH, "src/modules/")

using Pkg
Pkg.activate(".")

using JuMP
using Gurobi
using DelimitedFiles

using Data
#using OutputStatistics
#using Parameters
#using Formulation

# To run the code: julia TSP.jl <inputListFile> 
#                                         [1]             
#inputListFile:   inputFiles/<all.txt> or <> or <>

# Read input list file
input = readdlm(String(ARGS[1]))

# Get number of instances to run
numInst = input[1]

# Run all numInst instances in the input list file
for inst = 1:numInst

    # Get the name of the file containing the instance data
    instanceFile = String(input[inst + 1])

    println(instanceFile)
    # Read instance data
    #data = Data.readData(instanceFile)


end