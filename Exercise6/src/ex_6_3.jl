using RegionProperties
using Images
using Plots
include(joinpath(@__DIR__, "normalization_and_calibration.jl"))

function main()
    # Exercise part a: Find the origin for the world frame and plot it in the image.

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
    gr()        # Use gr backend instead of plotly for images (plotly can be slow)
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

    # Exercise part b: What is the camera pose in the world frame?
    # Let's plot the world frame and the camera frame in the 
    # same plot so we can see the camera pose relative to the world
    # frame.

    # Decompose projection matrix M to find rotation matrix and camera position.
    X = det([M[:, 2] M[:, 3] M[:, 4]])
    Y = -det([M[:, 1] M[:, 3] M[:, 4]])
    Z = det([M[:, 1] M[:, 2] M[:, 4]])
    W = -det([M[:, 1] M[:, 2] M[:, 3]])

    C = [X/W Y/W Z/W]   # Camera center

    temp = [1 0 0 -C[1];
    0 1 0 -C[2];
    0 0 1 -C[3]]

    KR = M/temp
    K, R = decompose_projection(KR)

    # Use rotation matrix R and camera location C to construct wTc
    wTc = [R[1, 1] R[1, 2] R[1, 3] -C[1];
        R[2, 1] R[2, 2] R[2, 3] -C[2];
        R[3, 1] R[3, 2] R[3, 3] -C[3];
        0 0 0 1]

    # There is a problem in the matrix M decomposition, due to which this
    # wTc matrix cannot be used. This is propably caused by using
    # the same 4 data points twice to construct matrix M.
    display(wTc)

    #plot_frames(wTc)   # How world and camera frames would be plotted
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

flipud(M) = reverse(M, dims=1)

function decompose_projection(M)
    Q0, R0 = M |> flipud |> transpose |> qr
    R = R0 |> transpose |> reverse
    Q = Q0 |> transpose |> flipud
    return (R, Q)
end

# The function gets camera frame as input parameter and plots
# it relative to the world frame.
function plot_frames(T)
    o = [0; 0; 0; 1]    # origin of the world frame

    # The length between origin and a point on an axis is one unit
    u = [1; 0; 0; 1];   # point on x axis
    v = [0; 1; 0; 1];   # point on y axis
    w = [0; 0; 1; 1];   # point on z axis

    # Plotting the world frame
    plotly()
    plot([o[1], u[1]], [o[2], u[2]], [o[3], u[3]], 
        color=RGB(1, 0, 0), markershape=:none, aspect_ratio=:equal)
    plot!([o[1], v[1]], [o[2], v[2]], [o[3], v[3]], 
        color=RGB(0, 1, 0), markershape=:none, aspect_ratio=:equal)
    plot!([o[1], w[1]], [o[2], w[2]], [o[3], w[3]],
        color=RGB(0, 0, 1), markershape=:none, aspect_ratio=:equal)

    # Multiplying the points of camera frame with the 
    # transformation matrices
    o2 = T * o;
    u2 = T * u;
    v2 = T * v;
    w2 = T * w;
    println(T)
    println(o2)
    println(u2)
    println(v2)
    println(w2)

    # Plotting the axes of camera frame
    plot!([o2[1], u2[1]], [o2[2], u2[2]], [o2[3], u2[3]], 
        color=RGB(1, 0, 0), markershape=:none, aspect_ratio=:equal)
    plot!([o2[1], v2[1]], [o2[2], v2[2]], [o2[3], v2[3]], 
        color=RGB(0, 1, 0), markershape=:none, aspect_ratio=:equal)
    p = plot!([o2[1], w2[1]], [o2[2], w2[2]], [o2[3], w2[3]],
        color=RGB(0, 0, 1), markershape=:none, aspect_ratio=:equal)

    annotate!(u[1], u[2], u[3], "World frame")
    annotate!(u2[1], u2[2], u2[3], "Camera frame")

    display(p)
end

main()
