using Images
using Plots
using LinearAlgebra

function main()
    blocks = load(joinpath(@__DIR__, "../data/blocks_bw.png"))
    sigma = 1
    img_gaussian = imfilter(blocks, Kernel.gaussian(sigma))

    # Corner detection with Harris method
    corners = find_corners(img_gaussian, 5, 0.005)
    plot(blocks)
    p = plot!(corners, seriestype=:scatter)

    # Corner detection with Thomasi-Kanade method
    corners_tk = thomasi_kanade(img_gaussian, 5, 0.04)
    plot(blocks)
    p2 = plot!(corners_tk, seriestype=:scatter)

    p3 = plot(p, p2)
    display(p3)

    # Even after adjusting the tresholds, the corner detection
    # using the Harris method and the Thomasi-Kanade method detect_edges
    # a bit different corners. For most part, they are the same, but
    # the two methods work a bit differently. In the plotted images,
    # both plots have certain corners that are not in the other one.
end

function find_corners(img, N, t, k=0.04)
    dimensions = size(img)
    cornerness = zeros(dimensions[1], dimensions[2])
    pruned_corners = zeros(dimensions[1], dimensions[2])
    Ix, Iy = imgradients(img, KernelFactors.sobel)
    half_neighborhood = div(N, 2)

    println("Looking for corners, please wait")

    # For each pixel
    for i in 1:dimensions[1]
        for j in 1:dimensions[2]
            # Go through the neighborhood to sum the gradients in the neighborhood
            sum_Ix_power2 = 0
            sum_Iy_power2 = 0
            sum_Ix_Iy = 0

            if (((i-half_neighborhood) < 1) ||((j-half_neighborhood)<1)||
                ((i+half_neighborhood) > dimensions[1]) || ((j+half_neighborhood)>dimensions[2]))
                # Special cases on the edges of the image: in this exercise, we can just
                # disrecard the few pixels at the very edges of the image. If those areas were
                # important to us, we should implement e.g. padding with the same values as
                # the pixels at the edge of the image.
            else
                #mapwindow(sum, Ix, N)
                for m in (i-half_neighborhood):(i+half_neighborhood)
                    for n in (j-half_neighborhood):(j+half_neighborhood)
                        sum_Ix_power2 += (Ix[m, n])^2
                        sum_Iy_power2 += (Iy[m, n])^2
                        sum_Ix_Iy += Ix[m, n] * Iy[m, n]
                    end
                end
            end
            # Construct matrix T
            T = [sum_Ix_power2 sum_Ix_Iy; sum_Ix_Iy sum_Iy_power2]
            # Calculate eigenvalues
            eig = eigvals(T)

            R = eig[1] * eig[2] - k * (eig[1] - eig[2])^2
            if (R > t)
                cornerness[i, j] = R
            else
                cornerness[i, j] = 0
            end
        end
    end

    for i in 1:dimensions[1]
        for j in 1:dimensions[2]
            if (((i-half_neighborhood) < 1) ||((j-half_neighborhood)<1) || 
                ((i+half_neighborhood) > dimensions[1]) ||((j+half_neighborhood)>dimensions[2]))
            else
                pruned_corners[i, j] = 1
                for m in (i-half_neighborhood):(i+half_neighborhood)
                    for n in (j-half_neighborhood):(j+half_neighborhood)
                        if ((cornerness[m, n] > cornerness[i, j]) || (cornerness[i, j] == 0))
                            pruned_corners[i, j] = 0
                        end
                    end
                end
            end
        end
    end

    corners = Vector{Tuple{Int64, Int64}}()
    for i in 1:dimensions[1]
        for j in 1:dimensions[2]
            if(cornerness[i, j] != 0)
                push!(corners, (j, i))
            end
        end
    end

    return corners
end

function thomasi_kanade(img, N, t)
    dimensions = size(img)
    cornerness = zeros(dimensions[1], dimensions[2])
    pruned_corners = zeros(dimensions[1], dimensions[2])
    Ix, Iy = imgradients(img, KernelFactors.sobel)
    half_neighborhood = div(N, 2)

    # For each pixel
    for i in 1:dimensions[1]
        for j in 1:dimensions[2]
            # Go through the neighborhood to sum the gradients in the neighborhood
            sum_Ix_power2 = 0
            sum_Iy_power2 = 0
            sum_Ix_Iy = 0

            # Special cases on the edges of the image
            if (((i-half_neighborhood) < 1) ||((j-half_neighborhood)<1)||
                ((i+half_neighborhood) > dimensions[1]) ||((j+half_neighborhood)>dimensions[2])) 
            else
                for m in (i-half_neighborhood):(i+half_neighborhood)
                    for n in (j-half_neighborhood):(j+half_neighborhood)
                        sum_Ix_power2 += (Ix[m, n])^2
                        sum_Iy_power2 += (Iy[m, n])^2
                        sum_Ix_Iy += Ix[m, n] * Iy[m, n]
                    end
                end
            end
            # Construct matrix T
            T = [sum_Ix_power2 sum_Ix_Iy; sum_Ix_Iy sum_Iy_power2]
            # Calculate eigenvalues
            eig = eigvals(T)

            if (eig[1] > t)
                cornerness[i, j] = eig[1]
            else
                cornerness[i, j] = 0
            end
        end
    end

    for i in 1:dimensions[1]
        for j in 1:dimensions[2]
            if (((i-half_neighborhood) < 1) ||((j-half_neighborhood)<1)||
                ((i+half_neighborhood) > dimensions[1]) ||((j+half_neighborhood)>dimensions[2]))
            else
                pruned_corners[i, j] = 1
                for m in (i-half_neighborhood):(i+half_neighborhood)
                    for n in (j-half_neighborhood):(j+half_neighborhood)
                        if ((cornerness[m, n] > cornerness[i, j]) || (cornerness[i, j] == 0))
                            pruned_corners[i, j] = 0
                        end
                    end
                end
            end
        end
    end

    corners = Vector{Tuple{Int64, Int64}}()
    for i in 1:dimensions[1]
        for j in 1:dimensions[2]
            if(cornerness[i, j] != 0)
                push!(corners, (j, i))
            end
        end
    end

    return corners
end

main()
