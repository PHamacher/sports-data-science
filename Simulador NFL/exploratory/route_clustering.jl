include("utils.jl")

df = CSV.read("Futebol/Simulador NFL/Big Data Bowl/2021/week1.csv", DataFrame)
aux = CSV.read("Futebol/Simulador NFL/Big Data Bowl/2021/plays.csv", DataFrame)
sort!(df, [:gameId, :playId, :nflId, :frameId])

dict_LoS = Dict([[row.gameId, row.playId] => row.absoluteYardlineNumber for row in eachrow(aux)])
df[!,:LoS] = [dict_LoS[[row.gameId, row.playId]] for row in eachrow(df)]
df[!,:x_adj] = [row.playDirection == "right" ? row.x-row.LoS : row.LoS-row.x for row in eachrow(df)]
df[!,:y_adj] = y_adj(df)

gp = groupby(df, [:gameId, :playId])
cmb = combine(gp, :frameId => maximum)
few_frames = Dict([row => nothing for row in eachrow(unique(filter(x->x.frameId_maximum<48,cmb)[:,1:2]))])
filter!(x -> !haskey(few_frames, x[[:gameId, :playId]]), df)

wrs = filter(x -> !ismissing(x.route), df)

gp = groupby(wrs, [:gameId, :playId, :nflId])
gp = gp[findall(x->x==0,[count(x->ismissing(x), g[:,:x_adj]) for g in gp])]
@assert all([issorted(g.frameId) for g in gp])

# considerar velocidade, aceleração, etc
# mais do que 21 frames? repetir frame final pros mais curtos?
# remover frames pré-snap?

X = hcat([vcat(g[1:48,:x_adj], g[1:48,:y_adj]) for g in gp]...) # só x e y
X = hcat([vcat([g[1:48,col] for col in [:x_adj,:y_adj,:s,:a,:dis,:o,:dir]]...) for g in gp]...)
# X = hcat([vcat(g[findfirst(x->x=="ball_snap",g.event):21,:x_adj], g[findfirst(x->x.event=="ball_snap",g):21,:y_adj]) for g in gp]...)

vline([0],legend=false); [scatter!(X[1:48,i], X[49:end,i]) for i in 1:100]; hline!([26.65])

using Clustering, Distances, Statistics
v = Float64[]
for k in 2:50
    cl = kmeans(X, k)

    dists = pairwise(SqEuclidean(), X)
    push!(v, mean(silhouettes(cl.assignments, dists)))
end

plot(2:50, v)

plot(); [scatter!(cl.centers[1:48,i], cl.centers[49:96,i]) for i in 1:k]; plot!()

df_routes = DataFrame(Route = [g[1,:route] for g in gp], Cluster = cl.assignments)
scatter(cl.assignments, [g[1,:route] for g in gp])

[display(histogram(filter(x -> x.Route == route, df_routes).Cluster, bins=k, title=route)) for route in unique(df_routes.Route)]






f1 = filter(x->x.frameId==1,wrs)
histogram(f1.y_adj)












gp_routes = groupby(wrs, :route)

