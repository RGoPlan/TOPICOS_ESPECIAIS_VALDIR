
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

# formulação



#simetrico

NI = 1:n
NJ = 1:n
NS = 3:6
NSS = 1:3
NSSS = 7:n

#@variable(model, X[i in NI, j in NJ#= , i != j  =#], Bin)


@objective(model, Min, sum( sqrt((x[i] - x[j])^2 + (y[i] - y[j])^2) * X[i,j]   for i in NI, j in NJ if i !=j ))


@constraint(model,rest_escolha[i in NI], sum( X[j,i] for j = 1 :i-1) + sum( X[i,j] for j = i +1:n) == 2 )

#@constraint(model,elimina[s in NS], sum(x[i,j] for i in NS, j in NSS  if j > i) + sum(x[i,j] for i in NSS, j in NS if j>i) >= 2)
#@constraint(model,elimina2[s in NS], sum(x[i,j] for i in NS, j in NSSS if j > i) + sum(x[i,j] for  i in NSSS, j in NS if j>i) >= 2)
#@constraint(model,elimina[s in NS], sum(x[i,j] for i in NS, j in NSS  if j > i) <= + sum(x[i,j] for i in NSS, j in NS if j>i) >= 2)
# Solve
# Print X[i,j] solution

#assimetrico
#= NI = 1:n
NJ = 1:n

@variable(model, X[i in NI, j in NJ], Bin)


@objective(model, Min, sum( sqrt((x[i] - x[j])^2 + (y[i] - y[j])^2) * X[i,j]   for i in NI, j in NJ if i !=j ))


@constraint(model,rest_arest[j in NJ], sum( X[i,j] for i in NI if j != i) == 1 )

@constraint(model,rest_arest2[i in NI ], sum( X[i,j] for j in NJ if i != j) == 1 ) =#




@constraint(model,rest1, X[1,4] + X[4,9] + X[1,9] <=2 )
@constraint(model,rest2, X[2,6] + X[2,3] + X[3,6] <=2 )
@constraint(model,rest3, X[5,11] + X[11,12] + X[5,12] <=2 )
@constraint(model,rest4, X[7,10] + X[7,8] + X[8,10] <=2 )

optimize!(model)

println("valor de x = ", value.(X))

#= for j = 1:n
     print("\nj_$j:")
     for i = 1:n
         if value(X[i,j]) > 0.9
             print(" X$i= ")
             print(round(value(X[i,j]), digits = 4))
         end
     end
end =#
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
               
         
   
     