function h = PlotFloorPlan(wall, corner, x, flagLabel)
% Plot the floor plan and all measurement points. If flagLabel = 0 or not
% specified then the measurement points will not be labeled; If flagLabel
% ~= 0 then all the measurement points will be labeled with their indices

numWall = size(wall, 1);
numPos = size(x, 1);

h = plot(75 - x(:,2), x(:,1), 'k+', 'linewidth', 1); hold on;

if nargin == 4
    if flagLabel ~= 0 ;
        for indexPos = 1:numPos
            text(75 - x(indexPos,2) + 0.5, x(indexPos,1) + 0.5, num2str(indexPos));
        end
    end
end

for indexWall = 1:numWall
    plot(75 - corner(wall(indexWall, :), 2), ...
         corner(wall(indexWall, :), 1), ...
         'k-', 'linewidth', 2);
end
grid on, axis equal;