using Images
using Plots
using ImageEdgeDetection
using ImageEdgeDetection: Percentile
using LinearAlgebra
using Random

function main()
    # Exercise part a: Load the image and perform edge detection.
    img = load(joinpath(@__DIR__, "../data/circle.png"))
    edge_points = edge_detection(img)

    # WHAT IS THE BEAUTIFUL WAY TO IMPLEMENT THIS?:
    println(size(edge_points))
    edgepoints_size = 158
    #x = size(getfield.(edge_points, 2))
    #println(x)
    #a = edge_points[6][1]
    #println(size(img))


    # Exercise part b: Implement SVD
    X = zeros(edgepoints_size, 4)
    #println(edge_points[1][1])
    rangex = [size(img)[1], 0]
    rangey = [size(img)[2], 0]
    # Construct matrix X that represents the circle.
    for i in 1:edgepoints_size
        X[i, 1] = (edge_points[i][1])^2 + (edge_points[i][2])^2
        X[i, 2] = edge_points[i][1]
        X[i, 3] = edge_points[i][2]
        X[i, 4] = 1

        if (edge_points[i][1] < rangex[1])
            rangex[1] = edge_points[i][1]
        end
        if (edge_points[i][2] < rangey[1])
            rangey[1] = edge_points[i][2]
        end
        if (edge_points[i][1] > rangex[2])
            rangex[2] = edge_points[i][1]
        end
        if (edge_points[i][2] > rangey[2])
            rangey[2] = edge_points[i][2]
        end
    end

    #println(rangex)
    #println(rangey)

    # Use SVD for solving the resulting set of linear equations.
    svd_vals = svd(X)
    V = svd_vals.V

    # Plot the circle found on the original image.
    #plot(V[:, 4])
    a = V[1, 4]
    b = V[2, 4]
    c = V[3, 4]
    d = V[4, 4]
    f(x, y) = a * (x^2 + y^2) + b*x + c*y + d

    gr()
    contour(
        range(rangex[1], rangex[2], 1000),
        range(rangey[1], rangey[2], 1000),
        f,
        color=:red,
        colorbar=nothing, 
        linewidth=2,
        aspect_ratio=:equal
    )
end

function edge_detection(img)
    dimensions = size(img)
    #println(dimensions)

    # Find gradients G_x and G_y.
    Gx, Gy = imgradients(img, KernelFactors.sobel)
    
    Gx_normalized = normalize(Gx)
    Gy_normalized = normalize(Gy)
    grayx = Gx_normalized .|> Gray
    grayy = Gy_normalized .|> Gray

    t = 0.01

    binary_img = falses(reverse(dimensions))

    # For each pixel, update binary image to represent the edges.
    for i in 1:dimensions[1]
        for j in 1:dimensions[2]
            if (t < sqrt(grayx[i, j] ^ 2 + grayy[i, j] ^ 2))
                binary_img[i, j] = true
            else
                binary_img[i, j] = false
            end
        end
    end

    # Thin the edges.
    binary = thinning(binary_img)
    edges = plot(Gray.(binary), title = "Edges")
    display(edges)

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
