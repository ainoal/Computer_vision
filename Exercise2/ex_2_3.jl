using MAT
using LinearAlgebra
include(joinpath(@__DIR__, "lib/color_plots.jl"))
include(joinpath(@__DIR__, "lib/plot_frame_makie.jl"))

function main()
    data = matread(joinpath(@__DIR__, "data/task3.mat"))
    o_x =  70          # Optical center of the camera
    o_y = 70
    s_x = 10*10^-6      # Effective size of pixel
    s_y = 10*10^-6
    f = 16*10^-3        # Focal length

    # Exercise part a: plot given colored points and camera frame.
    fig = Makie.Figure()
    fig, ax1, _ = plot_color(data["points"], data["colors"])
    ax2 = Axis(fig[1, 2]; aspect=DataAspect(), yreversed=true)
    plot_color_projected!(ax2, data["points"][1:2, :], data["colors"])
    plot_frame!(data["WTC"])
    display(fig);

    #sleep(5)

    # Exercise part b: Construct matrix M and use it to find image plane
    # projections of the given points. 

    # Intrinsic parameters
    K = [-f/s_x 0 o_x 0;
        0 -f/s_y o_y 0;
        0 0 1 0]

    # In matrix M, we take into account both intrinsic and extrinsic parameters.
    M = K * inv(data["WTC"])

    # Find image plane projections of the given points. 
    projections = M * data["points"]

    # Normalize the coordinates
    for i in 1:(Int(length(projections)/3))
        projections[1, i] = projections[1, i] / projections[3, i]
        projections[2, i] = projections[2, i] / projections[3, i]
    end

    # Exercise part c: plot projected points.
    # The points form the Lena image on the image plane.
    fig2, a1, _ = plot_color(projections, data["colors"])
    a2 = Axis(fig2[1, 2]; aspect=DataAspect(), yreversed=true)
    plot_color_projected!(a2, projections[1:2, :], data["colors"])
    display(fig2)

    sleep(10)

    # Exercise part d: Calculate point projection using weak-perspective camera.
    #cam_coords = inv(data["WTC"]) * data["points"]
    sum_of_zs = 0
    for i in 1:19600
        temp = inv(data["WTC"]) * data["points"][1:4,1]
        sum_of_zs = sum_of_zs + temp[3, 1]
    end
    Z = sum_of_zs / 19600

    Mwp = [-f/s_x 0 0 Z*o_x;
        0 -f/s_y 0 Z*o_y;
        0 0 0 Z]

    weak_projection = Mwp * inv(data["WTC"]) * data["points"]

    # Normalize the coordinates
    for i in 1:(Int(length(weak_projection)/3))
        weak_projection[1, i] = weak_projection[1, i] / weak_projection[3, i]
        weak_projection[2, i] = weak_projection[2, i] / weak_projection[3, i]
    end

    # Exercise part e: plot projected points.
    fig3, ax_1, _ = plot_color(weak_projection, data["colors"])
    ax_2 = Axis(fig3[1, 2]; aspect=DataAspect(), yreversed=true)
    plot_color_projected!(ax_2, weak_projection[1:2, :], data["colors"])
    display(fig3)

    # With weak-perspective projection, the plot is not showing a conscise
    # image. Weak-perspective camera can be used if the average depth of scene
    # is a lot bigger than the relative distance between the scene points.
    # The avg depth of scene should be at least 20 times bigger than relative distance.
    # For this particular case, the weak-perspective camera is not suitable.
end

main()
