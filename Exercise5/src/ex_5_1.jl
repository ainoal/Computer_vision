using Images

function main()
    I = load(joinpath(@__DIR__, "../data/lena_bw.png"))

    # Construct stack of Gaussians
    sigma = 1.6
    prev = I
    D = Vector{Matrix{Gray{Float64}}}()
    for i in 1:4
        next_sigma = sqrt(sigma)
        temp = imfilter(prev, Kernel.gaussian(sigma)) - imfilter(prev, Kernel.gaussian(next_sigma))
        push!(D, temp)
        sigma = next_sigma
        prev = temp
    end
end

main()
