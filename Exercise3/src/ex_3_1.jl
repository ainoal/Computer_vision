# Written before I realized there are ready functions for filtering
# with Julia.

using Statistics
using Plots

function main()
    sampled_values = [2,2,2,2,6,6,6,6]
    m = 3
    kernel = [1/4, 1/2, 1/4]

    median_filtered = median_filtering(sampled_values, m)
    linear_filtered = linear_filtering(sampled_values, kernel)
    plotly()
    plot1 = bar(0:7, sampled_values, title="Original values")
    plot2 = bar(0:7, median_filtered, title="Median filtering")
    plot3 = bar(0:7, linear_filtered, title="Linear filtering")
    p = Plots.plot(plot1, plot2, plot3)

end

function median_filtering(values, m)
    len = length(values)
    median_filtered = zeros(len, 1)
    for i in 1:len
        neighbors = neighborhood(m, i, values)
        median_filtered[i] = median(neighbors)
    end
    return median_filtered
end

function linear_filtering(values, kernel)
    m = length(kernel)
    len = length(values)
    linear_filtered = zeros(len, 1)
    for i in 1:len
        sum_of_neighborhood_values = 0
        neighbors = neighborhood(m, i, values)
        for j in 1:length(neighbors)
            sum_of_neighborhood_values = sum_of_neighborhood_values + neighbors[j] * kernel[j]
        end
        linear_filtered[i] = sum_of_neighborhood_values
    end
    return linear_filtered
end

# The function returns the neighborhood of a value in an array
function neighborhood(m, i, values)
    len = length(values)
    half_neighborhood = Int(floor(m/2))

    # If we are handling the beginning of the array, to be able to use the 
    # filter, we use padding at the beginning of the array. The padding
    #  gets the same value as the first entry in the values (in this exercise 2).
    if (i <= half_neighborhood)
        neighborhood = Vector{Int64}()
        diff = half_neighborhood - i + 1
        # The for loop handles the padding
        for j in 1:diff
            push!(neighborhood, values[1])
        end
        # For the rest of the filter, we use the actual values in the array.
        for k in 1:(m - diff)
            push!(neighborhood, values[k])
        end
        
    # Handle the end of the array in a similar manner as the beginning of it.
    elseif (len - i < half_neighborhood)
        neighborhood = []
        diff = half_neighborhood - (len - i) + 1
        for j in 1:(m - diff)
            push!(neighborhood, values[len-j])
        end
        for k in 1:diff
            push!(neighborhood, values[len])
        end

    # Middle of the array
    else
        neighborhood = values[(i - half_neighborhood):(i + half_neighborhood)]
    end
    return neighborhood
end

main()
