module Data



struct InstanceData_M01 
    numItems::Int   # Number of items
    b::Int        # Capacity is the same for all periods
    pc::Int         # Unitary production cost (same for all items in all periods)
    p              # Setup costs
    a              # Inventory holding costs
end

export InstanceData_M01, readData_M01

function readData_M01(instanceFile::String)


    n = 8   #numero de projetos
    b = [100] # capital disponivel  
    p = [41 33 14 25 32 32 9 19]
    a = [47 40 17 27 34 23 5 44]  

    # Print instance data
    #= println("\nNumber of items: ", n,
            "\nNumber of periods: ", m,
            "\nUnitary production cost: ", p,
            "\nSetup cost: ", f,
            "\nUnitary inventory holding cost: ", h,
            "\nUnitary resource consumptions: ", a,
            "\nSetup resource consumption: ", b,
            "\nResource availability (capacity): ", c,
            "\nDemands: ", d)=#

    instance = InstanceData( n, b, p, a) 

    return instance

end



end
