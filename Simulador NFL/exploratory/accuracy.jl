include("utils.jl")

df = CSV.read("Futebol/Simulador NFL/Big Data Bowl/2023/week1.csv", DataFrame)
roles = CSV.read("Futebol/Simulador NFL/Big Data Bowl/2023/pffScoutingData.csv", DataFrame)
plays = CSV.read("Futebol/Simulador NFL/Big Data Bowl/2023/plays.csv", DataFrame)
games = CSV.read("Futebol/Simulador NFL/Big Data Bowl/2023/games.csv", DataFrame)
players = CSV.read("Futebol/Simulador NFL/Big Data Bowl/2023/players.csv", DataFrame)

w1 = filter(x -> x.week == 1, games)
filter!(x -> x.gameId in w1.gameId, plays)
filter!(x->occursin(" to ",x.playDescription),plays) # conferir se eu devia estar descartando mesmo
filter!(x -> x.foulName1 == "NA", plays) # algumas faltas/situações poderiam ser mantidas

distance(row::DataFrameRow, df::DataFrame) = [(row.x-r.x)^2 + (row.y-r.y)^2 for r in eachrow(df)]
distance(row::DataFrame, df::DataFrame) = distance(row[1,:], df)

transform_name(name::AbstractString) = name[1] * '.' * name[findfirst(x->x==' ', name)+1:end]
dict_names = Dict(["$(row.nflId)" => transform_name(row.displayName) for row in eachrow(players)])

qb_speed, time_throw, rush_sep, air_dist, target_sep, side_sep, compl, idxs = Float64[], Float64[], Float64[], Float64[], Float64[], Float64[], Int64[], Int64[]
current_game, game = nothing, nothing
@time(
for (i,row) in enumerate(eachrow(plays))
    if current_game != row.gameId
        game = filter(x -> x.gameId == row.gameId, df)
        current_game = row.gameId
    end

    play = filter(x -> x.playId == row.playId && x.event == "pass_forward", game)
    size(play,1) == 0 && continue # log cortado antes do passe
    play_roles = filter(x->x.gameId == row.gameId && x.playId == row.playId, roles)
    f = filter(x->x.event == "pass_forward",play)

    rec = filter(x-> startswith(split(row.playDescription, " to ")[2], get(dict_names,x.nflId,"NA")), play)
    if size(rec,1) == 1
        rec = rec[1,:]
    else
        continue
    end

    id_qb = filter(x -> x.pff_role == "Pass", play_roles).nflId[1]
    qb = filter(x->x.nflId == "$(id_qb)", f)
    push!(qb_speed, qb.s[1])

    push!(time_throw, f[1,:frameId])

    id_pr = filter(x -> x.pff_role == "Pass Rush", play_roles).nflId
    pr = filter(x->x.nflId in ["$id" for id in id_pr], f)
    push!(rush_sep, minimum(distance(qb, pr)))

    push!(air_dist, distance(rec, qb)[1])

    def = filter(x -> !(x.team in [qb.team[1], "football"]), play)
    push!(target_sep, minimum(distance(rec, def)))

    push!(side_sep, min(53.3-rec.y, rec.y))

    push!(compl, row.passResult == "C")

    push!(idxs, i)
end
)

using GLM, MLBase

df_reg = DataFrame(compl=compl,qb_speed=qb_speed,time_throw=time_throw,rush_sep=rush_sep,air_dist=air_dist,target_sep=target_sep,side_sep=side_sep)
df_reg = hcat(df_reg, plays[idxs, vcat(4:6,10,25:32)])
df_reg[!,:is_fast] = [row.qb_speed > 3.91 for row in eachrow(df_reg)]

reg = glm(@formula(compl ~ qb_speed+time_throw+rush_sep+air_dist+target_sep+side_sep+side_sep^2), df_reg, Binomial(), ProbitLink())

X = hcat(ones(length(compl)), qb_speed, time_throw, rush_sep)
reg = glm(X, compl, Binomial(), ProbitLink())

reg = glm(@formula(compl ~ qb_speed+rush_sep+air_dist+target_sep+side_sep+side_sep^2), df_reg, Binomial(), ProbitLink())

reg = lm(Term(:compl) ~ sum(Term.(Symbol.(names(df_reg[:, Not(:compl)])))), df_reg)

reg = glm(@formula(compl ~ 0+qb_speed+rush_sep+air_dist+target_sep+side_sep+side_sep^2), df_reg, Binomial(), ProbitLink())

reg = glm(@formula(compl ~ qb_speed+rush_sep+air_dist+target_sep+side_sep+side_sep^2+is_fast+is_fast*qb_speed), df_reg, Binomial(), ProbitLink())
reg = glm(@formula(compl ~ 0+qb_speed+rush_sep+air_dist+target_sep+side_sep+side_sep^2+is_fast+is_fast*qb_speed), df_reg, Binomial(), ProbitLink())
reg = glm(@formula(compl ~ rush_sep+air_dist+target_sep+side_sep+side_sep^2+is_fast), df_reg, Binomial(), ProbitLink())
reg = glm(@formula(compl ~ 0+rush_sep+air_dist+target_sep+side_sep+side_sep^2+is_fast), df_reg, Binomial(), ProbitLink())

conf = MLBase.roc(compl, [x < 0.5 ? 0 : 1 for x in predict(reg)])
(conf.tp+conf.tn) / (conf.p+conf.n)

scatter(predict(reg), compl)


# ======================= write accuracy regression, anaylsis =======================
roles = CSV.read("Futebol/Simulador NFL/Big Data Bowl/2023/pffScoutingData.csv", DataFrame)
all_plays = CSV.read("Futebol/Simulador NFL/Big Data Bowl/2023/plays.csv", DataFrame)
games = CSV.read("Futebol/Simulador NFL/Big Data Bowl/2023/games.csv", DataFrame)
players = CSV.read("Futebol/Simulador NFL/Big Data Bowl/2023/players.csv", DataFrame)

df_all = DataFrame()
for week in 1:8
    df = CSV.read("Futebol/Simulador NFL/Big Data Bowl/2023/week$week.csv", DataFrame)
    w = filter(x -> x.week == week, games)
    plays = filter(x -> x.gameId in w.gameId, all_plays)
    filter!(x->occursin(" to ",x.playDescription), plays)
    filter!(x -> x.foulName1 == "NA", plays)
    dict_names = Dict(["$(row.nflId)" => transform_name(row.displayName) for row in eachrow(players)])
    qb_speed, time_throw, rush_sep, air_dist, target_sep, side_sep, compl, idxs = Float64[], Float64[], Float64[], Float64[], Float64[], Float64[], Int64[], Int64[]
    current_game, game = nothing, nothing
    for (i,row) in enumerate(eachrow(plays))
        if current_game != row.gameId
            game = filter(x -> x.gameId == row.gameId, df)
            current_game = row.gameId
        end
    
        play = filter(x -> x.playId == row.playId && x.event == "pass_forward", game)
        size(play,1) == 0 && continue
        play_roles = filter(x->x.gameId == row.gameId && x.playId == row.playId, roles)
        f = filter(x->x.event == "pass_forward",play)
    
        rec = filter(x-> startswith(split(row.playDescription, " to ")[2], get(dict_names,x.nflId,"NA")), play)
        if size(rec,1) == 1
            rec = rec[1,:]
        else
            continue
        end
    
        id_qb = filter(x -> x.pff_role == "Pass", play_roles).nflId[1]
        qb = filter(x->x.nflId == "$(id_qb)", f)
        push!(qb_speed, qb.s[1])
    
        push!(time_throw, f[1,:frameId])

        def = filter(x -> !(x.team in [qb.team[1], "football"]), play)
        push!(target_sep, minimum(distance(rec, def)))
    
        id_pr = filter(x -> x.pff_role == "Pass Rush", play_roles).nflId
        pr = filter(x->x.nflId in ["$id" for id in id_pr], f)
        if size(pr,1) > 0
            push!(rush_sep, minimum(distance(qb, pr)))
        else
            push!(rush_sep, minimum(distance(qb, def)))
        end
    
        push!(air_dist, distance(rec, qb)[1])
        
        push!(side_sep, min(53.3-rec.y, rec.y))
    
        push!(compl, row.passResult == "C")
    
        push!(idxs, i)
    end

    df_reg = DataFrame(compl=compl,qb_speed=qb_speed,time_throw=time_throw,rush_sep=rush_sep,air_dist=air_dist,target_sep=target_sep,side_sep=side_sep)

    df_all = vcat(df_all, df_reg)
end

CSV.write("Futebol/Simulador NFL/exploratory/reg passes.csv", df_all)


passes = CSV.read("Futebol/Simulador NFL/exploratory/reg passes.csv", DataFrame)

reg = glm(@formula(compl ~ 0+qb_speed+time_throw+rush_sep+air_dist+target_sep+side_sep+side_sep^2), passes, Binomial(), ProbitLink())
conf = MLBase.roc(passes.compl, [x < 0.5 ? 0 : 1 for x in predict(reg)])
(conf.tp+conf.tn) / (conf.p+conf.n)

pred = predict(reg)
closest_idxs = [findmin(abs.(p .- collect(.05:.05:.95)))[2] for p in pred]
passes_per_pred = [passes.compl[findall(x->x==i, closest_idxs)] for i in 1:19]
plot(collect(.05:.05:.95), collect(.05:.05:.95), legend = false, xlabel = "Completion Probability", ylabel = "Completion Percentage")
scatter!(collect(.05:.05:.95), mean.(passes_per_pred), markersize = length.(passes_per_pred) ./ 100)
