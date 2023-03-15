# Distance estimation from a stereo image pair

using Images
using Unitful
using Unitful.DefaultSymbols: mm, µm, m

function main()
    right_img = load(joinpath(@__DIR__, "../data/Right_image.png"))
    left_img = load(joinpath(@__DIR__, "../data/Left_image.png"))
    D = 120mm
    f_mm = 3.8mm
    pix_size = 7.4µm
    FOV_degrees = 66.15
    f_pix = 491.35

    # The cameras have parallel optical axes and same focal length f.
    # Use the simple example from lecture slides.

    
    # d = x_R - x_L
    #Z = f * T / d
end

main()
