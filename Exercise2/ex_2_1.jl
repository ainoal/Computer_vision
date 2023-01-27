using Pkg
using Plots
using LinearAlgebra
plotlyjs()
include("plots_plotly_extra.jl")

function main()
    # World, robot and camera coordinate frames
    wTw = Matrix{Float64}(I, 4, 4)
    wTr = [0.6645 -0.6645 0.3420 -2;
        0.7071 0.7071 0 1;
        -0.2418 0.2418 0.9397 -1;
        0 0 0 1]
    wTc = [0.1543 -0.6172 -0.7715 3;
        0.9866 0.0538 0.1543 0;
        0.0538 0.7850 -0.6172 3;
        0 0 0 1]

    plot_frames(wTr, wTc)   # plotting frames relative to world frame
    plot_frames(inv(wTr), inv(wTr) * wTc)   # relative to robot frame
    plot_frames(inv(wTc), inv(wTc) * wTr)   # relative to camera frame
end

# FIX THE FUNCTION DEFINITION: REFERENCE FRAME NOT PASSED TO 
# THE FUNCTION AS PARAMETER ANYMORE

# + ADD aspect_ratio := equal

# Plots.current() to get the current plot

# The function gets 3 frames as input parameters and plots all frames
# relative to the frame given as the first input parameter
function plot_frames(F2, F3)
    o = [0; 0; 0; 1]    # origin of the reference coordinate frame

    # The length between origin and a point on an axis is one unit
    u = [1; 0; 0; 1];   # point on x axis
    v = [0; 1; 0; 1];   # point on y axis
    w = [0; 0; 1; 1];   # point on z axis

    # Plotting the reference frame
    
    plot([o[1], u[1]], [o[2], u[2]], [o[3], u[3]], 
        color=RGB(1, 0, 0), markershape=:none,aspect_ratio=:equal)
    plot!([o[1], v[1]], [o[2], v[2]], [o[3], v[3]], 
        color=RGB(0, 1, 0), markershape=:none,aspect_ratio=:equal)
    plot!([o[1], w[1]], [o[2], w[2]], [o[3], w[3]],
        color=RGB(0, 0, 1), markershape=:none,aspect_ratio=:equal)

    # Multiplying the points of the other frames with the 
    # transformation matrices
    # (Modify this to decrease the amount of repetition: a separate function?)
    # Points along axes of the frame given as 2nd input parameter
    o2 = F2 * o;
    u2 = F2 * u;
    v2 = F2 * v;
    w2 = F2 * w;

    # Points along axes of the frame given as 3rd input parameter
    o3 = F3 * o;
    u3 = F3 * u;
    v3 = F3 * v;
    w3 = F3 * w;

    # Plotting the axes of the other frames
    plot!([o2[1], u2[1]], [o2[2], u2[2]], [o2[3], u2[3]], 
        color=RGB(1, 0, 0), markershape=:none,aspect_ratio=:equal)
    plot!([o2[1], v2[1]], [o2[2], v2[2]], [o2[3], v2[3]], 
        color=RGB(0, 1, 0), markershape=:none,aspect_ratio=:equal)
    plot!([o2[1], w2[1]], [o2[2], w2[2]], [o2[3], w2[3]],
        color=RGB(0, 0, 1), markershape=:none,aspect_ratio=:equal)
    
    plot!([o3[1], u3[1]], [o3[2], u3[2]], [o3[3], u3[3]], 
        color=RGB(1, 0, 0), markershape=:none,aspect_ratio=:equal)
    plot!([o3[1], v3[1]], [o3[2], v3[2]], [o3[3], v3[3]], 
        color=RGB(0, 1, 0), markershape=:none,aspect_ratio=:equal)
    p =plot!([o3[1], w3[1]], [o3[2], w3[2]], [o3[3], w3[3]],
        color=RGB(0, 0, 1), markershape=:none,aspect_ratio=:equal)

    display(p)

end

main()
