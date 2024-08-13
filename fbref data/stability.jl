using CSV, DataFrames, Statistics

df22 = CSV.read("C:/Users/pedrohamacher/OneDrive/Documentos antigo/Projetos_jl/Matérias PUC/23.1/prog mat/projeto/dados/dados2022.csv", DataFrame)
df23 = CSV.read("C:/Users/pedrohamacher/OneDrive/Documentos antigo/Projetos_jl/Matérias PUC/23.1/prog mat/projeto/dados/dados2023.csv", DataFrame)


inters = intersect(names(df22), names(df23))

ij = innerjoin(df22, df23, on = :Url, makeunique=true)
filter!(x -> x.Position != "Goalkeeper", ij)
filter!(x -> x.Mins_Per_90 >= 5 && x.Mins_Per_90_1 >= 5, ij)

stats = intersect(names(df22)[8:end-5], inters)
df = DataFrame(Stat = stats, Dif = [mean([abs(findfirst(x->x==i,sortperm(ij[:,nm])) - findfirst(x->x==i,sortperm(ij[:,"$(nm)_1"]))) for i in 1:size(ij,1)]) for nm in stats])
df[!,:Zeros] = [count(x->x==0,ij[:,name])/size(ij,1) for name in stats]



