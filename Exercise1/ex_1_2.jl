# Currently only plotting one coordinate frame in one plot

using Pkg
using Plots
using LinearAlgebra
using DataFrames

W = Matrix{Float64}(I, 4, 4)
C = [-0.866 -0.500 0.000 2.0; 
    -0.500 0.866 0.000 -1.0; 
    0.000 0.000 -1.000 3.0; 
    0 0 0 1]

# The function plots the X-, Y- and Z- axes of an input coordinate frame T
function plot_frame(T)
    o = [0; 0; 0; 1]    # origin of the world coordinate frame

    # The length between origin and a point on an axis is one unit
    u = [1; 0; 0; 1];   # point on x axis
    v = [0; 1; 0; 1];   # point on y axis
    w = [0; 0; 1; 1];   # point on z axis

    # Multiplying the points with the transformation matrix
    o = T * o;
    u = T * u;
    v = T * v;
    w = T * w;

    # Plotting the axes
    plotly()
    plot([o[1], u[1]], [o[2], u[2]], [o[3], u[3]], 
        color=RGB(1, 0, 0), length=10, markershape=:none)
    plot!([o[1], v[1]], [o[2], v[2]], [o[3], v[3]], 
        color=RGB(0, 1, 0), length=10, markershape=:none)
    p = plot!([o[1], w[1]], [o[2], w[2]], [o[3], w[3]],
        color=RGB(0, 0, 1), length=10, markershape=:none)
    display(p)

    return nothing
end

plot_frame(W)
plot_frame(C)
