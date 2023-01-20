W = eye(4);
C = [-0.866 -0.500 0.000 2.0; -0.500 0.866 0.000 -1.0; 0.000 0.000 -1.000 3.0; 0 0 0 1];

hold on
p = plot_frame(W);
cam = plot_frame(C);
hold off

% The function plots the X-, Y- and Z- axes of an input coordinate frame T
function frame = plot_frame(T)
    o = [0; 0; 0; 1]; % origin of the world coordinate frame

    % The length between origin and a point on an axis is one unit
    u = [1; 0; 0; 1]; % point on x axis
    v = [0; 1; 0; 1]; % point on y axis
    w = [0; 0; 1; 1]; % point on z axis

    % Multiplying the points with the transformation matrix
    o = T * o;
    u = T * u;
    v = T * v;
    w = T * w;

    % Plotting the axes
    plot3([o(1), u(1)], [o(2), u(2)], [o(3), u(3)], 'Color', 'r')
    plot3([o(1), v(1)], [o(2), v(2)], [o(3), v(3)], 'Color', 'g')
    plot3([o(1), w(1)], [o(2), w(2)], [o(3), w(3)], 'Color', 'b')
    
    frame = 0;
end
