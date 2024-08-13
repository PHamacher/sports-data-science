using Dates
include("utils.jl")
df = filter(x->x.expectedPointsAdded != "NA", CSV.read("Big Data Bowl/2024/plays.csv", DataFrame))
games = CSV.read("Big Data Bowl/2024/games.csv", DataFrame)

dict_home = Dict([row.gameId => row.homeTeamAbbr for row in eachrow(games)])

df_reg = Matrix{Float64}[]
for row in eachrow(df)
    yd = 110 - row.absoluteYardlineNumber # conferir esse 110
    # restante = 60*hour(row.gameClock) + minute(row.gameClock) + 15*60*(4-row.quarter)
    restante = 60*hour(row.gameClock) + minute(row.gameClock) + (row.quarter in [1,3] ? 15*60 : 0)
    down = row.down
    distance = row.yardsToGo
    result = row.playResult
    at_home = row.possessionTeam == dict_home[row.gameId]
    if row.possessionTeam == dict_home[row.gameId]
        vantagem = row.preSnapHomeScore - row.preSnapVisitorScore
        win_prob = row.preSnapHomeTeamWinProbability
    else
        vantagem = row.preSnapVisitorScore - row.preSnapHomeScore
        win_prob = row.preSnapVisitorTeamWinProbability
    end
    ep = row.expectedPoints
    epa = parse(Float64, row.expectedPointsAdded)
    push!(df_reg, [yd restante down distance vantagem at_home result ep epa win_prob])
end
df_reg = DataFrame(vcat(df_reg...), [:yd, :restante, :down, :distance, :vantagem, :at_home, :result, :ep, :epa, :win_prob])

using GLM

reg = lm(@formula(win_prob ~ yd + restante + down + distance + vantagem), df_reg)

reg = lm(@formula(epa ~ yd + restante + down + distance + vantagem + result), df_reg)

reg = lm(@formula(ep ~ yd + restante + down + distance + vantagem), df_reg)

scatter(GLM.predict(reg), df_reg.ep)
plot!(-2:6,-2:6)


using XGBoost, Term

X, y = df_reg[setdiff(1:size(df_reg,1),idx_erros),[:restante, :yd, :at_home, :down, :distance]], df_reg[setdiff(1:size(df_reg,1),idx_erros),:ep]
bst = xgboost((X, y), num_round = 50, max_depth = 500)
maximum((predict(bst, X) .- y) .^ 2)
maximum((predict(bst, df_reg[:,[:restante, :yd, :at_home, :down, :distance]]) .- df_reg.ep) .^ 2)

# ,    eta = 0.025,
# gamma = 1,
# subsample = 0.8,
# colsample_bytree = 0.8,
# min_child_weight = 1)

# Panel(trees(bst)[1])



scatter(XGBoost.predict(bst, X), y)
plot!(-2:6,-2:6)


erros = (predict(bst, X) .- y) .^ 2
idx_erros = findall(x -> x > 0.5, erros)
df_erros = df_reg[sortperm(erros)[end-length(idx_erros)+1:end],:]
df_erros[!,:Pred] = predict(bst, X)[idx_erros]


XGBoost.save(bst, "Futebol/Simulador NFL/exploratory/xgboost.json")



df

predict(bst, [472. 41. 0. 1. 10.])
predict(bst, [462. 50. 0. 2. 1.])

predict(bst, [1405. 19. 1. 3. 8.])
predict(bst, [1365. 42. 1. 1. 10.])

predict(bst, [1126. 15. 0. 3. 4.])
predict(bst, [1090. 25. 0. 1. 10.])




using NearestNeighbors, LinearAlgebra

x_knn = Matrix(df_reg[:,[:yd, :restante, :down, :distance, :vantagem]])'
maxs, mins = maximum(x_knn, dims=2)[:,1], minimum(x_knn, dims=2)[:,1]
[x_knn[i,:] = (x_knn[i,:] .- mins[i]) ./ (maxs[i] - mins[i]) for i in 1:size(x_knn,1)]
tree = KDTree(x_knn)
knn_(tree, v, k) = knn(tree, (v .- mins) ./ (maxs .- mins), k)

idxs, dists = knn_(tree, [50, 60*22, 1, 10, 0], 10)
df_reg[idxs,:]

idxs, dists = knn_(tree, [90, 60*22, 3, 12, 0], 10)
df_reg[idxs,:]
