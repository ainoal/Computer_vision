include("utils.jl")
using LinearAlgebra

function rectify_right(e, x₀)
    # TODO Implement algorithm for finding first rectification transform
    Ox = x₀[1]      # TODO: Check where Ox and Oy come from!
    Oy = x₀[2]

    e_normalized = [e[1]/e[3]; e[2]/e[3]]

    T = [0 0 -e[1];
        0 0 -e[2];
        0 0 1]

    e_1 = T ⊗ e_normalized

    alpha = atan(e_1[2], e_1[1])

    R = [cos(alpha) -sin(alpha) 0;
        sin(alpha) cos(alpha) 0;
        0 0 1]

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
    svd_vals = svd(Hr)
    V = svd_vals.V

    F_hat = transpose(reshape(V[:, end], 3, 3))
    svd_F = svd(F_hat)
    
    D_corrected = Diagonal(svd_F.S)
    F_normalized = svd_F.U * D_corrected * svd_F.Vt

    # Denormalize. See exercises week 6.
    F = transpose(T_R) * F_normalized * T_L

    return Hl
end
