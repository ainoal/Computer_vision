using MAT
using Plots
using LinearAlgebra

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
    plot2d = plot!(p2d_projected[1, :], p2d_projected[2, :], 
        seriestype=:scatter, markershape=:rect, markersize=2)
    display(plot2d)

    # Calculate reprojection error.
    error = reprojection_error(8, data["points2d"], p2d_projected[1:2, :])
    print("The reprojection error is ")
    println(error)

    # Exercise part d: add normalization
    # Construct T, U (lecture slides 23, 24)
    #T = [sqrt(2)/]

    # p2 = Tp2, p3 = Up3
    M2 = calibrate(data["points3d"], data["points2d"], true);

    # M2 = T^-1*M2*U
end

calibrate(points3d, points2d) = calibrate(points3d, points2d, false)
function calibrate(points3d, points2d, normalization)
    # Construct A (slide 19 in lecture slides)
    X = points3d[1, :]
    Y = points3d[2, :]
    Z = points3d[3, :]
    
    x = points2d[1, :]
    y = points2d[2, :]

    # TODO: make matrix A more beautiful by first initializing an empty matrix
    # and then updating 2 rows at a time inside a for loop
    A = [X[1] Y[1] Z[1] 1 0 0 0 0 -x[1]*X[1] -x[1]*Y[1] -x[1]*Z[1] -x[1];
        0 0 0 0 X[1] Y[1] Z[1] 1 -y[1]*X[1] -y[1]*Y[1] -y[1]*Z[1] -y[1];
        X[2] Y[2] Z[2] 1 0 0 0 0 -x[2]*X[2] -x[2]*Y[2] -x[2]*Z[2] -x[2];
        0 0 0 0 X[2] Y[2] Z[2] 1 -y[2]*X[2] -y[2]*Y[2] -y[2]*Z[2] -y[2];
        X[3] Y[3] Z[3] 1 0 0 0 0 -x[3]*X[3] -x[3]*Y[3] -x[3]*Z[3] -x[3];
        0 0 0 0 X[3] Y[3] Z[3] 1 -y[3]*X[3] -y[3]*Y[3] -y[3]*Z[3] -y[3];
        X[4] Y[4] Z[4] 1 0 0 0 0 -x[4]*X[4] -x[4]*Y[4] -x[4]*Z[4] -x[4];
        0 0 0 0 X[4] Y[4] Z[4] 1 -y[4]*X[4] -y[4]*Y[4] -y[4]*Z[4] -y[4];
        X[5] Y[5] Z[5] 1 0 0 0 0 -x[5]*X[5] -x[5]*Y[5] -x[5]*Z[5] -x[5];
        0 0 0 0 X[5] Y[5] Z[5] 1 -y[5]*X[5] -y[5]*Y[5] -y[5]*Z[5] -y[5];
        X[6] Y[6] Z[6] 1 0 0 0 0 -x[6]*X[6] -x[6]*Y[6] -x[6]*Z[6] -x[6];
        0 0 0 0 X[6] Y[6] Z[6] 1 -y[6]*X[6] -y[6]*Y[6] -y[6]*Z[6] -y[6];
        X[7] Y[7] Z[7] 1 0 0 0 0 -x[7]*X[7] -x[7]*Y[7] -x[7]*Z[7] -x[7];
        0 0 0 0 X[7] Y[7] Z[7] 1 -y[7]*X[7] -y[7]*Y[7] -y[7]*Z[7] -y[7];
        X[8] Y[8] Z[8] 1 0 0 0 0 -x[8]*X[8] -x[8]*Y[8] -x[8]*Z[8] -x[8];
        0 0 0 0 X[8] Y[8] Z[8] 1 -y[8]*X[8] -y[8]*Y[8] -y[8]*Z[8] -y[8]]

    # Use SVD for solving for M
    svd_vals = svd(A)
    V = svd_vals.V
    # return M = reshape(V[:, end], 3, 4)
    M = transpose(reshape(V[:, 12], 4, 3))
    return M
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
