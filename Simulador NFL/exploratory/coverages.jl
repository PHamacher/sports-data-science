include("exploratory/utils.jl")

df = CSV.read("Big Data Bowl/2023/week1.csv", DataFrame)

play = filter(x -> x.playId == df[1,:playId], df)

plot_play(df[1,:gameId], df[1,:playId], df)

plot_play(2021091210, 146, df)

