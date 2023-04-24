using MAT
using Plots
using Random
using LinearAlgebra

function main()
    # Load and plot the points
    data = matread(joinpath(@__DIR__, "../data/circle_points.mat"))
    points = data["points"]
    plt = plot(points[1, :], points[2, :], seriestype=:scatter, aspect_ratio=:equal)
    
    # Line fitting
    rangex = [-150, 100]
    rangey = [-80, 80]
    fitted_circle = fit_circle(points)
    f = fitted_circle[1]
    a = fitted_circle[2]
    b = fitted_circle[3]
    c = fitted_circle[4]
    d = fitted_circle[5]
    #display(plt2)

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

    # Implement RANSAC
    # Repeat steps 1 and 2 until the size of the consistent set (inliers)
    # is greater than treshold t.
    t = 360
    #N = log10(1 - p) / log10(1 - (1 - e))
    N = 10
    largest_set = 0
    largest_set_points = []
    best_model = [0, 0, 0, 0, 0]
    for n in 1:N
        circlefit = RANSAC_iter(points)
        inliers = circlefit[1]
        model = circlefit[2]
        num_inliers = size(inliers)[1]
        if (num_inliers > largest_set)
            largest_set = num_inliers
            largest_set_points = inliers
            best_model = model
        end

        # If the size of the consistent set is greater than t, re-estimate
        # the model using the inliers and terminate.
        if (num_inliers >= t)
            inlier_matrix = hcat(inliers...)
            circlefit = RANSAC_iter(inlier_matrix)
            inliers = circlefit[1]
            model = circlefit[2]
            num_inliers = size(inliers)[1]
            if (num_inliers > largest_set)
                largest_set = num_inliers
                largest_set_points = inliers
                best_model = model
            end
            println("here")
            break
        # If the size of the consistent set is smaller than t, repeat from 1.
        end
    end
    f2 = best_model[1]
    a2 = best_model[2]
    b2 = best_model[3]
    c2 = best_model[4]
    d2 = best_model[5]

    cont = contour!(
        range(rangex[1], rangex[2], 1000),
        range(rangey[1], rangey[2], 1000),
        f2,
        levels=0:0,
        color=:red,
        colorbar=nothing, 
        linewidth=2,
        aspect_ratio=:equal
    )

    # The fit using RANSAC is better than without it because outliers influence
    # the model less.
end

function RANSAC_iter(points)
    # Step 1: Randomly select a minimal sample of data points and
    # estimate the model using it.
    s = 10
    sz = size(points)[2]
    perm = randperm(sz)
    min_sample = perm[1:s]
    min_sample_points = points[:, min_sample]

    rangex = [-150, 100]
    rangey = [-80, 80]
    fitted_circle = plot_shape(rangex, rangey, min_sample_points)
    plt3 = fitted_circle[1]
    a = fitted_circle[2]
    b = fitted_circle[3]
    c = fitted_circle[4]
    d = fitted_circle[5]
    display(plt3)

    # Step 2: determine the set of data within a treshold d of the model.
    # Use algebraic error for tresholding the points.
    treshold = 0.1
    x = points[1, :]
    y = points[2, :]

    inliers = []
    for i in 1:sz
        val = abs(a * ((x[i])^2 + (y[i])^2) + b * x[i] + c * y[i] + d)
        #println(val)
        if (val < treshold)
            # Point is inlier
            push!(inliers, points[:, i])
        end
    end

    return [inliers, fitted_circle]
end

# Fit a circular line into a point set
function fit_circle(points)
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

    return [f, a, b, c, d]
end


main()
