using Images
using Plots
using ImageFiltering
using Statistics
using ImageEdgeDetection
using ImageEdgeDetection: Percentile

function main()
    blocks = load(joinpath(@__DIR__, "../data/blocks_bw.png"))
    dimensions = size(blocks)
    p_blocks = plot_image(blocks; title = "Original image")

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
    edges = plot_image(Gray.(binary), title = "Edges")
    
    # Compare the results to canny edge detection.
    canny_alg = Canny(spatial_scale = 3, high = Percentile(75), low = Percentile(10))
    img_canny = detect_edges(img_gaussian, canny_alg)
    plot_canny = plot_image(img_canny, title = "Edges with canny detection")

    p = plot(p_blocks, p_gaussian, edges, plot_canny; size = (700, 700),
        layout=@layout [x x; x x])
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
