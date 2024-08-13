using Distributions

include("passing.jl")
include("pass_rush.jl")
include("routes.jl")
include("running.jl")
include("structs.jl")
include("utils.jl")


function play()
    if rand() < .58
        return pass(), :Pass
    else
        return rush(nothing), :Run
    end
end

function drive(yd, team)
    firstdown_line = yd + 10
    down = 1
    logs = PlayLog[]
    while yd < 100 && down < 4
        gain, type = play()
        gain = Int64(round(gain, digits=0))
        push!(logs, PlayLog(team, yd, down, firstdown_line-yd, type, gain))
        yd += gain
        if yd > firstdown_line
            firstdown_line = yd+10
            down = 1
        else
            down += 1
        end
    end

    if yd >= 100
        points = 7
        yd = 75
    elseif yd > 66
        points = 3
        yd = 75
    else
        points = 0
        yd = min(99, yd+50)
    end
    return points, yd, logs
end

function game(team1, team2)
    yd = 75
    score = [0,0]
    game_log = PlayLog[]
    for i in 1:10
        yd = 100-yd
        points, yd, logs = drive(yd, team1)
        score[1] += points
        game_log = vcat(game_log, logs)
        yd = 100-yd
        points, yd, logs = drive(yd, team2)
        score[2] += points
        game_log = vcat(game_log, logs)
    end
    return score, game_log
end


gm = game("a", "b")






drive(25)

p = [pass() for i in 1:10^6]
runs = [rush(nothing) for i in 1:10^6]
plays = [play() for i in 1:10^6]

rotas = routes(collect(0:.1:4))

v = [passrush() for i in 1:10^6]
mean(v)

using Plots
histogram(v)

