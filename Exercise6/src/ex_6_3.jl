using RegionProperties
using Images
using Plots
include(joinpath(@__DIR__, "normalization_and_calibration.jl"))

function main()
    img = load(joinpath(@__DIR__, "../data/cubes-for-calib.jpg"))
    red = [510 175 25]
    green = [720 -159 25]
    blue = [720 45 25]
    black = [460 -109 25]

    red_center = [0, 0]
    blue_center = [0, 0]
    green_center = [0, 0]
    black_center = [0, 0]

    # Treshold the cubes from the background
    x = get_available_properties()
    pieces = locate_colors(img)
    black_pieces = locate_black(img)
    p = plot(img)

    # Localize each piece from background
    props = regionprops(pieces, :centroid, :minor_axis_length, :major_axis_length)

    for i in 1:length(props)
        if (props[i].minor_axis_length > 290) && (props[i].minor_axis_length < 291)
            red_center = (reverse(props[i].centroid))
            plot!(red_center, markershape=:diamond)
        elseif (props[i].minor_axis_length > 291) && (props[i].minor_axis_length < 293)
            green_center = (reverse(props[i].centroid))
            plot!(green_center, markershape=:diamond)
            #println(props[i].minor_axis_length)
        elseif (props[i].minor_axis_length > 350) && (props[i].minor_axis_length < 360)
            blue_center = (reverse(props[i].centroid))
            plot!(blue_center, markershape=:diamond)
        end
    end

    #black_pieces= locate_black(img)
    black_props = regionprops(black_pieces, :centroid, :minor_axis_length, :major_axis_length)
    
    for i in 1:length(black_props)
        if (black_props[i].minor_axis_length > 246.8) && (black_props[i].minor_axis_length < 247)
            black_piece = (reverse(black_props[i].centroid))
            plot!(black_piece, markershape=:diamond)
            #println(black_props[i].minor_axis_length)
        end
    end

    points3d = transpose([red; green; blue; black; red; green; blue; black])

    points2d = [red_center[1] green_center[1] blue_center[1] black_center[1] red_center[1] green_center[1] blue_center[1] black_center[1];
        red_center[2] green_center[2] blue_center[2] black_center[2] red_center[2] green_center[2] blue_center[2] black_center[2]]

    # Find projection matrix from 3D points to image points (2D).
    M = normalize_and_calibrate(points3d, points2d, 8)
    display(M)

    # Use the projection matrix to plot world frame origin in the photo.
    o = [0; 0; 0; 1]

    proj = M * o
    proj[1, :] = proj[1, :] ./ proj[3, :]
    proj[2, :] = proj[2, :] ./ proj[3, :]

    p = plot!(proj[1, :], proj[2, :], seriestype=:scatter)

    display(p)

    # The projection matrix is probably flawed because I am using
    # the centroids of the extracted cubes on the 2D image, which
    # do not necessarily perfectly correspond to the location of
    # the centers of mass.
end

# Locate the red, green and blue parts in RGB color space.
function locate_colors(img)
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

# Locate black areas in RGB color space.
function locate_black(img)
    img_channels = channelview(img)
    filter = img_channels[1, :, :] .< 0.2 .&&
        img_channels[2, :, :] .< 0.2 .&&
        img_channels[3, :, :] .< 0.2
    filter_img = Gray.(filter)
    return filter_img
end

main()
