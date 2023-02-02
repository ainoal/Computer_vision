# The program calculates the pixel coordinates of the projection of a point
# given in the exercise and prints them on the console.

using Unitful.DefaultSymbols: mm, µm, m
using Unitful

function main() 
    o_x =  320          # Optical center of the camera
    o_y = 240
    s_x = 10µm          # Effective size of pixel
    s_y = 10µm
    f = 16mm            # Focal length

    K = [-f/s_x 0 o_x;
        0 -f/s_y o_y;
        0 0 1]

    transf = K * [1; 0; 8]          # Transformation
    p = (round(transf[1]/transf[3]), round(transf[2]/transf[3]))  # Divide by z
    println("The pixel coordinates are p = (", Int(p[1]), ", ", Int(p[2]), ").")

    return nothing
end

main()
