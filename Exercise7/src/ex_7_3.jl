using LinearAlgebra
include(joinpath(@__DIR__, "ex_7_2.jl"))

function main()
    # Use the fundamental matrix from task 2.
    F = get_fundamental_matrix()
    display(F)

    # Locate epipoles using F. (Lecture slide 27)
    # Left epipole e_L is the null space of F.
    e_L = nullspace(F)
    ninth_coord_right = [156; 222; 1]
    println(e_L)
    #transpose(ninth_coord_right) * F * e_L

    # Right epipole is the null space of F^T.
    e_R = nullspace(transpose(F))
    println(e_R)

end

main()
