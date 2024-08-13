# TODO: incluir outros atributos (altura, weak foot, skills, workrate, pé bom, traits)?

function get_main_position(positions::AbstractString)
    main_pos = split(positions, ", ")[1]
    # MA = MEIA ABERTO (PENSAR NUM NOME MELHOR)
    corrige_lado = Dict("RM" => "MA", "LM" => "MA", "RW" => "PON", "LW" => "PON", "RB" => "LAT", "LB" => "LAT", "RWB" => "ALA", "LWB" => "ALA")
    return get(corrige_lado, main_pos, main_pos)
end

function cluster_positions(cluster::SubDataFrame)
    dict = Dict{String, Real}()
    corrige_lado = Dict("RM" => "MA", "LM" => "MA", "RW" => "PON", "LW" => "PON", "RB" => "LAT", "LB" => "LAT", "RWB" => "ALA", "LWB" => "ALA")
    for player in eachrow(cluster)
        positions = split(player.position, ", ")
        for pos in positions
            pos = get(corrige_lado, pos, pos)
            current = get(dict, pos, 0)
            dict[pos] = current + 1
        end
    end
    
    cluster_size = size(cluster,1)
    for (k,v) in dict
        dict[k] = v/cluster_size
    end

    return dict
end

function main_cluster_position(cluster::SubDataFrame)
    dict = cluster_positions(cluster)
    val, idx = findmax([v for v in values(dict)])
    main_pos = [k for k in keys(dict)][idx]
    return main_pos
end

function strengthes_weaknesses(cl, gp_cluster::GroupedDataFrame{DataFrame}, cluster_num::Int64, all_num::Vector{Int64};
                                name::String="Compared clusters", n_stats::Int64=3)

    # Print main strengthes and weaknesses (compared to position)
    pos_centers = cl.centers[:,all_num]
    media, dsv = mean(pos_centers,dims=2), std(pos_centers,dims=2)
    idx_cluster = findfirst(x -> x == cluster_num, all_num)
    cumul = [cdf(Normal(media[i], dsv[i]), stat) for (i,stat) in enumerate(pos_centers[:,idx_cluster])]

    println(Crayon(foreground = :white), "Main strengthes relative to $name")
    [println(Crayon(foreground = :green), stat) for stat in adj_names[sortperm(cumul)][end-n_stats+1:end]]
    println()

    println(Crayon(foreground = :white), "Main weaknesses relative to $name")
    [println(Crayon(foreground = :red), stat) for stat in adj_names[sortperm(cumul)][1:n_stats]]

    print(Crayon(foreground = :white))
end

function strengthes_weaknesses(cl, gp_cluster::GroupedDataFrame{DataFrame}, all_num::Vector{Int64}; name::String="Compared clusters", n_stats::Int64=3)
    for idx in all_num
        println("Cluster $idx")
        strengthes_weaknesses(cl, gp_cluster, idx, all_num; name = name, n_stats = n_stats)
        println()
    end
end

function print_cluster(cluster::SubDataFrame; minimum_pertinence::Float64=.2, n_jogadores::Int64=3, n_stats::Int64=3, overview::Bool=false, tol=1e-2)
    cluster_num = cluster[1,:cluster]
    println("\n\nCluster $cluster_num")
    println("Principais jogadores:")
    for i in 1:n_jogadores
        println(cluster[i,:name])
    end

    dict = cluster_positions(cluster)
    idxs = findall(x -> x>minimum_pertinence, [v for v in values(dict)])
    keys_max = [k for k in keys(dict)][idxs]
    println("\nPrincipais posições:")
    for k in keys_max
        val = 100*round(dict[k], digits=4)
        println("$k com pertinência $val%")
    end

    println()
    main_pos = main_cluster_position(cluster)
    idx_pos = findfirst(x -> x==main_pos, stats_per_position[:,1])
    # Normalizando
    total_cluster = sum(Array(cluster[:,3:end]), dims=2)
    norm_cluster = cluster[:,3:end] ./ total_cluster
  
    if overview
        isapprox(mean(norm_cluster.pace), stats_per_position[idx_pos,:pace_mean], atol=tol) ? println(Crayon(foreground = :white), "pace na média de $main_pos") : mean(norm_cluster.pace) > stats_per_position[idx_pos,:pace_mean] ? println(Crayon(foreground = :green), "pace acima da média para $main_pos") : println(Crayon(foreground = :red), "pace abaixo da média para $main_pos")
        isapprox(mean(norm_cluster.shooting), stats_per_position[idx_pos,:shooting_mean], atol=tol) ? println(Crayon(foreground = :white), "shooting na média de $main_pos") : mean(norm_cluster.shooting) > stats_per_position[idx_pos,:shooting_mean] ? println(Crayon(foreground = :green), "shooting acima da média para $main_pos") : println(Crayon(foreground = :red), "shooting abaixo da média para $main_pos")
        isapprox(mean(norm_cluster.passing), stats_per_position[idx_pos,:passing_mean], atol=tol) ? println(Crayon(foreground = :white), "passing na média de $main_pos") : mean(norm_cluster.passing) > stats_per_position[idx_pos,:passing_mean] ? println(Crayon(foreground = :green), "passing acima da média para $main_pos") : println(Crayon(foreground = :red), "passing abaixo da média para $main_pos")
        isapprox(mean(norm_cluster.dribbling), stats_per_position[idx_pos,:dribbling_mean], atol=tol) ? println(Crayon(foreground = :white), "dribbling na média de $main_pos") : mean(norm_cluster.dribbling) > stats_per_position[idx_pos,:dribbling_mean] ? println(Crayon(foreground = :green), "dribbling acima da média para $main_pos") : println(Crayon(foreground = :red), "dribbling abaixo da média para $main_pos")
        isapprox(mean(norm_cluster.defending), stats_per_position[idx_pos,:defending_mean], atol=tol) ? println(Crayon(foreground = :white), "defending na média de $main_pos") : mean(norm_cluster.defending) > stats_per_position[idx_pos,:defending_mean] ? println(Crayon(foreground = :green), "defending acima da média para $main_pos") : println(Crayon(foreground = :red), "defending abaixo da média para $main_pos")
        isapprox(mean(norm_cluster.physic), stats_per_position[idx_pos,:physic_mean], atol=tol) ? println(Crayon(foreground = :white), "physic na média de $main_pos") : mean(norm_cluster.physic) > stats_per_position[idx_pos,:physic_mean] ? println(Crayon(foreground = :green), "physic acima da média para $main_pos") : println(Crayon(foreground = :red), "physic abaixo da média para $main_pos")
    end
    println(Crayon(foreground = :white))

    idx_pos = findall(x -> x==main_pos, [main_cluster_position(gp) for gp in gp_cluster])
    strengthes_weaknesses(cl, gp_cluster, cluster_num, idx_pos; name = main_pos, n_stats = n_stats)
end