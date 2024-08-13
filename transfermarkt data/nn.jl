using Flux, IterTools

normalize(a::Array) = (a .- minimum(a)) / (maximum(a) - minimum(a))

function treina_rede(nn::Chain, df::DataFrame, batch_size::Int64, patience::Int64)
    original = deepcopy(nn)
    x = normalize(Array(df[:,1:end-1]))
    y = normalize(df[:,end])

    loss(x, y) = Flux.mse(nn(x), y)
    optimizer = ADAM(1e-5)

    xs = hcat.(partition([x[i,:] for i in 1:size(df,1)], batch_size)...)
    ys = hcat.(partition([y[i] for i in 1:size(df,1)], batch_size)...)

    minvals = Float64[]
    for validation_set in 1:batch_size
        nn = deepcopy(original)

        train_xs = xs[setdiff(1:batch_size, [validation_set])]
        val_xs = [xs[validation_set]]
        train_ys = ys[setdiff(1:batch_size, [validation_set])]
        val_ys = [ys[validation_set]]

        training_loss = Float64[]
        validation_loss = Float64[]
        epochs = Int64[]

        epoch = 1
        idx_min = 0

        while epoch - idx_min < patience
            Flux.train!(loss, params(nn), zip(train_xs, train_ys), optimizer)
            
            push!(epochs, epoch)
            push!(training_loss, mean(loss.(train_xs, train_ys)))
            push!(validation_loss, mean(loss.(val_xs, val_ys)))

            minval, idx_min = findmin(validation_loss)
            epoch += 1
        end
        @show epoch

        push!(minvals, minimum(validation_loss))

        # plot(epochs, training_loss; label="Training loss")
        # display(plot!(epochs, validation_loss; label="Validation loss"))
    end

    return nn, mean(minvals)
end
