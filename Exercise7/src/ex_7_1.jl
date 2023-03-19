# Distance estimation from a stereo image pair

using Images
using Plots
#using Unitful
#using Unitful.DefaultSymbols: mm, µm, m

function main()
    right_img = load(joinpath(@__DIR__, "../data/Right_image.png"))
    left_img = load(joinpath(@__DIR__, "../data/Left_image.png"))
    T = 120 * 10^-3       # Baseline = the distance between 2 cameras in a stereo camera
    f_m = 3.8 * 10^-3 
    pix_size = 7.4 * 10^-6
    FOV_degrees = 66.15
    f_pix = 491.35
    half_width = pix_size * 640 / 2


    # The cameras have parallel optical axes and same focal length f.
    # Use the simple example from lecture slides.

    # Manually choose points from the images.
    p1 = plot(right_img)
    plot!([312], [332], seriestype=:scatter, markersize=:2)    # X_R = 312
    plot!([182], [133], seriestype=:scatter, markersize=:1)
    plot!([374], [76], seriestype=:scatter, markersize=:2)
    display(p1)

    p2 = plot(left_img)
    plot!([378], [332], seriestype=:scatter, markersize=:2)    # X_L = 378
    plot!([213], [133], seriestype=:scatter, markersize=:1)
    plot!([395], [80], seriestype=:scatter, markersize=:2)
    display(p2)


    x_R_red = half_width - pix_size * 312
    x_L_red = half_width - pix_size * 378

    x_R_blue = half_width - pix_size * 182
    x_L_blue = half_width - pix_size * 213

    x_R_green = half_width - pix_size * 374
    x_L_green = half_width - pix_size * 395

    calc_distance("red", x_L_red, x_R_red, f_m, T)
    calc_distance("blue", x_L_blue, x_R_blue, f_m, T)
    calc_distance("green", x_L_green, x_R_green, f_m, T)
end

function calc_distance(color, x_L, x_R, f, T)
    d = x_R - x_L
    Z = f * T / d
    println("The ", color, " cube is ", round(Z; digits=2), " m away from the camera.")
end

main()
