completion_probability(qb_speed,time_throw,rush_sep,air_dist,target_sep,side_sep) = -0.0511402*qb_speed -
    0.00503766*time_throw +0.0148123*rush_sep -0.000633151*air_dist +0.0132063*target_sep +
    0.0547759*side_sep -0.00109471*side_sep^2 # regressão logística (accuracy.jl)

completion_probability(dist, sep) = return 1/(1+exp((dist-5sep)/20))

function is_complete(qb,rec,frame)
    qb_speed = 0
    time_throw = frame
    rush_sep = distance(qb, pr)
    air_dist = distance(qb, rec)
    target_sep = distance(rec, def)
    side_sep = sideline_separation(rec)

    prob = completion_probability(qb_speed,time_throw,rush_sep,air_dist,target_sep,side_sep)
    return rand() < prob
end

function pass()
    pressure = passrush()
    rotas = routes(0:.1:pressure)
    idx_time = rand(1:length(rotas[1].yards))
    wr_quali = map(wr -> wr.yards[idx_time] + wr.separation[idx_time], rotas) # qb só passa no último instante pra quem tiver em melhor posição
    idx_max = findmax(wr_quali)[2]
    dist, sep = rotas[idx_max].yards[idx_time], rotas[idx_max].separation[idx_time]
    completed = is_complete(nothing, nothing, dist, sep)
    return completed*dist
end
