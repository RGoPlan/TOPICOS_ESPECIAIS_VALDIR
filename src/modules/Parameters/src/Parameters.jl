module Parameters

using Data
using DelimitedFiles

struct StdFormParameters
    timeLimit::Int
    MIPgapTolerance::Float64
    integerFeasibilityTolerance::Float64
    numberOfThreads::Int
    screenOutput::Int
end


export StdFormParameters, readStdFormParameters

function readStdFormParameters(paramFile::String)
    paramData = readdlm(paramFile)
    timeLimit = paramData[1,2]
    MIPgapTolerance = paramData[2,2]
    integerFeasibilityTolerance = paramData[3,2]
    numberOfThreads = paramData[4,2]
    screenOutput = paramData[5,2]

    params = StdFormParameters(timeLimit,
                               MIPgapTolerance,
                               integerFeasibilityTolerance,
                               numberOfThreads,
                               screenOutput)

    return params
end



end
