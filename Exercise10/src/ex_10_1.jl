using MAT
using Plots

function main()
    slow_data = matread(joinpath(@__DIR__, "../data/slow_square.mat"))
    track(slow_data)
end

function track(data)
    start_point = data["start_point"]
    template = data["template"]
    seq = data["slow_square"]
    no_of_images = size(seq)[3]

    largest_allowed_displacement = 25

    p = start_point
    largest_similarity = -Inf
    d = [0; 0]
    sz = size(template)

    for imgno in 1:(no_of_images - 1)
        previmg = seq[:, :, imgno]
        thisimg = seq[:, :, imgno + 1]

        for dx in -largest_allowed_displacement:largest_allowed_displacement
            for dy in -largest_allowed_displacement:largest_allowed_displacement
                c = 0
                for l in 1:sz[1]
                    for m in 1:sz[2]
                        previmg_coord = Vector{Int64}([p[1] + l; p[2] + m])
                        thisimg_coord = Vector{Int64}([p[1] + l + dx; p[2] + m + dy])
                        c += ssd(previmg_coord, thisimg_coord, previmg, thisimg)
                    end
                end
                if (c > largest_similarity)
                    largest_similarity = c
                    d = [dx; dy]
                end
            end
        end
        p = p + d

        plt = plot(Gray.(thisimg))
        plot!([p[1]], [p[2]], seriestype=:scatter)
        display(plt)
    end

end

function ssd(prev_coord, this_coord, previmg, thisimg)
    ssd = -(previmg[prev_coord[1], prev_coord[2]] - thisimg[this_coord[1], this_coord[2]])^2
    return ssd
end

#plot_image(img; kws...) = 
#    plot(img; aspect_ratio=:equal, size=size(img), framestyle=:none, kws...)

main()
