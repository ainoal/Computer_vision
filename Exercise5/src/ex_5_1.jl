using Images
using ImageFiltering

function main()
    I = load(joinpath(@__DIR__, "../data/lena_bw.png"))

    # Exercise part a: Construct stack of Gaussians.
    gaussians = [I, I, I, I, I]     # Initialize the array
    sigma = 1.6

    for i in 1:5
        gaussians[i] = imfilter(I, Kernel.gaussian(sigma))
        sigma = sqrt(sigma)
    end

    # Calculate Differences of Gaussians.
    D = [I, I, I, I]                # Initialize the array
    for j in 1:4
        D[j] = gaussians[j] - gaussians[j+1]
    end

    # Exercise part b: Find local extrema in D.
    # Local features can be found by finding local extrema in the stack of DoG.
    window = (3, 3)
    for k in 1:4
        minmax = mapwindow(extrema, D[k], window)
        # TODO: Find minmax of the higher and lower level as well and update
        # minmax according to that
    end

end

main()
