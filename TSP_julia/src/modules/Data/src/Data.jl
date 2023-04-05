module Data

using DelimitedFiles

struct InstanceTypeData
    instName::String
    DIMENSION:: Int
    COORD_Type::String
end
struct InstanceDataEXPLICIT
    EDGE_WEIGHT_FORMAT::String
end
export InstanceTypeData, readData, InstanceDataEXPLICIT

function readTypeData(instanceFile::String)
    instance = readdlm(instanceFile)

    name = instance[1,2]
    dim = instance[4,2] 
    coord = instance[5,2]
 

    # Print instance data
    print(#= "Instance TYPE: ", 
            "\n", =#name#= ,
            "\n",dim,
            "\n", coord =#)

           

    instanceType = InstanceTypeData(name,dim,coord)

    return instanceType

end
function readDataEXPLICIT(instanceFile::String)
    instance = readdlm(instanceFile)

    format = instance[6,2]
    if format == "LOWER_DIAG_ROW"
    end
    # Print instance data
    println(#= "Instance data: ",
            "\n", =#" ", format)

           

    instance = InstanceDataEXPLICIT(format)

    return instance

end


end
