using CSV, DataFrames, Plots

function y_adj(df::DataFrame)
    adj = Float64[]
    initial_y = 0
    for row in eachrow(df)
        row.frameId == 1 && (initial_y = row.y)
        push!(adj, initial_y < 53.3/2 ? row.y : 53.3-row.y)
    end
    return adj
end

function plot_play(gameId, playId, df) # criar método já passando o df filtrado
    my = filter(x -> x.gameId == gameId && x.playId == playId, df)
    for frame in 1:maximum(my.frameId)
        f = filter(x -> x.frameId == frame, my)
        scatter(f.x, f.y, legend = false, bg = :green,
        color = [f[i,:team] == my[1,:team] ? :red : f[i,:team] != "football" ? :blue : :orange for i in 1:size(f,1)])

        display(vline!([floor(minimum(f.x/10)*10):5:ceil(minimum(f.x/10)*10)], color = :white))
    end
end
