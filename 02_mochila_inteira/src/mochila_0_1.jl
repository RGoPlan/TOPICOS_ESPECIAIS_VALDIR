
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
n = 8   #numero de projetos
b = [100] # capital disponivel  
p = [41 33 14 25 32 32 9 19]
a = [47 40 17 27 34 23 5 44]




# formulação


@variable(model, x[j = 1:n], Bin )

@objective(model, Max, sum(p[j] * x[j]  for j = 1:n))

@constraint(model,rest_capital, sum(a[j] * x[j] for j = 1:n) <= b[1])

# Solve

optimize!(model)

println("valor de otimo = ",objective_value(model))
println("valor de x = ", value.(x))