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
    w = 640

    # There is a small error. TODO: calculate X_L and x_R from
    # the angle (known from FOV), and focal length. Use trigonometry.

    # The cameras have parallel optical axes and same focal length f.
    # Use the simple example from lecture slides.

    # Manually choose X_L and X_R. Let's choose the further upper right
    # corner of the red cube as X. 
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

    conversion = f_pix / f_m
    T = conversion * T

    #f_pix_test = conversion * f_m
    #println(f_pix_test)

    x_R_red = 312 - w/2 + T
    x_L_red = 378 - w/2

    x_R_blue = 182 - w/2 + T
    x_L_blue = 213 - w/2

    x_R_green = 374 - w/2 + T
    x_L_green = 395 - w/2

    calc_distance("red", x_L_red, x_R_red, f_pix, T)
    calc_distance("blue", x_L_blue, x_R_blue, f_pix, T)
    calc_distance("green", x_L_green, x_R_green, f_pix, T)
end

function calc_distance(color, x_L, x_R, f, T)
    d = x_R - x_L
    Z = f * T / d
    print("The ")
    print(color)
    print(" cube is ")
    print(round(Z; digits=5))
    print(" m away from the camera.\n")
end

main()
