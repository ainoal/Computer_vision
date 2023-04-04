using Images
using Pkg
using Plots
Pkg.instantiate()

function main()
    # Load the sequence of images and stack them to a 3D matrix with dimensions
    # height x width x time
    img_seq = readdir(joinpath(@__DIR__, "../data/seq1"))
    img_matrix = load(joinpath(@__DIR__, "../data/seq1/", img_seq[1]))
    for i in 2:10
        new_img = load(joinpath(@__DIR__, "../data/seq1/", img_seq[i]))
        img_matrix = cat(img_matrix, new_img; dims=3)
    end
    motion_segmentation(img_matrix)

    img_seq2 = readdir(joinpath(@__DIR__, "../data/seq1"))
    img_matrix2 = load(joinpath(@__DIR__, "../data/seq1/", img_seq2[1]))
    for i in 2:10
        new_img = load(joinpath(@__DIR__, "../data/seq1/", img_seq2[i]))
        img_matrix2 = cat(img_matrix2, new_img; dims=3)
    end
    motion_segmentation(img_matrix2)
end

function motion_segmentation(img_matrix)
    # Convert to grayscale
    gray_matrix = Gray.(img_matrix)

    # Implement motion segmentation based on image difference.
    treshold = 0.5
    dimensions = size(gray_matrix)
    difference_matrix = zeros(dimensions[1], dimensions[2], dimensions[3] - 1)
    for i in 1:dimensions[1]
        for j in 1:dimensions[2]
            for img in 1:(dimensions[3] - 1)
                # Step 1: Compute a pointwise image difference
                difference = gray_matrix[i, j, img] - gray_matrix[i, j, img + 1]
                # Step 2: if the difference is larger than treshold, the pixel is moving
                if (abs(difference) > treshold)
                    difference_matrix[i, j, img] = 1
                end
            end
        end
    end

    for frame in 1:(dimensions[3] - 1)
        motion = plot_image(Gray.(difference_matrix[:, :, frame]), 
            title = "Difference between image frames")
        display(motion)
    end
end

plot_image(img; kws...) = 
    plot(img; aspect_ratio=:equal, size=size(img), framestyle=:none, kws...)

main()
