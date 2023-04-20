load("data\localization.mat")

A_red = double([projection_matrix(:, 1) projection_matrix(:, 2) ...
    -[double(red_projected); 1] (double(z_coordinate) * projection_matrix(:, 3) + projection_matrix(:, 4))])

[~, ~, V_red] = svd(A_red)
point_red = V_red(:, end)

point_red_dehomogenized = double([point_red(1)/point_red(4); ...
    point_red(2)/point_red(4); z_coordinate])

% Calculate the distance between the estimated 3D location
% and the true location
red3d = double(red_3d)
distance = sqrt((red3d(1) - point_red_dehomogenized(1))^2 + ...
    (red3d(2) - point_red_dehomogenized(2))^2 + ...
    (red3d(3) - point_red_dehomogenized(3))^2)
