include("utils.jl")

using LinearAlgebra
using LsqFit


function minimize_geom_error(pl, pr, Ml, Mr0, X0)
    function error_function(x)
        Mr, X = from_param(x)
        # TODO Fill in your code for calculating reprojection error
        # The output is a vector of errors for each point
        return err |> vec
    end
    to_param(Mr, X) = vcat(vec(Mr), vec(X))
    from_param(x) = reshape(x[1:length(Mr0)], size(Mr0)), reshape(x[length(Mr0)+1:end], size(X0))
    opt = LsqFit.lmfit(error_function, to_param(Mr0, X0), Float64[]; autodiff=:forward)
    
    Mr, X = from_param(opt.param)
    return Mr, X
end

function gold_standard(pl, pr)
    F = find_fundamental_matrix(pl, pr)
    Ml, Mr = estimate_cameras(F)
    X = linear_triangulation(pl, Ml, pr, Mr)
    
    Mr, X = minimize_geom_error(pl, pr, Ml, Mr, X)

    F = Mr[:, end] × Mr[:, 1:3]
    pl = Ml ⊗ X
    pr = Mr ⊗ X
    return F, pl, Ml, pr, Mr, X
end