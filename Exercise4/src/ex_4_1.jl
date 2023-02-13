# NOTE FOR SELF: remember to implement canny ImageEdgeDetection
# and answer the questions.
# More elegant way to get the dimensions

using Images
using Plots
using ImageFiltering
using Statistics
using ImageEdgeDetection
using ImageEdgeDetection: Percentile

function main()
    blocks = load(joinpath(@__DIR__, "../data/blocks_bw.png"))
    dimensions = size(blocks)
    p_blocks = plot_image(blocks)

    # Smooth out noise
    sigma = 0.5
    img_gaussian = imfilter(blocks, Kernel.gaussian(sigma))
    p_gaussian = plot_image(img_gaussian; title = "Gaussian, σ = $sigma");

    # Find gradients G_x and G_y
    Gx, Gy = imgradients(img_gaussian, KernelFactors.sobel)
    
    Gx_normalized = normalize(Gx)
    Gy_normalized = normalize(Gy)
    grayx = Gx_normalized .|> Gray
    grayy = Gy_normalized .|> Gray

    t = 0.74

    binary_img = falses(dimensions[1], dimensions[2])

    # For each pixel
    for i in 1:dimensions[1]
        for j in 1:dimensions[2]
            if (t < sqrt(grayx[i, j] ^ 2 + grayy[i, j] ^ 2))
                binary_img[i, j] = true
            else
                binary_img[i, j] = false
            end
        end
    end

    binary = thinning(binary_img)
    #Gy_img = plot_image(grayy)
    edges = plot_image(Gray.(binary))
    
    # Compare the results to canny edge detection.
    #sigma2 = 0.5
    #img_gaussian2 = imfilter(blocks, Kernel.gaussian(sigma2))
    canny_alg = Canny(spatial_scale = 3, high = Percentile(75), low = Percentile(10))
    img_canny = detect_edges(img_gaussian, canny_alg)
    plot_canny = plot_image(img_canny)

    p = plot(p_blocks, p_gaussian, edges, plot_canny)
end

plot_image(img; kws...) = 
    plot(img; aspect_ratio=:equal, size=size(img), framestyle=:none, kws...)

# Normalize the image by bringing all image values into the range [0, 1].
function normalize(img)
    min, max = extrema(img)
    normalized = (img .- min) ./ (max - min)
    return normalized
end

main()
