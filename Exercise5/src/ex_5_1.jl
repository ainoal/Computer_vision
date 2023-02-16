using Images
using ImageFiltering
using Plots

function main()
    I = load(joinpath(@__DIR__, "../data/lena_bw.png"))
    imgsize = size(I)
    p = plot(I)

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
    DoG_all_levels = cat(D[1], D[2], D[3], D[4]; dims=3)
    extrema = mapwindow(find_extrema, DoG_all_levels, window)
    
    # Exercise part c: Limit the number of local features with tresholding.
    t = 0.03
    for level in 1:4
        channels = channelview(extrema[level])
        features = abs.(channels[1, :, :]) .> t
        feature_points = Gray.(features)
        p = plot!(feature_points)
    end
    display(p)
end

function find_extrema(vals)
    c = centered(vals)[0, 0]
    if ((c == maximum(vals)) || (c == minimum(vals)))
        return c
    else
        return zero(c)
    end
end

main()
