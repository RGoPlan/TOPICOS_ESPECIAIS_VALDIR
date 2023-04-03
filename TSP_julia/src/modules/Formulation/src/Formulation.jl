module Formulation

using JuMP
using Data
using OutputStatistics



mutable struct ModelSolution
    obj::Float64
    x::Array{Float64}
    y::Array{Float64}
    s::Array{Float64}
    w::Array{Float64}
    q::Array{Float64}
    alpha::Array{Float64}
    beta::Array{Float64}
    gamma::Array{Float64}
    V::Array{Float64}
    N::Array{Float64}
    O::Array{Float64}
    f::Array{Float64}
    status
end

 

export ModelSolution, createModel!, solveModel!

function createModelSoxandGao!(data::InstanceData, model)

    println("Creating model...")
   
    NI   = 1:data.numItems
    NT   = 1:data.numPer
    NTT  = 2:data.numPer
    NTTT = 1:data.numPer - 1
    NJ   = 1:data.numItems

    # Create variables
    @variable(model, x[i in NI, t in NT] >= 0)
    @variable(model, s[i in NI, t in NT] >= 0)
    @variable(model, y[i in NI, t in NT], Bin)
    @variable(model, w[i in NI, t in NT], Bin)
    #Create Objective function
    @objective(model, Min,
               sum(data.pc * x[i,t] + data.sc[i] * y[i,t] + data.hc[i] * s[i,t] for i in NI, t in NT))

    # Create inventory balance constraints
    @constraint(model, iniBalConstr[i in NI],
                x[i,1] == data.dem[i,1] + s[i,1])

    @constraint(model, balConstr[i in NI, t in NTT],
                s[i,t-1] + x[i,t] ==  data.dem[i,t] + s[i,t])

    # Create capacity constraints
    @constraint(model, capConstr[t in NT],
                sum(data.st[i] * y[i,t] for i in NI) + sum(data.pt[i] * x[i,t] for i in NI) <= data.cap)

    # Compute, for each item, the sum of demands from the begining of the horizon to a given period t
    sumDem = Array{Int}(undef, data.numItems, data.numPer)
    for i in NI
        for t in NT
            sumDem[i,t]= sum(data.dem[i,j] for j=t:data.numPer)
        end
    end

    # Create disjunctive setup constraints
    @constraint(model, setupConstr[i in NI, t in NT],
                x[i,t] <= min(floor((data.cap - data.st[i]) / data.pt[i]), sumDem[i,t]) *(w[i,t] +  y[i,t]))

    # Create setup carryover constraints
    @constraint(model, setupPreservConstr[t in NTT], sum(w[i,t] for i in NI) == 1)  

    @constraint(model, setupNextPreservConstr[i in NI, t in NTT], w[i,t] <= y[i,t-1] + w[i,t-1])   

    @constraint(model, setupPostPreservConstr[i in NI, t in NTT, j in NJ, j != i],  w[i,t]  + w[i,t-1] + y[j,t-1] - y[i,t-1] <= 2)  

    @constraint(model, initialWConstr[i in NI], w[i,1] == 0)


    status = 0

    # write_to_file(model, "modelo.lp")

    x_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(x_values, 0.0)
    y_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(y_values, 0.0)
    s_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(s_values, 0.0)
    w_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(w_values, 0.0)
    

    sol = ModelSolution(10000000, x_values, y_values, s_values, w_values, zeros(1),zeros(1),zeros(1), zeros(1), zeros(1), zeros(1), zeros(1), zeros(1), status)

    return sol

end
function solveModel_SoxandGao!(model::Model, data::InstanceData, sol::ModelSolution, stats::StatisticsData)
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
            for period = 1:data.numPer
                sol.x[item, period] = value(model[:x][item,period])
            end
        end
        for item = 1:data.numItems
            for period = 1:data.numPer
                sol.s[item, period] = value(model[:s][item,period])
            end
        end
        for item = 1:data.numItems
            for period = 1:data.numPer
                sol.y[item, period] = value(model[:y][item,period])
            end
        end
        for item = 1:data.numItems
            for period = 1:data.numPer
                sol.w[item, period] = value(model[:w][item,period])
            end
        end
        
    end

    return zeros(1)

end
function createModelHaase!(data::InstanceData, model)

    println("Creating model...")
   
    NI   = 1:data.numItems
    NT   = 1:data.numPer
    NTT  = 2:data.numPer
    NTTT = 1:data.numPer - 1
    NJ   = 1:data.numItems

    # Create variables
    @variable(model, x[i in NI, t in NT] >= 0)
    @variable(model, s[i in NI, t in NT] >= 0)
    @variable(model, y[i in NI, t in NT], Bin)
    @variable(model, w[i in NI, t in NT], Bin)
    @variable(model, f[t in NT] >= 0)
    #Create Objective function
    @objective(model, Min,
               sum(data.pc * x[i,t] + data.sc[i] * (y[i,t] - w[i,t] ) + data.hc[i] * s[i,t] for i in NI, t in NT))

    # Create inventory balance constraints
    @constraint(model, iniBalConstr[i in NI],
                x[i,1] == data.dem[i,1] + s[i,1])

    @constraint(model, balConstr[i in NI, t in NTT],
                s[i,t-1] + x[i,t] ==  data.dem[i,t] + s[i,t])

    # Create capacity constraints
    @constraint(model, capConstr[t in NT],
                sum(data.st[i] *  (y[i,t] - w[i,t] ) for i in NI) + sum(data.pt[i] * x[i,t] for i in NI) <= data.cap)

    # Compute, for each item, the sum of demands from the begining of the horizon to a given period t
    sumDem = Array{Int}(undef, data.numItems, data.numPer)
    for i in NI
        for t in NT
            sumDem[i,t]= sum(data.dem[i,j] for j=t:data.numPer)
        end
    end

    # Create disjunctive setup constraints
    @constraint(model, setupConstr[i in NI, t in NT],
                x[i,t] <= min(floor((data.cap - data.st[i]) / data.pt[i]), sumDem[i,t]) * y[i,t])

    # Create setup carryover constraints
    @constraint(model, setupPreservConstr[t in NTT], sum(w[i,t] for i in NI) <= 1)  

    @constraint(model, setup1PreservConstr[i in NI, t in NTT], w[i,t] - y[i,t-1]  <= 0) 

    @constraint(model, setup2PreservConstr[i in NI, t in NTT], w[i,t] - y[i,t]  <= 0) 

    @constraint(model, setup3PreservConstr[t in NT], 1 - sum(y[i,t] for  i in NI ) + data.numItems * f[t] >= 0) 

    @constraint(model, setupPostPreservConstr[i in NI, t in NTT],  w[i,t]  + w[i,t-1] + f[t-1] <= 2)  

    @constraint(model, initialWConstr[i in NI], w[i,1] == 0)


    status = 0

    # write_to_file(model, "modelo.lp")

    
    x_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(x_values, 0.0)
    y_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(y_values, 0.0)
    s_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(s_values, 0.0)
    w_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(w_values, 0.0)
    f_values = Array{Float64}(undef, data.numPer)
    fill!(f_values, 0.0)

    sol = ModelSolution(10000000, x_values, y_values, s_values, w_values, zeros(1),zeros(1), zeros(1), zeros(1), zeros(1), zeros(1), zeros(1),f_values,  status)

    return sol


end
function solveModel_Haase!(model::Model, data::InstanceData, sol::ModelSolution, stats::StatisticsData)
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
            for period = 1:data.numPer
                sol.x[item, period] = value(model[:x][item,period])
            end
        end
        for item = 1:data.numItems
            for period = 1:data.numPer
                sol.s[item, period] = value(model[:s][item,period])
            end
        end
        for item = 1:data.numItems
            for period = 1:data.numPer
                sol.y[item, period] = value(model[:y][item,period])
            end
        end
        for item = 1:data.numItems
            for period = 1:data.numPer
                sol.w[item, period] = value(model[:w][item,period])
            end
        end
        
        for period = 1:data.numPer
            sol.f[period] = value(model[:f][period])
        end

    end

    return zeros(1)

end
function createModelArenales!(data::InstanceData, model)

    println("Creating model...")

    NI = 1:data.numItems
    NT = 1:data.numPer
    NTT = 2:data.numPer
    NTTT = 1:data.numPer - 1

    # Create variables
    @variable(model, x[i in NI, t in NT] >= 0)
    @variable(model, s[i in NI, t in NT] >= 0)
    @variable(model, y[i in NI, t in NT], Bin)
    @variable(model, w[i in NI, t in NT], Bin)
    @variable(model, q[t in NT] >= 0)

    #Create Objective function
    @objective(model, Min,
               sum(data.pc * x[i,t] + data.sc[i] * y[i,t] + data.hc[i] * s[i,t] for i in NI, t in NT))

    # Create inventory balance constraints
    @constraint(model, iniBalConstr[i in NI],
                x[i,1] == data.dem[i,1] + s[i,1])

    @constraint(model, balConstr[i in NI, t in NTT],
                s[i,t-1] + x[i,t] ==  data.dem[i,t] + s[i,t])

    # Create capacity constraints
    @constraint(model, capConstr[t in NT],
                sum(data.st[i] * y[i,t] for i in NI) + sum(data.pt[i] * x[i,t] for i in NI) <= data.cap)

    # Compute, for each item, the sum of demands from the begining of the horizon to a given period t
    sumDem = Array{Int}(undef, data.numItems, data.numPer)
    for i in NI
        for t in NT
            sumDem[i,t]= sum(data.dem[i,j] for j=t:data.numPer)
        end
    end

    # Create disjunctive setup constraints
    @constraint(model, setupConstr[i in NI, t in NT],
                x[i,t] <= min(floor((data.cap - data.st[i]) / data.pt[i]), sumDem[i,t]) *(w[i,t] + y[i,t]))

    # Create setup carryover constraints
    @constraint(model, setupPreservConstr[t in NTT], sum(w[i,t] for i in NI) <= 1)  

    @constraint(model, setupNextPreservConstr[i in NI, t in NTT], w[i,t] <= y[i,t-1] + w[i,t-1])   

    @constraint(model, setupPostPreservConstr[i in NI, t in NTTT], w[i,t+1] + w[i,t] <= 1 + q[t])  

    @constraint(model, setupSingleItemPreservConstr[i in NI, t in NT], y[i,t] + q[t] <= 1) 

    @constraint(model, initialWConstr[i in NI], w[i,1] == 0)

    @constraint(model, initialQConstr[i in NI], q[1] == 0)

    status = 0

    # write_to_file(model, "modelo.lp")

    x_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(x_values, 0.0)
    y_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(y_values, 0.0)
    s_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(s_values, 0.0)
    w_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(w_values, 0.0)
    q_values = Array{Float64}(undef, data.numPer)
    fill!(q_values, 0.0)

    sol = ModelSolution(10000000, x_values, y_values, s_values, w_values, q_values, zeros(1), zeros(1), zeros(1), zeros(1), zeros(1), zeros(1),zeros(1), status)

    return sol

end

function solveModel_Arenales!(model::Model, data::InstanceData, sol::ModelSolution, stats::StatisticsData)
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
            for period = 1:data.numPer
                sol.x[item, period] = value(model[:x][item,period])
            end
        end
        for item = 1:data.numItems
            for period = 1:data.numPer
                sol.s[item, period] = value(model[:s][item,period])
            end
        end
        for item = 1:data.numItems
            for period = 1:data.numPer
                sol.y[item, period] = value(model[:y][item,period])
            end
        end
        for item = 1:data.numItems
            for period = 1:data.numPer
                sol.w[item, period] = value(model[:w][item,period])
            end
        end
        
        for period = 1:data.numPer
            sol.q[period] = value(model[:q][period])
        end
        

    end
 
    return zeros(1)

end

function createModelGopalakrishnan!(data::InstanceData, model)

    println("Creating model...")

    NI = 1:data.numItems
    NT = 1:data.numPer
    NTT = 2:data.numPer

    # Create variables
    @variable(model, x[i in NI, t in NT] >= 0)
    @variable(model, s[i in NI, t in NT] >= 0)
    @variable(model, N[i in NI,t in NT] >= 0)
    @variable(model, V[i in NI, t in NT] >= 0)
    @variable(model, 0 <= q[t in NT] <= 1)
    @variable(model, O[t in NT] >= 0)
    @variable(model, w[i in NI, t in NT], Bin)
    @variable(model, y[i in NI, t in NT], Bin)
    @variable(model, alpha[i in NI, t in NT], Bin)
    @variable(model, beta[i in NI, t in NT], Bin)
    @variable(model, gamma[i in NI, t in NT], Bin)

    #Create Objective function
    @objective(model, Min, sum(data.hc[i] * s[i,t] + data.pc * x[i,t] + data.sc[i] * N[i,t]  for i in NI, t in NT) )    

    # Create inventory balance constraints
    @constraint(model, iniBalConstr[i in NI],
                x[i,1] == data.dem[i,1] + s[i,1])

    @constraint(model, balConstr[i in NI, t in NTT],
                s[i,t-1] + x[i,t] ==  data.dem[i,t] + s[i,t])

    # Create capacity constraints
    @constraint(model, capConstr[t in NT],
                sum(data.pt[i] * x[i,t] + data.st[i] * N[i,t]   for i in NI) <= data.cap)

    # Compute, for each item, the sum of demands from the begining of the horizon to a given period t
    sumDem = Array{Int}(undef, data.numItems, data.numPer)
    for i in NI
        for t in NT
            sumDem[i,t]= sum(data.dem[i,j] for j=t:data.numPer)
        end
    end

    # Create disjunctive setup constraints
    @constraint(model, setupConstr[i in NI, t in NT],
                x[i,t] <= min(floor((data.cap - data.st[i]) / data.pt[i]), sumDem[i,t]) * y[i,t])

    @constraint(model,setupcountConstr[i in NI, t in NT], 
                N[i,t] == y[i,t] - w[i,t] + V[i,t]    )  
                
    @constraint(model,isetupSConstr[i in NI], 2 * w[i,1] <=  alpha[i,1] )  
    @constraint(model,setupSConstr[i in NI, t in NTT], 2 * w[i,t] <= gamma[i,t-1] + alpha[i,t]) 

    @constraint(model,setupVConstr[i in NI, t in NT], V[i,t] >=  gamma[i,t] - beta[i,t] )     

    #Set-up carryover modelling

    @constraint(model, asetupwalphaConstr[t in NT], O[t] <= sum(alpha[i,t] for i in NI) ) 
    @constraint(model, bsetupwalphaConstr[t in NT], sum(alpha[i,t] for i in NI) <= 1) 

    @constraint(model, asetupwbetaConstr[t in NT], O[t] <= sum(beta[i,t] for i in NI) )  
    @constraint(model, bsetupwbetaConstr[t in NT], sum(beta[i,t] for i in NI) <= 1)  

    @constraint(model, setupABDConstr[i in NI, t in NT], alpha[i,t] + beta[i,t]  <= 2 - q[t])   

    @constraint(model, setupalphayConstr[i in NI, t in NT], alpha[i,t] <= y[i,t]) 
    @constraint(model, setupbetayConstr[i in NI, t in NT], beta[i,t] <= y[i,t]) 

    @constraint(model, setupalphaConstr[t in NT], sum(gamma[i,t] for i in NI) == 1) 

    @constraint(model, setupywPConstr[i in NI, t in NT], y[i,t] <= O[t]) 

    @constraint(model, setupyqConstr[t in NT], sum(y[i,t] for i in NI) -1 <= (data.numItems - 1) * q[t]) 

    status = 0

    # write_to_file(model, "modelo.lp")

    x_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(x_values, 0.0)
    y_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(y_values, 0.0)
    s_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(s_values, 0.0)
    w_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(w_values, 0.0)
    q_values = Array{Float64}(undef, data.numPer)
    fill!(q_values, 0.0)
    alpha_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(alpha_values, 0.0) 
    beta_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(beta_values, 0.0)
    gamma_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(gamma_values, 0.0)
    V_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(V_values, 0.0)
    N_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(N_values, 0.0)
    O_values = Array{Float64}(undef, data.numPer)
    fill!(O_values, 0.0)
    
    sol = ModelSolution(10000000, x_values, y_values, s_values, w_values, q_values, alpha_values, beta_values, gamma_values, V_values, N_values, O_values, zeros(1), status)

    return sol

end
function solveModel_Gopalakrishnan!(model::Model, data::InstanceData, sol::ModelSolution, stats::StatisticsData)
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

        fill!(sol.x, 0.0)
        fill!(sol.s, 0.0)
        fill!(sol.y, 0.0)
        fill!(sol.w, 0.0)
        fill!(sol.alpha, 0.0)
        fill!(sol.beta, 0.0)
        fill!(sol.gamma, 0.0)
        fill!(sol.V, 0.0)
        fill!(sol.N, 0.0)
        fill!(sol.q, 0.0)
        fill!(sol.O, 0.0)

        for period = 1:data.numPer
            for item = 1:data.numItems            
                if value(model[:x][item,period]) > 0.000001
                    sol.x[item, period] = value(model[:x][item,period])
                end
                if value(model[:s][item,period]) > 0.000001
                    sol.s[item, period] = value(model[:s][item,period])
                end
                if value(model[:y][item,period]) > 0.000001
                    sol.y[item, period] = value(model[:y][item,period])
                end
                if value(model[:w][item,period]) > 0.000001
                    sol.w[item, period] = value(model[:w][item,period])
                end
                if value(model[:alpha][item,period]) > 0.000001
                    sol.alpha[item, period] = value(model[:alpha][item,period])
                end
                if value(model[:beta][item,period]) > 0.000001
                    sol.beta[item, period] = value(model[:beta][item,period])
                end
                if value(model[:gamma][item,period]) > 0.000001
                    sol.gamma[item, period] = value(model[:gamma][item,period])
                end
                if value(model[:V][item,period]) > 0.000001
                    sol.V[item, period] = value(model[:V][item,period])
                end
                if value(model[:N][item,period]) > 0.000001
                    sol.N[item, period] = value(model[:N][item,period])
                end
            end

            if value(model[:q][period]) > 0.000001
                sol.q[period] = value(model[:q][period])
            end
            if value(model[:O][period]) > 0.000001
                sol.O[period] = value(model[:O][period])
            end
        end
    end

    return

end

function createModelBriskorn!(data::InstanceData, model)

    println("Creating model...")

    NI = 1:data.numItems
    NT = 1:data.numPer
    NTT = 2:data.numPer
    NTTT = 1:data.numPer - 1

    # Create variables
    @variable(model, x[i in NI, t in NT] >= 0)
    @variable(model, s[i in NI, t in NT] >= 0)
    @variable(model, y[i in NI, t in NT], Bin)
    @variable(model, w[i in NI, t in NT], Bin)

    #Create Objective function
    @objective(model, Min,
               sum(data.pc * x[i,t] + data.sc[i] * y[i,t] + data.hc[i] * s[i,t] for i in NI, t in NT))

    # Create inventory balance constraints
    @constraint(model, iniBalConstr[i in NI],
                x[i,1] == data.dem[i,1] + s[i,1])

    @constraint(model, balConstr[i in NI, t in NTT],
                s[i,t-1] + x[i,t] ==  data.dem[i,t] + s[i,t])

    # Create capacity constraints
    @constraint(model, capConstr[t in NT],
                sum(data.st[i] * y[i,t] for i in NI) + sum(data.pt[i] * x[i,t] for i in NI) <= data.cap)

    # Compute, for each item, the sum of demands from the begining of the horizon to a given period t
    sumDem = Array{Int}(undef, data.numItems, data.numPer)
    for i in NI
        for t in NT
            sumDem[i,t]= sum(data.dem[i,j] for j=t:data.numPer)
        end
    end

    # Create disjunctive setup constraints
    @constraint(model, setupConstr[i in NI, t in NT],
                x[i,t] <= min(floor((data.cap - data.st[i]) / data.pt[i]), sumDem[i,t]) * (w[i,t] + y[i,t]))

    # Create setup carryover constraints
    @constraint(model, setupPreservConstr[t in NTT], sum(w[i,t] for i in NI) <= 1)  

    @constraint(model, setupNextPreservConstr[i in NI, t in NTT], w[i,t] <= y[i,t-1] + w[i,t-1])   

    @constraint(model, setupPostPreservConstr[i in NI, t in NTT, j in NI, j != i],  w[i,t]  + w[i,t-1] + y[j,t-1] - y[i,t-1] <= 2)  

    @constraint(model, initialWConstr[i in NI], w[i,1] == 0)

    status = 0

    # write_to_file(model, "modelo.lp")

    x_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(x_values, 0.0)
    y_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(y_values, 0.0)
    s_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(s_values, 0.0)
    w_values = Array{Float64}(undef, data.numItems, data.numPer)
    fill!(w_values, 0.0)

    sol = ModelSolution(10000000, x_values, y_values, s_values, w_values, zeros(1), zeros(1), zeros(1), zeros(1), zeros(1), zeros(1), zeros(1),zeros(1), status)

    return sol

end
function solveModel_Briskorn!(model::Model, data::InstanceData, sol::ModelSolution, stats::StatisticsData)
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
            for period = 1:data.numPer
                sol.x[item, period] = value(model[:x][item,period])
            end
        end
        for item = 1:data.numItems
            for period = 1:data.numPer
                sol.s[item, period] = value(model[:s][item,period])
            end
        end
        for item = 1:data.numItems
            for period = 1:data.numPer
                sol.y[item, period] = value(model[:y][item,period])
            end
        end
        for item = 1:data.numItems
            for period = 1:data.numPer
                sol.w[item, period] = value(model[:w][item,period])
            end
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

function printSolution(data::InstanceData, sol::ModelSolution)

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
