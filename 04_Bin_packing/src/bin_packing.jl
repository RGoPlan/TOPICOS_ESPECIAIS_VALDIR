
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
b = 100  # capacidades disponivel  
p = [41 33 14 25 32 32 9 19] #lucratividade
w = [47 40 17 27 34 23 5 44] #pesos






# formulação

NJ = 1:n 
NI = 1:m

@variable(model, x[i in NI, j in NJ], Bin )
@variable(model, y[i in NI], Bin)

@objective(model, Min, sum(y[i]  for i in NI))

@constraint(model,rest_escolha[j in NJ], sum(x[i,j] for i in NI) == 1)

@constraint(model,rest_capital[i in NI], sum(w[j] * x[i,j] for j in NJ) <= b * y[i] )



# Solve

optimize!(model)

println("valor de otimo = ",objective_value(model))
println("valor de x = ", value.(x))