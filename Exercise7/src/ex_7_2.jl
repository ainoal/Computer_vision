using Images
using Plots
using LinearAlgebra

function get_fundamental_matrix()
    left_img = load(joinpath(@__DIR__, "../data/books1.jpg"))
    right_img = load(joinpath(@__DIR__, "../data/books2.jpg"))

    # Size of the images: (230, 306)
    # Choose 8(+) image coordinates, the same ones from left and 
    # right image.
    p1 = plot(left_img)
    plot!([223], [6], seriestype=:scatter, markersize=:2)
    plot!([185], [52], seriestype=:scatter, markersize=:2)
    plot!([88], [200], seriestype=:scatter, markersize=:2)
    plot!([117], [150], seriestype=:scatter, markersize=:2)
    plot!([68], [228], seriestype=:scatter, markersize=:2)
    plot!([102], [57], seriestype=:scatter, markersize=:2)
    plot!([148], [152], seriestype=:scatter, markersize=:2)
    plot!([28], [171], seriestype=:scatter, markersize=:2)
    plot!([249], [203], seriestype=:scatter, markersize=:2)
    display(p1)

    p2 = plot(right_img)
    plot!([247], [14], seriestype=:scatter, markersize=:2)
    plot!([198], [50], seriestype=:scatter, markersize=:2)
    plot!([36], [157], seriestype=:scatter, markersize=:2)
    plot!([98], [123], seriestype=:scatter, markersize=:2)
    plot!([28], [177], seriestype=:scatter, markersize=:2)
    plot!([120], [27], seriestype=:scatter, markersize=:2)
    plot!([119], [137], seriestype=:scatter, markersize=:2)
    plot!([13], [111], seriestype=:scatter, markersize=:2)
    plot!([156], [222], seriestype=:scatter, markersize=:2)
    display(p2)
    
    points_left_img = transpose([223 6; 185 52; 88 200; 117 150; 68 228;
        102 57; 148 152; 28 171])
    points_right_img = transpose([247 14; 198 50; 36 157; 98 123; 28 177;
        120 27; 117 137; 13 111])

    # Transform to normalized image coordinates.
    T_L = get_normalization_matrix(points_left_img, 8)
    T_R = get_normalization_matrix(points_right_img, 8)

    left_homogeneous = vcat(points_right_img, ones(1, 8))
    right_homogeneous = vcat(points_left_img, ones(1, 8))
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

    # Denormalize. See exercises week 6.
    F = transpose(T_R) * F_normalized * T_L

    # Test with a ninth coordinate pair if F works.
    ninth_coord_left = [249; 203; 1]
    ninth_coord_right = [156; 222; 1]
    test = transpose(ninth_coord_right) * F * ninth_coord_left
    println(test)

    return F
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

get_fundamental_matrix()
