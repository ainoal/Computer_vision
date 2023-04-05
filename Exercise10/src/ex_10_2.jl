using MAT
using Plots
using Images

function main()
    slow_data = matread(joinpath(@__DIR__, "../data/slow_square.mat"))
    track(slow_data, "slow_square")


    fast_data = matread(joinpath(@__DIR__, "../data//fast_square.mat"))
    track(fast_data, "fast_square")
end

function track(data, seq_name)
    start_point = data["start_point"]
    template = data["template"]
    seq = data[seq_name]
    no_of_images = size(seq)[3]

    # Generate a half resolution sequence
    halfres = zeros(Int64(size(seq)[1]/2), Int64(size(seq)[2]/2), no_of_images)
    for i in 1:no_of_images
        halfres[:, :, i] = imresize(seq[:, :, i], ratio = 1/2)
    end

    largest_allowed_displacement = 12

    p = start_point
    sz = size(template)

    for imgno in 1:no_of_images
        thisimg = seq[:, :, imgno]
        thishalfres = halfres[:, :, imgno]
        largest_similarity = -Inf
        d = [0; 0]

        # Perform tracking using the half resolution image
        for dx in -largest_allowed_displacement:largest_allowed_displacement
            for dy in -largest_allowed_displacement:largest_allowed_displacement
                c = 0
                for l in 1:(sz[1]/2)
                    for m in 1:(sz[2]/2)
                        template_coord = [Int64(floor(l)), Int64(floor(m))]
                        thishalfres_coord = Vector{Int64}([floor(p[1]/2 + l + dx); floor(p[2]/2 + m + dy)])
                        c += ssd(template_coord, thishalfres_coord, template, thishalfres)
                    end
                end
                if (c > largest_similarity)
                    largest_similarity = c
                    d = [dx*2; dy*2]
                end
            end
        end
        p = p + d

        # Perform tracking using the full resolution image
        for dx in -largest_allowed_displacement:largest_allowed_displacement
            for dy in -largest_allowed_displacement:largest_allowed_displacement
                c = 0
                for l in 1:sz[1]
                    for m in 1:sz[2]
                        template_coord = [l, m]
                        thisimg_coord = Vector{Int64}([p[1] + l + dx; p[2] + m + dy])
                        c += ssd(template_coord, thisimg_coord, template, thisimg)
                    end
                end
                if (c > largest_similarity)
                    largest_similarity = c
                    d = [dx; dy]
                end
            end
        end
        p = p + d

        plt = plot(Gray.(thisimg), title=seq_name)
        plot!([p[1]], [p[2]], seriestype=:scatter)
        plot!([p[1]], [p[2]+sz[2]], seriestype=:scatter)
        plot!([p[1]+sz[1]], [p[2]], seriestype=:scatter)
        plot!([p[1]+sz[1]], [p[2]+sz[2]], seriestype=:scatter)
        display(plt)
    end

end

function ssd(template_coord, this_coord, template, thisimg)
    ssd = -(template[template_coord[1], template_coord[2]] - thisimg[this_coord[1], this_coord[2]])^2
    return ssd
end

main()
