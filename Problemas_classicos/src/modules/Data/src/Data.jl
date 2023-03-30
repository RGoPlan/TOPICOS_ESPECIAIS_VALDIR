module Data

using DelimitedFiles

struct InstanceData
    instName::String
    numItems::Int   # Number of items
    numPer::Int     # Number of periods
    cap::Int        # Capacity is the same for all periods
    pc::Int         # Unitary production cost (same for all items in all periods)
    sc              # Setup costs
    hc              # Inventory holding costs
    pt              # Unitary production times
    st              # Setup times
    dem             # Demands
end

export InstanceData, readData, compute_bigM_coeffs

function readData(instanceFile::String)
    instance = readdlm(instanceFile)

    name = instanceFile
    n = instance[1, 1]  # Get number of items
    m = instance[1, 2]  # Get number of periods
    p = instance[2, 1]  # Get unitary production cost
    c = instance[3, 1]  # Get capacity

    a = Array{Float64}(undef, n)
    h = Array{Float64}(undef, n)
    b = Array{Float64}(undef, n)
    f = Array{Float64}(undef, n)
    for i=1:n
        a[i] = instance[3+i, 1]     # Get unitary resource consumptions
        h[i] = instance[3+i, 2]     # Get unitary inventory costs
        b[i] = instance[3+i, 3]     # Get setup resource consumptions
        f[i] = instance[3+i, 4]     # Get setup costs
    end

    d = Array{Int64}(undef, n, m)
    for i=1:n
        for t=1:m
            if i < 16
                d[i, t] = instance[3+n+t, i]    # Get demands
            elseif i >= 16
                d[i, t] = instance[3+n+t, i-15]
            end
        end
    end

    # Print instance data
    println("Instance data:",
            "\n", instanceFile,
            "\nNumber of items: ", n,
            "\nNumber of periods: ", m,
            "\nUnitary production cost: ", p,
            "\nSetup cost: ", f,
            "\nUnitary inventory holding cost: ", h,
            "\nUnitary resource consumptions: ", a,
            "\nSetup resource consumption: ", b,
            "\nResource availability (capacity): ", c,
            "\nDemands: ", d)

    instance = InstanceData(name, n, m, c, p, f, h, a, b, d)

    return instance

end



end
