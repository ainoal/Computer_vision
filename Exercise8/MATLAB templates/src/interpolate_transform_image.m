function [F, p2] = interpolate_transform_image(I, H)
    [xl, yl] = meshgrid(1:size(I, 2), 1:size(I, 1));
    p1 = [xl(:)'; yl(:)'];
    p1(3, :) = 1;
    p2 = H * p1;
    p2 = p2 ./ p2(3, :);
    I = im2double(I);
    cL = I(:);
    F = scatteredInterpolant(p2(1,:)',p2(2, :)',cL);
end