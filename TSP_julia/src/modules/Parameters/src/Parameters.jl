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
struct RFFOParameters
    rfMaxTime::Int
    restrictedModelMaxTime::Float64
    rfWindowSize::Int
    rfStep::Int
    foWindowSize::Int
    foStep::Int
    MIPgapTolerance::Float64
    integerFeasibilityTolerance::Float64
    numberOfThreads::Int
    screenOutput::Int
end
struct RFOParameters
    rfMaxTime::Int
    restrictedModelMaxTime::Float64
    rfWindowSize::Int
    rfStep::Int
    foWindowSize::Int
    foStep::Int
    MIPgapTolerance::Float64
    integerFeasibilityTolerance::Float64
    numberOfThreads::Int
    screenOutput::Int
    startFO:: Int
end

export StdFormParameters, readStdFormParameters,RFFOParameters, readRFFOParameters,RFOParameters, readRFOParameters

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

function readRFFOParameters(paramFile::String, data::InstanceData)
    paramData = readdlm(paramFile)

    rfMaxTime = paramData[1,2]
    restrictedModelMaxTime = paramData[2,2]  #paramData[1,2]/ (2 * ceil(1 + (data.numPer - paramData[7,2] ) / paramData[8,2])) 
    rfWindowSize =  paramData[7,2] #ceil(data.numPer / 3)  ### restrictedModelMaxTime = rfMaxTime / (2 * arrendondamento(1+(m-tj)/tp))
    rfStep = paramData[8,2] #ceil((2 * rfWindowSize) / 3) 
    foWindowSize = paramData[9,2] #ceil(data.numPer / 3)
    foStep = paramData[10,2] #ceil(foWindowSize / 2)

    MIPgapTolerance = paramData[3,2]
    integerFeasibilityTolerance = paramData[4,2]
    numberOfThreads = paramData[5,2]
    screenOutput = paramData[6,2]

    params = RFFOParameters(rfMaxTime,
                            restrictedModelMaxTime,
                            rfWindowSize,
                            rfStep,
                            foWindowSize,
                            foStep,
                            MIPgapTolerance,
                            integerFeasibilityTolerance,
                            numberOfThreads,
                            screenOutput)

    return params
end
function readRFOParameters(paramFile::String, data::InstanceData)
    paramData = readdlm(paramFile)

    rfMaxTime = paramData[1,2]
    restrictedModelMaxTime = paramData[1,2]/ (2 * ceil(1 + (data.numPer - paramData[7,2] ) / paramData[8,2])) #paramData[2,2] 
    rfWindowSize = paramData[7,2]#ceil(data.numPer / 3)
    rfStep = paramData[8,2] #ceil((2 * rfWindowSize) / 3)
    foWindowSize = paramData[9,2] #ceil(data.numPer / 3)
    foStep = paramData[10,2] #ceil(foWindowSize / 2)
    startFO = paramData[11,2]

    MIPgapTolerance = paramData[3,2]
    integerFeasibilityTolerance = paramData[4,2]
    numberOfThreads = paramData[5,2]
    screenOutput = paramData[6,2]

    params = RFOParameters(rfMaxTime,
                            restrictedModelMaxTime,
                            rfWindowSize,
                            rfStep,
                            foWindowSize,
                            foStep,
                            MIPgapTolerance,
                            integerFeasibilityTolerance,
                            numberOfThreads,
                            screenOutput,
                            startFO)

    return params
end


end
