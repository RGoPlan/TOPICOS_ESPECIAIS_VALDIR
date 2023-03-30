
using Pkg
Pkg.activate(".")

using JuMP
using  Gurobi

# criação do modelo vazio

#model = Model(optimizer_with_attributes(Gurobi.Optimizer))
model = Model(optimizer_with_attributes(Gurobi.Optimizer, "OutputFlag" => 0))

#leitura de dados
n = 6
e = 7



M = 1000000000000000000000000

C= [ M	2	M	M	M	M;
     M	M	1	M	M	M;
     M	M	M	3	M	M;
     M	M	M	M	1	6;
     M	M	M	M	M	2;
     M	4	M	M	M	M ]

NE = [(1,2), (2,3), (3,4), (4,5), (4,6), (5,6), (6,2)]
NN = [1:n]

@variable(model, X[NE] >= 0, Int)


@objective(model, Min, sum( C[i,j]* X[i,j]   for (i,j) in NE ) )



@constraint(model, rest_arest[i in NN], sum(X[i,j] for (i,j) in NE if i<j) == sum(X[j,i] for (i,j) in NE if i<j))
#@constraint(model,rest_arest[i in NN ], sum( X[i,j] for j:(i,j) in NE ) - sum( X[j,i] for j:(i,j) in NE ) == 0 )

@constraint(model, rest_obriga[(i,j) in NE], X[i,j] >= 1)


optimize!(model)

for (i,j) in NE
    if value(X[i,j]) > 0.9
        println("valor de X[", i, ",", j, "] = ", value(X[i,j]))
    end


  
     