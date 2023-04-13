using Statistics
using LinearAlgebra
using Noise
using Plots
include(joinpath(@__DIR__, "ex_11_1.jl"))

function main()
    P1 = [0.0; 0.0; 0.0]
    P2 = [0.0; 0.0; 1.0]
    P3 = [0.0; 1.0; 0.0]
    P4 = [1.0; 0.0; 0.0]

    Q1 = [-1.0; 0.0; 1.0]
    Q2 = [-1.0; 0.0; 2.0]
    Q3 = [-1.644; 0.765; 1.000]
    Q4 = [-0.235; 0.644; 1.000]

    pointset_P = [P1, P2, P3, P4]
    pointset_Q = [Q1, Q2, Q3, Q4]
    t = abs_orientation(pointset_P, pointset_Q)
    display(t)

    matrix_P = hcat(pointset_P...)
    matrix_Q = hcat(pointset_Q...)
    sigma = 0.1
    gaussian_P = add_gauss(matrix_P, sigma, clip=false)
    gaussian_P = [gaussian_P[:, 1], gaussian_P[:, 2], gaussian_P[:, 3], gaussian_P[:, 4]]
    gaussian_Q = add_gauss(matrix_Q, sigma, clip=false)
    gaussian_Q = [gaussian_Q[:, 1], gaussian_Q[:, 2], gaussian_Q[:, 3], gaussian_Q[:, 4]]
    
    t2 = abs_orientation(gaussian_P, gaussian_Q)
    display(t2)

    error = t - t2

    #p = plot()
end


main()
