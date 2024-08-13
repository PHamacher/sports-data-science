using CSV, DataFrames

cd("Futebol/fbref data")

br21 = CSV.read("Brasileirão/2021/playing_time.csv", DataFrame)
br22 = CSV.read("Brasileirão/2022/playing_time.csv", DataFrame)

br21 = br21[findall(x -> !ismissing(x), br21[:,"On-Off"]),:]
br22 = br22[findall(x -> !ismissing(x), br22[:,"On-Off"]),:]

# br21 = br21[findall(x -> x >= 60, br21[:,"Min%"]),:]
# br22 = br22[findall(x -> x >= 60, br22[:,"Min%"]),:]

valid = intersect(br21[:,end], br22[:,end])

br21 = br21[findall(x -> x in valid, br21[:,"-9999"]),:]
br22 = br22[findall(x -> x in valid, br22[:,"-9999"]),:]

function stat_evolution(df1::DataFrame, df2::DataFrame, col_name::Union{String,Symbol}, valid_keys::Vector{String})
    v1, v2 = Float64[], Float64[]
    for key in valid_keys
        idx1, idx2 = findfirst(x -> x == key, df1[:,end]), findfirst(x -> x == key, df2[:,end])
        push!(v1, df1[idx1, col_name])
        push!(v2, df2[idx2, col_name])
    end
    return v1, v2
end

pm21, pm22 = stat_evolution(br21, br22, "On-Off", String.(valid))

using Plots

@assert valid == br21[:,end]

scatter(pm21, pm22, series_annotations = text.(br21.Player, 8, :bottom))

pct21 = [findfirst(x -> x == idx, sortperm(pm21))/length(pm21) for idx in 1:length(pm21)]
pct22 = [findfirst(x -> x == idx, sortperm(pm22))/length(pm22) for idx in 1:length(pm22)]

scatter(pct21, pct22, series_annotations = text.(br21.Player, 8, :bottom), legend = false)

idx_gk = findall(x -> occursin(x, "FW"), br21.Pos)
pct_gk21, pct_gk22 = pct21[idx_gk], pct22[idx_gk]
scatter(pct_gk21, pct_gk22, series_annotations = text.(br21[idx_gk, :Player], 8, :bottom), legend = false, ylim = (0,1), xlim = (0,1))

hline!([.5], line = :dash, color = :black)
vline!([.5], line = :dash, color = :black)

# -----------------------------------------------------
teste = CSV.read("Brasileirão/2022/playing_time.csv", DataFrame)

dict_files = Dict{String, DataFrame}()
for filename in first(walkdir("Brasileirão/2022"))[3]
    df_seasons = DataFrame[]
    for season in 2019:2022
        file = CSV.read("Brasileirão/$season/$filename", DataFrame)
        file[!, :Season] = repeat([season], size(file,1))
        push!(df_seasons, file)
    end
    dict_files[filename] = vcat(df_seasons...)
end

all_players_br = dict_files["misc.csv"]
for (k,v) in dict_files
    if k !== "misc.csv"
        if size(v,1) == 2964
            all_players_br = innerjoin(all_players_br, v, on = ["Player", "Season", "Squad", "Pos", "Age"], makeunique=true)
        else
            all_players_br = leftjoin(all_players_br, v, on = ["Player", "Season", "Squad", "Pos", "Age"], makeunique=true, matchmissing=:notequal)
        end
        @show k, size(all_players_br,1)
    end
end

all_players_br = all_players_br[:, Not(filter(x ->isdigit(x[end]) && x[end-1] == '_', names(all_players_br)))]

CSV.write("Brasileirão/all_players.csv", all_players_br)

# --------------

teste = CSV.read("Big 5/big5_team_playing_time.csv", DataFrame)
teste = CSV.read("Big 5/big5_player_standard.csv", DataFrame)
teste2 = CSV.read("Big 5/big5_player_playing_time.csv", DataFrame)

# 16139: defense, gca, passing, passing_types, possession
# keepers=2888, keepers_adv=1179
# misc=37894, playing_time=42652, shooting=37984, standard=38008

dict_file = Dict{String,DataFrame}()

for filename in first(walkdir("Big 5/2023"))[3][3:end]
    file = CSV.read("Big 5/2023/$filename", DataFrame)
    @show filename
    if occursin("player", filename) && size(file,1) == 16139
        dict_file["Player"] = haskey(dict_file, "Player") ? innerjoin(dict_file["Player"], file, on = ["Url", "Season_End_Year", "Squad"], makeunique=true) : file
    elseif occursin("player", filename) && size(file,1) != 16139
        dict_file["Player"] = haskey(dict_file, "Player") ? leftjoin(dict_file["Player"], file, on = ["Url", "Season_End_Year", "Squad"], makeunique=true) : @error("")
    elseif occursin("team", filename)
        dict_file["Team"] = haskey(dict_file, "Team") ? innerjoin(dict_file["Team"], file, on = ["Url", "Season_End_Year", "Team_or_Opponent"], makeunique=true) : file
    end
    @show size(dict_file["Player"]), size(file)
    GC.gc()
end

df_players = dict_file["Player"]
df_teams = dict_file["Team"]

df_players = df_players[:, Not(filter(x ->isdigit(x[end]) && x[end-1] == '_', names(df_players)))]
df_teams = df_teams[:, Not(filter(x ->isdigit(x[end]) && x[end-1] == '_', names(df_teams)))]

CSV.write("Big 5/all_players.csv", df_players)
CSV.write("Big 5/all_teams.csv", df_teams)

pct(s::AbstractString) = s == "NA" ? 0 : parse(Float64, s)/100
teste[!,"Min_percent_Playing.Time"] = pct.(teste[:,"Min_percent_Playing.Time"])

idx = findall(x -> x != "NA" && .5 <= pct(x) <= .95 ,teste[:,"Min_percent_Playing.Time"])

filter(x -> x[1] < 2023 && x[end] != "NA" && parse(Float64, x[4]) <= 90, sort(teste[idx,[2,3,5,13,26]], 5, rev=true))

# retirar colunas inúteis (_10, Column1)
# corrigir tamanho das planilhas de jogadores
# Lasso/NN pra prever sucesso do jogador/time
# stats por jogo (por causa da Bundesliga)

df_players = CSV.read("Big 5/all_players.csv", DataFrame)
df_players = CSV.read("Brasileirão/all_players.csv", DataFrame)
rename!(df_players, "Min_Playing_Time" => "Min_Playing.Time", "Season" => "Season_End_Year", "Plus_Minus90_Team_Success" =>
        "plus_per__minus_90_Team.Success", "Age" => "Born")
df_teams = CSV.read("Big 5/all_teams.csv", DataFrame)

using Lasso

function explanatory(df_players::DataFrame)
    vars = findall(x -> x in [String3, String7, Int64, Float64, Union{Missing, String3}, Union{Missing, String7}], eltype.(eachcol(df_players)))
    x = df_players[:,vars][:,Not(["plus_per__minus_90_Team.Success", "Nation", "Pos"])]

    types = eltype.(eachcol(df_players))
    x, names_ = DataFrame(), String[]
    for (i,col) in enumerate(eachcol(df_players))
        if types[i] in [Int64, Float64]
            push!(names_, names(df_players)[i])
            x = hcat(x, col)
            rename!(x, names_)
        elseif types[i] in [String3, String7] && length(intersect(map(x->x[1:1],col), ["$i" for i in 0:9])) > 0 # numerical only
            x = hcat(x, [el == "NA" ? 0 : parse(Float64, el) for el in col])
            push!(names_, names(df_players)[i])
            rename!(x, names_)
        # elseif types[i] in [Union{Missing, String3}, Union{Missing, String7}]
        end
    end

    x = x[:,findall(x -> x !== Missing, eltype.(eachcol(x)))]
    x = x[:, Not(unique(vcat(filter(x->length(x)>0,[findall(el->ismissing(el), x[i,:]) for i in 1:size(x,1)])...)))]
    x = x[:, Not(["Column1", "Season_End_Year"])]
    playing_time = x[:,"Min_Playing.Time"]
    del = ["playing.time", "starts", "subs", "team.success", "playing_time", "team.success"]
    x = x[:, Not(filter(n -> maximum(occursin.(del, lowercase(n))), names(x)))]

    # convert everything to per match
    keep = ["percent", "per", "90"]
    idx_per_match = findall(n -> !maximum(occursin.(keep, lowercase(n))), names(x))
    x[!,idx_per_match] = x[:,idx_per_match] ./ (playing_time/90)

    return Array{Float64}(x), names(x)
end

df = filter(x-> (x["MP_Playing_Time"] == "NA" ? 0 : parse(Int64, x["MP_Playing_Time"])) >= 17, df_players)
df = filter(x->x["MP_Playing.Time"] >= 5, df_players)

dict_coef = Dict{String, Vector{Float64}}()
scores = zeros(size(filter(x->x["MP_Playing.Time"] >= 17, df_players), 1))

for pos in ["DF", "MF", "FW"]
    df = filter(x->x["MP_Playing.Time"] >= 17 && startswith(pos, x["Pos"]), df_players)
    idx = findall(y->startswith(pos, y["Pos"]), eachrow(filter(x->x["MP_Playing.Time"] >= 17, df_players)))
    x, nms = explanatory(df)
    y = parse.(Float64, df[:,"plus_per__minus_90_Team.Success"])

    model = fit(LassoModel, x, y)

    # dict_coef[pos] = coef(model)

    scores[idx] = predict(model)
end

df.Score = scores

# function score(player::AbstractString, year::Int64, squad::AbstractString)
#     idx = findall(l -> l.Player == player && l.Season_End_Year == year && l.Squad == squad, eachrow(df))
#     @assert length(idx) == 1
#     idx = idx[1]

#     pos = df[idx, :Pos][1:2]
#     coefs = dict_coef[pos]
#     @show player, year, squad, pos
#     return sum(vcat(ones(1), x[idx,:]) .* coefs)
# end

# df.Score = [score(r.Player, r.Season_End_Year, r.Squad) for r in eachrow(df)]

scatter(df[:,"Min_Playing.Time"], df.Score, hover = ["$(l["Player"]) $(l["Season_End_Year"])" for l in eachrow(df)])


scatter(y, predict(model), hover = ["$(l["Player"]) $(l["Season_End_Year"])" for l in eachrow(df)]); plot!([-3,3], [-3,3])

1 - sum((predict(model)[i] - y[i])^2 for i in 1:size(x,1)) / sum((y[i] - mean(y))^2 for i in 1:size(x,1))
sort(DataFrame(hcat(nms, Lasso.coef(model)[2:end]), :auto), 2, rev=true)

using Statistics

string_mean(v) = mean(parse.(Float64, v))
players = groupby(filter(x -> x["Tkl+Int"] != "NA", df_players), :Player)
of_def = combine(players, "Tkl+Int" => string_mean, "SCA_SCA" => string_mean, "Min_Playing.Time" => sum)
filter!(x -> x[end] >= 5000, of_def)
scatter(of_def[:,"Tkl+Int_string_mean"], of_def[:,"SCA_SCA_string_mean"], marker_z = of_def[:,"Min_Playing.Time_sum"], color = cgrad(:lightrainbow), label = nothing,
        xlabel = "Tackles + Interceptions", ylabel = "Shots Created", title = "Big 5 leagues (2018-2022)",
        series_annotations = text.([pl[2] >= 120 || pl[3] >= 100 ? pl[1] : "" for pl in eachrow(of_def)], 5, :bottom))


player_seasons = groupby(filter(x -> x["On_minus_Off_Team.Success"] != "NA" && x["Min_percent_Playing.Time"] < 95, df_players), [:Player, :Season_End_Year])
plus_minus = combine(player_seasons, "plus_per__minus_90_Team.Success" => string_mean, "On_minus_Off_Team.Success" => string_mean, "Min_Playing.Time" => sum)
filter!(x -> x[end] >= 1530, plus_minus) # meia temporada de Bundesliga
scatter(plus_minus[:,"plus_per__minus_90_Team.Success_string_mean"], plus_minus[:,"On_minus_Off_Team.Success_string_mean"],
        marker_z = plus_minus[:,"Min_Playing.Time_sum"], color = cgrad(:lightrainbow), label = nothing,
                xlabel = "Team Success", ylabel = "Player Importance", title = "Big 5 leagues (2018-2022)",        
                series_annotations = text.([abs(pl[3]) > 3 || abs(pl[4]) > 3 ? "$(pl.Player), $(pl.Season_End_Year)" : "" for pl in eachrow(plus_minus)], 5, :bottom))





# --------- integrate with transfermarkt ------------------

# dict_url = Dict([row[2:8] => row.Url for row in eachrow(teste2)])

df["players"].url = map(x -> replace(x, "co.uk" => "com"), df["players"].url)

tm_fb = CSV.read("C:\\Users\\admin\\Downloads\\worldfootballR_data-master\\raw-data\\fbref-tm-player-mapping\\output/fbref_to_tm_mapping.csv", DataFrame)

# dict_fb_tm = Dict([row.UrlFBref => row.UrlTmarkt for row in eachrow(tm_fb)])
# map(x -> get(dict_fb_tm, x, ""), df_players.Url)

idx_players = intersect(findall(x -> x in df_players.Url, tm_fb.UrlFBref), findall(x -> x in df["players"].url, tm_fb.UrlTmarkt))

# for el in df_players[1,10:end]
#     try
#         el = parse(Float64, el)
#     catch
#     end
# end

mutable struct Player
    name::String
    birth::Union{Date, Missing}
    position::Union{String, Missing}
    nation::Union{String, Missing}
    stats::DataFrame
    valuations::DataFrame
end

function Player(tm_fb::DataFrameRow, df_fb::DataFrame, df_trm::DataFrame, df_vals::DataFrame)
    name, url_fb, url_tm, pos = tm_fb
    pos = ismissing(pos) ? pos : String(pos)

    stats = filter(x -> x.Url == url_fb, df_fb)
    # stats = df_plyr[:,10:end]
    nat = stats.Nation[end]
    nat = ismissing(nat) ? nat : String(nat)

    df_tm = filter(x -> x.url == url_tm, df_trm)
    @assert size(df_tm,1) == 1
    name, birth = df_tm.pretty_name[1], df_tm.date_of_birth[1]
    id_tm = df_tm.player_id[1]

    vals = filter(x -> x.player_id == id_tm, df_vals)

    return Player(name, birth, pos, nat, stats, vals)
end


@time players = [Player(row, df_players, df["players"], df["player_valuations"]) for row in eachrow(tm_fb[idx_players,:])]


df_per_game = DataFrame(x,nms)
df_per_game.Url = df.Url
df_per_game = hcat(df[:,2:6], df_per_game)



idx_players = intersect(findall(x -> x in df_per_game.Url, tm_fb.UrlFBref), findall(x -> x in df["players"].url, tm_fb.UrlTmarkt))
players = [Player(row, df_per_game, df["players"], df["player_valuations"]) for row in eachrow(tm_fb[idx_players,:])]

function value_per_year(player::Player)
    for year in unique(player.stats.Season_End_Year)

    end
    # return valorization and stats for each year (dict?)
end

function team_value(team, season)

end
