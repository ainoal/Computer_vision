# Color segmentation
using Images

function main()
    blocks = load(joinpath(@__DIR__, "../data/blocks-col.png"))
    circles = load(joinpath(@__DIR__, "../data/circles.png"))

    #@show typeof(blocks)
    #pix = blocks[1, 200]
    #println(typeof(pix))
    #println(pix.r, ", ", pix.g, ", ", pix.b)
    #display(pix)

    # Locating the red block in RGB color space
    img_channels = channelview(blocks)
    filter = img_channels[1, :, :] .> 0.56 .&&
        img_channels[2, :, :] .< 0.47 .&&
        img_channels[3, :, :] .< 0.53
    filter_img = Gray.(filter)
    display(filter_img)

    # Locating the red block in HSV color space
    blocks_hsv = HSV.(blocks)
    #display(blocks_hsv)
    #@show typeof(blocks_hsv)
    hsv_channels = channelview(blocks_hsv)
    #@show size(hsv_channels)
    hsv_filter = hsv_channels[1, :, :]

end

main()
