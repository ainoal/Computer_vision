# QUESTIONS for the exercise class: Sobel and Brewitt kernel:
# what are they, differences, when to use each...?

using Images
using Plots
using ImageFiltering
using Statistics
using ImageEdgeDetection
using ImageEdgeDetection: Percentile

function main()
    blocks = load(joinpath(@__DIR__, "../data/blocks_bw.png"))
    dimensions = [576, 768]

    # Smooth out noise
    sigma = 0.5
    img_gaussian = imfilter(blocks, Kernel.gaussian(sigma))
    p_gaussian = plot_image(img_gaussian; title = "Gaussian, σ = $sigma");

    # Find gradients G_x and G_y
    # QUESTION for the exercise class: Sobel and Brewitt kernel:
    # what are they, differences, when to use each...?
    Gx, Gy = imgradients(img_gaussian, KernelFactors.sobel)
    
    Gx_normalized = normalize(Gx)
    Gy_normalized = normalize(Gy)
    grayx = Gx_normalized .|> Gray
    grayy = Gy_normalized .|> Gray


    t = 0.74

    print(size(grayx))

    # HUOM: EI TARVITA MOLEMPIA KUVIA, KOSKA NE OVAT SAMAT
    binary_img = falses(dimensions[1], dimensions[2])

    # For each pixel
    for i in 1:dimensions[1]
        for j in 1:dimensions[2]
            if (t < sqrt(grayx[i, j] ^ 2 + grayy[i, j] ^ 2))
                binary_img[i, j] = true
                grayy[i, j] = 1
            else
                binary_img[i, j] = false
                grayy[i, j] = 0
            end
        end
    end

    binary = thinning(binary_img)
    #Gx_img = plot_image(grayx)
    Gy_img = plot_image(grayy)
    edges = plot_image(Gray.(binary))
    
    p = plot(p_gaussian, edges, Gy_img)
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
