using Images
using ImageFiltering

function main()
    I = load(joinpath(@__DIR__, "../data/lena_bw.png"))
    imgsize = size(I)

    # Exercise part a: Construct stack of Gaussians.
    gaussians = [I, I, I, I, I]     # Initialize the array
    sigma = 1.6

    for i in 1:5
        gaussians[i] = imfilter(I, Kernel.gaussian(sigma))
        sigma = sqrt(2) * sigma
    end

    # Calculate Differences of Gaussians.
    D = [I, I, I, I]                # Initialize the array
    for j in 1:4
        D[j] = gaussians[j] .- gaussians[j+1]
    end

    # Exercise part b: Find local extrema in D.
    # Local features can be found by finding local extrema in the stack of DoG.
    window = (3, 3, 3)
    #DoG_all_levels = [D[1], D[2], D[3], D[4]]
    # use function cat instead
    DoG_all_levels = cat(D[1], D[2], D[3], D[4], dims=3)
    

    #extrema_all_levels = []
    #b = mapwindow(extrema, D[2], window)
    # = getfield.(b, 2)
    #println(c)

    

    # Exercise part c: Limit the number of local features with tresholding.
    t = 0.03
    for n in 1:4
        #min = getfield.(extrema_all_levels[n], 1)
        #max = getfield.(extrema_all_levels[n], 2)

        #min_channels = channelview(min)
        #max_channels = channelview(max)
        #println(size(min_channels))
        
    end
    #extrema_all_levels[4, 2]
end

function find_maxima(vals)
    c = centered(vals)[0, 0]
    if (c = maximum(vals))
        ret = c
    else
        ret = zero(c)
    end
    return ret
end

main()

    #=for k in 1:4
        minmax = mapwindow(extrema, D[k], window)
        # TODO: Find minmax of the higher and lower level as well and update
        # minmax according to that
        if (k == 1)
            minmax_higher = mapwindow(extrema, D[k+1], window)
            for l in 1:imgsize[1]
                for m in 1:imgsize[2]
                    if (minmax_higher[l, m] > minmax[l, m])
                        minmax[l, m] = minmax_higher[l, m]
                    end
                end
            end
        elseif (k == 4)
            minmax_lower = mapwindow(extrema, D[k-1], window)
            for l in 1:imgsize[1]
                for m in 1:imgsize[2]
                    if (minmax_lower[l, m] > minmax[l, m])
                        minmax[l, m] = minmax_lower[l, m]
                    end
                end
            end
        else
            minmax_lower = mapwindow(extrema, D[k-1], window)
            minmax_higher = mapwindow(extrema, D[k+1], window)
            for l in 1:imgsize[1]
                for m in 1:imgsize[2]
                    if (minmax_higher[l, m] > minmax[l, m])
                        minmax[l, m] = minmax_higher[l, m]
                    end
                    if (minmax_lower[l, m] > minmax[l, m])
                        minmax[l, m] = minmax_lower[l, m]
                    end
                end
            end
        end
        push!(extrema_all_levels, minmax)
    end=#