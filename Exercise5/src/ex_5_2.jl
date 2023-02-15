# Line fitting with gradient method

using MAT

function main()
    data = matread(joinpath(@__DIR__, "../data/xy.mat"))

    # Gradient descent
    starting_point = (1, 1, 1)
    stepsize = 1*10^-8
    iterations = 1000

    # Code the iteration: 
    for i in 1:iterations
        # Calculate params+1 according to the formula in the exercise.
    end 
    # Use the last params from the iteration to define the function of the line.

    # Plot the data points and the line in the same plot.

end

main()
