function [indexPosNeighbor, weight] = FindPosNeighbor(location, numNeighbor, x, corner, wall, epsilon)
% Find n closest neighboring measurement positions not blocked by wall.
% Output: 
% indexPosNeighbor: the index of the returned neighboring measurement
%                   posittion
% weight: indicate how close the location is to each neighboring position.
%         Inverse proportional to their distance. The sum of all weight is
%         1.
% Input:
% location: 2-D coordinate
% numNeighbor: desired number of returned neighboring measurement position.
%              If there are not so many of them, 
% x: the coordinate of each measurement position
% corner: the corner of each wall
% wall: just walls
% epsilon: when the location is within this distance to one measurement
%          position, this location is "dominated" by this measurement
%          position

numPos = size(x, 1);
numWall = size(wall, 1);
distance = Inf(numPos, 1);
numLOS = 0;
for indexPos = 1 : numPos
    flagCrossWall = false;
    for indexWall = 1 : numWall
        if IsCross([location; x(indexPos, :)], corner(wall(indexWall, :)', :))
            flagCrossWall = true;
            break;
        end
    end
    if ~flagCrossWall
        distance(indexPos) = norm(location - x(indexPos, :));
        numLOS = numLOS + 1;
    end
end

[distanceSorted, indexPosSorted] = sort(distance);
numNeighborActual = min([numNeighbor, numLOS]);
if (numNeighborActual == 0) % No neighboring measurement position is found
    error('No neighboring measurement position found!');
elseif (distanceSorted(1) < epsilon) % the location is exactly a measurement position
    indexPosNeighbor = indexPosSorted(1);
    weight = 1;
    return;
else
    indexPosNeighbor = indexPosSorted(1:numNeighborActual);
    weight = (1 ./ distanceSorted(1:numNeighborActual)) / sum(1 ./ distanceSorted(1:numNeighborActual));
end

    