# Color segmentation

using Images

function main()
    blocks = load(joinpath(@__DIR__, "../data/blocks-col.png"))
    circles = load(joinpath(@__DIR__, "../data/circles.png"))

    # Locate the red block in the blocks image with color segmentation.
    locate_red(blocks)

    # Use the same tresholds for the circles image.
    locate_red(circles)

    # The same tresholds do not work for the other image. That is due to the
    # facts that (1) The red circle is a different hue from the red cube and
    # (2) What looks to the human eye like semi-transparent circles overlapping,
    # is not percieved as circles by a computer. In this simple case, it would
    # be sufficient to change the color tresholds to detect the red circle correctly,
    # but in real life applications of color segmentation there are usually
    # more parts. Some of them might be overlapping like these circles, some are
    # fully or partially in the shadows while some are under direct light etc.
    # This makes it difficult if not impossible to choose the right tresholds,
    # especially if they need to be implemented with several photos.

    # With the way that I have implemented the tresholds in RGB and HSV spaces, 
    # there is no big difference between the quality of the segmentation in 
    # the two color spaces. However, the HSV color space allows us to filter
    # also based on saturation and value, which can come in handy if we for example
    # want to filter out dark/light parts of the image that could belong to a 
    # part of the image that does not interest us. On the other hand, in RGB color
    # space it can be easier to filter based solely on color. Filtering for example
    # yellow could, however, be easier in HSV space.

    # Some other things that can cause difficulties with image segmantation, based 
    # on my experience with this exercise:
    # - When working in the RGB space, you need to filter out very light colors whose
    #   value of the color channel that you want to detect is high.

end

function locate_red(img)
    # Locating the red part in RGB color space
    img_channels = channelview(img)
    filter = img_channels[1, :, :] .> 0.57 .&&
        img_channels[2, :, :] .< 0.48 .&&
        img_channels[3, :, :] .< 0.51
    filter_img = Gray.(filter)
    display(filter_img)

    # Locating the red part in HSV color space
    img_hsv = HSV.(img)
    hsv_channels = channelview(img_hsv)
    hsv_filter = (hsv_channels[1, :, :] .<25 .|| hsv_channels[1, :, :] .> 335) .&&
        hsv_channels[2, :, :] .>0.29 .&&
        hsv_channels[3, :, :] .>0.58
    hsv_filter_img = Gray.(hsv_filter)
    display(hsv_filter_img)
end

main()
