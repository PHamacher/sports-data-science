function plot_play(gameId, playId, df) # ajeitar de df pra structs
    my = filter(x -> x.gameId == gameId && x.playId == playId, df)
    for frame in 1:maximum(my.frameId)
        f = filter(x -> x.frameId == frame, my)
        scatter(f.x, f.y, legend = false, bg = :green,
        color = [f[i,:team] == my[1,:team] ? :red : f[i,:team] != "football" ? :blue : :orange for i in 1:size(f,1)])

        display(vline!([floor(minimum(f.x/10)*10):5:ceil(minimum(f.x/10)*10)], color = :white))
    end
end

distance(row::DataFrameRow, df::DataFrame) = [(row.x-r.x)^2 + (row.y-r.y)^2 for r in eachrow(df)]# ajeitar de df pra structs
distance(row::DataFrame, df::DataFrame) = distance(row[1,:], df)# ajeitar de df pra structs

sideline_separation() = algo