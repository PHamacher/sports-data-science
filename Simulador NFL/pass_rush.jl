function passrush_gap(protecters, rushers)
    # calcular em quanto tempo ocorre a pressão/sack de acordo com qualidade e quantidade de DL/OL
    # fazer também a distância do rusher pro qb?
    return rand(LogNormal(log(3.9), .3))
end

function passrush()
    return minimum([passrush_gap(nothing, nothing) for gap in 1:4])
end