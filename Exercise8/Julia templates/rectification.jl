include("utils.jl")

function rectify_right(e, x₀)
    # TODO Implement algorithm for finding first rectification transform
    Ox = x₀[1]      # TODO: Check where Ox and Oy come from!
    Oy = x₀[2]

    e_normalized = [e[1]/e[3]; e[2]/e[3]]

    T = [0 0 -Ox;
        0 0 -Oy;
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
    #return Hl
    return 0
end