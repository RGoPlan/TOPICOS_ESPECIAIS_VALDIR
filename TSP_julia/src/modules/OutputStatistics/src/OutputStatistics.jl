module OutputStatistics

using Data

mutable struct StatisticsData
    instName::String
    DIMENSION:: Int
    EDGE_WEIGHT_FORMAT::String
    Max_Value:: Int

end


export  StatisticsData, setupStdStatsFile,initStatsData!

function setupStdStatsFile(datatype::InstanceTypeData)

    out = open(statsFile,"w")

    println(out, "EDGE_WEIGHT_TYPE: ", datatype.coord )
    
            

    print(out, "\nInstance & Nos & C_max & totalTime \\\\")

    close(out)

return
end

function initStatsData!()
    name =  ""
    dim =  0
    WEIGHT = ""
    MaxC= 0
   

    stats = StatisticsData(name,
                           dim,
                           WEIGHT,
                           MaxC  
                           )

    return stats
end


end # module