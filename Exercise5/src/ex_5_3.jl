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
    #println(size(edge_points))
    edgepoints_size = 158

    # Exercise part b and c: Implement SVD and plot the circle
    # found in the original image.
    plot_shape(img, edge_points, edgepoints_size, "circle")

    # Exercise part d: Use the the equation for an ellipse to fitting
    # the circle found in the original image.
    plot_shape(img, edge_points, edgepoints_size, "ellipse")
end

# The function detects edges in the input image and returns a list of pixels
# along the edges.
function edge_detection(img)
    dimensions = size(img)

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

# The function plots a circle or an ellipse based on the inputs.
function plot_shape(img, edge_points, edgepoints_size, shape)
    columns = 0
    if (shape == "circle")
        columns = 4
    elseif (shape == "ellipse")
        columns = 6
    end
    X = zeros(edgepoints_size, columns)
    rangex = [size(img)[1], 0]
    rangey = [size(img)[2], 0]
    
    for i in 1:edgepoints_size
        # Construct matrix X that represents the circle.
        if (shape == "circle")
            X[i, 1] = (edge_points[i][1])^2 + (edge_points[i][2])^2
            X[i, 2] = edge_points[i][1]
            X[i, 3] = edge_points[i][2]
            X[i, 4] = 1
        elseif (shape == "ellipse")
            X[i, 1] = (edge_points[i][1])^2
            X[i, 2] = edge_points[i][1] * edge_points[i][2]
            X[i, 3] = (edge_points[i][2])^2
            X[i, 4] = edge_points[i][1]
            X[i, 5] = edge_points[i][2]
            X[i, 6] = 1
        end

        # Find the range of x and y values.
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

    # Use SVD for solving the resulting set of linear equations.
    svd_vals = svd(X)
    V = svd_vals.V

    # Plot the shape found on the image.
    eps = 0.1

    if (shape == "circle")
        a = V[1, 4]
        b = V[2, 4]
        c = V[3, 4]
        d = V[4, 4]
        f(x, y) = a * (x^2 + y^2) + b*x + c*y + d
        cont = contour(
            range(rangex[1]-eps, rangex[2], 1000),
            range(rangey[1], rangey[2], 1000),
            f,
            levels=0:0,
            color=:red,
            colorbar=nothing, 
            linewidth=2,
            aspect_ratio=:equal
        )
    elseif (shape == "ellipse")
        a = V[1, 4]
        b = V[2, 4]
        c = V[3, 4]
        d = V[4, 4]
        e = V[5, 4]
        f = V[6, 4]
        g(x, y) = a*x^2 + b*x*y + c*y^2 + d*x + e*y + f
        cont = contour(
            # Modifying the range because fitting an ellipse
            # to the parameters does not work perfectly.
            range(rangex[1]-100, rangex[2]+100, 1000),
            range(rangey[1]-100, rangey[2]+100, 1000),
            g,
            levels=0:0,
            color=:red,
            colorbar=nothing, 
            linewidth=2,
            aspect_ratio=:equal
        )
    end

    display(cont)
end

plot_image(img; kws...) = 
    plot(img; aspect_ratio=:equal, size=size(img), framestyle=:none, kws...)

main()
