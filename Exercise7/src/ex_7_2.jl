using Images
using Plots

function main()
    left_img = load(joinpath(@__DIR__, "../data/books1.jpg"))
    right_img = load(joinpath(@__DIR__, "../data/books2.jpg"))

    # print(size(left_img)) # (230, 306)
    # TODO: Choose 8(+) image coordinates, the same ones from left and 
    # right image.

    p2 = plot(left_img)
    plot!([220], [7], seriestype=:scatter, markersize=:2)
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

    # TODO:  Determine the fundamental matrix Fˆ from the singular vector corresponding to
    # smallest singular value of Aˆ.

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

main()
