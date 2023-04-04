using Images
using ImageFiltering
using Statistics
using LinearAlgebra

function main()
    plotlyjs()
    # Load the sequence of images and stack them to a 3D matrix with dimensions
    # height x width x time
    img_seq = readdir(joinpath(@__DIR__, "../data/seq1"))
    first_img = load(joinpath(@__DIR__, "../data/seq1/", img_seq[1]))
    img_matrix = imresize(first_img, ratio=1/4)
    for i in 2:10
        new_img = load(joinpath(@__DIR__, "../data/seq1/", img_seq[i]))
        new_img = imresize(new_img, ratio=1/4)
        img_matrix = cat(img_matrix, new_img; dims=3)
    end

    # Smooth along dimensions h x w with a Gaussian filter
    dimensions = size(img_matrix)
    sigma = 1.5         # Standard deviation
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
    gradients = cat(Ix_g, Iy_g, It_g; dims=3)

    # For each pixel of the image sequence, compute matrix A and vector b
    window = (5, 5, 3)
    v = mapwindow(find_v, gradients, window)

    # Plot the optical flow
    p = plot_image(imresize(Gray.(first_img), ratio=1/4))
    for i in 1:dimensions[1]
        for j in 1:dimensions[2]
            if (mod(i, 5) == 0)
                quiver!(i, j, quiver=(v[1],v[2]))
            end
        end
    end
    display(p)
end

function find_v(vals)
    A = zeros(5 * 5, 2)
    b = zeros(5 * 5)

    for i in 1:5
        for j in 1:5
            A[5*i-5 + j, 1] = vals[i, j, 1]     # 1 = x values
            A[5*i-5 + j, 2] = vals[i, j, 2]     # 2 = y values
            b[5*i-5 + j] = -vals[i, j, 3]       # 3 = t values
        end
    end

    T = transpose(A) * A
    if (is_invertable(T))
        R = (det(T) - 0.04 * tr(T))
        if (abs(R) > 0.001)
            vec = (transpose(A) * A) \ transpose(A) * b
        else
            vec = zeros(eltype(vals), 2)
        end
    else
        vec = zeros(eltype(vals), 2)
    end

    #display(vec)
    return vec
end

function is_invertable(M)
    # If determinant not equal to 0, is invertable
    if (det(M) == 0)
        return false
    else
        return true
    end
end

plot_image(img; kws...) = 
    plot(img; aspect_ratio=:equal, size=size(img), framestyle=:none, kws...)

main()
