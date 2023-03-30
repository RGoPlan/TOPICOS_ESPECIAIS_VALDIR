using Pkg
Pkg.activate(".")

using JuMP
using Gurobi

# criação do modelo vazio
model = Model(optimizer_with_attributes(Gurobi.Optimizer, "OutputFlag" => 0))

# leitura de dados
n = 6
e = 7

E = [(1,2); (2,3); (3,4); (4,5); (4,6); (5,6); (6,2)]
E2 = [(2,1); (3,2); (4,3); (5,4); (6,4); (6,5); (2,6)]
c= (2, 1, 4, 1, 6, 2, 4 )
NEE = 1:e
NN = 1:n
C = Dict(zip(E, c))



@variable(model, X[(i,j) in E] >= 0, Int)

@objective(model, Min, sum(C[(i,j)]* X[(i,j)] for (i,j) in E))

@constraint(model, rest_obriga[(i,j) in E], X[(i,j)] >= 1)

@constraint(model, rest_arest[i in NN], sum(X[(i,j)] for j in NN if (i,j) in E) - sum(X[(j,i)] for j in NN if (j,i) in E) == 0)

println(model)


optimize!(model)

println("valor de otimo = ",objective_value(model))
#= for (i,j) in NE
    if value(X[i,j]) > 0.9
        println("valor de X[", i, ",", j, "] = ", value(X[i,j]))
    end
end
 =#
