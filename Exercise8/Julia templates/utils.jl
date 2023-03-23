
using LinearAlgebra
using Interpolations


# A function to create cross product matrix
# can be written with \times + Tab = ×
×(x) = [0       -x[3]    x[2]
        x[3]     0      -x[1]
       -x[2]     x[1]    0]
# 
×(x, y) = ×(x) * y


to_homogeneous(p) = vcat(p, ones(1, size(p, 2)))
from_homogeneous(p) = p[1:end-1, :] ./ p[end:end, :]

# A convenient function that applies projective mapping M
# to a matrix of points of size d x n.
# Can be written with \otimes + Tab = ⊗
⊗(M, p) = from_homogeneous(M * to_homogeneous(p))


# Functions for deshearing rectification transforms
deshear_tform(H, I) = deshear_tform(H, reverse(size(I))...)
function deshear_tform(H, w, h)
    halfW = w/2
    halfH = h/2
    a = H ⊗ [halfW, 1]
    b = H ⊗ [w, halfH]
    c = H ⊗ [halfW, h]
    d = H ⊗ [1, halfH]
    x = b - d
    y = c - a
    k1 = (h^2*x[2]^2 + w^2 * y[2]^2)/(h*w*(x[2]*y[1]-x[1]*y[2]))
    k2 = (h^2*x[1]*x[2] + w^2 * y[1] * y[2])/(h*w*(x[1]*y[2]-x[2]*y[1]))
    H = I[1:3, 1:3] .|> Float64
    H[1, 1:2] .= [-k1, -k2]
    return H
end
deshear(H, w, h) = deshear_tform(H, w, h) * H
deshear(H, I) = deshear_tform(H, I) * H

# Functions for applying rectification to an image
function find_transformation_limits(I, H)
    inds = CartesianIndices(I) .|> x -> [x[2], x[1]]
    new_inds = reduce(hcat, Ref(H) .⊗ inds)

    xlims, ylims = extrema(new_inds, dims=2)
    return round.(Int64, xlims), round.(Int64, ylims)
end

function create_warped_image(I, H, xrange, yrange)
    int = extrapolate(interpolate(I, BSpline(Linear()), OnGrid()), zero(eltype(Il)))
    
    to_length(range) = range[2] - range[1] + 1
    rI = zeros(eltype(I), to_length(yrange), to_length(xrange))
    for ind ∈ CartesianIndices(rI)
        p = inv(H) ⊗ [ind[2] + xrange[1], ind[1] + yrange[1]]
        rI[ind] = int[p[2], p[1]]
    end
    return rI
end

function warp_images(Il, Hl, Ir, Hr)
    
    xlimsl, ylimsl = find_transformation_limits(Il, Hl)
    xlimsr, ylimsr = find_transformation_limits(Ir, Hr)

    yrange = (min(ylimsl[1], ylimsr[1]), max(ylimsl[2], ylimsr[2]))
    rIl = create_warped_image(Il, Hl, xlimsl, yrange)
    rIr = create_warped_image(Ir, Hr, xlimsr, yrange)
    
    return rIl, rIr, yrange
end

warp_image(I, H) = create_warped_image(I, H, find_transformation_limits(I, H)...)