include("utils.jl")


function find_fundamental_matrix(pl, pr)
    # TODO Fill in your code for finding fundamental matrix F
    # Transform to normalized image coordinates.
    T_L = get_normalization_matrix(pl[:, 1:8], 8)
    T_R = get_normalization_matrix(pr[:, 1:8], 8)

    left_homogeneous = vcat(pl[:, 1:8], ones(1, 8))
    right_homogeneous = vcat(pr[:, 1:8], ones(1, 8))
    left_normalized = T_L * left_homogeneous
    right_normalized = T_R * right_homogeneous

    # Determine the fundamental matrix Fˆ from the singular vector corresponding to
    # smallest singular value of Aˆ.
    A_hat = get_matrix_A(left_normalized, right_normalized)
    svd_A = svd(A_hat, full=true)
    V = svd_A.V
    F_hat = transpose(reshape(V[:, end], 3, 3))
    svd_F = svd(F_hat)
    
    # Calculate Fˆ′ from Fˆ using SVD such that Fˆ′ = UD′V^T and D'
    # has the smallest singular value set equal to zero.
    D_corrected = Diagonal(svd_F.S)
    F_normalized = svd_F.U * D_corrected * svd_F.Vt

    # Denormalize
    F = transpose(T_R) * F_normalized * T_L

    # Test with a ninth coordinate pair if F works.
    ninth_coord_left = pl[:, 9]
    ninth_coord_right = pr[:, 9]
    ninth_coord_left = [ninth_coord_left; 1]
    ninth_coord_right = [ninth_coord_right; 1]
    test = transpose(ninth_coord_right) * F * ninth_coord_left
    println(test)
    return F
end

function get_normalization_matrix(points2d, N)
    # Constructing matrix T for normalization for image (2D) points.
    sumx = 0
    sumy = 0
    sumd = 0

    for i in 1:N
        sumx += points2d[1, i]
        sumy += points2d[2, i]
    end
    x = (1/N) * sumx
    y = (1/N) * sumy

    for i in 1:N
        sumd += sqrt((points2d[1, i] - x)^2 + (points2d[2, i] - y)^2)
    end
    d = (1/N) * sumd

    T = [sqrt(2)/d 0 -(sqrt(2))*x/d;
        0 sqrt(2)/d -(sqrt(2))*y/d;
        0 0 1]

    return T
end

function get_matrix_A(left, right)
    Xr = right[1, :]
    Yr = right[2, :]
    Xl = left[1, :]
    Yl = left[2, :]

    A = [Xr[1]*Xl[1] Xr[1]*Yl[1] Xr[1] Yr[1]*Xl[1] Yr[1]*Yl[1] Yr[1] Xl[1] Yl[1] 1]
    for n in 2:8
        row = [Xr[n]*Xl[n] Xr[n]*Yl[n] Xr[n] Yr[n]*Xl[n] Yr[n]*Yl[n] Yr[n] Xl[n] Yl[n] 1]
        A = vcat(A, row)
    end
    return A
end

function find_epipoles(F)
    # TODO Fill in your code for finding epipoles el and er
    svd_F = svd(F)
    e_L = svd_F.V[:, end]
    e_R = svd_F.U[:, end]
    return e_L, e_R
end


function estimate_cameras(F, er)
    # TODO Fill in your code for estimating cameras Ml and Mr from F
    eRx = [0 -er[3] er[2];
        er[3] 0 -er[1];
        -er[2] er[1] 0]

    # TODO: Check how to construct M_L and M_R
    Ml = hcat(Matrix{Int}(I, 3, 3), [0; 0; 0])
    Mr = hcat(eRx * F, er)

    return Ml, Mr
end
estimate_cameras(F) = estimate_cameras(F, find_epipoles(F)[2])

function linear_triangulation(pl, Ml, pr, Mr)
    # TODO Fill in your code for linear triangulation.
    # NOTE: " do not forget to include normalization"
    len = size(pl)[2] - 1

    A = [pl[1, 1] * transpose(Ml[3, :]) - transpose(Ml[1, :]);
        pl[2, 1] * transpose(Ml[3, :]) - transpose(Ml[2, :]);
        pr[1, 1] * transpose(Mr[3, :]) - transpose(Mr[1, :]);
        pr[2, 1] * transpose(Mr[3, :]) - transpose(Mr[2, :])]

    svd_vals = svd(A)
    P = svd_vals.V[:, end]
    X = Ml * P

    for i in 2:len
        A = [pl[1, i] * transpose(Ml[3, :]) - transpose(Ml[1, :]);
            pl[2, i] * transpose(Ml[3, :]) - transpose(Ml[2, :]);
            pr[1, i] * transpose(Mr[3, :]) - transpose(Mr[1, :]);
            pr[2, i] * transpose(Mr[3, :]) - transpose(Mr[2, :])]

        svd_vals = svd(A)
        P = svd_vals.V[:, end]
        X = hcat(X, Ml * P)
    end

    return X
end

function reprojection_error(pl, pr, X, Ml, Mr)
    X_homogeneous = vcat(X, [1 1 1 1 1 1 1 1])
    pl_hat = Ml * X_homogeneous
    pr_hat = Mr * X_homogeneous

    pl_hat = transpose([pl_hat[1, :] ./ pl_hat[3, :] pl_hat[2, :] ./ pl_hat[3, :]])
    pr_hat = transpose([pr_hat[1, :] ./ pr_hat[3, :] pr_hat[2, :] ./ pr_hat[3, :]])

    err = 0
    for i in 1:8
        err += sqrt((pl[1, i] - pl_hat[1, i])^2 + (pl[2, i] - pl_hat[2, i])^2) + 
            sqrt((pr[1, i] - pr_hat[1, i])^2 + (pr[2, i] - pr_hat[2, i])^2)
    end
    return err

end
