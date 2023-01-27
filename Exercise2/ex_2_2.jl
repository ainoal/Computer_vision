using Unitful.DefaultSymbols: mm, µm, m
using Unitful

function main() 
    (o_x, o_y) = (320µm, 240µm)     # Optical center of the camera
    (s_x, s_y) = (10µm, 10µm)       # Effective size of pixel
    f = 16mm                        # Focal length

    K = [-f/s_x 0 o_x;
        0 -f/s_y o_y;
        0 0 1]

    transf = K * (1; 0; 8)          # Transformation
    p = (transf(1)/transf(3), transf(2)/transf(3))  # Divide by z
    println("The pixel coordinates are p = (", p(1), "," p(2), ").")

    return nothing
end

main()
