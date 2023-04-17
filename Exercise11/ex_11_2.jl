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
    t1 = abs_orientation(pointset_P, pointset_Q)
    matrix_P = hcat(pointset_P...)
    matrix_Q = hcat(pointset_Q...)

    # Add Gaussian noise to the point coordinates and examine the
    # amount of change in t with respect to correct value.
    sigma1 = 0.1
    error1 = calculate_error(matrix_P, matrix_Q, sigma1, t1)
    sigma2 = 0.5
    error2 = calculate_error(matrix_P, matrix_Q, sigma2, t1)
    sigma3 = 1
    error3 = calculate_error(matrix_P, matrix_Q, sigma3, t1)
    sigma4 = 3
    error4 = calculate_error(matrix_P, matrix_Q, sigma4, t1)
    sigma5 = 5
    error5 = calculate_error(matrix_P, matrix_Q, sigma5, t1)

    # Plot the errors.
    sigmas = [sigma1 sigma2 sigma3 sigma4 sigma5]
    errors = [error1 error2 error3 error4 error5]
    p = plot(sigmas, errors, seriestype=:scatter)
    display(p)

    # From the plot, we can see that on average, the more noise we add,
    # the bigger the error. However, as Gaussian noise is random, the
    # exact results differ run by run.

    # Corrupt one of the points with a large disturbance.
    Q1_corrupted = [-100.0; 10.0; 84.0]
    P1_corrupted = [600.0; -385.0; 99.0]
    pointset_Q_corrupted = [Q1_corrupted, Q2, Q3, Q4]
    pointset_P_corrupted = [P1_corrupted, P2, P3, P4]
    t_corrupted = abs_orientation(pointset_P_corrupted, pointset_Q_corrupted)
    error_onecorrupted = sqrt((t1[1] - t_corrupted[1])^2 + (t1[2] - t_corrupted[2])^2 + (t1[3] - t_corrupted[3])^2)
    print("Error with one corrupted point: ")
    println(error_onecorrupted)

    # We can see that when we corrupt one point with a large disturbance, the
    # error becomes also really big. This also depends on how large the disturbance
    # added to the point is.
end

function calculate_error(matrix_P, matrix_Q, sigma, t1)
    gaussian_P = add_gauss(matrix_P, sigma, clip=false)
    gaussian_P = [gaussian_P[:, 1], gaussian_P[:, 2], gaussian_P[:, 3], gaussian_P[:, 4]]
    gaussian_Q = add_gauss(matrix_Q, sigma, clip=false)
    gaussian_Q = [gaussian_Q[:, 1], gaussian_Q[:, 2], gaussian_Q[:, 3], gaussian_Q[:, 4]]
    
    t2 = abs_orientation(gaussian_P, gaussian_Q)

    error = sqrt((t1[1] - t2[1])^2 + (t1[2] - t2[2])^2 + (t1[3] - t2[3])^2)
    return error
end

main()
