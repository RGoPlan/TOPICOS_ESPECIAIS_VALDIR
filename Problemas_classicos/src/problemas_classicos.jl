push!(LOAD_PATH, "src/modules/")


using Pkg
Pkg.activate(".")

using JuMP
using  Gurobi

using Parameters
using Data



using Problem

#using OutputStatistics




#problemas 

#mochila_0_1,mochila_0_1,  

# run =  julia src/problemas_classicos.jl mochila_0_1 



# ler os parametros

params = Parameters.readStdFormParameters("src/paramFiles/stdFormParams")

# ler arquivos de dados do problema

problem = (String(ARGS[1]))
#caminho = "src/Instancias/"

if problem == "mochila_0_1"
    dataFile = "src/Instancias/mochila"
elseif problem == "mochila"
    dataFile = "src/Instancias/mochila"
end


#dataFile = caminho*problem

    #definir a estrutura de leitura do arquivo baseado no problema

if problem == "mochila_0_1"
    data = Data.readData_Mochila(dataFile)
elseif problem == "mochila"
    data = Data.readData_Mochila(dataFile)
end




# criação do modelo vazio

model = Model(optimizer_with_attributes(Gurobi.Optimizer,
                                                "TimeLimit" => params.timeLimit,
                                                "MIPGap" => params.MIPgapTolerance,
                                                "IntFeasTol" => params.integerFeasibilityTolerance,
                                                "Threads" => params.numberOfThreads,
                                                "LogToConsole" => params.screenOutput))

#leitura de dados



    # Build formulation
    if problem == "mochila_0_1"
        solution = Problem.createModel_Mochila_0_1!(data, model)
    elseif problem == "mochila"
        solution = Problem.createModel_Mochila!(data, model)
    end   




# Solve

    
optimize!(model)

println("valor de otimo = ",objective_value(model))

