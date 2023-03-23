
using Pkg
Pkg.activate(".")

using JuMP
using  Gurobi

# criação do modelo vazio

model = Model(optimizer_with_attributes(Gurobi.Optimizer))
#= model = Model(optimizer_with_attributes(Gurobi.Optimizer,
                                                "TimeLimit" => 600,
                                                "MIPGap" => 1e-8,
                                                "IntFeasTol" => 1e-6,
                                                "Threads" => 1,
                                                "LogToConsole" => 1))
 =#

#leitura de dados
n = 8   #numero de itens
m = 3   #numero de mochilas
C = [15 61 3 94 86 68 69 51;
     21 28 76 48 54 85 39 72;
     21 21 46 43 21 3 84 44 ]

A = [31 69 14 84 51 65 35 54;
     23 20 71 86 91 57 30 74;
     20 55 39 60 83 67 35 32]
b = [100 100 100]  # capacidades disponivel  


   





# formulação


NI = 1:m
NJ = 1:n


@variable(model, x[i in NI, j in NJ], Bin )


@objective(model, Min, sum(C[i,j] * x[i,j] for i in NI, j in NJ))


@constraint(model,rest_escolha[j in NJ], sum(x[i,j] for i in NI) == 1)

@constraint(model,rest_capital[i in NI], sum(A[i,j] * x[i,j] for j in NJ) <= b[i] )



# Solve

optimize!(model)

println("valor de x = ", value.(x))
