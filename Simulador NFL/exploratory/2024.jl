using CSV, DataFrames

function plot_play(gameId, playId, df) # criar método já passando o df filtrado
    my = filter(x -> x.gameId == gameId && x.playId == playId, df)
    for frame in 1:maximum(my.frameId)
        f = filter(x -> x.frameId == frame, my)
        scatter(f.x, f.y, legend = false, bg = :green,
        color = [f[i,:club] == my[1,:club] ? :red : f[i,:club] != "football" ? :blue : :orange for i in 1:size(f,1)])

        display(vline!([floor(minimum(f.x/10)*10):5:ceil(minimum(f.x/10)*10)], color = :white))
    end
end

df = CSV.read("Futebol/Simulador NFL/Big Data Bowl/2024/tracking_week_1.csv", DataFrame)

play = filter(x -> x.playId == df[1,:playId], df)

plot_play(df[end,:gameId], df[end,:playId], df)
