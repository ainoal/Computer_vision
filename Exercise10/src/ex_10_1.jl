using MAT
using Plots

function main()
    slow_data = matread(joinpath(@__DIR__, "../data/slow_square.mat"))
    track(slow_data, "slow_square")

    fast_data = matread(joinpath(@__DIR__, "../data//fast_square.mat"))
    track(fast_data, "fast_square")

    # The same tracking algorithm works for both image sequences.
    # However, if the largest allowed displacement was smaller than
    # the movement of the square between two frames, the algorithm
    # would not work anymore. 

    # With more complex images, choosing the correct maximum displacement 
    # should be done more precisely because choosing a too large values
    # could lead to matching the template with a wrong area of the picture.
    # With these image sequences, however, there is no fear for that since
    # there is only one white square in the otherwise black scene.
end

function track(data, seq_name)
    start_point = data["start_point"]
    template = data["template"]
    seq = data[seq_name]
    no_of_images = size(seq)[3]

    largest_allowed_displacement = 25

    p = start_point
    sz = size(template)

    for imgno in 1:no_of_images
        thisimg = seq[:, :, imgno]
        largest_similarity = -Inf
        d = [0; 0]

        for dx in -largest_allowed_displacement:largest_allowed_displacement
            for dy in -largest_allowed_displacement:largest_allowed_displacement
                c = 0
                for l in 1:sz[1]
                    for m in 1:sz[2]
                        template_coord = [l, m]
                        thisimg_coord = Vector{Int64}([p[1] + l + dx; p[2] + m + dy])
                        c += diff(template_coord, thisimg_coord, template, thisimg)
                    end
                end
                if (c > largest_similarity)
                    largest_similarity = c
                    d = [dx; dy]
                end
            end
        end
        p = p + d

        # The corners of the box
        corner1 = [p[1]; p[2]]
        corner2 = [p[1]+sz[1]; p[2]]
        corner3 = [p[1]+sz[1]; p[2]+sz[2]]
        corner4 = [p[1]; p[2]+sz[2]]

        plt = plot(Gray.(thisimg), title=seq_name)
        plot!(corner1, corner2)
        plot!(corner2, corner3)
        plot!(corner3, corner4)
        plot!(corner4, corner1)
        display(plt)
    end

end

function diff(template_coord, this_coord, template, thisimg)
    diff = -(template[template_coord[1], template_coord[2]] - thisimg[this_coord[1], this_coord[2]])^2
    return diff
end

main()
