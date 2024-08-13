using CSV, DataFrames, Plots, Statistics

all_years = Dict{Int64, DataFrame}()

for i in 15:22
    df = CSV.read("fifa datasets/data/players_$i.csv", DataFrame)
    all_years[i] = df
end

cte = intersect([v.sofifa_id for (k,v) in all_years]...)


@time ovrs_cte = [[filter(x -> x.sofifa_id == id, all_years[i]).overall for i in 15:22] for id in cte]
ovrs_cte = [vcat(el...) for el in ovrs_cte]

last_age = [filter(x -> x.sofifa_id == id, all_years[22]).age[1] for id in cte]
ages = [collect(age-7:age) for age in last_age]

cte_names = [filter(x -> x.sofifa_id == id, all_years[22]).short_name[1] for id in cte]

n = 15
plot(ages[1:n], ovrs_cte[1:n], xlabel = "Idade", ylabel = "Overall", label = permutedims(cte_names[1:n]), legend = :bottomright)


# ------------------------------------ uniting years ---------------------------------------------

# vcat(1,3:105) -> remove urls
united = DataFrame(Matrix{Any}(undef,0,105), vcat(names(all_years[22])[vcat(1,3:105)], "fifa"))

for i in 15:22
    fifa = hcat(all_years[i][:,vcat(1,3:105)], repeat([i], size(all_years[i],1)))
    rename!(fifa, Dict(:x1 => :fifa))
    united = vcat(united, fifa)
end

CSV.write("fifa datasets/data/players_complete.csv", united)

# --------------------------------------------------------------------------------------
united = CSV.read("fifa datasets/data/players_complete.csv", DataFrame)

gp = groupby(united, :sofifa_id)


gp_age = groupby(united, :age)
per_age = sort(combine(gp_age, :overall => mean, :potential => mean),:age)

hist_age = sort(DataFrame(vcat([hcat(gp[1,:age],size(gp,1)) for gp in gp_age]...),[:age, :obs]),:age)

plot(hist_age.age, hist_age.obs)

plot(per_age.age, per_age.overall_mean, xlabel = "Idade", ylabel = "Overall", legend = false)
plot(per_age.age, per_age.potential_mean, xlabel = "Idade", ylabel = "Potencial", legend = false)


flop_index(df::SubDataFrame) = df[1,:potential] - maximum(df.overall)
flop_index(pot, ovr) = pot[1] - maximum(ovr)
df_flop = unique(combine(gp, :short_name => :name, [:potential, :overall] => flop_index, :age => :age, keepkeys=false))
sort!(df_flop, 2)

idx_flop = findlast(x->x>25,df_flop.age)
df_flop[idx_flop,:] # Liu Xinyu (cagada da EA)

idx_flop = findlast(x->x>25,df_flop[1:133869-1,:age])
df_flop[idx_flop,:]

idx_flop = findlast(x->x>25,df_flop[1:133869-1,:age])
df_flop[idx_flop,:]


df_flop_best = unique(combine(gp, :short_name => :name, [:potential, :overall] => flop_index, :age => :age))
sort!(df_flop_best, 3)
df_flop_best = df_flop_best[findall(x->x.sofifa_id in best_ids, eachrow(df_flop_best)),[2,3,4]]
idx_flop_best = findlast(x->x>25,df_flop_best.age)
df_flop_best[idx_flop_best,:]

df_flop_best[findall(x -> x.age>25, eachrow(df_flop_best)),:]


best_ids = united[findall(x -> x.overall >= 75, eachrow(united)), :sofifa_id]


# evolução por idade
#TODO: fazer por atributo, testar outras distribuições?
using Distributions

idades, evs = Int64[], Int64[]
for jogador in gp
    idades = vcat(idades, jogador.age[1:end-1])
    evs = vcat(evs, diff(jogador.overall))
end

dist_age(age::Int64) = evs[findall(x -> x==age, idades)]

histogram(dist_age(20))


mu, sigma, dists = Float64[], Float64[], []
for age in sort(unique(united.age))[1:29]
    x = dist_age(age) .+ 100
    dist = [Normal, LogNormal]
    teste = fit.(dist, Ref(x))

    # Winning Distributions
    teste[findmax(loglikelihood.(teste, Ref(x)))[2]]
    push!(dists, dist[findmax(loglikelihood.(teste, Ref(x)))[2]])
    push!(mu, teste[findmax(loglikelihood.(teste, Ref(x)))[2]].μ)
    push!(sigma, teste[findmax(loglikelihood.(teste, Ref(x)))[2]].σ)
end

plot(sort(unique(united.age))[1:20], mu[1:20])
plot(sort(unique(united.age))[1:20], sigma[1:20])


plot(sort(unique(united.age))[1:29],mean.(dist_age.(sort(unique(united.age))))[1:29])


# ------------------------------------------------------

united_olds = filter(row -> row.age > 25, united)

df_flop_olds = unique(combine(gp, :short_name => :name, [:potential, :overall] => flop_index, :pace => mean, :shooting => mean, :passing => mean, :dribbling => mean, :defending => mean, :physic => mean))
filter!(row -> row.sofifa_id in united_olds.sofifa_id && !ismissing(row.pace_mean), df_flop_olds)
sort!(df_flop_olds, 3)

cor(df_flop_olds.potential_overall_flop_index, df_flop_olds.pace_mean)
cor(df_flop_olds.potential_overall_flop_index, df_flop_olds.shooting_mean)
cor(df_flop_olds.potential_overall_flop_index, df_flop_olds.passing_mean)
cor(df_flop_olds.potential_overall_flop_index, df_flop_olds.dribbling_mean)
cor(df_flop_olds.potential_overall_flop_index, df_flop_olds.defending_mean)
cor(df_flop_olds.potential_overall_flop_index, df_flop_olds.physic_mean)


