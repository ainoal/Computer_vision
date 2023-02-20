using Images
using ImageFiltering
using Plots

function main()
    I = load(joinpath(@__DIR__, "../data/lena_bw.png"))
    p = plot(I)
    I = channelview(I)

    # Exercise parts a-d
    exercise(I)

    # The features show the locations of edges of features well.
    # This feature recognition could be improved for example by
    # grouping points together that belong to the same feature.
    # If we want to concentrate on features of certain size, we can
    # only look at the output of some levels of the DoG images. In this
    # way, if we i.e. want to detect a person's eyes, we will not
    # find too big features like head or too small features like
    # a freckle on the face.

    # Exercise part e: repeat (a-d) for transformed image.
    img = load(joinpath(@__DIR__, "../data/lena_bw_transformed.png"))
    p = plot(img)
    img = channelview(img)
    exercise(img)

    # For the most part, the features recognized in the original and
    # transformed images are the same. However, in the transformed image,
    # for example the edges of the image are recognized as features.
end

function exercise(I)
    # Exercise part a: Construct stack of Gaussians.
    gaussians = Matrix{Float64}[I, I, I, I, I]     # Initialize the array
    sigma = 1.6
    imgsize = size(I)

    for i in 1:5
        gaussians[i] = imfilter(I, Kernel.gaussian(sigma))
        sigma = sqrt(2) * sigma
    end

    # Calculate Differences of Gaussians.
    D = Matrix{Float64}[I, I, I, I]                # Initialize the array
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
        features = abs.(extrema[:, :, level]) .> t
        feature_p = Gray.(features)
        feature_points = Vector{Tuple{Int64, Int64}}()
        for k in 1:imgsize[1]
            for j in 1:imgsize[2]
                if (feature_p[k, j] == true)
                    push!(feature_points, (j, k))
                end
            end
        end

        p = plot!(feature_points, seriestype=:scatter)
        display(p)
    end
end

function find_extrema(vals)
    c = centered(vals)[0, 0, 0]
    if ((c == maximum(vals)) || (c == minimum(vals)))
        return c
    else
        return zero(c)
    end
end

main()
