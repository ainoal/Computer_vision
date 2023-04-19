using MAT
using Plots
using Random
using LinearAlgebra

function main()
    # Load and plot the points
    data = matread(joinpath(@__DIR__, "../data/circle_points.mat"))
    points = data["points"]
    plt = plot(points[1, :], points[2, :], seriestype=:scatter, aspect_ratio=:equal)
    display(plt)
    
    # Line fitting
    rangex = [-150, 100]
    rangey = [-80, 80]
    fitted_circle = plot_shape(rangex, rangey, points)
    plt2 = fitted_circle[1]
    a = fitted_circle[2]
    b = fitted_circle[3]
    c = fitted_circle[4]
    d = fitted_circle[5]
    display(plt2)

    # Implement RANSAC
    # Step 1: Randomly select a minimal sample of data points and
    # estimate the model using it.
    s = 10
    sz = size(points)[2]
    perm = randperm(sz)
    min_sample = perm[1:s]
    min_sample_points = zeros(2, s)
    for i in 1:s
        min_sample_points[:, i] = points[:, min_sample[i]]
    end

    # Step 2: determine the set of data within a treshold d of the model.
    # Use algebraic error for tresholding the points.
    d = 0.1
    ms_x = min_sample_points[1, :]
    ms_y = min_sample_points[2, :]
    
    for pt in 1:s
        val = abs(a * ((ms_x[pt])^2 + (ms_y[pt])^2) + b * ms_x[pt] + c * ms_y[pt] + d)
        println(val)
        if (val < 0.1)
            # Point is inlier
            println("inlier")
        else
            # Point is outlier
        end
    end


end

# Fit a circular line into a point set
function plot_shape(rangex, rangey, points)
    columns = 4
    sz = size(points)[2]
    X = zeros(sz, columns)
    
    for i in 1:sz
        # Construct matrix X that represents the circle.
        X[i, 1] = (points[1, i])^2 + (points[2, i])^2
        X[i, 2] = points[1, i]
        X[i, 3] = points[2, i]
        X[i, 4] = 1

    end

    display(X)
    # Use SVD for solving the resulting set of linear equations.
    svd_vals = svd(X)
    V = svd_vals.V

    # Plot the fitted circle.
    a = V[1, 4]
    b = V[2, 4]
    c = V[3, 4]
    d = V[4, 4]
    f(x, y) = a * (x^2 + y^2) + b*x + c*y + d
    cont = contour!(
        range(rangex[1], rangex[2], 1000),
        range(rangey[1], rangey[2], 1000),
        f,
        levels=0:0,
        color=:red,
        colorbar=nothing, 
        linewidth=2,
        aspect_ratio=:equal
    )

    return [cont, a, b, c, d]
end

main()
