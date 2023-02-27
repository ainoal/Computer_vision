using Images
using Plots

function main()
    img = load(joinpath(@__DIR__, "../data/cubes-for-calib.jpg"))
    red = [510 175 25]
    green = [720 -159 25]
    blue = [720 45 25]
    black = [460 -109 25]

    # Treshold the cubes from the background
    locate_red(img)
end

function locate_red(img)
    # Locating the red part in RGB color space
    img_channels = channelview(img)
    filter = img_channels[1, :, :] .> 0.25 .&&
        img_channels[2, :, :] .< 0.18 .&&
        img_channels[3, :, :] .< 0.2
    filter_img = Gray.(filter)
    display(filter_img)
end

main()
