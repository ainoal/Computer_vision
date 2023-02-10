using Images
using Plots
using LinearAlgebra

function main()
    blocks = load(joinpath(@__DIR__, "../data/blocks_bw.png"))
    sigma = 0
    img_gaussian = imfilter(blocks, Kernel.gaussian(sigma))
    println("Looking for corners")
    corners = find_corners(img_gaussian, 9, 0.02)
    #plot_image(blocks)
    plot(blocks)
    #print(corners)
    #L = [(71, 295), (94, 156)]
    p = plot!(corners, seriestype=:scatter)
end

function find_corners(img, N, t, k=0.04)
    dimensions = size(img)
    cornerness = zeros(dimensions[1], dimensions[2])
    pruned_corners = zeros(dimensions[1], dimensions[2])
    Ix, Iy = imgradients(img, KernelFactors.sobel)
    half_neighborhood = div(N, 2)


    #mapwindow(sum_neighborhood, Ix, N)
    #L = Vector{Float64}()

    # For each pixel
    #mapwindow(sum, Ix, N)
    for i in 1:dimensions[1]
        for j in 1:dimensions[2]
            # Go through the neighborhood to sum the gradients in
            # the neighborhood
            sum_Ix_power2 = 0
            sum_Iy_power2 = 0
            sum_Ix_Iy = 0

            # Special cases on the edges of the image: to be implemented later
            if (((i-half_neighborhood) < 1) ||((j-half_neighborhood)<1)|| ((i+half_neighborhood) > dimensions[1]) ||((j+half_neighborhood)>dimensions[2]))
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

    #minmax = mapwindow(extrema, img, N)
    #print(size(minmax))
    for i in 1:dimensions[1]
        for j in 1:dimensions[2]
            # REMEMBER SPECIAL CASES
            if (((i-half_neighborhood) < 1) ||((j-half_neighborhood)<1)|| ((i+half_neighborhood) > dimensions[1]) ||((j+half_neighborhood)>dimensions[2]))
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

#=function sum_neighborhood()
    
end=#

#plot_image(img; kws...) = 
#    plot(img; aspect_ratio=:equal, size=size(img), framestyle=:none, kws...)

main()
