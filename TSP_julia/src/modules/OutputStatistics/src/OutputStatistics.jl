module OutputStatistics

using Data
using Parameters

mutable struct StatisticsData
    approach::String
    formulation::String
    bestLB::Float64
    bestUB::Float64
    gap::Float64
    rfUB::Float64
    rfIterations::Int
    rfTime::Float64
    rfBacktrackAttempts::Int
    foUB::Float64
    foImprovement::Float64
    foIterations::Int
    foRounds::Int
    foTime::Float64
    totalTime::Float64
    solStatus
end



export  StatisticsData, setupStdStatsFile, setupRFFOStatsFile, setupRFOStatsFile, initStatsData!, printStats!, setupFOImprovementStatsFile

function setupStdStatsFile(statsFile::String,
                           stdFormParams::StdFormParameters, formulation::String)

    out = open(statsFile,"w")

    println(out, "Statistics for clsp with setup carryover")
    println(out, "Formulation: ", formulation)
    println(out, "Approach: STD")
    println(out, "Time limit: ", stdFormParams.timeLimit)
    println(out, "MIP gap tolerance: ", stdFormParams.MIPgapTolerance)
    println(out, "Integer feasibility tolerance: ", stdFormParams.integerFeasibilityTolerance)
    println(out, "Number of threads: ", stdFormParams.numberOfThreads)
    println(out, "Screen output: ", stdFormParams.screenOutput)

    print(out, "\nInstance & I & T & LB & UB & gap & status & totalTime \\\\")

    close(out)

    return
end

function setupRFFOStatsFile(statsFile::String,
    rfParams::RFFOParameters, formulation::String)

    out = open(statsFile,"w")
    println(out, "Formulation: ", formulation)
    println(out, "Approach: Relax-and-fix")
    println(out, "Relax-and-fix time limit: ", rfParams.rfMaxTime)
    println(out, "Restricted model time limit: ", rfParams.restrictedModelMaxTime)
    println(out, "RF window size:",rfParams.rfWindowSize )
    println(out, "RF step size: ",rfParams.rfStep)
    println(out, "FO window size: ",rfParams.foWindowSize)
    println(out, "FO step size: ",rfParams.foStep)
    println(out, "MIP gap tolerance: ", rfParams.MIPgapTolerance)
    println(out, "Integer feasibility tolerance: ", rfParams.integerFeasibilityTolerance)
    println(out, "Number of threads: ", rfParams.numberOfThreads)
    println(out, "Screen output: ", rfParams.screenOutput)

    print(out, "\nInstance & I & T & rfUB & rfIter & rfBT & rfTime & foUB & foImprov & foIter & foRnds & foTime & status & totalTime \\\\")

    close(out)

    return
end

function setupRFOStatsFile(statsFile::String,
    rfParams::RFOParameters, formulation::String)

    out = open(statsFile,"w")
    println(out, "Formulation: ", formulation)
    println(out, "Approach: Relax-and-fix-and-Optimizer")
    println(out, "Relax-and-fix time limit: ", rfParams.rfMaxTime)
    println(out, "Restricted model time limit: ", rfParams.restrictedModelMaxTime)
    println(out, "RF window size:",rfParams.rfWindowSize )
    println(out, "RF step size: ",rfParams.rfStep)
    println(out, "FO window size: ",rfParams.foWindowSize)
    println(out, "FO step size: ",rfParams.foStep)

    println(out, "MIP gap tolerance: ", rfParams.MIPgapTolerance)
    println(out, "Integer feasibility tolerance: ", rfParams.integerFeasibilityTolerance)
    println(out, "Number of threads: ", rfParams.numberOfThreads)
    println(out, "Screen output: ", rfParams.screenOutput)

    print(out, "\nInstance & I & T & rfUB & rfIter & rfBT & rfTime & foUB & foImprov & foIter & foRnds & foTime & status & totalTime \\\\")

    close(out)

    return
end

function setupFOImprovementStatsFile(statsFile::String)
    out = open(statsFile,"w")

    print(out, "Instance & J & T & rfUB & rnd1_UB & rnd1_Imp & rnd1_Time & rnd2_UB & rnd2_Imp & rnd2_Time & rnd3_UB & rnd3_Imp & rnd3_Time & rnd4_UB & rnd4_Imp & rnd4_Time & rnd5_UB & rnd5_Imp & rnd5_Time & rnd6_UB & rnd6_Imp & rnd6_Time & rnd7_UB & rnd7_Imp & rnd7_Time & rnd8_UB & rnd8_Imp & rnd8_Time & rnd9_UB & rnd9_Imp & rnd9_Time & rnd10_UB & rnd10_Imp & rnd10_Time \\\\")

    close(out)

    return
end


function initStatsData!()
    approach = ""
    formulation = ""
    bestLB = -100000
    bestUB = 100000
    gap = 100
    rfUB = 100000
    rfIterations = 0
    rfTime = 0.0
    rfBacktrackAttempts = 0
    foUB = 100000
    foImprovement = 0.0
    foIterations = 0
    foRounds = 0
    foTime = 0.0
    totalTime = 0.0
    solStatus = 0

    stats = StatisticsData(approach,
                           formulation,
                           bestLB,
                           bestUB,
                           gap,
                           rfUB,
                           rfIterations,
                           rfTime,
                           rfBacktrackAttempts,
                           foUB,
                           foImprovement,
                           foIterations,
                           foRounds,
                           foTime,
                           totalTime,
                           solStatus)

    return stats
end

function printStats!(statsFile::String, data::InstanceData, stats::StatisticsData) 

    out = open(statsFile,"a")
       
    if stats.approach == "std" 

        print(out, "\n", data.instName, " & ",
        data.numItems, " & ",
        data.numPer, " & ",
        round(stats.bestLB, digits = 2), " & ",
        round(stats.bestUB, digits = 2), " & ",
        round(stats.gap, digits = 4), " & ",
        stats.solStatus, " & ",
        round(stats.totalTime, digits = 2), " \\\\")

    
    elseif stats.approach == "RFFO"
        print(out, "\n", data.instName, " & ",
            data.numItems, " & ",
            data.numPer, " & ",
            round(stats.rfUB, digits = 2), " & ",
            stats.rfIterations, " & ",
            stats.rfBacktrackAttempts, " & ",
            round(stats.rfTime, digits = 2), " & ",
            round(stats.foUB, digits = 2), " & ",
            round(stats.foImprovement, digits = 2), " & ",
            stats.foIterations, " & ",
            stats.foRounds, " & ",
            round(stats.foTime, digits = 2), " & ",
            stats.solStatus, " & ",
            round(stats.totalTime, digits = 2), " \\\\")

    elseif stats.approach == "RFO"
        print(out, "\n", data.instName, " & ",
                    data.numItems, " & ",
                    data.numPer, " & ",
                    round(stats.rfUB, digits = 2), " & ",
                    stats.rfIterations, " & ",
                    stats.rfBacktrackAttempts, " & ",
                    round(stats.rfTime, digits = 2), " & ",
                    round(stats.foUB, digits = 2), " & ",
                    round(stats.foImprovement, digits = 2), " & ",
                    stats.foIterations, " & ",
                    stats.foRounds, " & ",
                    round(stats.foTime, digits = 2), " & ",
                    stats.solStatus, " & ",
                    round(stats.totalTime, digits = 2), " \\\\")
    end

    close(out)

    return
end


end # module