using RegionProperties
using Images
using Plots

function main()
    img = load(joinpath(@__DIR__, "../data/cubes-for-calib.jpg"))
    red = [510 175 25]
    green = [720 -159 25]
    blue = [720 45 25]
    black = [460 -109 25]

    # Treshold the cubes from the background
    x = get_available_properties()
    println(x)
    pieces = locate_colors(img)
    black_pieces= locate_black(img)
    p = plot(black_pieces)

    # Localize each piece from background
    props = regionprops(pieces, :centroid, :indices, :circularity,
        :minor_axis_length, :major_axis_length, :orientation)

    for i in 1:length(props)
        if ((props[i].minor_axis_length > 250) && (props[i].minor_axis_length < 300) ||
            (props[i].minor_axis_length > 350) && (props[i].minor_axis_length < 360))
            piece = (reverse(props[i].centroid))
            plot!(piece, markershape=:diamond)
            #println(props[i].minor_axis_length)
        end
    end

    #black_pieces= locate_black(img)
    black_props = regionprops(black_pieces, :centroid, :indices, :circularity,
        :minor_axis_length, :major_axis_length, :orientation)
    
    for i in 1:length(black_props)
        if (black_props[i].minor_axis_length > 246.8) && (black_props[i].minor_axis_length < 247)
            black_piece = (reverse(black_props[i].centroid))
            plot!(black_piece, markershape=:diamond)
            println(black_props[i].minor_axis_length)
        end
    end

    display(p)
end



function locate_colors(img)
    # Locating the red part in RGB color space
    img_channels = channelview(img)
    filter = (img_channels[1, :, :] .> 0.25 .&&
        img_channels[2, :, :] .< 0.18 .&&
        img_channels[3, :, :] .< 0.2) .||
        (img_channels[1, :, :] .< 0.20 .&&
        img_channels[2, :, :] .> 0.15 .&&
        img_channels[3, :, :] .< 0.3) .||
        (img_channels[1, :, :] .< 0.1 .&&
        img_channels[2, :, :] .< 0.15 .&&
        img_channels[3, :, :] .> 0.12) 
    filter_img = Gray.(filter)
    return filter_img
end

function locate_black(img)
    img_channels = channelview(img)
    filter = img_channels[1, :, :] .< 0.2 .&&
        img_channels[2, :, :] .< 0.2 .&&
        img_channels[3, :, :] .< 0.2
    filter_img = Gray.(filter)
    return filter_img
end

main()
