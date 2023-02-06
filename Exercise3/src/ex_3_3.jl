using Images
using Plots
using ImageFiltering

# Show by counterexample that median filtering is not separable.
function main()
    lena = load(joinpath(@__DIR__, "../data/lena_bw.png"))
    salt_pepper_noise_p = 0.5
    sp_lena = salt_pepper(lena, salt_pepper_noise_p)
    p = plot_image(sp_lena, title = "Image to be filtered")

    # Plot the result of 5 x 5 median filtering.
    window = (5, 5)
    img_5x5 = mapwindow(median, sp_lena, window)
    p_5x5 = plot_image(img_5x5; title = "Median, $(join(window, " × ")) window")

    # Plot the result of 5 x 1 median filtering followed by 1 x 5 median filtering.
    window2 = (5, 1)
    window3 = (1, 5)
    img_sep = mapwindow(median, sp_lena, window2)
    img_sep_final = mapwindow(median, img_sep, window3)
    p_sep =  plot_image(img_sep_final; 
        title = "Median, $(join(window2, " × ")) -> $(join(window3, " × ")) windows")

    # Show the difference of the image filtered by 5 x 5 filter and the one
    # first filtered with 5 x 1 filter and then 1 x 5 filter.
    difference = @. img_5x5 - img_sep_final
    p_diff = plot_image(difference, title="Difference")

    plt = plot(p, p_5x5, p_sep, p_diff; size = (700, 700), layout=@layout [x x; x x])
    display(plt)

    # When we compare the two filtered images, we can see they are not exactly the same. 
    # This is confirmed by the difference image that marks differences between the two images.
end

plot_image(img; kws...) = 
    plot(img; aspect_ratio=:equal, size=size(img), framestyle=:none, kws...)

main()
