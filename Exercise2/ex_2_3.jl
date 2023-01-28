using MAT
include(joinpath(@__DIR__, "lib/color_plots.jl"))
include(joinpath(@__DIR__, "lib/plot_frame_makie.jl"))

function main()
    data = matread(joinpath(@__DIR__, "data/task3.mat"))
    o_x =  70          # Optical center of the camera
    o_y = 70
    s_x = 10*10^-6      # Effective size of pixel
    s_y = 10*10^-6
    f = 16*10^-3        # Focal length

    # Exercise part a: plot given colored points and camera frame
    fig, ax1, _ = plot_color(data["points"], data["colors"])
    ax2 = Axis(fig[1, 2]; aspect=DataAspect(), yreversed=true)
    plot_color_projected!(ax2, data["points"][1:2, :], data["colors"])
    plot_frame!(data["WTC"])
    display(fig)

    # Exercise part b: Construct matrix M and use it to find image plane
    # projections of the given points.
end

main()
