function H = deshear(I, H)
    [h, w] = size(I);
    halfW = w*0.5;
    halfH = h*0.5;
    a = H*[halfW; 1; 1];
    a = a/a(end);
    b = H*[w; halfH; 1];
    b = b/b(end);
    c = H*[halfW; h; 1];
    c = c/c(end);
    d = H*[1; halfH; 1];
    d = d/d(end);
    x = b - d;
    y = c - a;
    k1 = (h^2*x(2)^2 + w^2 * y(2)^2)/(h*w*(x(2)*y(1)-x(1)*y(2)));
    k2 = (h^2*x(1)*x(2) + w^2 * y(1) * y(2))/(h*w*(x(1)*y(2)-x(2)*y(1)));
    H = eye(3);
    H(1, 1:2) = [-k1 -k2];
end