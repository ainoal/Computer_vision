include("utils.jl")
using LinearAlgebra

function rectify_right(e, x₀)
    # TODO Implement algorithm for finding first rectification transform
    e_normalized = [e[1]/e[3]; e[2]/e[3]]

    T = [1 0 -e[1];
        0 1 -e[2];
        0 0 1]

    e_1 = T ⊗ e_normalized

    alpha = atan(e_1[2], e_1[1])

    R = [cos(alpha) -sin(alpha) 0;
        sin(alpha) cos(alpha) 0;
        0 0 1]
    println("R: ")
    display(R)

    e_2 = R ⊗ e_1

    G = [1 0 0;
        0 1 0;
        -1/e_2[1] 0 1]

    e_3 = G ⊗ e_2

    Hr = G * R * T
    return Hr
end

function rectify_left(pl, pr, Mr, Hr)
    # TODO Implement algorithm for finding second rectification transform
    M = [pl[1, 1] pl[2, 1] 1 -pr[1, 1]]
    for i in 2:8
        M = vcat(M, [pl[1, i] pl[2, i] 1 -pr[1, i]])
    end

    svd_vals = svd(M)
    V = svd_vals.V

    Hl = [V[1, end] V[2, end] V[3, end];
        0 1 0;
        0 0 1]

    return Hl
end
