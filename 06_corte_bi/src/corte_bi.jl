
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
n = 10   #numero de itens
m = 4   #numero de mochilas
L = 11
l = [2 3 3.5 4]
b = [8 4 6 3 ]  # capacidades disponivel  

   





# formulação

NJ = 1:m
NI = 1:n

@variable(model, x[i in NI, j in NJ] >= 0, Int )
@variable(model, y[i in NI], Bin)

@objective(model, Min, sum(y[i]  for i in NI))


@constraint(model,rest_escolha[j in NJ], sum(x[i,j] for i in NI) >= b[j])

@constraint(model,rest_capital[i in NI], sum(l[j] * x[i,j] for j in NJ) <= L * y[i] )



# Solve

optimize!(model)

println("valor de x = ", value.(x))
println("valor de y = ", value.(y))