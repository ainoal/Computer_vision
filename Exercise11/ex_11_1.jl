using Statistics
using LinearAlgebra

function main()
    P1 = [0.0; 0.0; 0.0]
    P2 = [0.0; 0.0; 1.0]
    P3 = [0.0; 1.0; 0.0]

    Q1 = [-1.0; 0.0; 1.0]
    Q2 = [-1.0; 0.0; 2.0]
    Q3 = [-1.644; 0.765; 1.000]

    t = abs_orientation([P1, P2, P3], [Q1, Q2, Q3])
    display(t)
    print("\n")

    # Add a 4th point to the set and test the implementation with
    # the new set of points.
    P4 = [1.0; 0.0; 0.0]
    Q4 = [-0.235; 0.644; 1.000]

    t2 = abs_orientation([P1, P2, P3, P4], [Q1, Q2, Q3, Q4])
    display(t2)
end

function abs_orientation(pointset_P, pointset_Q)
    # Calculate the centroids of the point sets
    mean_P = mean(pointset_P)
    mean_Q = mean(pointset_Q)
    #println(mean_P)
    #println(mean_Q)

    # Calculate P hat and Q hat
    P_hat = pointset_P
    sz_P = size(pointset_P)[1]
    for i in 1:sz_P
        P_hat[i] = pointset_P[i] - mean_P
    end
    Q_hat = pointset_P
    sz_Q = size(pointset_Q)[1]
    for i in 1:sz_Q
        Q_hat[i] = pointset_Q[i] - mean_Q
    end
    # Transform the arrays of arrays into a matrix
    P_hat = hcat(P_hat...)      # Note for self: same as P_hat = hcat(P_hat[1], P_hat[2], ...)
    Q_hat = hcat(Q_hat...)
    
    # Calculate 3x3 matrix H
    H = P_hat * transpose(Q_hat)

    # Calculate SVD of H
    svd_H = svd(H)

    # Calculate matrix X
    V = svd_H.V
    U = svd_H.U
    X = V * transpose(U)

    # Calculate the determinant det(X)
    determinant = det(X)
    if (determinant < 0)
        println("Negative determinant of X")
    else
        println("Positive determinant of X")
    end

    # Calculate the translation
    matrix_P = hcat(pointset_P...)
    matrix_Q = hcat(pointset_Q...)
    translation = matrix_Q - X * matrix_P
end

main()
