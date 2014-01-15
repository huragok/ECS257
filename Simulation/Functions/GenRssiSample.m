function rssiSample = GenRssiSample(xSample, x, corner, wall, epsilon, rssiDatabase)
% Function used to generate RSSI sample along the route
% Output:
% rssiSample: sampled RSSI at each location specified by xSample
% Input: 
% xSample: location of each sampled point
% x: the location of all measurement positions
% corner: corner of walls
% wall: wall
% epsilon: same epsilon as in the FindPosNeighbor function
% rssiDatabase: the measured rssiDatabase

numSample = size(xSample, 1);
rssiSample = zeros(numSample, 5);
for indexSample = 1: numSample
    [indexPosNeighbor, weight] = FindPosNeighbor(xSample(indexSample,:), 4, x, corner, wall, epsilon);
    rssiSample(indexSample, :) = GenRssi(indexPosNeighbor, weight, rssiDatabase);
end

end

