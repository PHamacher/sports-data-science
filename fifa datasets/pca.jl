# PCA
df = CSV.read("data/Fifa 23 players data.csv", DataFrame)
sorted_df = sort(filter(x->x["Best Position"]!="GK", df), :Overall)
dados = Matrix{Int64}(transpose(Array(sorted_df[:,39:72])))
totais = sum(dados, dims=1)
X = dados ./ totais
M = fit(PCA, X)
transformed = MultivariateStats.transform(M, X)

scatter(transformed[1,:], transformed[2,:], marker_z = sorted_df.Overall, color = cgrad(:lightrainbow), label=nothing,
        xlabel = "PC1", ylabel = "PC2", hover = sorted_df[:,"Known As"])



hcat(names(df)[39:72],M.proj[:,1:5])[sortperm(M.proj[:,2]),:]



df = CSV.read("../../Matérias PUC/23.1/prog mat/projeto/dados/dados2022.csv", DataFrame)
filter!(x -> x.Mins_Per_90 >= 5, df)
replace!(df.Position, "midfield" => "Centre-Back", "Second Striker" => "Centre-Forward", "Right Midfield" => "Winger", "Left Midfield" => "Winger", "attack" => "Winger", "Right-Back" => "Fullback", "Left-Back" => "Fullback", "Left Winger" => "Winger", "Right Winger" => "Winger")
sorted_df = filter(x->x.Position!="Goalkeeper" && x.Player!="Frederik Rønnow", df) # bug Ronnow
dados = Matrix{Float64}(transpose(Array(sorted_df[:,8:154])))
totais = sum(dados, dims=1)
X = dados ./ totais
M = fit(PCA, X)
transformed = MultivariateStats.transform(M, X)

plot();[scatter!([0],[0],color=i, label = unique(sorted_df.Position)[i]) for i in 1:length(unique(sorted_df.Position))]
scatter!(transformed[1,:], transformed[2,:], color = [findfirst(x->x==pos, unique(sorted_df.Position)) for pos in sorted_df.Position],
        xlabel = "Ofensividade", ylabel = "Velocidade", hover = sorted_df.Player, label = "", legend=:outertopright)

plot();[scatter!([0],[0],color=i, label = unique(sorted_df.Position)[i]) for i in 1:length(unique(sorted_df.Position))]
scatter!(transformed[3,:], transformed[4,:], color = [findfirst(x->x==pos, unique(sorted_df.Position)) for pos in sorted_df.Position],
        xlabel = "Bola pra trás/lado", ylabel = "Ações mais fáceis", hover = sorted_df.Player, label = "", legend=:outertopright)

plot();[scatter!([0],[0],color=i, label = unique(sorted_df.Position)[i]) for i in 1:length(unique(sorted_df.Position))]
scatter!(transformed[5,:], transformed[6,:], color = [findfirst(x->x==pos, unique(sorted_df.Position)) for pos in sorted_df.Position],
        xlabel = "Drible %", ylabel = "Canhoto", hover = sorted_df.Player, label = "", legend=:outertopright)



hcat(names(df)[8:154],M.proj[:,1:7])[sortperm(M.proj[:,1]),:]





# ========================================
using GLM

fifa = filter(x->x.player_positions!="GK", CSV.read("data/players_22.csv", DataFrame))
real = filter(x->x.Position!="Goalkeeper" && !(x.Player in ["Frederik Rønnow","Fali"]) && x.Mins_Per_90 >= 5, CSV.read("../../Matérias PUC/23.1/prog mat/projeto/dados/dados2022.csv", DataFrame))

fifa_names = fifa.long_name
real_names = split.(real.Player, " ")
v = []
for real_name in real_names
    matches = [all(occursin.(real_name,fifa_name)) for fifa_name in fifa_names]
    ret = sum(matches) == 1 ? findfirst(x -> x == 1, matches) : missing
    push!(v, ret)
end
real = real[findall(x->!ismissing(x), v),:]
fifa = fifa[filter(x->!ismissing(x), v),:]

real_vals = real[:,8:154]
fifa_vals = fifa[:,vcat(6,29:30,38:72)]
X = Matrix{Float64}(real_vals)

pvalue(reg::LinearModel) = DataFrame(coeftable(reg))[:,5]

all_regs = [lm(hcat(ones(size(X, 1)), X), Float64.(y)) for y in eachcol(fifa_vals)]

reg = all_regs[11]
hcat(vcat("Intercept",names(real))[findall(x -> x < 0.01, pvalue(reg))], filter(x -> x < 0.01, pvalue(reg)))

scatter(real.Gls_Standard, fifa.attacking_finishing, xlabel = "Gols/jogo", ylabel = "Finishing", label = false, hover = fifa.short_name)

scatter(real.Succ_Dribbles, fifa.skill_dribbling, xlabel = "Dribles/jogo", ylabel = "Dribbling", label = false, hover = fifa.short_name)

######################

# fifa 22
# defensivo x ofensivo
# forte x rápido
# físico x técnico
# pontinha x centralizado??
# cruzamentos x passes rasteiros??
# músculos tipo 2 x tipo 1
# ??? x chutes longos
# porra loka x paciente??

# fifa 23
# ofensivo x defensivo
# cabeceador x ??
# físico x técnico
# pontinha x centralizador??
# passador x físico/cruzador?
# músculos tipo 2 x tipo 1
# chute longo x cruzador/físico??
# porra loka x paciente?


# fbref
# participativo x precisão de passes -> foi o jeito dele de identificar ofensivo x defensivo
# percentuais x carregadas -> jeito dele de identificar velocidade??
# distancia progressiva x distancia total
# tentativas x percentuais??
# drible % (baixo x alto)
# destros x canhotos



# qtd de variáveis de um tipo influencia no PCA?