using Plots
using Images

function main()
    img = load(joinpath(@__DIR__, "../data/image.png"))
    template = load(joinpath(@__DIR__, "../data/template.png"))
    track(img, template)
end

function track(img, template)
    sz = size(template)

    # Construct template histogram
    template_histogram = zeros(2, 2, 2)
    for i in 1:sz[1]
        for j in 1:sz[2]
            point = template[i, j]
            if ((red(point) == 1) && (blue(point) == 0) && (green(point) == 0))         # red 
                template_histogram[1, 2, 2] += 1
            elseif ((red(point) == 0) && (blue(point) == 1) && (green(point) == 0))    # green
                template_histogram[2, 1, 2] += 1
            elseif ((red(point) == 0) && (blue(point) == 0) && (green(point) == 1))    # blue
                template_histogram[2, 2, 1] += 1
            elseif ((red(point) == 0) && (blue(point) == 0) && (green(point) == 0))    # black
                template_histogram[2, 2, 2] += 1
            elseif ((red(point) == 1) && (blue(point) == 1) && (green(point) == 1))    # white
                template_histogram[1, 1, 1] += 1

            # Mixes of two colors
            elseif ((red(point) == 1) && (blue(point) == 1) && (green(point) == 0))
                template_histogram[1, 1, 2] += 1
            elseif ((red(point) == 1) && (blue(point) == 0) && (green(point) == 1))
                template_histogram[1, 2, 1] += 1
            elseif ((red(point) == 0) && (blue(point) == 1) && (green(point) == 1))
                template_histogram[2, 1, 1] += 1
            end
        end
    end
    #display(template_histogram)

    # Normalize template histogram
    no_of_pixels = sz[1] * sz[2]
    for rval in 1:2
        for gval in 1:2
            for bval in 1:2
                template_histogram[rval, gval, bval] /= no_of_pixels
            end
        end
    end
    #display(template_histogram)

    # For each pixel in a target patch, find an appropriate bin u
    # of the RGB colour in histogram. Add 1 to that bin u

    # Normalize by dividing each bin by the number of pixels

    # Compute mean shift and update
end

main()
