# Line fitting with gradient method

using MAT
using Flux
#using ForwardDiff
#using ReverseDiff

function main()
    data = matread(joinpath(@__DIR__, "../data/xy.mat"))
    #size = size(data)
    #println(size)
    size = 512

    # Gradient descent
    starting_point = (1, 1, 1)
    stepsize = 1*10^-8
    iterations = 1000

    params = []
    push!(params, starting_point)
    prev_params = starting_point


    # Code the iteration: 
    for i in 1:iterations
        # Calculate params+1 according to the formula in the exercise.
        #f(a, b, c) = (a * data[i])
        #next_params = prev_params - stepsize * grad
    end 
    # Use the last params from the iteration to define the function of the line.

    # Plot the data points and the line in the same plot.

end

function partial_derivative(datapoint, size)
    for i in 1:size
        f(a, b, c) = (a * datapoint[1] + b * datapoint[2] + c)^2
        df_a = gradient(f, a)
    end
end

main()
