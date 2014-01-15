clear all;
close all;
clc;

addpath('../Data','../Functions');

%% 0. Load necessary files
load('../Data/Data.mat');

%% 1. Plot the floorplan
PlotFloorPlan(data.wall, data.corner, data.x, 1);

%% 2. specify a route and randomly generate a speed profile
routeRaw = [62, 73, 64, 126, 117, 144, 158, 3, 21, 36, 34, 65, 66, 20, 9, 27];
speedRange = [0.5, 3];
numSpeed = 6;
route = ModifyRoute(routeRaw, data.next, data.walkDistance);
speedProfile = GenSpeedProfile(route, speedRange, numSpeed, data.walkDistance);

%% 2. Sample this route
Ts = 2;
[xSample, speedSample, tSample] = GenRouteSample(route, speedProfile, Ts, data.walkDistance, data.x);
rssiSample = GenRssiSample(xSample, data.x, data.corner, data.wall, 0.05, data.rssiDatabase);
%plot(75 - xSample(:, 2), xSample(:, 1), 'ro-', 'linewidth', 2);

%% 3. Run the Viterbi-like algorithm
p = 0.2; % Perturbation parameter used in the calculation of transition probability
k = 50; % choose k nearest neighbors as possible position

numSample = size(rssiSample, 1); % number of samples
indexPosCurrent = zeros(1, numSample); % best estimation of the current position at each sampling time

costViterbi = zeros(k, 1); % The cost function of the route with least cost whose current position is the ith measurement position, i = 1, 2, ..., k 
routeViterbi = zeros(k, 1); % The corresponding route up to current position i, i = 1, 2, ..., k

% Initialization: in the first step the cost comes only from the
% observation, assuming equally likely initial state
indexPoskNear = GetkNear(rssiSample(1, :), data.meanRssi, k); % Coarsely find the k possible positions according to the first observation
routeViterbi(:, 1) = indexPoskNear;
for indexk = 1 : k
    costViterbi(indexk) = GetDeltaLLR(rssiSample(1, :), data.meanRssi(indexPoskNear(indexk), :), data.covRssi(:, :, indexPoskNear(indexk)));
end

[~, indexkCostMin] = min(costViterbi);
indexPosCurrent(1) = routeViterbi(indexkCostMin, 1);

% "Let the hunt begin."
for indexSample = 2 : numSample
    plot(75 - [xSample(indexSample - 1, 2); xSample(indexSample, 2)], [xSample(indexSample - 1, 1); xSample(indexSample, 1)], 'ro--', 'linewidth', 2);
    
    [indexPosCurrent(indexSample), costViterbi, routeViterbi] = GetPosCurrent(rssiSample(indexSample, :), speedSample(indexSample - 1), data.meanRssi, data.covRssi, data.walkDistance, Ts, p, k, costViterbi, routeViterbi); % Updatee position estimation and Viterbi cost and routes
    plot(75 - [data.x(indexPosCurrent(indexSample - 1), 2); data.x(indexPosCurrent(indexSample), 2)], [data.x(indexPosCurrent(indexSample - 1), 1); data.x(indexPosCurrent(indexSample), 1)], 'bs--', 'linewidth', 2); % Plot the estimated current posiition
end

set(gca,'Fontsize', 14);
