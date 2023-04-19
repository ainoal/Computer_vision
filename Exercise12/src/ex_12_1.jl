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
    
    rangex = [-150, 100]
    rangey = [-80, 80]

    plt2 = plot_shape(rangex, rangey, points)
    display(plt2)

    #for pt in 1:s
        # If point is inlier
        #if min_sample_points[:, pt]
        # Else if point is outlier
    #end


end

# The function plots a circle
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

    return cont
end

main()
