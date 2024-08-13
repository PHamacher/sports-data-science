include("utils.jl")

df = CSV.read("Futebol/Simulador NFL/Big Data Bowl/2023/week1.csv", DataFrame)
aux = CSV.read("Futebol/Simulador NFL/Big Data Bowl/2023/pffScoutingData.csv", DataFrame)
aux2 = CSV.read("Futebol/Simulador NFL/Big Data Bowl/2023/plays.csv", DataFrame)

my = filter(x -> x.playId == 2032, df)
my = filter(x -> x.gameId == df[1,1] && x.team == "TB", df)
my_aux = filter(x -> x.playId in my.playId && x.gameId in my.gameId, aux)
my_aux2 = filter(x -> x.playId in my.playId && x.gameId in my.gameId, aux2)


my[!,:LoS] = [parse(Int64, filter(x->x.playId==row.playId,my_aux2)[1,:absoluteYardlineNumber]) for row in eachrow(my)]
my[!,:x_adj] = [row.playDirection == "right" ? row.x-row.LoS : row.LoS-row.x for row in eachrow(my)]
my[!,:y_adj] = y_adj(my)


f1 = filter(x -> x.frameId == 1, my)

for frame in 1:maximum(my.frameId)
    f = filter(x -> x.frameId == frame, my)
    scatter(f.x, f.y, legend = false, bg = :green,
            color = [f[i,:team] == "TB" ? :white : f[i,:team] == "DAL" ? :blue : :orange for i in 1:23])
    display(vline!([35:5:65], color = :white))
end


wrs_jerseys = string.(filter(y->y.pff_role == "Pass Route", my_aux).nflId)
wrs = filter(x -> x.nflId in wrs_jerseys, my)

vline([0:5:100], color = :white, bg = :green, legend = false)
scatter!(wrs.x_adj, wrs.y)


scatter(wrs.x_adj, wrs.y, marker_z = wrs.s, color = cgrad(:lightrainbow))
vline!([0])

godwin = filter(x -> x.nflId == "44896", my)
scatter(godwin.x_adj, godwin.y, color = godwin.playId)
