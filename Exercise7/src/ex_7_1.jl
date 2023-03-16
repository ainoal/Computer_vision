# Distance estimation from a stereo image pair

using Images
using Unitful
using Unitful.DefaultSymbols: mm, µm, m

function main()
    right_img = load(joinpath(@__DIR__, "../data/Right_image.png"))
    left_img = load(joinpath(@__DIR__, "../data/Left_image.png"))
    T = 120 * 10^-3       # Baseline = the distance between 2 cameras in a stereo camera
    f_m = 3.8* 10^-3 
    pix_size = 7.4 * 10^-6
    FOV_degrees = 66.15
    f_pix = 491.35

    # The cameras have parallel optical axes and same focal length f.
    # Use the simple example from lecture slides.

    # Manually choose X_L and X_R. Let's choose the further upper right
    # corner of the red cube as X. 
    p1 = plot(right_img)
    plot!([338], [292], seriestype=:scatter)    # X_R = 338
    display(p1)

    p2 = plot(left_img)
    plot!([402], [292], seriestype=:scatter)    # X_L = 402
    display(p2)

    x_L = 402
    x_R = 338

    d = x_L - x_R
    println(d)
    Z = f_pix * T / d
    print("The further upper right corner of the red cube is ")
    print(Z)
    print(" m away from the camera.")
end

main()
