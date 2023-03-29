include("utils.jl")
include("triangulation.jl")

using LinearAlgebra
using LsqFit


function minimize_geom_error(pl, pr, Ml, Mr0, X0)
    function error_function(x)
        Mr, X = from_param(x)
        # TODO Fill in your code for calculating reprojection error
        # The output is a vector of errors for each point
        X_homogeneous = vcat(X, [1 1 1 1 1 1 1 1])
        pl_hat = Ml * X_homogeneous
        pr_hat = Mr * X_homogeneous

        pl_hat = transpose([pl_hat[1, :] ./ pl_hat[3, :] pl_hat[2, :] ./ pl_hat[3, :]])
        pr_hat = transpose([pr_hat[1, :] ./ pr_hat[3, :] pr_hat[2, :] ./ pr_hat[3, :]])

        err = zeros(eltype(x),(1, 8))
        for i in 1:8
            err[1, i] = sqrt((pl[1, i] - pl_hat[1, i])^2 + (pl[2, i] - pl_hat[2, i])^2) + 
                sqrt((pr[1, i] - pr_hat[1, i])^2 + (pr[2, i] - pr_hat[2, i])^2)
        end
        
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

    # task 2d
    # TODO:
    #p_hat_L = Ml * X
    #X = vcat(X, [1 1 1 1 1 1 1 1])
    p_hat = Ml
    
    # task 2e
    Mr, X = minimize_geom_error(pl, pr, Ml, Mr, X)
    println("Mr: ")
    display(Mr)

    F = Mr[:, end] × Mr[:, 1:3]
    pl = Ml ⊗ X
    pr = Mr ⊗ X
    return F, pl, Ml, pr, Mr, X
end
