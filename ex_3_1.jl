using Plots
using Images
using Statistics
 
function main()
    sampled_values = [2 2 2 2 6 6 6 6]
    m = 3
    kernel = [1/4, 1/2, 1/4]

    window = (m, 1)
    median_filtered = mapwindow(median, sampled_values, window)
    #median_filtered = 

    plotly()
    plot1 = bar(0:7, sampled_values, title="Original values")
    plot2 = bar(0:7, median_filtered, title="Median filtering")

    #plot3 = bar(0:7, linear_filtered, title="Linear filtering")
    p = Plots.plot(plot1, plot2)
    display(p)
    println("moi")

end

main()
