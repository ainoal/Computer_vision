using Images
using Plots
using LinearAlgebra

function main()
    left_img = load(joinpath(@__DIR__, "../data/books1.jpg"))
    right_img = load(joinpath(@__DIR__, "../data/books2.jpg"))

    # print(size(left_img)) # (230, 306)
    # TODO: Choose 8(+) image coordinates, the same ones from left and 
    # right image.

    p2 = plot(left_img)
    plot!([223], [6], seriestype=:scatter, markersize=:2)
    plot!([185], [52], seriestype=:scatter, markersize=:2)
    plot!([90], [200], seriestype=:scatter, markersize=:2)
    plot!([117], [150], seriestype=:scatter, markersize=:2)
    plot!([68], [227], seriestype=:scatter, markersize=:2)
    plot!([103], [60], seriestype=:scatter, markersize=:2)
    plot!([148], [152], seriestype=:scatter, markersize=:2)
    plot!([30], [170], seriestype=:scatter, markersize=:2)
    plot!([250], [200], seriestype=:scatter, markersize=:2)
    display(p2)

    p1 = plot(right_img)
    plot!([250], [15], seriestype=:scatter, markersize=:2)
    plot!([200], [50], seriestype=:scatter, markersize=:2)
    plot!([38], [155], seriestype=:scatter, markersize=:2)
    plot!([98], [120], seriestype=:scatter, markersize=:2)
    plot!([28], [177], seriestype=:scatter, markersize=:2)
    plot!([120], [28], seriestype=:scatter, markersize=:2)
    plot!([118], [138], seriestype=:scatter, markersize=:2)
    plot!([13], [110], seriestype=:scatter, markersize=:2)
    plot!([160], [225], seriestype=:scatter, markersize=:2)
    display(p1)
    
    points_left_img = transpose([220 7; 185 52; 90 200; 117 150; 68 227;
        103 60; 148 152; 30 170])
    points_right_img = transpose([250 15; 200 50; 38 155; 98 120; 28 177;
        120 28; 118 138; 13 110])

    # TODO: Transform to normalized image coordinates.
    T_L = get_normalization_matrix(points_left_img, 8)
    T_R = get_normalization_matrix(points_right_img, 8)

    left_homogeneous = vcat(points_right_img, ones(1, 8))
    right_homogeneous = vcat(points_left_img, ones(1, 8))
    left_normalized = T_L * left_homogeneous
    right_normalized = T_R * right_homogeneous

    # TODO:  Determine the fundamental matrix Fˆ from the singular vector corresponding to
    # smallest singular value of Aˆ.
    A_hat = get_matrix_A(left_normalized, right_normalized)
    #display(A_hat)
    #F_hat = svd(A_hat) ? wrong?

    svd_A = svd(A_hat)
    V = svd_A.V
    F_hat = (reshape(V[:, end], 3, 3))
    #display(F_hat)
    svd_F = svd(F_hat)
    
    D_corrected = svd_F.V
    #display(D_corrected)
    #println(D_corrected[end, end])
    #D_corrected[end, end] = 0

    #display(svd_F.U)
    #display(D_corrected)
    #display(svd_F.Vt)
    F_normalized = svd_F.U * Diagonal(svd_F.S) * svd_F.Vt #<- Just testing
    #F_normalized = svd_F.U * D_corrected * svd_F.Vt
    F = transpose(T_R) * F_normalized * T_L

    #println(T_R)
    #println(right_homogeneous[:, end])
    test = transpose(right_homogeneous[:, end]) * F * left_homogeneous[:, end]
    #A = A_hat
    #A[]
    #F_normalized = 

    #F_hat = V[:, end]
    #F_hat = transpose(reshape(V[:, end], 4, 3))

    # TODO: Calculate Fˆ′ from Fˆ using SVD such that Fˆ′ = UD′V^T and D'
    # has the smallest singular value set equal to zero.

    # TODO: Denormalize. See exercises week 6.
end

function get_normalization_matrix(points2d, N)
    # Construct T (lecture slides 23, 24 last week).
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

main()
