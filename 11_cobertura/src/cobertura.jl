
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
n = 6   #numero de pontos
m = 5 #numero de bairros
c = [20 76 16 23 23 18]
A = [1 1 0 0 1 0;
     1 0 1 0 0 0;
     0 1 0 1 0 0;
     0 0 1 0 0 1;
     0 1 1 0 0 1]  # capacidades disponivel  

   





# formulação

NI = 1:n
NJ = 1:m
@variable(model, x[i in NI ], Bin)


@objective(model, Min, sum(c[i] * x[i]   for i in NI))


@constraint(model,rest_escolha[j in NJ], sum( A[j,i] * x[i] for i in NI) >= 1 )





# Solve

optimize!(model)

println("valor de x = ", value.(x))
