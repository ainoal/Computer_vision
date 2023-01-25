
plot_frame!(frame) = plot_frame!(current_axis(), frame)
plot_frame!(ax, frame) = arrows!(ax, 
                        eachrow(frame[1:3, [4, 4, 4]])..., 
                        eachrow(frame[1:3, 1:3])..., 
                        color=[:red, :green, :blue], arrowsize=0.1)
