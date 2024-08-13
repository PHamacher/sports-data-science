using CSV, DataFrames, Clustering, Statistics, Crayons, Distributions

cd("Futebol/fifa datasets")

include("clustering/clustering_utils.jl")

df = CSV.read("data/players_22.csv", DataFrame)

df[!, :main_position] = get_main_position.(df.player_positions)
gp_main_position = groupby(df, :main_position)
stats_per_position = combine(gp_main_position, :pace => mean, :shooting => mean, :passing => mean, :dribbling => mean, :defending => mean, :physic => mean)
filter!(x -> !ismissing(x.main_position) && !(x.main_position in ["GK","RES","SUB"]), stats_per_position)
total_per_position = sum(Array(stats_per_position[:,2:end]),dims=2)
stats_per_position[:,2:end] = stats_per_position[:,2:end] ./ total_per_position

idx_no_gk = findall(x->x!="GK", df.player_positions)

dados = Matrix{Int64}(transpose(Array(df[idx_no_gk,44:72]))) # all attributes

totais = sum(dados, dims=1)
normalizado = dados ./ totais

# max_norm, min_norm, max_alt, min_alt = maximum(normalizado), minimum(normalizado), maximum(df.height_cm), minimum(df.height_cm)
# altura_normalizada = [((max_norm - min_norm) * (A - min_alt) / (max_alt - min_alt)) + min_norm for A in df.height_cm]

# normalizado = vcat(normalizado, transpose(altura_normalizada[idx_no_gk]))

k = 12
cl = kmeans(normalizado, k)
adj_names = [str[findfirst(x->x=='_',str)+1:end] for str in names(df)[44:72]]
# adj_names = [str[findfirst(x->x=='_',str)+1:end] for str in names(df)[vcat(44:72,12)]]

df_cluster = deepcopy(df[idx_no_gk,:])
df_cluster[!,:cluster] = cl.assignments
df_cluster = df_cluster[:,[:short_name, :player_positions, :pace, :shooting, :passing, :dribbling, :defending, :physic, :cluster]]
rename!(df_cluster, Dict("short_name" => "name", "player_positions" => "position"))

gp_cluster = groupby(df_cluster, :cluster)


# ---------------------------

using MultivariateStats, Plots

X = normalizado
M = fit(PCA, X)

principalvars(M) ./ tvar(M) * 100
[names(df_cluster)[2:end][findall(x -> x >= quantile(col, .95), col)] for col in eachcol(projection(M))]

transformed = MultivariateStats.transform(M, X)

scatter(transformed[1,:], transformed[2,:], marker_z = cl.assignments, color = cgrad(:lightrainbow), label = "Cluster",
        xlabel = "PC1", ylabel = "PC2", hover = df[idx_no_gk,:].short_name)

plot();
for pos in unique(vcat(split.(df[idx_no_gk,:player_positions],", ")...))
    idx_pos =  findall(x -> occursin(pos, x.player_positions), eachrow(df[idx_no_gk,:]))
    scatter!(transformed[1,idx_pos], transformed[2,idx_pos], marker_z = df[idx_no_gk,:overall][idx_pos], color = cgrad(:lightrainbow), label = pos,
            xlabel = "PC1", ylabel = "PC2", hover = df[idx_no_gk,:short_name][idx_pos]);
end
plot!()
