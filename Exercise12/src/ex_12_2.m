load("data\localization.mat")

red3d = double(red_3d);
point_red = estimate_location(red_projected, projection_matrix, z_coordinate);
distance_red = calc_distance(red3d, point_red)

green3d = double(green_3d);
point_green = estimate_location(green_projected, projection_matrix, z_coordinate);
distance_green = calc_distance(green3d, point_green)

blue3d = double(blue_3d);
point_blue = estimate_location(blue_projected, projection_matrix, z_coordinate);
distance_blue = calc_distance(blue3d, point_blue)

black3d = double(black_3d);
point_black = estimate_location(black_projected, projection_matrix, z_coordinate);
distance_black = calc_distance(black3d, point_black)

function point_dehomogenized = estimate_location(projected_point, projection_matrix, z_coordinate)
    A = double([projection_matrix(:, 1) projection_matrix(:, 2) -[double(projected_point); 1] ...
        (double(z_coordinate) * projection_matrix(:, 3) + projection_matrix(:, 4))]);
    
    [~, ~, V_red] = svd(A);
    point = V_red(:, end);
    
    point_dehomogenized = double([point(1)/point(4); ...
        point(2)/point(4); z_coordinate]);
end

% Calculate the distance between the estimated 3D location
% and the true location
function distance = calc_distance(true, estimated)
    distance = sqrt((true(1) - estimated(1))^2 + ...
        (true(2) - estimated(2))^2 + (true(3) - estimated(3))^2);
end

