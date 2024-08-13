function route(receiver, dbs, timestamps)
    # separação e yds percorridas por tempo
    sep, yds = [1.], [0.]
    for t in timestamps
        push!(sep, sep[end] + rand(Normal(.04,.01)))
        push!(yds, yds[end] + rand(Normal(.8,.1)))
    end
    return (separation = sep, yards = yds)
end

function routes(timestamps)
    return [route(nothing,nothing,timestamps) for wr in 1:4]
end