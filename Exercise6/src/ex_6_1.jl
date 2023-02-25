using MAT
using Plots

function main()
    data = matread(joinpath(@__DIR__, "../data/cube_points.mat"))
    idx = data["connecting_indices"]
    plotly()
    plot(data["points3d"][1, :], data["points3d"][2, :], data["points3d"][3, :], 
        seriestype =:scatter)

    # TODO: implement the following for the whole cube (with a for loop?)
    p = plot!([data["points3d"][1, idx[1]], data["points3d"][1, idx[2]]],
        [data["points3d"][2, idx[1]], data["points3d"][2, idx[2]]],
        [data["points3d"][3, idx[1]], data["points3d"][3, idx[2]]])
    display(p)
    plot(data["points2d"][1,:], data["points2d"][2,:],
        seriestype=:scatter)
end

main()
