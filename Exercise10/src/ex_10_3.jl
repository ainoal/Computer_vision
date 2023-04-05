using Plots
using Images

function main()
    img = load(joinpath(@__DIR__, "../data/image.png"))
    template = load(joinpath(@__DIR__, "../data/template.png"))
    track(img, template)
end

function track(img, template)
    sz = size(template)
    template_histogram = zeros(8)


    # For each pixel in a target patch, find an appropriate bin u
    # of the RGB colour in histogram. Add 1 to that bin u

    # Normalize by dividing each bin by the number of pixels

    # Compute mean shift and update
end

main()
