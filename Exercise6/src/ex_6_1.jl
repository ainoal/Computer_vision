# Please note that the functions calibrate(points3d, points2d) and
# normalize_and_calibrate(points3d, points2d, N) that are a part of
# this exercise are located in the file normalization_and_calibration.jl

using MAT
using Plots
using LinearAlgebra
include(joinpath(@__DIR__, "normalization_and_calibration.jl"))

function main()
    # Exercise part a: Plot 3D and 2D cubes with the given indices.
    data = matread(joinpath(@__DIR__, "../data/cube_points.mat"))
    idx = data["connecting_indices"]
    plotly()
    plot3d = plot(data["points3d"][1, :], data["points3d"][2, :], data["points3d"][3, :], 
        seriestype =:scatter)
    for i in 1:16
        plot!([data["points3d"][1, idx[i]], data["points3d"][1, idx[i+1]]],
            [data["points3d"][2, idx[i]], data["points3d"][2, idx[i+1]]],
            [data["points3d"][3, idx[i]], data["points3d"][3, idx[i+1]]])
    end
    display(plot3d)

    plot(data["points2d"][1,:], data["points2d"][2,:],
        seriestype=:scatter, aspect_ratio=:equal)
    for i in 1:16
        plot!([data["points2d"][1, idx[i]], data["points2d"][1, idx[i+1]]],
            [data["points2d"][2, idx[i]], data["points2d"][2, idx[i+1]]])
    end

    # Exercise part b: implement a function that parforms direct-linear-transformation
    # (DLT) and finds a suitable projection matrix that would project points3d
    # to points2d. Apply the given function to find projection matrix M.
    M = calibrate(data["points3d"], data["points2d"])

    ones = [1 1 1 1 1 1 1 1]
    p3_homogeneous = vcat(data["points3d"], ones)

    # Exercise part c: project given 3D points using found matrix M.
    p2d_projected = M * p3_homogeneous
    p2d_projected[1, :] = p2d_projected[1, :] ./ p2d_projected[3, :]
    p2d_projected[2, :] = p2d_projected[2, :] ./ p2d_projected[3, :]
    plot!(p2d_projected[1, :], p2d_projected[2, :], 
        seriestype=:scatter, markershape=:rect, markersize=2)

    # Calculate reprojection error.
    error = reprojection_error(8, data["points2d"], p2d_projected[1:2, :])
    print("The reprojection error is ")
    println(error)

    # Exercise part d: add normalization
    # Construct T, U (lecture slides 23, 24)
    M2 = normalize_and_calibrate(data["points3d"], data["points2d"], 8)

    p2d_proj = M2 * p3_homogeneous
    p2d_proj[1, :] = p2d_proj[1, :] ./ p2d_proj[3, :]
    p2d_proj[2, :] = p2d_proj[2, :] ./ p2d_proj[3, :]

    plot2d = plot!(p2d_projected[1, :], p2d_projected[2, :], 
        seriestype=:scatter, markershape=:cross, markersize=1)
    display(plot2d)

    error_2 = reprojection_error(8, data["points2d"], p2d_proj[1:2, :])
    print("With normalization, the reprojection error is ")
    println(error_2)

    # Exercise part e: Compare the results with noisy data.
    noisy_data = matread(joinpath(@__DIR__, "../data/cube_points_noisy.mat"))

    plot_noisy = plot(noisy_data["points2d_noisy"][1,:], noisy_data["points2d_noisy"][2,:],
        seriestype=:scatter, aspect_ratio=:equal)
    for i in 1:16
        plot!([noisy_data["points2d_noisy"][1, idx[i]], noisy_data["points2d_noisy"][1, idx[i+1]]],
            [noisy_data["points2d_noisy"][2, idx[i]], noisy_data["points2d_noisy"][2, idx[i+1]]])
    end

    M3 = calibrate(noisy_data["points3d_noisy"], noisy_data["points2d_noisy"])
    p3_noisy = vcat(noisy_data["points3d_noisy"], ones)

    p2d_noisy = M3 * p3_noisy
    p2d_noisy[1, :] = p2d_noisy[1, :] ./ p2d_noisy[3, :]
    p2d_noisy[2, :] = p2d_noisy[2, :] ./ p2d_noisy[3, :]
    plot!(p2d_noisy[1, :], p2d_noisy[2, :], 
        seriestype=:scatter, markershape=:rect, markersize=2)

    error_noisydata = reprojection_error(8, noisy_data["points2d_noisy"], p2d_noisy[1:2, :])
    print("The reprojection error with noisy data is ")
    println(error_noisydata)

    M4 = normalize_and_calibrate(data["points3d"], data["points2d"], 8)

    p2d_proj_noisy = M4 * p3_homogeneous
    p2d_proj_noisy[1, :] = p2d_proj_noisy[1, :] ./ p2d_proj_noisy[3, :]
    p2d_proj_noisy[2, :] = p2d_proj_noisy[2, :] ./ p2d_proj_noisy[3, :]

    plot!(p2d_proj_noisy[1, :], p2d_proj_noisy[2, :], 
        seriestype=:scatter, markershape=:cross, markersize=2)
    display(plot_noisy)

    error_2 = reprojection_error(8, noisy_data["points2d_noisy"], p2d_proj_noisy[1:2, :])
    print("With normalization, the reprojection error with noisy data is ")
    println(error_2)

    # Conclusions: with the first dataset, normalization does not make a
    # significant difference because the data does not contain oise. However,
    # real life data usually has some noise. When we compare the projections
    # of our noisy data with and without normalization, we can see
    # that with normalization the projections are good, whereas without
    # they do not produce a satisfactory result (rectangles in the last plot).
end

function reprojection_error(N, points, projected_points)
    sum = 0
    for i in 1:N
        sum += abs(points[i] - projected_points[i])
    end
    error = (1/N) * sum
    return error
end

main()
