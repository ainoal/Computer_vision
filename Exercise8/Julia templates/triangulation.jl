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
        svd_A = svd(A_hat)
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

function find_epipoles(F)
    # TODO Fill in your code for finding epipoles el and er
   #return el, er
end


function estimate_cameras(F, er)
    # TODO Fill in your code for estimating cameras Ml and Mr from F
    Ml = 0
    Mr = 0
    return Ml, Mr
end
estimate_cameras(F) = estimate_cameras(F, find_epipoles(F)[2])

function linear_triangulation(pl, Ml, pr, Mr)
    # TODO Fill in your code for linear triangulation
    #return X
end



