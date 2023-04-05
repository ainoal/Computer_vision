% Color segmentation

clear all; close all; clc;

% Read the input images
% Reading the files works only when you are inside Exercise3 folder.
blocks = imread("data\blocks-col.png");

% Locate the red part in RGB and HSV color spaces
[rgb_img, hsv_img] = locate_red(blocks);
%image(circles)
figure(1);
imshow(rgb_img);
figure(2);
imshow(hsv_img);

function [rgb_img, hsv_img] = locate_red(img)
    % Locate red in RGB color space
    % Specify minimum and maximum values for color channels
    % Note: both RGB and HSV values are used differently for Julia and MATLAB
    rmin = 255 * 0.57;  % Range 0-255, with Julia range 0-1
    rmax = 255;
    gmin = 0;
    gmax = 255 * 0.48;
    bmin = 0;
    bmax = 255 * 0.51;

    filter = (img(:, :, 1) >= rmin) & (img(:, :, 1) <= rmax) & ...
      (img(:, :, 2) >= gmin) & (img(:, :, 2) <= gmax) & ...
      (img(:, :, 3) >= bmin) & (img(:, :, 3) <= bmax);

    
    rgb_img = filter;

    % Locate red in HSV color space
    imghsv = rgb2hsv(img);
    hmax = 17 / 360;    % H range 0-1, with Julia 0-360s
    hmin = 340 / 360;
    smin = 0.29;
    vmin = 0.58;
    vmax = 0.8;

    filter_hsv = (imghsv(:, :, 1) >= hmin) | (imghsv(:, :, 1) <= hmax) & ...
      (imghsv(:, :, 2) >= smin) & ...
      (imghsv(:, :, 3) >= vmin) & (imghsv(:, :, 3) <= vmax);

    
    hsv_img = filter_hsv;
end
