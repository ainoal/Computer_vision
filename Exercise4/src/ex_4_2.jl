using Images
using Plots
using LinearAlgebra

function main()
    blocks = load(joinpath(@__DIR__, "../data/blocks_bw.png"))
    corners = find_corners(blocks, 3, 0.02)
    plot_image(blocks)
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
            # INSTEAD OF THIS IMPLEMENTATION: use mapwindow()
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
            # Construct matrix t
            T = [sum_Ix_power2 sum_Ix_Iy; sum_Ix_Iy sum_Iy_power2]
            # Calculate eigenvalues
            eig = eigvals(T)
            R = eig[1] * eig[2] - k * (eig[1] - eig[2])^2
            #println(eigenvalues)

            # FROM HERE: change the code according to slides p. 40
            if (R > t)
                cornerness[i, j] = R
                #print("cornerness > 0")
            else
                cornerness[i, j] = 0
            end
        end
    end

    #minmax = mapwindow(extrema, img, N)
    #print(size(minmax))
    for i in 1:dimensions[1]
        for j in 1:dimensions[2]
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
                push!(corners, (i, j))
            end
        end
    end

    println(":)")
    return corners
end

plot_image(img; kws...) = 
    plot(img; aspect_ratio=:equal, size=size(img), framestyle=:none, kws...)

main()
