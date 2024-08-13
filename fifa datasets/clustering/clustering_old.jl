# TODO: incluir outros atributos (altura, weak foot, skills, workrate, pé bom, traits)?
# fuzzy clustering?




# --------------------------- determinando k ---------------------------

using Distances, Statistics

# dists = pairwise(SqEuclidean(), normalizado) # custoso

mean(silhouettes(cl.assignments, dists))

sils = Float64[]
for k in 2:20
    cl = kmeans(normalizado, k)
    push!(sils, mean(silhouettes(cl.assignments, dists)))
end

using Plots
plot(2:20, sils)

# --------------------------------------------
cl = kmeans(normalizado, 7)
df_cluster = DataFrame(hcat(df[idx_no_gk,:short_name], df[idx_no_gk,:club_name], df[idx_no_gk,:club_position], cl.assignments), [:name, :club, :position, :cluster])
gp_cluster = groupby(df_cluster, :cluster)

filter!(x -> !ismissing(x.position) && !(x.position in ["RES", "SUB"]), df_cluster)

teams = groupby(df_cluster, :club);
esquemas = [sort(team[:,[3,4]], 1) for team in teams];
length(esquemas), length(unique(esquemas))
repetidos = [k for (k, v) in countmap(esquemas) if v > 1]
idx_repetidos = findall(x -> x in repetidos, esquemas)
teams[idx_repetidos]






# ------------- playground ---------------

cl = kmeans(normalizado, 18)
hcat(names(df)[44:72], cl.centers)
hcat(names(df)[44:72],  cl.centers*100/maximum(cl.centers))


using CSV, DataFrames
CSV.write("fifa datasets/centros.csv", DataFrame(hcat(names(df)[44:72],  cl.centers*100/maximum(cl.centers)), :auto))

# df_cluster = DataFrame(hcat(df[idx_no_gk,:short_name], df[idx_no_gk,:player_positions], cl.assignments), [:name, :position, :cluster])
df_cluster = deepcopy(df[idx_no_gk,:])
df_cluster[!,:cluster] = cl.assignments
df_cluster = df_cluster[:,[:short_name, :player_positions, :pace, :shooting, :passing, :dribbling, :defending, :physic, :cluster]]
rename!(df_cluster, Dict("short_name" => "name", "player_positions" => "position"))

gp_cluster = groupby(df_cluster, :cluster)

[print_cluster(gp, n_jogadores=5, minimum_pertinence=.25) for gp in gp_cluster];

# gráfico de barra com 6 atributos pra cada cluster
using Plots
using StatsPlots

gerdau = [9, 19, 26, 18]
posco = [86, 62, 72, 76]
hyundai = [88, 86, 58, 77]
fortescue = [83, 68, 71, 74]
media = [19, 17, 22, 20]

todos = transpose(hcat(gerdau, posco, hyundai, fortescue, media))
nomes = ["Gerdau", "POSCO", "Hyundai", "Fortescue", "Média do setor"]
nomes = repeat(nomes, 4)
ctg = vcat(repeat(["E"],5), repeat(["S"],5), repeat(["G"],5), repeat(["Score"],5))

groupedbar(nomes, todos, group = ctg, ylim = (0,110))

n_clus = 1
[mean(gp_cluster[n_clus].pace), mean(gp_cluster[n_clus].shooting), mean(gp_cluster[n_clus].passing), mean(gp_cluster[n_clus].dribbling), mean(gp_cluster[n_clus].defending), mean(gp_cluster[n_clus].physic)]

function cluster_bars(gp_cluster, n_clusts::Vector{Int64})
    todos = transpose(hcat([[mean(gp_cluster[i].pace), mean(gp_cluster[i].shooting), mean(gp_cluster[i].passing), mean(gp_cluster[i].dribbling), mean(gp_cluster[i].defending), mean(gp_cluster[i].physic)] for i in n_clusts]...))

    
end




df_flop_olds
df_cluster_olds = deepcopy(df[idx_no_gk,:])
df_cluster_olds[!,:cluster] = cl.assignments
filter!(row -> row.age > 25, df_cluster_olds)
df_cluster_olds = df_cluster_olds[:,[:sofifa_id, :short_name, :cluster]]
@time teste=[[findfirst(x->x==df_cluster_olds.sofifa_id[i], df_flop_olds.sofifa_id), :potential_overall_flop_index] for i in 1:size(df_cluster_olds,1)];
idxs=findall(x->isnothing(x),map(x->x[1],teste))
df_cluster_olds = df_cluster_olds[setdiff(1:size(df_cluster_olds,1), idxs),:]
@time df_cluster_olds[!, :flop_index] = [df_flop_olds[findfirst(x->x==df_cluster_olds.sofifa_id[i], df_flop_olds.sofifa_id), :potential_overall_flop_index] for i in 1:size(df_cluster_olds,1)]

gp_flop = groupby(df_cluster_olds, :cluster)
sort(combine(gp_flop, :flop_index => mean), 2)





[(i, 100*cluster_positions(gp_cluster[i])[main_cluster_position(gp_cluster[i])]) for i in 1:length(gp_cluster)]


i = 15
filter(row -> !occursin(main_cluster_position(gp_cluster[i]), row.position), gp_cluster[i])


# ------------------------------------------- comparando posições & modo carreira ----------------------------------------------

using Distributions

pos = "ST"
idx_pos = findall(x -> x==pos, [main_cluster_position(gp) for gp in gp_cluster])
[print_cluster(gp) for gp in gp_cluster[idx_pos]];
hcat(adj_names, cl.centers[:,idx_pos])


df_cluster = deepcopy(df[idx_no_gk,:])
df_cluster[!,:cluster] = cl.assignments
df_cluster = df_cluster[:,[:short_name, :player_positions, :overall, :potential, :value_eur, :preferred_foot, :international_reputation, :cluster]]
filter(x -> x.cluster in [13,37], df_cluster)


df_orig = deepcopy(df[idx_no_gk,:])
df_orig[!,:cluster] = cl.assignments
df_st = df_orig[:,[:short_name, :player_positions, :club_name, :overall, :height_cm, :pace, :cluster]]
gp_clubs = groupby(df_st, :club_name)
grandalhoes = findall(x->x>=2, ([size(filter(x -> x.cluster in [8,36], sort(club, :overall, rev=true)[1:14,:]),1) for club in gp_clubs]))
pontinhas = findall(x->x>=2, ([size(filter(x -> x.cluster in [4,5,31,17,40], sort(club, :overall, rev=true)[1:14,:]),1) for club in gp_clubs]))
intersect(grandalhoes, pontinhas)


df_orig = deepcopy(df[idx_no_gk,:])
df_orig[!,:cluster] = cl.assignments
df_pos = df_orig[:,[:short_name, :player_positions, :club_name, :overall, :pace, :power_stamina, :height_cm, :cluster]]
gp_clubs = groupby(df_pos, :club_name)
cam = findall(x->x>=1, ([size(filter(x -> x.cluster in [25,26,38], sort(club, :overall, rev=true)[1:11,:]),1) for club in gp_clubs]))
ata = findall(x->x>=2, ([size(filter(x -> x.cluster in [1, 44, 50, 25], sort(club, :overall, rev=true)[1:14,:]),1) for club in gp_clubs]))
motor = findall(x->x>=2, ([size(filter(x -> x.cluster in [24, 31, 41, 8, 33, 17], sort(club, :overall, rev=true)[1:14,:]),1) for club in gp_clubs]))
intersect(cam, motor, ata)
intersect(motor, ata)


lat_of = findall(x->x>=1, ([size(filter(x -> x.cluster in [7,28,32], sort(club, :overall, rev=true)[1:15,:]),1) for club in gp_clubs]))
lat_df = findall(x->x>=1, ([size(filter(x -> x.cluster in [22,34,42], sort(club, :overall, rev=true)[1:15,:]),1) for club in gp_clubs]))
cdm = findall(x->x>=1, ([size(filter(x -> x.cluster in [10,18,35], sort(club, :overall, rev=true)[1:15,:]),1) for club in gp_clubs]))
cm = findall(x->x>=1, ([size(filter(x -> x.cluster in [1,29,37,49], sort(club, :overall, rev=true)[1:15,:]),1) for club in gp_clubs]))
scarpa = findall(x->x>=1, ([size(filter(x -> x.cluster in [8,31,48], sort(club, :overall, rev=true)[1:15,:]),1) for club in gp_clubs]))
pontinha = findall(x->x>=1, ([size(filter(x -> x.cluster in [9,33,36,40], sort(club, :overall, rev=true)[1:15,:]),1) for club in gp_clubs]))
quebrador = findall(x->x>=1, ([size(filter(x -> x.cluster in [4, 14, 15, 20, 23, 47], sort(club, :overall, rev=true)[1:15,:]),1) for club in gp_clubs]))
pivozao = findall(x->x>=1, ([size(filter(x -> x.cluster in [5, 50, 24, 12, 11], sort(club, :overall, rev=true)[1:15,:]),1) for club in gp_clubs]))

v = [count(x -> i in x, [lat_of, lat_df, cdm, cm, scarpa, pontinha, quebrador, pivozao]) for i in 1:length(gp_clubs)]


ata = findall(x->x>=2, ([size(filter(x -> x.pace >= 85 && occursin("ST", x.player_positions), sort(club, :overall, rev=true)[1:14,:]),1) for club in gp_clubs]))


strengthes_weaknesses(cl, gp_cluster, [7,14,20,27,31,35,39,45];n_stats=5)



# --------------------------- inserindo um novo jogador --------------------------------------

eu = [62, 54, 68, 73, 56, 60, 63, 52, 75, 67, 83, 83, 76, 74, 52, 62, 74, 73, 61, 50, 68, 76, 53, 61, 72, 69, 73, 80, 74, 183]
almeida = [67,63,56,75,61,74,68,66,66,72,68,63,76,77,76,61,61,62,54,59,60,62,66,71,67,63,60,60,57,171]
bob = [63,60,63,65,57,56,63,57,66,63,53,52,55,55,62,61,60,61,58,61,57,62,63,61,65,67,65,69,67,180]
tt = [66,71,62,70,77,84,67,63,64,83,81,78,85,80,81,73,88,75,80,71,76,80,73,67,67,70,78,82,76,167]
tuca = [75,82,66,82,79,83,79,77,77,84,82,82,81,80,78,82,79,79,72,79,71,68,78,81,77,80,68,67,65,177]
cout = [57,56,67,60,54,52,55,50,60,60,60,60,60,63,67,63,65,68,66,58,75,73,67,66,60,68,75,74,72,175]
elabras = [60,63,54,63,50,56,61,52,62,63,64,64,63,61,65,62,65,66,68,61,65,74,63,65,63,64,77,78,72,177]
mello = [65,60,61,63,60,57,65,60,63,60,80,80,76,75,58,70,73,74,52,78,63,67,61,62,64,64,68,68,70,186]
joe = [72,80,62,70,68,73,74,68,74,77,70,70,72,74,75,82,72,75,60,79,78,81,76,68,69,70,84,82,80,172]
pig = [71,74,64,70,73,74,72,69,67,76,73,73,74,73,75,76,72,74,71,70,78,65,74,72,74,73,65,65,63,169]
gugao = [57,74,72,62,70,60,57,50,59,62,57,56,58,59,65,76,66,64,78,68,66,68,73,61,66,65,67,67,63,181]
felipe = [64,74,85,72,80,72,73,64,67,73,71,75,74,76,78,75,82,73,75,69,68,66,80,68,63,64,65,65,64,180]
murilo = [63,68,63,66,69,69,69,62,63,70,79,78,78,78,76,72,84,78,69,67,55,54,65,64,68,63,56,55,57,176]
mig = [62,65,63,66,65,66,65,70,64,62,75,71,74,73,76,68,69,70,64,60,58,53,61,60,64,62,51,52,52,167]
coelho = [58,60,62,64,57,56,58,50,60,63,55,55,57,59,64,70,60,56,60,62,62,63,63,63,65,57,65,66,61,171]
joebo = [66,68,61,75,68,69,68,64,72,74,67,68,69,70,71,72,73,72,65,69,75,79,70,73,68,70,81,80,75,174]
new_player = coelho

new_dados = hcat(vcat(dados, transpose(df[idx_no_gk,:height_cm])), new_player)

difs=[sum((new_dados[i,j]-new_dados[i,17108])^2 for i in 1:29) for j in 1:size(dados,2)]
val, idx = findmin(difs)
idx = findall(x -> x<2000, difs)
df_cluster[idx,:]

[(el => count(x->x==el,df_cluster[idx,:cluster])) for el in unique(df_cluster[idx,:cluster])]

# recomendar posição (posição dos mais próximos)

val, idx = 0, 17107
while idx > 0 && val < 6000
    val, new_idx = findmin(difs[1:idx])
    println("$(df_cluster[new_idx,:name]) - $(df_cluster[new_idx,:position]) - cluster $(df_cluster[new_idx,:cluster]) (diferença = $val)")
    idx = new_idx - 1
end


# ------------------------ testes para diferentes k e seeds --------------------------------------


# testar quanto de cada posição ele pega pra diferentes k
# testar qual a melhor seed com métricas de clustering

dicts = Dict[]

for k in 1:50
    cl = kmeans(normalizado, k)
    adj_names = [str[findfirst(x->x=='_',str)+1:end] for str in names(df)[vcat(44:72,12)]]

    df_cluster = deepcopy(df[idx_no_gk,:])
    df_cluster[!,:cluster] = cl.assignments
    df_cluster = df_cluster[:,[:short_name, :player_positions, :pace, :shooting, :passing, :dribbling, :defending, :physic, :cluster]]
    rename!(df_cluster, Dict("short_name" => "name", "player_positions" => "position"))

    gp_cluster = groupby(df_cluster, :cluster)

    positions = [main_cluster_position(gp) for gp in gp_cluster]
    dict_positions = Dict([(el => count(x->x==el, positions)) for el in unique(positions)])
    push!(dicts, dict_positions)
end

dicts = Dict[]
sils = Float64[]

for seed in 1:10
    Random.seed!(seed)

    cl = kmeans(normalizado, 50)

    df_cluster = deepcopy(df[idx_no_gk,:])
    df_cluster[!,:cluster] = cl.assignments
    df_cluster = df_cluster[:,[:short_name, :player_positions, :pace, :shooting, :passing, :dribbling, :defending, :physic, :cluster]]
    rename!(df_cluster, Dict("short_name" => "name", "player_positions" => "position"))

    gp_cluster = groupby(df_cluster, :cluster)

    positions = [main_cluster_position(gp) for gp in gp_cluster]
    dict_positions = Dict([(el => count(x->x==el, positions)) for el in unique(positions)])
    push!(dicts, dict_positions)
    push!(sils, mean(silhouettes(cl.assignments, dists)))

end

# para k = 50: de 1 a 10, melhor seed é 9 (silhueta média = 0.10523163320605175)
