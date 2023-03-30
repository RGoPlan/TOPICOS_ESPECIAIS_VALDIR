module Problem

using JuMP
using Data
#using OutputStatistics

 

mutable struct ModelSolution
    obj::Float64
    x::Array{Float64}
    status
end

 

export ModelSolution, createModel!, solveModel!

function createModel_Mochila_0_1!(data::InstanceData_M01, model)

    println("Creating model...")
   
    NJ = 1:data.numItems

    @variable(model, x[j in NJ], Bin )

    @objective(model, Max, sum(data.p[j] * x[j]  for j in NJ))

    @constraint(model,rest_capital, sum(data.a[j] * x[j] for j in NJ) <= data.b[1])
     
    status = 0

    x_values = Array{Float64}(undef, data.numItems)
    fill!(x_values, 0.0)

    sol = ModelSolution(10000000, x_values, status)

    return sol

end
function solveModel_Mochila_0_1!(model::Model, data::InstanceData_M01, sol::ModelSolution, stats::StatisticsData)
    
    optimize!(model)

    sol.status = termination_status(model)
    stats.solStatus = sol.status
    stats.totalTime = solve_time(model)

    # Get solution
    if has_values(model) == true # Check if there is a primal solution available
        sol.obj = objective_value(model)

        println("Status = ", sol.status,
                "\nObjective = ", sol.obj)
        
        stats.bestLB = objective_bound(model)
        stats.bestUB = sol.obj
        stats.gap = 100 * ((stats.bestUB - stats.bestLB) / stats.bestUB)

        for item = 1:data.numItems
           
            sol.x[item, period] = value(model[:x][item])
           
        end
      
        
    end

    return zeros(1)

end

function solveModel!(model, sol::ModelSolution, stats::StatisticsData)
    optimize!(model)

    sol.status = termination_status(model)
    stats.solStatus = sol.status
    stats.totalTime = solve_time(model)

    # Get solution
    if has_values(model) == true # Check if there is a primal solution available
        sol.obj = objective_value(model)

        println("Status = ", sol.status,
                "\nObjective = ", sol.obj)
        
        stats.bestLB = objective_bound(model)
        stats.bestUB = sol.obj
        stats.gap = 100 * ((stats.bestUB - stats.bestLB) / stats.bestUB)

    end

end

function printSolution(data::InstanceData_M01, sol::ModelSolution)

    # Print x[i,t] solution
    println("Production")
    for t = 1:data.numPer
        print("\nt_$t:")
        for i = 1:data.numItems
            if value(sol.x[i,t]) > 0.0001
                print(" i$i = ")
                print(round(value(sol.x[i,t]), digits = 4))
            end
        end
    end

	# Print y[i,t] solution
	println("Setups")
	for t = 1:data.numPer
        print("\nt_$t:")
        for i = 1:data.numItems
            if value(sol.y[i,t]) > 0.9
                print(" y$i= ")
                print(round(value(sol.y[i,t]), digits = 4))
            end
        end
    end
end


end #module
