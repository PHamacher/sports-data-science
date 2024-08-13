using Plots, Statistics, StatsBase
plotly()

generalized_mean(v) = isa(v[1], Real) ? mean(v) : mean(parse.(Float64, v))
generalized_mean(v,w) = isa(v[1], Real) ? mean(v,weights(w)) : mean(parse.(Float64, v), weights(w))

function plot_attributes(df_players::DataFrame, att1::String, att2::String; name1=nothing, name2=nothing, q::Float64=.99,
                            att3::String="Min_Playing.Time", name3="Minutes Played", min_minutes::Real=90*19)
    name1 = isnothing(name1) ? att1 : name1
    name2 = isnothing(name2) ? att2 : name2

    players = groupby(filter(x -> length(intersect([x[att1], x[att2]], ["NA", missing])) == 0, df_players), [:Url, :Player])
    data = combine(players, [att1,"Min_Playing.Time"]  => generalized_mean, [att2, "Min_Playing.Time"] => generalized_mean,
                            [att3, "Min_Playing.Time"] => generalized_mean,"Min_Playing.Time" => sum)
    filter!(x -> x[end] >= min_minutes, data)

    z = att3 == "Min_Playing.Time" ? data[:,end] : data[:,5]

    scatter(data[:,3], data[:,4], marker_z = z, color = cgrad(:lightrainbow), label = name3,
        xlabel = name1, ylabel = name2, title = "Brasileirão (2019-2022)", hover = data.Player,
        series_annotations = text.([pl[3] >= quantile(data[:,3], q) || pl[4] >= quantile(data[:,4], q) ? pl[2] : "" for pl in eachrow(data)], 5, :bottom))
end

plot_attributes(df_players, "Dis_Carries", "npxG+xAG_Expected", name1 = "Lost balls", name2 = "Expected Goals + Assists")
plot_attributes(df_players, "Dis_Carries", "xA", name1 = "Lost balls")
plot_attributes(df_players, "Dis_Carries", "SCA_SCA", name1 = "Lost balls", name2 = "Shots Created")
plot_attributes(df_players, "Save_percent", "PSxG+_per__minus__Expected", name1 = "Save %", name2 = "xG - Goals", att3="CS", name3 = "Clean Sheets")
plot_attributes(df_players, "Att_Long", "Cmp_percent_Long", name1 = "Long Passes Attempted", name2 = "Long Passes %")
plot_attributes(df_players, "Att_Dribbles", "Succ_percent_Dribbles", name1 = "Dribbles Attempted", name2 = "Dribbles %")
plot_attributes(df_players, "xG_Expected", "Gls", name1 = "xG", name2 = "Goals"); plot!(1:30,1:30)
plot_attributes(df_players, "Past_Vs", "Succ_Pressures", name1 = "Dribbled", name2 = "Pressures")
plot_attributes(df_players, "Past_Vs", "Tkl+Int", name1 = "Dribbled", name2 = "Tackles + Interceptions")
plot_attributes(df_players, "Tkl+Int", "SCA_SCA", name1 = "Tackles + Interceptions", name2 = "Shots Created")
plot_attributes(df_players, "Won_Aerial", "Won_percent_Aerial", name1 = "Aerials Won", name2 = "Aerials %")
plot_attributes(df_players, "Tkl_percent_Vs", "Won_percent_Aerial", name1 = "Duels %", name2 = "Aerials %") # CBs
plot_attributes(df_players, "Tkl+Int", "CrsPA", name1 = "Tackles + Interceptions", name2 = "Crosses in area") # LATs
plot_attributes(df_players, "", "Tkl+Int", name1 = "Pressures", name2 = "Tackles + Interceptions") # CDMs
plot_attributes(df_players, "Succ_Dribbles", "SCA_SCA", name1 = "Dribbles", name2 = "Shots Created") # Wingers
plot_attributes(df_players, "Won_percent_Aerial", "G_minus_xG_Expected", name1 = "Aerials %", name2 = "Exceeding Goals") # Strikers

# time lançamentos
plot_attributes(df_players, "Won_percent_Aerial", "Succ_percent_Dribbles", name1 = "Aerials %", name2 = "Dribbles %")
plot_attributes(df_players, "Won_percent_Aerial", "Mid 3rd_Pressures", name1 = "Aerials %", name2 = "Pressures")
plot_attributes(df_players, "Won_percent_Aerial", "xA", name1 = "Aerials %", name2 = "Goals")



# per game
df_per_game = DataFrame(x,nms)
df_per_game.Player = df.Player
df_per_game[!,"Min_Playing.Time"] = df[:,"Min_Playing.Time"]
df_per_game.Url = df.Url
plot_attributes(df_per_game, "Tkl+Int", "SCA_SCA", name1 = "Tackles + Interceptions per game", name2 = "Shots Created per game")
plot_attributes(df_per_game, "Dis_Carries", "SCA_SCA", name1 = "Lost balls per game", name2 = "Shots Created per game")
plot_attributes(df_per_game, "Succ_percent_Take_Ons", "TO_SCA_Types", name1 = "Dribble %", name2 = "Shots Created via Dribble per game",
                att3 = "Dis_Carries", name3 = "Lost balls per game")
plot_attributes(df_per_game, "Cmp_Long", "Cmp_percent_Long", name1 = "Long Passes per game", name2 = "Long Passes %")
plot_attributes(df_per_game, "Past_Vs", "Tkl+Int", name1 = "Dribbled per game", name2 = "Tackles + Interceptions per game")
plot_attributes(df_per_game, "PrgDist_Carries", "PrgDist_Total", name1 = "Progressive carries per game (m)",
                name2 = "Progressive passes per game (m)", att3 = "Tkl+Int", name3 = "Tackles + Interceptions per game")
plot_attributes(df_per_game, "Past_Vs", "Succ_Pressures", name1 = "Dribbled", name2 = "Pressures", att3 = "Tkl+Int", name3 = "Tackles + Interceptions per game")
plot_attributes(df_per_game, "Def 3rd_Tackles", "Att 3rd_Tackles", name1 = "Defensive", name2 = "Attacking", att3 = "Mid 3rd_Tackles", name3 = "Midfield")
plot_attributes(df_per_game, "Tkl+Int", "Recov", name1 = "Tackles + Interceptions per game", name2 = "Recoveries per game", att3 = "Lost_Challenges", name3 = "Dribbled per game")

plot_attributes(df_per_game, "Prog", "Cmp_percent_Total", name1 = "Progressive passes per game", name2 = "Pass %", att3 = "Def 3rd_Pressures", name3 = "Defensive pressures per game") # jorginho
plot_attributes(df_per_game, "PrgP", "Cmp_percent_Total", name1 = "Progressive passes per game", name2 = "Pass %", att3 = "Def 3rd_Tackles", name3 = "Defensive tackles per game") # jorginho
plot_attributes(df_per_game, "Cmp_percent_Medium", "KP", name1 = "Medium passes %", name2 = "Key passes per game", att3 = "Final_Third", name3 = "Final third passes per game", q=1.) # camisa 10
plot_attributes(df_per_game, "Tkl_Vs", "Won_Aerial", name1 = "Tackle %", name2 = "Aerials won per game", att3 = "Mid 3rd_Tackles", name3 = "Midfield tackles per game", q=1.) # lateral-âncora
plot_attributes(df_per_game, "Succ_Dribbles", "CrsPA", name1 = "Dribbles per game", name2 = "Crosses per game", att3 = "Def 3rd_Tackles", name3 = "Defensive tackles per game", q=1.) # lateral ofensivo
plot_attributes(df_per_game, "Succ_Dribbles", "Prog_Receiving", name1 = "Dribbles per game", name2 = "Receiving per game (m)", att3 = "Drib_SCA", name3 = "Dribble-created shots per game", q=1.) # pontinha

plot_attributes(df_per_game, "G_per_Sh_Standard", "G_minus_xG_Expected", name1 = "Goals per shot", name2 = "Goals - xG", att3 = "Gls", name3 = "Goals", q=1.)
plot_attributes(df_per_game, "Tkl_percent_Challenges", "Won_percent_Aerial_Duels", name1 = "Tackle %", name2 = "Aerials %", att3 = "Tkl+Int", name3 = "Tackles + Interceptions per game", q=1.)



# teams
# criar um índice de 'surpresa' PPM vs valor do elenco (transfermarkt)

own, opp = groupby(filter(x -> x.Mins_Per_90 >= 34, df_teams), :Team_or_Opponent)

scatter(own.xG_Per, opp.xG_Per, marker_z = own[:,"PPM_Team.Success"], color = cgrad(:lightrainbow), label = "PPM", xlabel = "Team xG",
         ylabel = "Opponent xG", title = "Big 5 leagues (2018-2022)", hover = ["$(l["Squad"]) $(l["Season_End_Year"])" for l in eachrow(own)])

scatter(parse.(Int64, own[:,"Def 3rd_Pressures"]), parse.(Int64, own[:,"Att 3rd_Pressures"]), marker_z = own[:,"PPM_Team.Success"], color = cgrad(:lightrainbow), label = "PPM",
        xlabel = "Defensive Pressures", ylabel = "Attacking Pressures", title = "Big 5 leagues (2018-2022)", hover = ["$(l["Squad"]) $(l["Season_End_Year"])" for l in eachrow(own)])







# quantiles


gp_players = groupby(df_per_game, :Player)
players_avg = combine(gp_players, valuecols(gp_players) .=> mean)

rankings = DataFrame(hcat(players_avg.Player, hcat([invperm(sortperm(col)) for col in eachcol(players_avg)[2:end]]...)), names(players_avg))


function player_strengthes(r::DataFrameRow)
    idx = sortperm(Array(r[2:end]))
    return names(r)[2:end][idx]
end

name = "Aaron Wan-Bissaka"
idx_player = findfirst(x->x==name, rankings.Player)
main_stats = names(rankings[idx_player, player_strengthes(rankings[idx_player,:])][end-2:end])
scatter(players_avg[:,main_stats[1]], players_avg[:,main_stats[1]], marker_z = players_avg[:,main_stats[3]], color = cgrad(:lightrainbow), label = main_stats[3],
        xlabel = main_stats[1], ylabel = main_stats[2], title = "Similarity to $name", hover = players_avg.Player)



# PCA

using MultivariateStats

transposed = transpose(Matrix(players_avg[:,2:end]))
M = fit(PCA, transposed)

principalvars(M) ./ tvar(M) * 100
[names(players_avg)[2:end][findall(x -> x >= quantile(col, .95), col)] for col in eachcol(projection(M))]

transformed = MultivariateStats.transform(M, transposed)

scatter(transformed[1,:], transformed[2,:], marker_z = transformed[3,:], color = cgrad(:lightrainbow), label = "PC3",
        xlabel = "PC1", ylabel = "PC2", hover = players_avg.Player)





# Plus-minus
using CSV, DataFrames, Plots
df = CSV.read("Futebol/fbref data/Big 5/2023/player_playing_time.csv", DataFrame)
rename!(df, "plus_per__minus_90_Team.Success" => "Team+-", "On_minus_Off_Team.Success" => "Dif")

df = CSV.read("Futebol/fbref data/Brasileirão/2022/playing_time.csv", DataFrame)
rename!(df, "Plus_Minus90_Team_Success" => "Team+-", "On_minus_Off_Team_Success" => "Dif")

filter!(x -> x["Team+-"] != "NA" && x["Dif"] != "NA", df)
df[!,"Team+-"] = parse.(Float64, df[:,"Team+-"])
df[!,"Dif"] = parse.(Float64, df[:,"Dif"])


scatter(df[:,"Dif"], df[:,"Team+-"], series_annotations = text.(df.Player,8,:bottom))
scatter(df[:,"Dif"], df[:,"Team+-"], legend = false)

scatter(df[:,"Dif"], df[:,"Team+-"], series_annotations = text.(df.Player,8,:bottom), xlim = (-40,100), ylim = (-40,100))
scatter(df[:,"Dif"], df[:,"Team+-"], series_annotations = text.(df.Player,8,:bottom), xlim = (80,100), ylim = (80,100))




# regressão plus minus
using GLM, CSV, DataFrames, Lasso
df = CSV.read("Futebol/fbref data/Big 5/2022 - all years/all_players.csv", DataFrame)[1:16125,:]
# df = CSV.read("Futebol/fbref data/Big 5/2023/all_players.csv", DataFrame)

filter!(x -> !ismissing(x.Pos), df)
df_pos = filter(x -> x.Pos == "FW", df)

idx2022 = vcat(11:33, 35:50, 95:159, 182:224) # , 232:247
idx2023 = vcat(11:26, 28:43, 87:139, 162:200, 209:228)

reg_mtx = Matrix(df_pos[:,idx2022])
replace!(reg_mtx, "NA" => 0)
X = [(isa(el,AbstractString) ? parse(Float64, el) : Float64(el)) for el in reg_mtx]
Y = parse.(Float64, df_pos[:,"plus_per__minus__Team.Success"])
Y = parse.(Float64, df_pos[:,"onG_Team.Success"])
Y = parse.(Float64, df_pos[:,"onGA_Team.Success"])

# df_reg = df_reg[:, findall(x->!ismissing(x) && x!="NA",df_reg[1,:])]
# dropmissing!(df_reg)
# filter!(x -> !("NA" in x), df_reg)
# Y = Float64.(df_reg[:,"plus_per__minus__Team.Success"])
# X = [(isa(df_reg[1,col], AbstractString) ? parse.(Float64, df_reg[:,col]) : Float64.(df_reg[:,col])) for col in setdiff(names(df_reg), vcat("plus_per__minus__Team.Success", "Url"))]

reg = lm(hcat(ones(size(X, 1)), X), Y)

lasso = fit(LassoModel, X, Y)

# várias variáveis totalmente correlacionadas (tackle por lugar do campo e total de tackles, vários de gols por chute, etc)
# tem que remover
findall(x->x>.9,cor(X)) # fazer um grafo disso pra ver os grupos correlacionados

using Graphs, GraphRecipes, Plots
dfCor = cor(X)
cutoff = 0.95
g = Graph(size(dfCor,1))

idxs = findall(x -> x >= cutoff, dfCor)

for idx in idxs
    x,y = idx[1], idx[2]
    if x > y
        add_edge!(g, x, y)
    end
end

lens = length.(connected_components(g))

graphplot(g, curves=false, fontsize = 5, linewidth=1, nodesize = 0.05, nodeshape=:circle, title = "Cutoff = $cutoff", method = :spring)

println([(count(x -> x == el, lens), el) for el in sort(unique(lens))])



data22 = CSV.read("Matérias PUC/23.1/prog mat/projeto/dados/dados2022.csv", DataFrame)[:,[:Url, :Value]]

joined = innerjoin(df, data22, on = [:Url])
# rename!(joined, "plus_per__minus_90_Team.Success" => "Team", "On_minus_Off_Team.Success" => "Dif")
joined[!,:Team] = parse.(Float64, joined[:,"plus_per__minus_90_Team.Success"])
joined[!,:Dif] = map(x -> x == "NA" ? 0 : parse(Float64, x), joined[:,"On_minus_Off_Team.Success"])
filter!(x -> !ismissing(x.Age), joined)
joined[!,:Age] = map(x -> occursin('-',x) ? parse(Int64, x[1:2]) + parse(Int64, x[4:end])/365 : parse(Float64,x), joined.Age)
filter!(x -> 500/38 <= x["Min_percent_Playing.Time"] <= 3300/38, joined)
reg = lm(@formula(Value ~ Team + Dif + Age), joined)
reg = lm(@formula(Value ~ Dif + Age), joined)


scatter(joined.Team, joined.Dif, marker_z = joined.Value, color = cgrad(:lightrainbow), series_annotations = text.(map(x->split(x,' ')[end],joined.Player),8, :bottom))


