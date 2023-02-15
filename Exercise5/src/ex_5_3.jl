using Images
using Plots
using ImageEdgeDetection
using ImageEdgeDetection: Percentile

function main()
    # Exercise part a: Load the image and perform edge detection.
    img = load(joinpath(@__DIR__, "../data/circle.png"))
    edge_points = edge_detection(img)


end

function edge_detection(img)
    dimensions = size(img)

    # Find gradients G_x and G_y.
    Gx, Gy = imgradients(img, KernelFactors.sobel)
    
    Gx_normalized = normalize(Gx)
    Gy_normalized = normalize(Gy)
    grayx = Gx_normalized .|> Gray
    grayy = Gy_normalized .|> Gray

    t1 = 0.75
    t2 = 0.70

    binary_img = falses(reverse(dimensions))

    # For each pixel, update binary image to represent the edges.
    for i in 1:dimensions[1]
        for j in 1:dimensions[2]
            if ((t1 < sqrt(grayx[i, j] ^ 2 + grayy[i, j] ^ 2)) || t2 > sqrt(grayx[i, j] ^ 2 + grayy[i, j] ^ 2))
                binary_img[i, j] = true
            else
                binary_img[i, j] = false
            end
        end
    end

    # Thin the edges.
    binary = thinning(binary_img)
    edges = plot_image(Gray.(binary), title = "Edges")

    # Make a list of the pixels along the edge.
    list = []
    for i in 1:dimensions[1]
        for j in 1:dimensions[2]
            if (binary[i, j] == 1)
                push!(list, (i, j))
            end
        end
    end
    return list
end

plot_image(img; kws...) = 
    plot(img; aspect_ratio=:equal, size=size(img), framestyle=:none, kws...)

main()
