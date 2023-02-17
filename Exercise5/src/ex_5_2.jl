# Line fitting with gradient method

using MAT
using LinearAlgebra
#using Flux
#using ForwardDiff
#using ReverseDiff

function main()
    data = matread(joinpath(@__DIR__, "../data/xy.mat"))
    points = data["xy"] 
    #size = size(data)
    #println(size)
    size = 512
    #println(sizeof(points))
    print(points[:, 4])
    points_matrix = []
    #plot(points[:, 1], seriestype=:scatter)
    
    for i in 1:512
        #points_matrix[i] = (points[1,i], points[2, i])
        p = plot!(points[:, i], seriestype=:scatter)
        push!(points_matrix, (points[1, i], points[2, i]))
    end


    #println(points_matrix)

    # Gradient descent
    starting_point = [1, 1, 1]
    stepsize = 1*10^-8
    iterations = 1000

    #params = []
    #push!(params, starting_point)
    prev_params = starting_point
    params = starting_point

    # Code the iteration: 

   # println(points[2, 1])
    for j in 1:iterations
        params = prev_params - stepsize * partial_derivative(prev_params, points)
        prev_params = params
    end
    #println(partial_derivative(prev_params, points))
    #println(params)
    # Use the last params from the iteration to define the function of the line.
    #f(x, y) = params[1] * x + params[2] * y + params[3]

    # This part not working
    x = range(0, 512, length=512)
    y = ((-params[1] / params[2]) * x .+ (- params[3] / params[2]))

    # Plot the data points and the line in the same plot.
    #plot(points, seriestype=:scatter)
    #plot!(x, y)
    display(p)

end

function partial_derivative(prev_params, points)
    gradient = [0.0, 0.0, 0.0]
    for i in 1:3
        gradient[1] += 2 * (prev_params[1]*points[1, i] + prev_params[2]*points[2, i] + prev_params[3]) * points[1, i]
        gradient[2] += 2 * (prev_params[1]*points[1, i] + prev_params[2]*points[2, i] + prev_params[3]) * points[2, i]
        gradient[3] += 2 * (prev_params[1]*points[1, i] + prev_params[2]*points[2, i] + prev_params[3])
    end
    return normalize(gradient)
end

#=function partial_derivative(datapoint, size)
    for i in 1:size
        f(a, b, c) = (a * datapoint[1] + b * datapoint[2] + c)^2
        df_a = gradient(f, a)
    end
end=#

main()
