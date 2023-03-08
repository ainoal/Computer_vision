# RQ decomposition

using MAT
using Plots
using LinearAlgebra
using Random
plotlyjs()
include(joinpath(@__DIR__, "../lib/plots_plotly_extra.jl"))
include(joinpath(@__DIR__, "normalization_and_calibration.jl"))

function main()
        data = matread(joinpath(@__DIR__, "../data/cube_points.mat"))
        M = normalize_and_calibrate(data["points3d"], data["points2d"], 8)

        X = det([M[:, 2] M[:, 3] M[:, 4]])
        Y = -det([M[:, 1] M[:, 3] M[:, 4]])
        Z = det([M[:, 1] M[:, 2] M[:, 4]])
        W = -det([M[:, 1] M[:, 2] M[:, 3]])

        C = [X/W Y/W Z/W]   # Camera center

        temp = [1 0 0 -C[1];
            0 1 0 -C[2];
            0 0 1 -C[3]]

        KR = M/temp
        K, R = decompose_projection(KR)

        plot_frame(data["points3d"], R, C)

end

function plot_frame(points, R, C)
    # Translation is C. Take that into account in the transformation matrix!
    T = [R[1, 1] R[1, 2] R[1, 3] C[1];
        R[2, 1] R[2, 2] R[2, 3] C[2];
        R[3, 1] R[3, 2] R[3, 3] C[3];
        0 0 0 1]

    # The length between origin and a point on an axis is one unit
    u = [1; 0; 0; 1]   # point on x axis
    v = [0; 1; 0; 1]   # point on y axis
    w = [0; 0; 1; 1]   # point on z axis

    # Transforming the points with the transformation matrix
    u = T * u
    v = T * v
    w = T * w

    # Plotting the axes
    plot(points[1, :], points[2, :], points[3, :], seriestype =:scatter)
    plot!([C[1], u[1]], [C[2], u[2]], [C[3], u[3]],
        color=RGB(1, 0, 0), markershape=:none, aspect_ratio=:equal)
    plot!([C[1], v[1]], [C[2], v[2]], [C[3], v[3]], 
        color=RGB(0, 1, 0), markershape=:none, aspect_ratio=:equal)
    p = plot!([C[1], w[1]], [C[2], w[2]], [C[3], w[3]],
        color=RGB(0, 0, 1), markershape=:none, aspect_ratio=:equal)
    display(p)

end

flipud(M) = reverse(M, dims=1)

function decompose_projection(M)
    Q0, R0 = M |> flipud |> transpose |> qr
    R = R0 |> transpose |> reverse
    Q = Q0 |> transpose |> flipud
    return (R, Q)
end

main()
