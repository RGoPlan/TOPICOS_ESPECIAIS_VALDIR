push!(LOAD_PATH, "src/modules/")

using Pkg
Pkg.activate(".")

using JuMP
using Gurobi
using DelimitedFiles
using CPUTime

using Data
#using OutputStatistics
#using Parameters
#using Formulation

# To run the code: julia TSP.jl <inputListFile> 
#                                         [1]             
#inputListFile:   inputFiles/<ALL.txt> or <ATT.txt> or <CEIL_2D.txt> or <EUC_2D.txt> or <EXPLICIT.txt> or <GEO.txt>
# Read input list file
input = readdlm(String(ARGS[1]))

# Get number of instances to run
numInst = input[1]

timeInit = time_ns()


# Run all numInst instances in the input list file
for inst = 1:numInst

    # Get Time
 
    timeStart = time_ns()
    
    # Initialize statistics data structure
    #stats = OutputStatistics.initStatsData!()

    # Get the name of the file containing the instance data
    instanceFile = String(input[inst + 1])

    # Read instance data
    datatype = Data.readTypeData(instanceFile)
    

    
    if datatype.COORD_Type == "EXPLICIT"
        #println("Weights are listed explicitly in the corresponding section")
        data = Data.readDataEXPLICIT(instanceFile, datatype)
    else 
       # println("Geographical distance")  
        #data = Data.readDataGEO(instanceFile, datatype) 
        data = Data.readDataXY(instanceFile, datatype)
    end

    timeEndRF = time_ns()


    readTime = (timeEndRF - timeStart) * 1e-9
    println("readTimeeeee = ", readTime,"\n" )
end
timeEndRF = time_ns()
totaltime = (timeEndRF - timeInit) * 1e-9
println("readTimeeeee = ", totaltime ,"\n" )
