using Images
using Plots
using Noise
using Random
using ImageFiltering
using Statistics

function main()
    # Load and plot the image
    lena = load(joinpath(@__DIR__, "../data/lena_bw.png"))

    # Add zero-mean gaussian noise with variance 0.01
    # and compare different filters against each other
    gauss_noise_sigma = 0.1
    gaussian_noise_lena = add_gauss(lena, gauss_noise_sigma, clip=true)
    p1 = plot_image(gaussian_noise_lena, title = "Gaussian noise")
    linear_filtering(p1, gaussian_noise_lena)
    median_filtering(p1, gaussian_noise_lena)

    # Comparing filters for reducing Gaussian noice: 
    # Linear filtering with a Gaussian kernel: the filter with σ = 1
    # produces the most pleasing image to my eye, whereas σ = 0.5 leaves too
    # much noise, and on the other hand, σ = 2 blurs the image a lot.
    # If the desired output image is smooth and losing some sharpness doesn't
    # matter, σ = 2 is the best option.
    # Median filtering: 5 x 5 window produces the best result, but again,
    # it depends on the desired output.

    # Add salt-and-pepper noise with propability p = 0.05
    # and compare different filters against each other
    salt_pepper_noise_p = 0.05
    sp_noise_lena = salt_pepper(lena, salt_pepper_noise_p)
    p2 = plot_image(sp_noise_lena, title = "Salt and pepper noise")
    linear_filtering(p2, sp_noise_lena)
    median_filtering(p2, sp_noise_lena)

    # Comparing filters for reducing salt-and-pepper noice: 
    # For salt-and-pepper noice, Gaussian filtering does not work well.
    # Median filtering with a small window size 3 x 3 produces the best
    # result because it works well at getting rid of the noice, but it does
    # not blur the image more than necessary.

    # Add speckle noise with variance v = 0.02
    # and compare different filters against each other
    speckle_noise_v = 0.2
    speckle_lena = speckle_noise(lena, speckle_noise_v)
    p3 = plot_image(speckle_lena, title = "Speckle noise");

    linear_filtering(p3, speckle_lena)
    median_filtering(p3, speckle_lena)

    # In general, the smaller the Gaussian kernel or the median filter window size,
    # the less blurry the image becomes. The larger the kernel is, the more 
    # effective the filter is at removing noise. Thus, we should try to use the
    # smallest kernel possible that removes noise from the image in hand
    # sufficiently enough. Gaussian filtering works well for Gaussian noise or
    # speckle noise, but median filtering is way better for salt-and-pepper noise.
    # In Gaussian filtering, a bigger variance should also mean choosing a bigger
    # kernel size.

    # It is possible to computationally measure the visual quality. However, this
    # can be very tricky. The human perception of image quality can be very 
    # different from the computational quality when you compare the pixel values.
    # Sometimes the human eye does not for example notice differences in color that are
    # evident computationally.
    # Peak signal-to-noise ratio (PSNR) is one way to measure the quality of an image
    # in the presence of noise and corruption. 
end

# Exercise part a: linear filtering with a Gaussian kernel
function linear_filtering(p, img)
    # i. σ = 0.5
    sigma_i = 0.5
    img_gaussian_i = imfilter(img, Kernel.gaussian(sigma_i))
    p_gaussian_i = plot_image(img_gaussian_i; title = "Gaussian, σ = $sigma_i");

    # ii. σ = 1
    sigma_ii = 1
    img_gaussian_ii = imfilter(img, Kernel.gaussian(sigma_ii))
    p_gaussian_ii = plot_image(img_gaussian_ii; title = "Gaussian, σ = $sigma_ii");

    # iii. σ = 2
    sigma_iii = 2
    img_gaussian_iii = imfilter(img, Kernel.gaussian(sigma_iii))
    p_gaussian_iii = plot_image(img_gaussian_iii; title = "Gaussian, σ = $sigma_iii");

    plt = plot(p, p_gaussian_i, p_gaussian_ii, p_gaussian_iii; size=(700, 700), layout=@layout [x x; x x]);
    display(plt)
end

# Exercise part b: Median filtering
function median_filtering(p, img)
    # i. filter size 3 x 3
    window_i = (3, 3)
    img_median_i = mapwindow(median, img, window_i)
    p_median_i = plot_image(img_median_i; title = "Median, $(join(window_i, " × ")) window");

    # ii. filter size 5 x 5
    window_ii = (5, 5)
    img_median_ii = mapwindow(median, img, window_ii)
    p_median_ii = plot_image(img_median_ii; title = "Median, $(join(window_ii, " × ")) window");

    # iii. filter size 9 x 9
    window_iii = (9, 9)
    img_median_iii = mapwindow(median, img, window_iii)
    p_median_iii = plot_image(img_median_iii; title = "Median, $(join(window_iii, " × ")) window");

    plt = plot(p, p_median_i, p_median_ii, p_median_iii; size=(700, 700), layout=@layout [x x; x x]);
    display(plt)
end

plot_image(img; kws...) = 
    plot(img; aspect_ratio=:equal, size=size(img), framestyle=:none, kws...)

speckle_noise(img, sigma) = 
    img .+ 2 * sigma * sqrt(3) .* img .* (rand(eltype(img), size(img)) .- 0.5)

main()
