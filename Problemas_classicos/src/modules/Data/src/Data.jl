module Data

using DelimitedFiles

struct InstanceData_Mochila
    instName::String
    numItems::Int   # Number of items
    numMochi::Int   # Number of binpack
    b               # Capacity is the same for all periods
    p               # profitability
    w               # Weight
end
export InstanceData_Mochila, readData_Mochila

function readData_Mochila(dataFile::String)
    instance = readdlm(dataFile)

    name = dataFile
    n = instance[1, 1]  # Get number of items
    m = instance[1, 2]  # Get number  of Pack


    b = Array{Float64}(undef, m)
   
    for i = 1:m
        b[i] = instance[2,i]        # get unitary capacity
    end
    p = Array{Float64}(undef, n)
    w = Array{Float64}(undef, n)
    for i=1:n
        p[i] = instance[3, i]     # Get unitary 
        w[i] = instance[4, i]     # Get unitary 

    end

   

    # Print instance data
    println("Instance data:",
            "\n", name,
            "\nNumber of items: ", n,
            "\nNumber of packs : ", m,
            "\nUnitary capacity: ", b,
            "\ncoisa: ", p,
            "\nUnitary cost: ", w)

    instance = InstanceData_Mochila(name, n, m, b, p, w)

    return instance

end



end
