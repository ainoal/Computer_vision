using Plots
using Images

function main()
    img = load(joinpath(@__DIR__, "../data/image.png"))
    template = load(joinpath(@__DIR__, "../data/template.png"))

    # As the lecture slides define p(x) as the color histogram of a region
    # centered at image point x but the starting points of task 10.3
    # are on the upper left corners of the squares as per figure 2 of task assignment,
    # I am adding half template size to the x and y coordinates of each starting
    # point so that I can use the algorithm from the slides more easily.
    starting_point1 = [60 + 40; 155 + 40]
    starting_point2 = [50 + 40; 55 + 40]
    starting_point3 = [150 + 40; 15 + 40]

    track(img, template, starting_point1)
    track(img, template, starting_point2)
    track(img, template, starting_point3)
end

function track(img, template, x)
    sz = size(template)
    println(sz)

    # Construct template histogram.
    # For each pixel in a target patch, find an appropriate bin u
    # of the RGB colour in histogram. Add 1 to that bin u.
    template_histogram = zeros(2, 2, 2)
    for i in 1:sz[1]
        for j in 1:sz[2]
            point = template[i, j]
            if ((red(point) == 1) && (blue(point) == 0) && (green(point) == 0))        # red 
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

    # Compute mean shift and update
    while(true)
        # Compute histogram of the region
        region_histogram = zeros(2, 2, 2)
        for i in 1:sz[1]
            for j in 1:sz[2]

                try
                    point = img[Int64(x[1] + i - sz[1]/2), Int64(x[2] + j - sz[2]/2)]
                    if ((red(point) == 1) && (blue(point) == 0) && (green(point) == 0))        # red 
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
                    println("Bounds Error")
                    
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
        #display(region_histogram)
        
        # Compute weight
        w = zeros(sz[1], sz[2])
        for i in 1:sz[1]
            for j in 1:sz[2]

                try
                    point = img[Int64(x[1] + i - sz[1]/2), Int64(x[2] + j - sz[2]/2)]
                    
                    if ((red(point) == 1) && (blue(point) == 0) && (green(point) == 0))         # red 
                        w[i, j] += sqrt(template_histogram[1, 2, 2] / region_histogram[1, 2, 2])
                    elseif ((red(point) == 0) && (blue(point) == 1) && (green(point) == 0))    # green
                        w[i, j] += sqrt(template_histogram[2, 1, 2] / region_histogram[2, 1, 2])
                    elseif ((red(point) == 0) && (blue(point) == 0) && (green(point) == 1))    # blue
                        w[i, j] += sqrt(template_histogram[2, 2, 1] / region_histogram[2, 2, 1])
                    elseif ((red(point) == 0) && (blue(point) == 0) && (green(point) == 0))    # black
                        w[i, j] += sqrt(template_histogram[2, 2, 2] / region_histogram[2, 2, 2])
                    elseif ((red(point) == 1) && (blue(point) == 1) && (green(point) == 1))    # white
                        w[i, j] += sqrt(template_histogram[1, 1, 1] / region_histogram[1, 1, 1])
        
                    # Mixes of two colors
                    elseif ((red(point) == 1) && (blue(point) == 1) && (green(point) == 0))
                        w[i, j] += sqrt(template_histogram[1, 1, 2] / region_histogram[1, 1, 2])
                    elseif ((red(point) == 1) && (blue(point) == 0) && (green(point) == 1))
                        w[i, j] += sqrt(template_histogram[1, 2, 1] / region_histogram[1, 2, 1])
                    elseif ((red(point) == 0) && (blue(point) == 1) && (green(point) == 1))
                        w[i, j] += sqrt(template_histogram[2, 1, 1] / region_histogram[2, 1, 1])
                    end
                catch BoundsError
                    println("Bounds Error")
                end

            end
        end

        # Compute new x
        sumw = 0
        sumwx = [0, 0]
        for i in 1:sz[1]
            for j in 1:sz[2]
                point = [x[1] + i - sz[1]/2, x[2] + j - sz[2]/2]
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

        # Break if x does not get updated anymore and plot the result.
        if (new_x == x)
            plt = plot(img)
            plot!([new_x[1]], [new_x[2]], seriestype=:scatter)

            # Plot the corners of the square
            plot!([new_x[1] - sz[1]/2], [new_x[2] - sz[2]/2], seriestype=:scatter)
            plot!([new_x[1] - sz[1]/2], [new_x[2] + sz[2]/2], seriestype=:scatter)
            plot!([new_x[1] + sz[1]/2], [new_x[2] - sz[2]/2], seriestype=:scatter)
            plot!([new_x[1] + sz[1]/2], [new_x[2] + sz[2]/2], seriestype=:scatter)

            display(plt)
            break
        end

        # Update x
        x = new_x

    end
end

function construct_histogram()

end

main()
