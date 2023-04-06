using Plots
using Images

function main()
    img = load(joinpath(@__DIR__, "../data/image.png"))
    template = load(joinpath(@__DIR__, "../data/template.png"))
    starting_point1 = [60; 155]
    starting_point2 = [50; 55]
    starting_point3 = [150; 15]

    track(img, template, starting_point1)
end

function track(img, template, x)
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
    display(template_histogram)

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
    while(true)
        # Compute histogram of the region
        region_histogram = zeros(2, 2, 2)
        for i in 1:sz[1]
            for j in 1:sz[2]

                try
                    point = img[Int64(x[1] + i), Int64(x[2] + j)]
                    if ((red(point) == 1) && (blue(point) == 0) && (green(point) == 0))         # red 
                        region_histogram[1, 2, 2] += 1
                    elseif ((red(point) == 0) && (blue(point) == 1) && (green(point) == 0))    # green
                        region_histogram[2, 1, 2] += 1
                    elseif ((red(point) == 0) && (blue(point) == 0) && (green(point) == 1))    # blue
                        region_histogram[2, 2, 1] += 1
                    elseif ((red(point) == 0) && (blue(point) == 0) && (green(point) == 0))    # black
                        region_histogram[2, 2, 2] += 1
                    elseif ((red(point) == 1) && (blue(point) == 1) && (green(point) == 1))    # white
                        region_histogram[1, 1, 1] += 1
        
                    # Mixes of two colors
                    elseif ((red(point) == 1) && (blue(point) == 1) && (green(point) == 0))
                        region_histogram[1, 1, 2] += 1
                    elseif ((red(point) == 1) && (blue(point) == 0) && (green(point) == 1))
                        region_histogram[1, 2, 1] += 1
                    elseif ((red(point) == 0) && (blue(point) == 1) && (green(point) == 1))
                        region_histogram[2, 1, 1] += 1
                    end
                catch BoundsError
                    #println("Bounds error")
                end

            end
        end

        # Normalize histogram
        for rval in 1:2
            for gval in 1:2
                for bval in 1:2
                    region_histogram[rval, gval, bval] /= no_of_pixels
                end
            end
        end
        display(region_histogram)
        
        # Compute weight
        w = zeros(sz[1], sz[2])
        for i in 1:sz[1]
            for j in 1:sz[2]

                try
                    point = img[Int64(x[1] + i), Int64(x[2] + j)]
                    if ((red(point) == 1) && (blue(point) == 0) && (green(point) == 0))         # red 
                        w[i, j] = sqrt(template_histogram[1, 2, 2] / region_histogram[1, 2, 2])
                    elseif ((red(point) == 0) && (blue(point) == 1) && (green(point) == 0))    # green
                        w[i, j] = sqrt(template_histogram[2, 1, 2] / region_histogram[2, 1, 2])
                    elseif ((red(point) == 0) && (blue(point) == 0) && (green(point) == 1))    # blue
                        w[i, j] = sqrt(template_histogram[2, 2, 1] / region_histogram[2, 2, 1])
                    elseif ((red(point) == 0) && (blue(point) == 0) && (green(point) == 0))    # black
                        w[i, j] = sqrt(template_histogram[2, 2, 2] / region_histogram[2, 2, 2])
                    elseif ((red(point) == 1) && (blue(point) == 1) && (green(point) == 1))    # white
                        w[i, j] = sqrt(template_histogram[1, 1, 1] / region_histogram[1, 1, 1])
        
                    # Mixes of two colors
                    elseif ((red(point) == 1) && (blue(point) == 1) && (green(point) == 0))
                        w[i, j] = sqrt(template_histogram[1, 1, 2] / region_histogram[1, 1, 2])
                    elseif ((red(point) == 1) && (blue(point) == 0) && (green(point) == 1))
                        w[i, j] = sqrt(template_histogram[1, 2, 1] / region_histogram[1, 2, 1])
                    elseif ((red(point) == 0) && (blue(point) == 1) && (green(point) == 1))
                        w[i, j] = sqrt(template_histogram[2, 1, 1] / region_histogram[2, 1, 1])
                    end
                catch BoundsError
                    #println("Bounds Error")
                end

            end
        end

        # Compute new x
        sumw = 0
        sumwx = [0, 0]
        for i in 1:sz[1]
            for j in 1:sz[2]
                point = [x[1] + i, x[2] + j]
                sumwx += point * w[i, j]
                sumw += w[i, j]
            end
        end
        if (sumw == 0)
            plt = plot(img)
            plot!([x[1]], [x[2]], seriestype=:scatter)
            display(plt)
            println("end")
            break
        end
        new_x = sumwx / sumw
        new_x[1] = round(Int64, new_x[1])
        new_x[2] = round(Int64, new_x[2])

        # break if x does not get updated anymore
        if (new_x == x)
            break
        end

        # Update x
        x = new_x
    end
end

main()
