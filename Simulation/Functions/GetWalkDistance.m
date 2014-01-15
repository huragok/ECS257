function [walkDistance, next] = GetWalkDistance(x, corner, wall)

numWall = size(wall, 1);
numPos = size(x, 1);

walkDistance = Inf(numPos, numPos); % The walking distance matrix between the ith and the jth position
next = zeros(numPos, numPos); % the via position from the ith position on the shortest path to the jth position
for indexPosSrc = 1:numPos
    walkDistance(indexPosSrc, indexPosSrc) = 0;
    for indexPosDest = indexPosSrc +1 :numPos
        flagCrossWall = false;
        for indexWall = 1: numWall
            if IsCross(corner(wall(indexWall, :)',:), [x(indexPosSrc, :); x(indexPosDest, :)])
                flagCrossWall = true;
                break;
            end
        end
        if ~flagCrossWall
            walkDistance(indexPosSrc, indexPosDest) = norm(x(indexPosSrc, :) - x(indexPosDest, :));
            walkDistance(indexPosDest, indexPosSrc) = norm(x(indexPosSrc, :) - x(indexPosDest, :));
        end
    end
end
 
for indexPosVia = 1 : numPos
    for indexPosSrc = 1 : numPos
        for indexPosDest = indexPosSrc + 1 : numPos
            walkDistanceVia = walkDistance(indexPosSrc, indexPosVia) + walkDistance(indexPosVia, indexPosDest);
            if walkDistanceVia < walkDistance(indexPosSrc, indexPosDest)
                
                walkDistance(indexPosSrc, indexPosDest) = walkDistanceVia;
                next(indexPosSrc, indexPosDest) = indexPosVia;
         
                walkDistance(indexPosDest, indexPosSrc) = walkDistanceVia;
                next(indexPosDest, indexPosSrc) = indexPosVia;
            end
        end
    end
end