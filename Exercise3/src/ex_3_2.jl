# NOTE TO SELF: CHECK THE VARIANCE OF THE GAUSSIAN NOICE

using Images
using Plots
using Noise
using Random
using ImageFiltering
using Statistics

function main()
    # Load and plot the image
    lena = load(joinpath(@__DIR__, "../data/lena_bw.png"))
    plot_image(img; kws...) = plot(img; aspect_ratio=:equal, size=size(img),
        framestyle=:none, kws...)
    #p = plot_image(lena)

    # Add zero-mean gaussian noise with variance 0.01 and display the image
    # CHECK THE VARIANCE
    noise_variance = 0.01
    gaussian_noise_lena = add_gauss(lena, noise_variance, clip=true)
    p = plot_image(gaussian_noise_lena, title = "Gaussian noise")

    # Exercise part a: linear filtering with a Gaussian kernel
    # i. σ = 0.5
    sigma_i = 0.5
    img_gaussian_i = imfilter(gaussian_noise_lena, Kernel.gaussian(sigma_i))
    p_gaussian_i = plot_image(img_gaussian_i; title = "Gaussian, σ = $sigma_i")
    # ii. σ = 1
    sigma_ii = 1
    img_gaussian_ii = imfilter(gaussian_noise_lena, Kernel.gaussian(sigma_ii))
    p_gaussian_ii = plot_image(img_gaussian_ii; title = "Gaussian, σ = $sigma_ii")
    # iii. σ = 2
    sigma_iii = 2
    img_gaussian_iii = imfilter(gaussian_noise_lena, Kernel.gaussian(sigma_iii))
    p_gaussian_iii = plot_image(img_gaussian_iii; title = "Gaussian, σ = $sigma_iii")

    # Exercise part b: Median filtering
    # i. filter size 3 x 3
    window_i = (3, 3)
    img_median_i = mapwindow(median, gaussian_noise_lena, window_i)
    p_median_i = plot_image(img_median_i; title = "Median, $(join(window_i, " × ")) window")
    # ii. filter size 5 x 5
    window_ii = (5, 5)
    img_median_ii = mapwindow(median, gaussian_noise_lena, window_ii)
    p_median_ii = plot_image(img_median_ii; title = "Median, $(join(window_ii, " × ")) window")
    # iii. filter size 9 x 9
    window_iii = (9, 9)
    img_median_iii = mapwindow(median, gaussian_noise_lena, window_iii)
    p_median_iii = plot_image(img_median_iii; title = "Median, $(join(window_iii, " × ")) window")

    p = plot(p, p_gaussian_i, p_gaussian_ii, p_gaussian_iii, p_median_i, 
        p_median_ii, p_median_iii; size=(700, 1050), layout=@layout [x x; x x; x x; x ])
end



main()