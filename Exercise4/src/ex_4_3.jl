using RegionProperties
using Images

function main()
    # Load image
    img = load(joinpath(@__DIR__, "../data/lego1.jpg"))
    x = get_available_properties()
    println(x)

    # Treshold the pieces from the background
    lego = locate_piece(img)
    p = plot(lego)

    # Localize each piece from background
    props = regionprops(lego, :bounding_box, :centroid, :area, :indices, :subscripts, 
        :circularity, :equiv_diameter, :convex_hull, :convex_image, :convex_area, :solidity, 
        :minor_axis_length, :major_axis_length, :orientation, :eccentricity, :image, :extent, 
        :extrema, :perimeter, :perimeter_points)

    _, tl = findmax(props.major_axis_length)
    topleft = (props[tl].centroid[2], props[tl].centroid[1])

    # TODO: find a property with which you can locate the top right block
    _, tr = findmax(props.solidity)
    topright = (props[tr].centroid[2], props[tr].centroid[1])

    _, bl = findmax(props.minor_axis_length)
    bottomleft = (props[bl].centroid[2], props[bl].centroid[1])

    _, br = findmax(props.circularity)
    bottomright = (props[br].centroid[2], props[br].centroid[1])

    println(props[tl].bounding_box)
    println(props[bl].bounding_box)
    println(props[br].bounding_box)
    println(props[4].bounding_box)

    # Code for checking the package, which does not seem to be working as it should
    #a_centroid = (props[1].centroid[2], props[1].centroid[1])
    #b_centroid = (props[2].centroid[2], props[2].centroid[1])
    #c_centroid = (props[3].centroid[2], props[3].centroid[1])
    #d_centroid = (props[4].centroid[2], props[4].centroid[1])
    #a_centroid = props[1].centroid
    #b_centroid = props[2].centroid
    #c_centroid = props[3].centroid
    #d_centroid = props[4].centroid

    p2 = plot!(topleft,  markershape=:circle)
    #p3 = plot!(topright,  markershape=:x)
    p4 = plot!(bottomleft,  markershape=:diamond)
    p5 = plot!(bottomright,  markershape=:rect)
    display(p5)
end

# Locate pieces using color information
function locate_piece(img)
    img_channels = channelview(img)
    filter = img_channels[1, :, :] .< 0.5 .&&
        img_channels[2, :, :] .< 0.5 .&&
        img_channels[3, :, :] .> 0.05
    filter_img = Gray.(filter)
    return filter_img
end

#plot_image(img; kws...) = 
#    plot(img; aspect_ratio=:equal, size=size(img), framestyle=:none, kws...)

main()
