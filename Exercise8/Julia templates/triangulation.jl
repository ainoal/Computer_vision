include("utils.jl")


function find_fundamental_matrix(pl, pr)
    # TODO Fill in your code for finding fundamental matrix F
    return F
end

function find_epipoles(F)
    # TODO Fill in your code for finding epipoles el and er
   return el, er
end


function estimate_cameras(F, er)
    # TODO Fill in your code for estimating cameras Ml and Mr from F
    return Ml, Mr
end
estimate_cameras(F) = estimate_cameras(F, find_epipoles(F)[2])

function linear_triangulation(pl, Ml, pr, Mr)
    # TODO Fill in your code for linear triangulation
    return X
end



