using Images
using ImageFiltering
using Statistics
using LinearAlgebra


function main()
    # Load the sequence of images and stack them to a 3D matrix with dimensions
    # height x width x time
    img_seq = readdir(joinpath(@__DIR__, "../data/seq1"))
    img_matrix = load(joinpath(@__DIR__, "../data/seq1/", img_seq[1]))
    for i in 2:10
        new_img = load(joinpath(@__DIR__, "../data/seq1/", img_seq[i]))
        img_matrix = cat(img_matrix, new_img; dims=3)
    end

    # Smooth along dimensions h x w with a Gaussian filter
    dimensions = size(img_matrix)
    sigma = 1.5     # Standard deviation
    gaussians = zeros(RGB{Float64}, dimensions[1], dimensions[2], dimensions[3])
    for img in 1:dimensions[3]
        gaussians[:, :, img] = imfilter(img_matrix[:, :, img], Kernel.gaussian(sigma))
    end

    # Smooth along the temporal dimension
    for i in 1:dimensions[1]
        for j in 1:dimensions[2]
            gaussians[i, j, :] = imfilter(img_matrix[i, j, :], Kernel.gaussian((sigma,)))
        end
    end

    # Find gradients G_x and G_y
    Ix, Iy, It = imgradients(gaussians, KernelFactors.sobel)
    Ix_n = normalize(Ix)
    Iy_n = normalize(Iy)
    It_n = normalize(It)
    Ix_g = Ix_n .|> Gray
    Iy_g = Iy_n .|> Gray
    It_g = It_n .|> Gray
    gradients = zip.(Ix_g, Iy_g, It_g)
    #display(gradients)

    # For each pixel of the image sequence, compute matrix A and vector b
    #A = zeros(5 * 5, 2)
    window = (5, 5, 5)
    # TODO: initialize empty matrices A and b
    #for img in 1:dimensions[3]
    A = mapwindow(find_A_and_b, gradients, window)
        #display(A)
    #end
end

function find_A_and_b(vals)
    A = zeros(5*5, 2)
    b = zeros(5*5)

    v = collect(vals)
    display(v)
    #=for i in 1:5
        for j in 1:5
            println(vals[i, j, 2][2])
            A[5*i-5 + j, 2] = vals[i, j, 3, 1]
        end
    end=#

    return A
end

function mapdimension(vals)
    v = zeros(5*5)
    #vec = 
    println()
    for i in 1:5
        for j in 1:5
            #println(vals[i, j, 3][3])
            v[i, j] = vals[i, j]
        end
    end

    return v
end

main()

