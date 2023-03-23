function [F, pl1, Ml, pr1, Mr, X] = gold_standard(pl, pr)
    F = find_fundamental_matrix(pl, pr);
    [er, ~] = FindEpipoles(F);
    Ml = [ eye(3) [0; 0; 0]];
    F = F / F(end);
    Mr = [GetCrossMatrix([er; 1])*F [er;1]];
    X = linear_triangulation(pl, pr, Ml, Mr);
    options = optimoptions(@lsqnonlin,...
        'Algorithm','levenberg-marquardt',...
        'StepTolerance', 1e-12, 'ScaleProblem', 'jacobian');
    [params, ~] = lsqnonlin(@(x) DistFunc(x, pl, pr, Ml), [Mr(:); X(:)], ...
        [],[],options);
    disp(sum(DistFunc(params, pl, pr).^2));
    X = reshape(params(13:end), [3 size(pl, 2)]);
    X(4, :) = 1;
    Mr = reshape(params(1:12), [3 4]);
    Mr = Mr/Mr(end);
    M = Mr(1:3, 1:3);
    t = Mr(:, 4);
    F = GetCrossMatrix(t) * M;
    pl1 = Ml * X;
    pl1 = pl1 ./ pl1(3, :);
    pr1 = Mr * X;
    pr1 = pr1 ./ pr1(3, :);
end

function d = DistFunc(params, pl, pr, Ml)
% TODO Fill in your code for calculating reprojection error
% The output is a vector of errors for each point
    
end