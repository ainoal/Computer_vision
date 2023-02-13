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
    props = regionprops(lego, :centroid, :indices, :circularity,
    :minor_axis_length, :major_axis_length, :orientation)

    _, tl = findmax(props.major_axis_length)
    topleft = (reverse(props[tl].centroid))
    p2 = plot!(topleft,  markershape=:circle)

    for i in 1:length(props)
        if ((props[i].orientation < 1) && (props[i].orientation > 0.87))
            tr = i
            topright = (reverse(props[tr].centroid))
            p3 = plot!(topright,  markershape=:x)
        end
    end

    _, bl = findmax(props.minor_axis_length)
    bottomleft = (reverse(props[bl].centroid))
    p4 = plot!(bottomleft,  markershape=:diamond)

    _, br = findmax(props.circularity)
    bottomright = (reverse(props[br].centroid))

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

main()
