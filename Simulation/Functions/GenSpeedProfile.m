function speedProfile = GenSpeedProfile(route, speedRange, numSpeed, walkDistance)
% Randomly generate a speed profile for the input route
% Output:
% speedProfile: generated speedProfile
% Input:
% route: the input route
% speedRange: [minSpeed, maxSpeed]
% numSpeed: number of different speed along this route

speedProfile = zeros(numSpeed, 2);

%% compute the length of the route
numEdge = length(route) - 1; % The number of edges on this route
lenEdge = zeros(numEdge, 1); % The length of each edge on this route
for indexPos = 1:numEdge
    lenEdge(indexPos) = walkDistance(route(indexPos), route(indexPos+1));
end
lenRoute = sum(lenEdge);

%% randomly divide the entire route into numSpeed segments
distSpeedChange = lenRoute * sort(rand(numSpeed - 1, 1));

lenSegment = zeros(numSpeed, 1);
if numSpeed == 1;
    lenSegment = lenRoute + 0.1;
else
    lenSegment(1) = distSpeedChange(1);
    lenSegment(numSpeed) = lenRoute - distSpeedChange(numSpeed - 1) + 0.1;
    for indexSpeedChange = 1 : numSpeed - 2
        lenSegment(indexSpeedChange + 1) = distSpeedChange(indexSpeedChange + 1) - distSpeedChange(indexSpeedChange);
    end
end

%% randomly generate a speed for each segments
speedMin = speedRange(1);
speedMax = speedRange(2);
speedProfile(:, 1) = speedMin + (speedMax - speedMin) * rand(numSpeed, 1);

%% compute the time spent on each segment
speedProfile(:, 2) = lenSegment ./ speedProfile(:, 1);

end

