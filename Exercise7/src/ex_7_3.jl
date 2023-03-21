using LinearAlgebra
using Plots
include(joinpath(@__DIR__, "ex_7_2.jl"))

function main()
    right_img = load(joinpath(@__DIR__, "../data/books2.jpg"))
    ninth_coord = [156; 222; 1]
    # Use the fundamental matrix from task 2.
    F = get_fundamental_matrix()

    # Locate epipoles using F. (Lecture slide 27)
    # Left epipole e_L is the null space of F.
    svd_F = svd(F)
    e_L = svd_F.V[:, end]
    e_L1 = e_L[1]/e_L[3] 
    e_L2 = e_L[2]/e_L[3]
    e_L = [e_L1 e_L2]
    println(e_L)

    # Right epipole is the null space of F^T.
    e_R = svd_F.U[:, end]
    e_R1 = e_R[1]/e_R[3] 
    e_R2 = e_R[2]/e_R[3]
    e_R = [e_R1 e_R2]
    println(e_R)

    # Plot the epipolar line.
    plot(right_img)
    plot!([e_R1], [e_R2], seriestype=:scatter, markersize=:4)
    plot!([ninth_coord[1]], [ninth_coord[2]], seriestype=:scatter, markersize=:4)
    p = plot!([ninth_coord[1], e_R1], [ninth_coord[2], e_R2])
    display(p)
end

main()
