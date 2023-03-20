
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
m = 2   #numero de mochilas
k = 1   #numero de tipos de capacidade 
b = [100 100] # capacidades disponivel  
p = [41 33 14 25 32 32 9 19] #lucratividade
w = [47 40 17 27 34 23 5 44] #pesos






# formulação

NJ = 1:n 
NI = 1:m
NK = 1:k
@variable(model, x[i in NI, j in NJ], Bin )

@objective(model, Max, sum(p[j] * x[i,j]  for i in NI, j in NJ))

@constraint(model,rest_capital[i in NI, k in NK], sum(w[i,j] * x[i,j] for j in NJ) <= b[i,k])

@constraint(model,rest_escolha[j in NJ], sum(x[i,j] for i in NI) <= 1)

# Solve

optimize!(model)

println("valor de otimo = ",objective_value(model))
println("valor de x = ", value.(x))