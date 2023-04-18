using MAT
using Plots
using Random

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
    
    for pt in 1:s
        # If point is inlier
        #if min_sample_points[:, pt]
        # Else if point is outlier
    end


end

main()
