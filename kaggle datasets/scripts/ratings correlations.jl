using CSV, DataFrames

df = CSV.read("Futebol/Kaggle datasets/data_football_ratings.csv", DataFrame)
wc = filter(row -> row[:competition] == "World Cup 2018", df)

gp = groupby(df, [:match, :player])

sf, ws, ss, kc, gd, bd = [], [], [], [], [], []
for g in gp
    idx_sf = findfirst(row -> row[:rater] == "SkySports", eachrow(g))
    idx_ws = findfirst(row -> row[:rater] == "WhoScored", eachrow(g))
    idx_ss = findfirst(row -> row[:rater] == "SofaScore", eachrow(g))
    idx_kc = findfirst(row -> row[:rater] == "Kicker", eachrow(g))
    idx_gd = findfirst(row -> row[:rater] == "TheGuardian", eachrow(g))
    idx_bd = findfirst(row -> row[:rater] == "Bild", eachrow(g))
    push!(sf, (isnothing(idx_sf) ? missing : g[idx_sf, :original_rating]))
    push!(ws, (isnothing(idx_ws) ? missing : g[idx_ws, :original_rating]))
    push!(ss, (isnothing(idx_ss) ? missing : g[idx_ss, :original_rating]))
    push!(kc, (isnothing(idx_kc) ? missing : -2*g[idx_kc, :original_rating] + 12))
    push!(gd, (isnothing(idx_gd) ? missing : g[idx_gd, :original_rating]))
    push!(bd, (isnothing(idx_bd) ? missing : -2*g[idx_bd, :original_rating] + 12))
end

# correlation Matrix

using StatsBase
using Plots
using StatsPlots

names = ["SkySports", "WhoScored", "SofaScore", "Kicker", "TheGuardian", "Bild"]
x = [sf, ws, ss, kc, gd, bd]
for i in 1:6, j in 1:6
    idx_x = findall(!ismissing, x[i])
    idx_y = findall(!ismissing, x[j])
    idx = intersect(idx_x, idx_y)
    a = x[i][idx]
    b = x[j][idx]
    length(idx) > 0 && println(names[i], " ", names[j], " ", cor(a,b))
end

cor_matrix = cor([sf ws ss kc gd bd])
heatmap(cor_matrix, xticks = (1:4, ["SkySports", "WhoScored", "SofaScore", "Kicker"]), yticks = (1:4, ["SkySports", "WhoScored", "SofaScore", "Kicker"]), title = "Correlation Matrix", color = cgrad(:lightrainbow))