using Images
using Plots
using LinearAlgebra

function main()
    blocks = load(joinpath(@__DIR__, "../data/blocks_bw.png"))
    find_corners(blocks, 3, 3)
end

function find_corners(img, N, t, k=0.04)
    dimensions = [576, 768]
    cornerness = zeros(dimensions[1], dimensions[2])
    Ix, Iy = imgradients(img, KernelFactors.sobel)
    R = 

    # For each pixel
    for i in 1:dimensions[1]
        for j in 1:dimensions[2]
            # Go through the neighborhood to sum the gradients in
            # the neighborhood
            half_neighborhood = div(N, 2)
            sum_Ix = 0
            sum_Iy = 0
            # INSTEAD OF THIS IMPLEMENTATION: use mapwindow()
            # Special cases on the edges of the image: to be implemented later
            if (((i-half_neighborhood) < 1) ||((j-half_neighborhood)<1)|| ((i+half_neighborhood) > dimensions[1]) ||((j+half_neighborhood)>dimensions[2]))
            else
                for m in (i-half_neighborhood):(i+half_neighborhood)
                    for n in (j-half_neighborhood):(j+half_neighborhood)
                        sum_Ix += Ix[m, n]
                        sum_Iy += Iy[m, n]
                    end
                end
            end
            # Construct matrix t
            T = [sum_Ix^2 sum_Ix*sum_Iy; sum_Ix*sum_Iy sum_Iy^2]
            # Calculate eigenvalues
            eig = eigvals(T)
            R = eig[1] * eig[2] - k * (eig[1] - eig[2])^2
            #println(eigenvalues)

            #cornerness[i, j] = Gx
            #=if (t < sqrt(grayx[i, j] ^ 2 + grayy[i, j] ^ 2))
                binary_img[i, j] = true
                grayy[i, j] = 1
            else
                binary_img[i, j] = false
                grayy[i, j] = 0
            end=#
        end
    end
    println("lopussa")
    corners = 1
    return corners
end

main()
