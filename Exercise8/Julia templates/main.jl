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

# The first 8 coordinates have been used for 8 point algorithm and the 9th coordinate
# has been used for testing the algorithm.
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
    println("X:")
    display(X)

    # TODO: Calculate reprojection error using Ml, Mr and X
    # pl, pr = given values
    # "hat values" = values in the matrix X projected by using Ml
    error = reprojection_error(pl, pr, X, Ml, Mr)
    print("Reprojection error: ")
    println(error)

    # Plotting the epipolar lines
    el, er = find_epipoles(F)
    plot_epipolar_lines(pl, pr, el, er)
 
end


# TASK 2

include("gold_standard.jl")

function task2(Il, Ir, pl, pr)
    # TODO: implement missing parts in gold_standard from file gold_standard.jl
    F, pl, Ml, pr, Mr, X = gold_standard(pl, pr)

    # TODO: Plot both images and epipolar lines for each of the points from pl and pr
    el, er = find_epipoles(F)
    plot_epipolar_lines(pl, pr, el, er)
    
end


# TASK 3

include("rectification.jl")

function task3(Il, Ir, pl, pr)
    # TODO: Implement rectify_right, rectify_left from file rectification.jl

    # Rectification means transforming a pair of stereo images so that conjugate epipolar
    # lines become collinear and parallel to one of the image axes. Rectification
    # is used in computer vision to simplify finding matching points between stereo images.

    F, pl, Ml, pr, Mr, X = gold_standard(pl, pr)

    _, er = find_epipoles(F)

    Hr = deshear(rectify_right(er, reverse(size(Ir))./2), Ir)
    Hl = deshear(rectify_left(pl, pr, Mr, Hr), Il)

    println("Hl:")
    display(Hl)
    println("Hr:")
    display(Hr)

    rIl, rIr, y_offset = warp_images(Il, Hl, Ir, Hr)

    rectified_pair = hcat(rIl, rIr)

    # TODO: Plot rectified images side-by-side along with epipolar lines on them
    # Do you notice the difference?

    rp = plot(rectified_pair)
    el, er = find_epipoles(F)

    for i in 1:8
        left_coord = pl[:, i]
        params_l = cross([left_coord[1]; left_coord[2]; 1], [el[1]; el[2]; el[3]])
        x = [0, 306]
        y(x) = (params_l[1] * x - params_l[3]) / params_l[2]
        #plot!(x, y)
    end
    display(rp)

    # I did not plot the epipolar lines on the images because
    # (1) the left epipolar lines are incorrect and
    # (2) my rectification is not working correctly
end

function plot_epipolar_lines(pl, pr, el, er)
    pltl = plot(Il)
    for i in 1:8
        left_coord = pl[:, i]
        params_l = cross([left_coord[1]; left_coord[2]; 1], [el[1]; el[2]; el[3]])
        x = [0, 306]
        y(x) = (params_l[1] * x - params_l[3]) / params_l[2]
        plot!(x, y)
    end
    display(pltl)

    pltr = plot(Ir)
    for i in 1:8
        right_coord = pr[:, i]
        params_r = cross([right_coord[1]; right_coord[2]; 1], [er[1]; er[2]; er[3]])
        x = [0, 306]
        y(x) = (params_r[1] * x - params_r[3]) / params_r[2]
        plot!(x, y)
    end
    display(pltr)
end


task1(Il, Ir, pl, pr)
task2(Il, Ir, pl, pr)
task3(Il, Ir, pl, pr)
