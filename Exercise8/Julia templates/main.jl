import Pkg; Pkg.activate(".")

using Images
using Statistics

using Plots
gr()

plot_image(I; kws...) = plot_image!(plot(), I; kws...)
plot_image!(I; kws...) = plot_image!(Plots.current(), I; kws...)
plot_image!(p, I; kws...) = plot!(p, I; aspect_ratio=:equal, size=size(I), framestyle=:none, kws...)



# Load images
Il = load(joinpath(@__DIR__, "../data/books1.jpg"))
Ir = load(joinpath(@__DIR__, "../data/books2.jpg"))


pl = [249.1886  251.1865  185.7675  186.6054   96.5758   19.0369   87.8358  201.7579 72.6772;
204.1058   50.1468   51.0201  126.5525   80.9284  148.0381  200.0909  205.3973 54.0182]
pr = [154.4705  257.6632  199.4353  166.7630   95.2722   10.0000   35.7504  121.1513 85.2440;
223.2215   70.5352   48.8615  124.8812   47.2440   86.0000  157.2300  205.4297 12.9543]



# TASK 1

include("triangulation.jl")

function task1(Il, Ir, pl, pr)
    # TODO: Implement find_fundamental_matrix, estimate_cameras, linear_triangulation from file triangulation.jl
    F = find_fundamental_matrix(pl, pr)
    Ml, Mr = estimate_cameras(F)
    X = linear_triangulation(pl, Ml, pr, Mr)

    # TODO: Calculate reprojection error using Ml, Mr and X
    # pl, pr = given values
    # "hat values" = values in the matrix X projected by using Ml
    error = reprojection_error(8, pl, pr, X)
    print("Error: ")
    println(error)
end


# TASK 2

include("gold_standard.jl")

function task2(Il, Ir, pl, pr)
    # TODO: implement missing parts in gold_standard from file gold_standard.jl
    F, pl, Ml, pr, Mr, X = gold_standard(pl, pr)

    # TODO: Plot both images and epipolar lines for each of the points from pl and pr
end


# TASK 3

include("rectification.jl")

function task3(Il, Ir, pl, pr)
    # TODO: Implement rectify_right, rectify_left from file rectification.jl
    F, pl, Ml, pr, Mr, X = gold_standard(pl, pr)

    _, er = find_epipoles(F)

    Hr = deshear(rectify_right(er, reverse(size(Ir))./2), Ir)
    Hl = deshear(rectify_left(pl, pr, Mr, Hr), Il)

    rIl, rIr, y_offset = warp_images(Il, Hl, Ir, Hr)

    rectified_pair = hcat(rIl, rIr)

    # TODO: Plot rectified images side-by-side along with epipolar lines on them
    # Do you notice the difference?
end

task1(Il, Ir, pl, pr)
task2(Il, Ir, pl, pr)
#task3(Il, Ir, pl, pr)
