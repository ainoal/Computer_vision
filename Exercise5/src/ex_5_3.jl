using Images
using Plots
using ImageEdgeDetection
using ImageEdgeDetection: Percentile

function main()
    # Exercise part a: Load the image and perform edge detection.
    img = load(joinpath(@__DIR__, "../data/circle.png"))
    dimensions = size(img)

    # Smooth out noise
    #sigma = 0
    #img_gaussian = imfilter(img, Kernel.gaussian(sigma))
    #p_gaussian = plot_image(img_gaussian; title = "Gaussian, σ = $sigma");

    # Find gradients G_x and G_y
    Gx, Gy = imgradients(img, KernelFactors.sobel)
    
    Gx_normalized = normalize(Gx)
    Gy_normalized = normalize(Gy)
    grayx = Gx_normalized .|> Gray
    grayy = Gy_normalized .|> Gray

    t = 0.73

    binary_img = falses(reverse(dimensions))

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
    edges = plot_image(Gray.(binary_img), title = "Edges")

    #=canny_alg = Canny(spatial_scale = 3, high = Percentile(80), low = Percentile(10))
    img_canny = detect_edges(img_gaussian, canny_alg)
    p_canny = plot_image(img_canny, title = "Edges with canny detection")
    p = plot(p_gaussian, p_canny; size = (700, 350), layout=@layout [x x])
    display(p)=#

end

plot_image(img; kws...) = 
    plot(img; aspect_ratio=:equal, size=size(img), framestyle=:none, kws...)

main()
