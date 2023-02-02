using Images
using Plots
using Noise
using Random

function main()
    # Load and plot the image
    lena = load(joinpath(@__DIR__, "../data/lena_bw.png"))
    plot_image(img; kws...) = plot(img; aspect_ratio=:equal, size=size(img),
        framestyle=:none, kws...)
    #p = plot_image(lena)

    # Add zero-mean gaussian noise with variance 0.01 and display the image
    noise_variance = 0.01
    gaussian_noise_lena = add_gauss(lena, noise_variance, clip=true)
    p = plot_image(gaussian_noise_lena)
end

main()