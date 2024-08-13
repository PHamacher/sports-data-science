using CSV, DataFrames, Dates, Statistics

cd("Futebol")

files = readdir("transfermarkt data")

cd("transfermarkt data")

df = Dict{String,DataFrame}()

for file in files
    if endswith(file, ".csv")
        df[file[1:end-4]] = CSV.read(file, DataFrame)
    end
end

# mutable struct Player
#     name::String
#     birth::Union{Date, Missing}
#     position::Union{String, Missing}
# end

dict_players = Dict([row.player_id => Player(row.pretty_name, row.date_of_birth, row.sub_position) for row in eachrow(df["players"])])
dict_clubs = Dict([row.club_id => row.pretty_name for row in eachrow(df["clubs"])])
dict_leagues = Dict([row.competition_id => row.pretty_name for row in eachrow(df["competitions"])])

player_vals = groupby(df["player_valuations"], :player_id)


mutable struct Valorization
    age_begin::Float64
    age_end::Float64
    value_begin::Int64
    value_end::Int64
end

all_vals = Valorization[]

for player in player_vals
    birth = dict_players[player.player_id[1]].birth
    if !ismissing(birth)
        !issorted(player.date) ? player = sort(player, 1) : nothing
        ages = [Dates.value(dt - birth)/365.25 for dt in player.date]
        for i in 1:size(player,1)-1
            push!(all_vals, Valorization(ages[i], ages[i+1], player.market_value[i], player.market_value[i+1]))
        end
    end
end

# df_valorization = DataFrame(age_begin=map(x->x.age_begin, all_vals), age_end=map(x->x.age_end, all_vals), value_begin=map(x->x.value_begin, all_vals), value_end=map(x->x.value_end, all_vals))
df_valorization_abs = DataFrame(age_begin=map(x->floor(x.age_begin), all_vals), age_end=map(x->floor(x.age_end), all_vals),  value_begin=map(x->x.value_begin, all_vals), valorization_per_year=map(x -> (x.value_end-x.value_begin)/(x.age_end-x.age_begin), all_vals))
# df_valorization = DataFrame(age_begin=map(x->floor(x.age_begin), all_vals), valorization_per_year_pct=map(x -> (x.value_end-x.value_begin)/(x.age_end-x.age_begin)/x.value_begin, all_vals))
df_valorization_rel = DataFrame(age_begin=map(x->floor(x.age_begin), all_vals), value_begin=map(x->floor(x.value_begin), all_vals), valorization_per_year_pct=map(x -> (x.value_end-x.value_begin)/(x.age_end-x.age_begin)/x.value_begin, all_vals))

gp_val_abs = groupby(df_valorization_abs, :age_begin)
val_per_age_abs = combine(gp_val_abs, :valorization_per_year => mean)
sort!(val_per_age_abs, :age_begin)
scatter(val_per_age_abs.age_begin, val_per_age_abs.valorization_per_year_mean, xlabel = "Age", ylabel = "Mean absolute valorization (per year)")


gp_val_rel = groupby(df_valorization_rel, :age_begin)
val_per_age_rel = combine(gp_val_rel, :valorization_per_year_pct => mean)
sort!(val_per_age_rel, :age_begin)
scatter(val_per_age_rel.age_begin, val_per_age_rel.valorization_per_year_pct_mean, xlabel = "Age", ylabel = "Mean relative valorization (per year)")

# relativo parece mais consistente, pois absoluto tem uma subida após 30 anos (prov pq os jogadores bons aposentam mais tarde)


[mean(sort(gp_val[8], :value_begin)[i:i+1000,:valorization_per_year_pct]) for i in 1:1000:27722-1000]
[mean(sort(gp_val[8], :value_begin)[i:i+Int64(round(size(gp_val[8],1)/10)),:valorization_per_year]) for i in 1:Int64(round(size(gp_val[8],1)/10)):size(gp_val[8],1)-Int64(round(size(gp_val[8],1)/10))]
teste = groupby(df_valorization, [:age_begin, :value_begin])
scatter(gp_val[12].value_begin, gp_val[12].valorization_per_year_pct)
plot([mean(sort(gp_val[8], :value_begin)[i:i+1000,:valorization_per_year]) for i in 1:1000:27722-1000])



plot(legend = false, xlabel = "Quantil valor inicial", ylabel = "Valorização média", title = "Valorização absoluta por valor inicial")
[plot!([mean(sort(el, :value_begin)[i:i+Int64(round(size(el,1)/10)),:valorization_per_year]) for i in 1:Int64(round(size(el,1)/10)):size(el,1)-Int64(round(size(el,1)/10))]) for el in gp_val_abs[3:29]];
plot!()
# 25% mais valiosos possuem mudanças bem mais significativas
# parece que o bottom 75% pode ser considerado tudo a mesma coisa?


plot(legend = false, xlabel = "Quantil valor inicial", ylabel = "Valorização média (%)", title = "Valorização relativa por valor inicial")
[plot!([mean(sort(el, :value_begin)[i:i+Int64(round(size(el,1)/10)),:valorization_per_year_pct]) for i in 1:Int64(round(size(el,1)/10)):size(el,1)-Int64(round(size(el,1)/10))]) for el in gp_val_rel[3:29]];
plot!()

using Plots

function plot_player_valuation!(player::SubDataFrame)
    birth = dict_players[player.player_id[1]].birth
    ages = [Dates.value(dt - birth)/365.25 for dt in player.date]
    plot!(ages, player.market_value, legend = nothing, xlabel = "Age", ylabel = "Value (€)")
end

function plot_player_valuation!(gp::GroupedDataFrame{DataFrame})
    plot()
    [plot_player_valuation!(pl) for pl in gp]
    display(plot!())
end

function plot_diffs!(player::SubDataFrame)
    birth = dict_players[player.player_id[1]].birth
    ages = [Dates.value(dt - birth)/365.25 for dt in player.date[1:end-1]]
    difs = diff(player.market_value) ./ player.market_value[1:end-1]
    plot!(ages, difs, legend = nothing, xlabel = "Age", ylabel = "Valorization (%)")
end

function plot_diffs!(gp::GroupedDataFrame{DataFrame})
    plot()
    [plot_diffs!(pl) for pl in gp]
    display(plot!())
end

plot_player_valuation!(player_vals[1:50])
plot_diffs!(player_vals[1:50])

# evolução por idade
#   por dia? percentual ou absoluto? por faixa de valor?
# caraceterística de flops?
# perfil de contratação dos times (doméstico, ligas inferiores, idade...)
# valorização do jogador de acordo com os stats na temporada anterior


# dividir o all_vals em treinamento e teste (com cross-validation) e comparar qual o método de
#   'previsão' mais preciso (absoluto x relativo, dividir por faixa de valor ou não, GLM x rede neural x etc...)
# input da previsão: valor inicial, idade inicial, número de dias
# output: valor final


include("nn.jl")

df_nn = DataFrame(age_begin = map(x->x.age_begin,all_vals), value_begin = map(x->x.value_begin,all_vals),
                    days = map(x->x.age_end,all_vals) .- map(x->x.age_begin,all_vals), value_end = map(x->x.value_end,all_vals))


nn = Chain(Dense(3,7,relu), Dense(7,1,identity))
       
res = treina_rede(nn, df_nn[1:10,:], 5, 20)


nn_pred = [res[1](Array(row[1:3]))[1] for row in eachrow(df_nn)]

# previsão da rede neural + bootstrap




using GLM

model = lm(@formula(value_end ~ age_begin + value_begin + days), df_nn[1:10,:]) # pra aquecer
model = lm(@formula(value_end ~ age_begin + value_begin + days), df_nn)
coef(model)

scatter(df_nn.value_end, predict(model), label = "GLM")
scatter!(df_nn.value_end, nn_pred, label = "NN")
plot!(df_nn.value_end, df_nn.value_end)

mean(df_nn.value_end .- predict(model))
mean(df_nn.value_end .- nn_pred)

mean(abs.((df_nn.value_end .- predict(model)) ./ df_nn.value_end))






