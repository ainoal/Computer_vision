# RQ decomposition

using MAT
using Plots
using LinearAlgebra
using Random

function main()
        data = matread(joinpath(@__DIR__, "../data/cube_points.mat"))
        M = calibrate(data["points3d"], data["points2d"])

        X = det([M[:, 2] M[:, 3] M[:, 4]])
        Y = -det([M[:, 1] M[:, 3] M[:, 4]])
        Z = det([M[:, 1] M[:, 2] M[:, 4]])
        W = -det([M[:, 1] M[:, 2] M[:, 3]])

        C = [X/W Y/W Z/W]   # Camera center

        I = [1 0 0;
            0 1 0;
            0 0 1]

        temp = [1 0 0 -C[1];
            0 1 0 -C[2];
            0 0 1 -C[3]]

        KR = M * transpose(temp)
        (K, R) = decompose_projection(KR)

        display(K)
        display(R)

        mat = KR * temp     # Not completely matching with M, why?
        #display(mat)
        #display(M)

        plot_frame(data["points3d"], R, C)
end

function plot_frame(points, rotation, C)

    R = [rotation[1, 1] rotation[1, 2] rotation[1, 3] 0;
        rotation[2, 1] rotation[2, 2] rotation[2, 3] 0;
        rotation[3, 1] rotation[3, 2] rotation[3, 3] 0;
        0 0 0 1]

    # The length between origin and a point on an axis is one unit
    u = [1; 0; 0; 1];   # point on x axis
    v = [0; 1; 0; 1];   # point on y axis
    w = [0; 0; 1; 1];   # point on z axis

    # Transforming the points with the transformation matrix
    u = R * u;
    v = R * v;
    w = R * w;

    # Plotting the axes
    plotly()
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

# Function used in exercise 6.1 to find matrix M
function calibrate(points3d, points2d)
    # Construct A
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

    M = transpose(reshape(V[:, 12], 4, 3))
    return M
end

main()
