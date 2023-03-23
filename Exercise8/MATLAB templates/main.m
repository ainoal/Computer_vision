%% Input
addpath(genpath('./src'));

Il = imread('./data/books1.jpg');
Ir = imread('./data/books2.jpg');


pl = [249.1886  251.1865  185.7675  186.6054   96.5758   19.0369   87.8358  201.7579 72.6772;
      204.1058   50.1468   51.0201  126.5525   80.9284  148.0381  200.0909  205.3973 54.0182];
pr = [154.4705  257.6632  199.4353  166.7630   95.2722   10.0000   35.7504  121.1513 85.2440;
      223.2215   70.5352   48.8615  124.8812   47.2440   86.0000  157.2300  205.4297 12.9543];

task1(pl, pr, Il, Ir);

task2(pl, pr, Il, Ir);

task3(pl, pr, Il, Ir);





%% Functions
function task1(pl, pr, Il, Ir)
    % TODO: Implement functions find_fundamental_matrix, estimate_cameras and linear_triangulation
    F = find_fundamental_matrix(pl, pr);
    [Ml, Mr] = estimate_cameras(F);
    X = linear_triangulation(pl, Ml, pr, Mr);
    % TODO: Calculate reprojection error using Ml, Mr and X
end

function task2(pl, pr, Il, Ir)
    % TODO: implement missing parts in gold_standard from file gold_standard.jl

    [F, pl1, Ml, pr1, Mr, X] = gold_standard(pl, pr);
    
    % TODO: Plot both images and epipolar lines for each of the points from pl and pr
end

function task3(pl, pr, Il, Ir)
% TODO: Implement rectify_right, rectify_left 
    
    [F, pl, Ml, pr, Mr, X] = gold_standard(pl, pr);

    [~, er] = find_epipoles(F);

    Il(1, :) = 0; Il(:, 1) = 0; Il(end, :) = 0; Il(:, end) = 0;
    Ir(1, :) = 0; Ir(:, 1) = 0; Ir(end, :) = 0; Ir(:, end) = 0;
    
    Hr = rectify_right(er, 0.5*fliplr(size(Ir))');
    Hr = deshear(Ir, Hr) * Hr;
    Hl = rectify_left(M, pl, pr, Hr);
    Hl = deshear(Il, Hl) * Hl;
    
    [Fl, pl2] = interpolate_transform_image(Il, Hl);
    [Fr, pr2] = interpolate_transform_image(Ir, Hr);
    
    [Il1, Ir1, minLR] = warp_images(Fl, pl2, Fr, pr2);
% TODO: Plot rectified images side-by-side along with epipolar lines on them
% Do you notice the difference?
end
