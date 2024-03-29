close all; clear; clc;

load("..\data\localization.mat")

% Estimate 3D locations and compare them with the true locations
red3d = double(red_3d);
point_red = estimate_location(red_projected, projection_matrix, z_coordinate);
distance_red = calc_distance_3d(red3d, point_red)

green3d = double(green_3d);
point_green = estimate_location(green_projected, projection_matrix, z_coordinate);
distance_green = calc_distance_3d(green3d, point_green)

blue3d = double(blue_3d);
point_blue = estimate_location(blue_projected, projection_matrix, z_coordinate);
distance_blue = calc_distance_3d(blue3d, point_blue)

black3d = double(black_3d);
point_black = estimate_location(black_projected, projection_matrix, z_coordinate);
distance_black = calc_distance_3d(black3d, point_black)

% Project estimated locations using projection matrix
red = projection_matrix * [point_red; 1];
green = projection_matrix * [point_green; 1];
blue = projection_matrix * [point_blue; 1];
black = projection_matrix * [point_black; 1];

% Dehomogenize the points
red = [red(1)/red(3); red(2)/red(3)]
green = [green(1)/green(3); green(2)/green(3)]
blue = [blue(1)/blue(3); blue(2)/blue(3)]
black = [black(1)/black(3); black(2)/black(3)]


% Compare with the given 2D points
fprintf("Distances between projected points and given 2D points");
dist_red = calc_distance_2d(double(red_projected), red)
dist_green = calc_distance_2d(double(green_projected), green)
dist_blue = calc_distance_2d(double(blue_projected), blue)
dist_black = calc_distance_2d(double(black_projected), black)

function point_dehomogenized = estimate_location(projected_point, projection_matrix, z_coordinate)
    A = double([projection_matrix(:, 1) projection_matrix(:, 2) -[double(projected_point); 1] ...
        (double(z_coordinate) * projection_matrix(:, 3) + projection_matrix(:, 4))]);
    
    [~, ~, V] = svd(A);
    point = V(:, end);
    
    point_dehomogenized = double([point(1)/point(4); ...
        point(2)/point(4); z_coordinate])
end

% Calculate the distance between the estimated 3D location
% and the true location
function distance = calc_distance_3d(true, estimated)
    distance = sqrt((true(1) - estimated(1))^2 + ...
        (true(2) - estimated(2))^2 + (true(3) - estimated(3))^2);
end

function distance = calc_distance_2d(given, proj)
    distance = sqrt((given(1) - proj(1))^2 + (given(2) - proj(2))^2);
end
