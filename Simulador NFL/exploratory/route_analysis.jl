include("utils.jl")

df = CSV.read("Futebol/Simulador NFL/Big Data Bowl/2021/week1.csv", DataFrame)
aux = CSV.read("Futebol/Simulador NFL/Big Data Bowl/2021/plays.csv", DataFrame)

my = filter(x -> !ismissing(x.route), df)
my = filter(x -> x.gameId == df[1,:gameId], my)
my_aux = filter(x -> x.gameId in my.gameId, aux)

my[!,:LoS] = [filter(x->x.playId==row.playId,my_aux)[1,:absoluteYardlineNumber] for row in eachrow(my)]
my[!,:x_adj] = [row.playDirection == "right" ? row.x-row.LoS : row.LoS-row.x for row in eachrow(my)]
my[!,:y_adj] = y_adj(my)

hitch = filter(x->x.route=="POST", my)
scatter(hitch.x_adj, hitch.y_adj)