push!(LOAD_PATH, "src/modules/")


using Pkg
Pkg.activate(".")

using JuMP
using  Gurobi

using Parameters
using Data



#using Problem

#using OutputStatistics




#problemas 

#mochila_0_1,  

# run =  julia src/problemas_classicos.jl mochila_0_1 paramFiles/<stdFormParams>  outputFiles/<file name>



# ler os parametros

params = Parameters.readStdFormParameters("src/paramFiles/stdFormParams")

# ler arquivos de dados do problema

Problem = (String(ARGS[1]))
caminho = "src/Instancias/"

dataFile = caminho*Problem

    #definir a estrutura de leitura do arquivo baseado no problema

if Problem == "mochila_0_1"
    data = Data.readData_Mochila(dataFile)

    
end
#=
# Initialize statistics data structure
stats = OutputStatistics.initStatsData!()

stats.formulation = String(ARGS[1])




# Get the name of the file containing the instance data
#instance = String(ARGS[1])

# Read instance data
data = Data.eadData_M01


# criar aquivo de saida




# criação do modelo vazio

model = Model(optimizer_with_attributes(Gurobi.Optimizer,
                                                "TimeLimit" => params.restrictedModelMaxTime,
                                                "MIPGap" => params.MIPgapTolerance,
                                                "IntFeasTol" => params.integerFeasibilityTolerance,
                                                "Threads" => params.numberOfThreads,
                                                "LogToConsole" => params.screenOutput))

#leitura de dados



    # Build formulation
    if stats.formulation == "mochila_0_1"
        solution = Formulation.createModel_Mochila_0_1!(data, model)
    elseif stats.formulation == "arenales"
        solution = Formulation.createModelArenales!(data, model)
    elseif stats.formulation == "briskorn" 
        solution = Formulation.createModelBriskorn!(data, model)
    elseif stats.formulation == "gopalakrishnan"
        solution = Formulation.createModelGopalakrishnan!(data, model)
    elseif stats.formulation == "haase"
        solution = Formulation.createModelHaase!(data, model)
    end   




# Solve


    # Solve
    Formulation.solveModel!(model, solution, stats)

println("valor de otimo = ",objective_value(model))
println("valor de x = ", value.(x)) =#