# Line fitting with gradient method

using MAT
using LinearAlgebra

function main()
    data = matread(joinpath(@__DIR__, "../data/xy.mat"))
    points = data["xy"] 

    size = 512

    p = plot((points[1, 1], points[2, 1]), seriestype=:scatter)
    #for i in 1:512
    for i in 1:100
        p = plot!((points[1, i], points[2, i]), seriestype=:scatter)

    end

    # Gradient descent
    starting_point = [1, 1, 1]
    stepsize = 1*10^-8
    iterations = 1000

    prev_params = starting_point
    params = starting_point

    # Code the iteration: 
    for j in 1:iterations
        params = prev_params - stepsize * partial_derivative(prev_params, points)
        prev_params = params
    end

    # Use the last params from the iteration to define the function of the line.
    x = range(0, 100, length=512)
    y = ((-params[1] / params[2]) * x .+ (- params[3] / params[2]))
    plot!(x, y)

end

function partial_derivative(prev_params, points)
    gradient = [0.0, 0.0, 0.0]
    for i in 1:512
        gradient[1] += 2 * (prev_params[1]*points[1, i] + prev_params[2]*points[2, i] + prev_params[3]) * points[1, i]
        gradient[2] += 2 * (prev_params[1]*points[1, i] + prev_params[2]*points[2, i] + prev_params[3]) * points[2, i]
        gradient[3] += 2 * (prev_params[1]*points[1, i] + prev_params[2]*points[2, i] + prev_params[3])
    end
    return gradient
    #return normalize(gradient)
end

main()
