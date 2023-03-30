
using Pkg
Pkg.activate(".")

using JuMP
using  Gurobi
using GraphPlot
using LightGraphs
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
n = 12
#x = Array{Float64}(undef, n)
#y = Array{Float64}(undef, n)
x = [ 43 58 53 21 78 46 79 60 42 87 77 99]
y = [ 23 76 64 38 68 57 06 05 30 02 97 79]

c = Array{Float64}(undef, n,n)
for i = 1:n
     for j = 1:n
          
          c[i,j] = sqrt((x[i] - x[j])^2 + (y[i] - y[j])^2)
         
     end
end 




NI = 1:n
NJ = 1:n
NJJ = 2:n
@variable(model, X[i in NI, j in NJ], Bin)
@variable(model, u[i in NI] >= 0)

#@objective(model, Min, sum( sqrt((x[i] - x[j])^2 + (y[i] - y[j])^2) * X[i,j]   for i in NI, j in NJ #= if i !=j =# ))

@objective(model, Min, sum( c[i,j]* X[i,j]   for i in NI, j in NJ #= if i !=j =# ))

@constraint(model,rest_arest0[i in NJ], X[i,i] == 0 )

@constraint(model,rest_arest[j in NJ], sum( X[i,j] for i in NI ) == 1 )

@constraint(model,rest_arest2[i in NI ], sum( X[i,j] for j in NJ ) == 1 )

@constraint(model,elemina[i in NI, j in NJJ, i != j <=n], u[i] + X[i,j] <= u[j] + (n + 1) *(1 - X[i,j]))



optimize!(model)

for i = 1:n
     for j = 1:n
          if value(X[i,j]) > 0.9
               println("valor de x[$i,$j] = ", value.(X[i,j]))
          end
     end
end


#= g = SimpleGraph(n)

for i in n
     for j in n
          if i != j && getvalue(X[i, j]) > 0.99
          add_edge!(g, i, j)
          
          end
     end
end

gplot(g) =#
#=   
gplot(
     SimpleGraph(
          [
          for i in n
               for j in n
                    if i != j && getvalue(X[i, j]) > 0.99
                    add_edge!(g, i, j)
                    
                    end
               end
          end   
          ]
     

     )


) =#
               
         
   
     