using Images
using ImageFiltering

function main()
    I = load(joinpath(@__DIR__, "../data/lena_bw.png"))

    # Exercise part a: Construct stack of Gaussians.
    sigma = 1.6
    prev = I
    D = Vector{Matrix{Gray{Float64}}}()
    push!(D, I)
    for i in 1:4
        next_sigma = sqrt(sigma)
        temp = imfilter(prev, Kernel.gaussian(sigma)) - imfilter(prev, Kernel.gaussian(next_sigma))
        push!(D, temp)
        sigma = next_sigma
        prev = temp
    end

    # Exercise part b: Find local extrema.
    window = 3
    for j in 1:4
        minmax_i = mapwindow(extrema, D[j], window)
    end
end

main()
