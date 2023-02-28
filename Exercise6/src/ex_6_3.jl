using RegionProperties
using Images
using Plots
using LinearAlgebra

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
    #println(x)
    pieces = locate_colors(img)
    black_pieces= locate_black(img)
    p = plot(img)

    # Localize each piece from background. Use the centroid to model
    # the center of mass of each piece.
    props = regionprops(pieces, :centroid, :indices, :circularity,
        :minor_axis_length, :major_axis_length, :orientation)

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
    black_props = regionprops(black_pieces, :centroid, :indices, :circularity,
        :minor_axis_length, :major_axis_length, :orientation)
    
    for i in 1:length(black_props)
        if (black_props[i].minor_axis_length > 246.8) && (black_props[i].minor_axis_length < 247)
            black_center = (reverse(black_props[i].centroid))
            plot!(black_center, markershape=:diamond)
            #println(black_props[i].minor_axis_length)
        end
    end

    points3d = transpose([red; green; blue; black; red; green; blue; black])

    points2d = [red_center[1] green_center[1] blue_center[1] black_center[1] red_center[1] green_center[1] blue_center[1] black_center[1];
        red_center[2] green_center[2] blue_center[2] black_center[2] red_center[2] green_center[2] blue_center[2] black_center[2]]

    # Find projection matrix from 3D points to image points (2D).
    M = normalize_and_calibrate(points3d, points2d, 8)
    #M = calibrate(points3d, points2d)

    # Use the projection matrix to plot world frame origin in the photo.
    o = [0; 0; 0; 1]

    proj = M * o
    proj[1, :] = proj[1, :] ./ proj[3, :]
    proj[2, :] = proj[2, :] ./ proj[3, :]

    

    plot!(proj[1, :], proj[2, :], seriestype=:scatter)

    display(p)

    # The origin should be plotted at the bottom of the camera, but
    # the transformation matrix is not working properly.
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

function calibrate(points3d, points2d)
    # Construct A
    X = points3d[1, :]
    Y = points3d[2, :]
    Z = points3d[3, :]
    
    x = points2d[1, :]
    y = points2d[2, :]

    # TODO: make matrix A more beautiful by first initializing an empty matrix
    # and then updating 2 rows at a time inside a for loop
    A = [X[1] Y[1] Z[1] 1 0 0 0 0 -x[1]*X[1] -x[1]*Y[1] -x[1]*Z[1] -x[1];
        0 0 0 0 X[1] Y[1] Z[1] 1 -y[1]*X[1] -y[1]*Y[1] -y[1]*Z[1] -y[1];
        X[2] Y[2] Z[2] 1 0 0 0 0 -x[2]*X[2] -x[2]*Y[2] -x[2]*Z[2] -x[2];
        0 0 0 0 X[2] Y[2] Z[2] 1 -y[2]*X[2] -y[2]*Y[2] -y[2]*Z[2] -y[2];
        X[3] Y[3] Z[3] 1 0 0 0 0 -x[3]*X[3] -x[3]*Y[3] -x[3]*Z[3] -x[3];
        0 0 0 0 X[3] Y[3] Z[3] 1 -y[3]*X[3] -y[3]*Y[3] -y[3]*Z[3] -y[3];
        X[4] Y[4] Z[4] 1 0 0 0 0 -x[4]*X[4] -x[4]*Y[4] -x[4]*Z[4] -x[4];
        0 0 0 0 X[4] Y[4] Z[4] 1 -y[4]*X[4] -y[4]*Y[4] -y[4]*Z[4] -y[4];
        X[1] Y[1] Z[1] 1 0 0 0 0 -x[1]*X[1] -x[1]*Y[1] -x[1]*Z[1] -x[1];
        0 0 0 0 X[1] Y[1] Z[1] 1 -y[1]*X[1] -y[1]*Y[1] -y[1]*Z[1] -y[1];
        X[2] Y[2] Z[2] 1 0 0 0 0 -x[2]*X[2] -x[2]*Y[2] -x[2]*Z[2] -x[2];
        0 0 0 0 X[2] Y[2] Z[2] 1 -y[2]*X[2] -y[2]*Y[2] -y[2]*Z[2] -y[2];
        X[3] Y[3] Z[3] 1 0 0 0 0 -x[3]*X[3] -x[3]*Y[3] -x[3]*Z[3] -x[3];
        0 0 0 0 X[3] Y[3] Z[3] 1 -y[3]*X[3] -y[3]*Y[3] -y[3]*Z[3] -y[3];
        X[4] Y[4] Z[4] 1 0 0 0 0 -x[4]*X[4] -x[4]*Y[4] -x[4]*Z[4] -x[4];
        0 0 0 0 X[4] Y[4] Z[4] 1 -y[4]*X[4] -y[4]*Y[4] -y[4]*Z[4] -y[4]]

    println(size(A))
    # Use SVD for solving for M
    svd_vals = svd(A)
    V = svd_vals.V
    println(size(V))
    M = transpose(reshape(V[:, 12], 4, 3))
    return M
end

function normalize_and_calibrate(points3d, points2d, N)
    # Construct T, U (lecture slides 23, 24).
    # Constructing matrix T for normalization for image (2D) points.
    sumx = 0
    sumy = 0
    sumd = 0

    for i in 1:N
        sumx += points2d[1, i]
        sumy += points2d[2, i]
    end
    x = (1/N) * sumx
    y = (1/N) * sumy

    for i in 1:N
        sumd += sqrt((points2d[1, i] - x)^2 + (points2d[2, i] - y)^2)
    end
    d = (1/N) * sumd

    T = [sqrt(2)/d 0 -(sqrt(2))*x/d;
        0 sqrt(2)/d -(sqrt(2))*y/d;
        0 0 1]

    # Constructing matrix U for normalization for model (3D) points.
    sum_X = 0
    sum_Y = 0
    sum_Z = 0
    sum_D = 0

    for i in 1:N
        sum_X += points3d[1, i]
        sum_Y += points3d[2, i]
        sum_Z += points3d[3, i]
    end
    X = (1/N) * sum_X
    Y = (1/N) * sum_Y
    Z = (1/N) * sum_Z

    for i in 1:N
        sum_D += sqrt((points3d[1, i] - X)^2 + (points3d[2, i] - Y)^2 +
            (points3d[3, i] - Z)^2)
    end
    D = (1/N) * sum_D

    U = [sqrt(3)/D 0 0 -(sqrt(3))*X/D;
        0 sqrt(3)/D 0 -(sqrt(3))*Y/D;
        0 0 sqrt(3)/D -(sqrt(3))*Z/D;
        0 0 0 1]

    # Normalization using the matrices
    ones = [1 1 1 1 1 1 1 1]
    p2_homogeneous = vcat(points2d, ones)
    p3_homogeneous = vcat(points3d, ones)

    p2 = T * p2_homogeneous
    p3 = U * p3_homogeneous

    # Calibration
    M2 = calibrate(p3, p2)

    # Denormlization
    M = inv(T) * M2 * U

    return M
end

main()
