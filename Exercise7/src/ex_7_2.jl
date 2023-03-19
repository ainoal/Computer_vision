using Images
using Plots

function main()
    books1 = load(joinpath(@__DIR__, "../data/books1.jpg"))
    books2 = load(joinpath(@__DIR__, "../data/books2.jpg"))

    # TODO: Choose 8(+) image coordinates, the same ones from left and 
    # right image.
    # TODO: Transform to normalized image coordinates.
    
    # TODO:  Determine the fundamental matrix Fˆ from the singular vector corresponding to
    # smallest singular value of Aˆ.

    # TODO: Calculate Fˆ′ from Fˆ using SVD such that Fˆ′ = UD′V^T and D'
    # has the smallest singular value set equal to zero.

    # TODO: Denormalize. See exercises week 6.
end



function get_normalization_matrix(points2d)
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
