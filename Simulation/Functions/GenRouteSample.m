function [xSample, speedSample, tSample] = GenRouteSample(route, speedProfile, Ts, walkDistance, x)
% Generate the user's location, speed at n sampling time
% Output:
% xSample: n*2 matrix, location
% speedSample: n*1 vector, instant speed
% tSample: sample time
% Input:
% route: the index of the nodes (measurement position) on the user's route.
%        The neighboring nodes must not be blocked by any wall
% speedProfile: [v, T], where v is the users speed (m/s) and T is the time 
%               (s) in which the user walks in speed v. This speedProfile 
%               is checked against the total route length: using this speed 
%               profile the user must be able to cover the total route
%               length.
% Ts: sampling period
% walkDistance: the walking distance between neighboring measurement 
%               positions
% x: the location of each measurement position

numEdge = length(route) - 1; % The number of edges on this route
lenEdge = zeros(numEdge, 1); % The length of each edge on this route
for indexPos = 1:numEdge
    lenEdge(indexPos) = walkDistance(route(indexPos), route(indexPos+1));
end
lenRoute = sum(lenEdge);
% Specify how this guy walks on this route. The first column is the speed
% (m/s) and the second column is the time (s) this guy walks in this speed.

% Check whether this speed profile is valid: the total distance covered
% must be larger than the actual walk distance
if (speedProfile(:, 1)' * speedProfile(:, 2) < lenRoute)
    error('Invalid speed profile!');
end

% Compute the actual walking time
distanceProfile = cumsum(speedProfile(:, 1) .* speedProfile(:, 2));
indexEdge = find(distanceProfile >= lenRoute, 1, 'first');
if indexEdge == 1
    timeRoute = lenRoute / speedProfile(1, 1);
else
    timeRoute = (lenRoute - distanceProfile(indexEdge - 1)) / speedProfile(indexEdge, 1) + sum(speedProfile(1 : indexEdge - 1, 2));
end
% Find the position along this route at each sampling time
tSample = 0 : Ts: timeRoute; % The time of each sampling
numSample = length(tSample);  % Number of samples along this route

% Find the speed, coordinate at each sampling point.
timeSpeedChange = cumsum(speedProfile(:, 2)); % The time when the speed changes
cumLenEdge = cumsum(lenEdge); % The distance covered at each position along the route

speedSample = zeros(numSample, 1);
xSample = zeros(numSample, 2);

for indexSample = 1:numSample
    indexSpeed = find(timeSpeedChange > tSample(indexSample),  1, 'first');
    speedSample(indexSample) = speedProfile(indexSpeed, 1); % The speed at the sampling point
    if indexSpeed == 1
        lenRouteSample = tSample(indexSample) * speedSample(indexSample); % The distance from the starting position to the sample position
    else
        lenRouteSample = distanceProfile(indexSpeed - 1) + (tSample(indexSample) - timeSpeedChange(indexSpeed - 1)) * speedSample(indexSample); % The walk distance up to the sampling point
    end
   
    indexPosRouteLast = find(cumLenEdge > lenRouteSample, 1, 'first');
    indexPosLast = route(indexPosRouteLast); % The last measurement position from the sample position
    indexPosNext = route(indexPosRouteLast + 1); % The next measurement position from the sample position
    p = (cumLenEdge(indexPosRouteLast) - lenRouteSample) / lenEdge(indexPosRouteLast); % Weight coefficient with respect to the last measurement position
    xSample(indexSample, :) = p * x(indexPosLast, :) +  (1 - p) * x(indexPosNext, :); % The location of the sampling position
end

