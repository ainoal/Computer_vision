
using Images: colorview, RGB
using GLMakie

function plot_color(points, colors)
    fig = Figure()
    ax = Axis3(fig[1, 1]; aspect=:data)
    return fig, ax, plot_color!(ax, points, colors)
end
plot_color!(points, colors) = plot_color!(current_axis(), points, colors)
plot_color!(ax, points, colors) = GLMakie.scatter!(ax, points[1:3, :], color=colorview(RGB, colors), markersize=0.6, strokewidth=0)


function plot_color_projected(points, colors)
    fig = Figure()
    ax = Axis(fig[1, 1]; aspect=DataAspect(), yreversed=true)
    return fig, ax, plot_color_projected!(ax, points, colors)
end
plot_color_projected!(points, colors) = plot_color_projected!(current_axis(), points, colors)
plot_color_projected!(ax, points, colors) = GLMakie.scatter!(ax, points, color=colorview(RGB, colors), markersize=7)