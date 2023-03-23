function [Il1, Ir1, minLR] = warp_images(Fl, pl2, Fr, pr2)
    minL = min(pl2(1:2, :), [], 2); maxL = max(pl2(1:2, :), [], 2);
    minR = min(pr2(1:2, :), [], 2); maxR = max(pr2(1:2, :), [], 2);

    minLR = min(minL, minR);
    maxLR = max(maxL, maxR);

    [X, Y] = meshgrid(minLR(1):maxLR(1), minLR(2):maxLR(2));
    Il1 = Fl(X(:), Y(:));
    newSz = fliplr(ceil(maxLR - minLR)');
    Il1 = reshape(Il1, newSz);
    Ir1 = Fr(X(:), Y(:));
    Ir1 = reshape(Ir1, newSz);
end